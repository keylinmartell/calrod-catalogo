import { supabase } from '@/services/supabase'
import type {
  CompatInput,
  Part,
  PartImageDraft,
  PartInput,
  SpecInput,
} from '@/types/part'

const BUCKET = 'part-images'

/**
 * Extrae el path dentro del bucket a partir de una URL pública de Supabase
 * Storage. Ignora el cache-buster (`?v=…`). Devuelve null si la URL no apunta a
 * nuestro bucket (p. ej. una imagen externa pegada a mano).
 *   …/object/public/part-images/<code>/photo?v=123  →  "<code>/photo"
 */
function storagePathFromUrl(url?: string | null): string | null {
  if (!url) return null
  const marker = `/${BUCKET}/`
  const i = url.indexOf(marker)
  if (i === -1) return null
  const rest = url.slice(i + marker.length)
  return decodeURIComponent(rest.split('?')[0]) || null
}

/**
 * Carpeta de una pieza dentro del bucket, deducida de una de sus URLs públicas.
 * Todas las fotos de una pieza viven en la misma carpeta (`<carpeta>/<archivo>`),
 * así que con una URL cualquiera se sabe dónde están las demás.
 *   …/part-images/BR-4471-C/9f3a…  →  "BR-4471-C"
 */
function folderOfUrl(url?: string | null): string | null {
  const path = storagePathFromUrl(url)
  if (!path) return null
  const i = path.lastIndexOf('/')
  return i > 0 ? path.slice(0, i) : null
}

/** Vacía una carpeta del bucket. No-op si no hay carpeta o si ya está vacía. */
async function removeFolder(folder: string | null): Promise<void> {
  if (!folder) return
  const { data: items } = await supabase.storage.from(BUCKET).list(folder)
  if (!items || !items.length) return
  await supabase.storage.from(BUCKET).remove(items.map((f) => `${folder}/${f.name}`))
}

/**
 * Normaliza el valor de un <input type="number"> de año a `number | null`.
 * Vue con `v-model.number` deja "" cuando el campo se vacía (no null), y
 * `Number("")` es 0 — así que hay que descartar "" explícitamente para no
 * guardar un año 0. "" / null / undefined / NaN → null; número válido se conserva.
 * Evita además el error 22P02 de Postgres al insertar "" en una columna int.
 */
function toYearOrNull(value: unknown): number | null {
  if (value === null || value === undefined) return null
  if (typeof value === 'string' && value.trim() === '') return null
  const n = Number(value)
  return Number.isFinite(n) ? n : null
}

/**
 * useAdminParts — capa de escritura a Supabase (espejo de useParts, que solo lee).
 * Toda mutación aquí depende de las policies RLS de admin (0004): sin sesión de
 * admin, Postgres rechaza el INSERT/UPDATE/DELETE y estas funciones lanzan error.
 */
export function useAdminParts() {
  async function createPart(
    input: PartInput,
    specs: SpecInput[],
    compat: CompatInput[],
  ): Promise<string> {
    const { data, error } = await supabase
      .from('parts')
      .insert(input)
      .select('id')
      .single()
    if (error) throw error

    const partId = (data as { id: string }).id
    await replaceChildren(partId, specs, compat)
    return partId
  }

  async function updatePart(
    id: string,
    input: PartInput,
    specs: SpecInput[],
    compat: CompatInput[],
  ): Promise<void> {
    // `.select()` + verificación de filas: un UPDATE que no matchea ninguna fila
    // (RLS silenciosa si caducó la sesión de admin, o id inexistente) responde
    // 200 con data:[] y error:null. Sin este chequeo, ese "200 fantasma" pasaría
    // por éxito y la edición se perdería sin aviso.
    const { data, error } = await supabase
      .from('parts')
      .update(input)
      .eq('id', id)
      .select('id')
    if (error) throw error
    if (!data || data.length === 0) {
      throw new Error(
        `El update no afectó ninguna fila (id=${id}). ¿Sigue activa tu sesión de admin?`,
      )
    }
    await replaceChildren(id, specs, compat)
  }

  async function deletePart(id: string, imageUrl?: string | null): Promise<void> {
    // specs, compatibilidad y fotos (part_images, 0020) caen por
    // `on delete cascade`.
    const { error } = await supabase.from('parts').delete().eq('id', id)
    if (error) throw error

    // Las fotos NO caen por cascade (viven en Storage, no en la tabla). Basta
    // una URL cualquiera de la pieza para deducir su carpeta y vaciarla entera,
    // así una pieza con cinco fotos se limpia sin traer la galería completa.
    await removeFolder(folderOfUrl(imageUrl))
  }

  /**
   * Reemplaza specs y compatibilidad de una pieza: borra las existentes e
   * inserta las nuevas. Simple y correcto — el volumen por pieza es bajo, así
   * evitamos reconciliar filas una por una.
   */
  async function replaceChildren(
    partId: string,
    specs: SpecInput[],
    compat: CompatInput[],
  ): Promise<void> {
    const delSpecs = await supabase.from('part_specs').delete().eq('part_id', partId)
    if (delSpecs.error) throw delSpecs.error
    const delCompat = await supabase
      .from('part_compatibility')
      .delete()
      .eq('part_id', partId)
    if (delCompat.error) throw delCompat.error

    const cleanSpecs = specs
      .filter((s) => s.label.trim() && s.value.trim())
      .map((s) => ({ part_id: partId, label: s.label.trim(), value: s.value.trim() }))
    if (cleanSpecs.length) {
      const { error } = await supabase.from('part_specs').insert(cleanSpecs)
      if (error) throw error
    }

    const cleanCompat = compat
      // La marca del auto es NOT NULL (0013): una fila sin marca no se puede
      // guardar y tampoco describe nada, así que se descarta en silencio en vez
      // de hacer fallar el alta entera (solo el nombre de la pieza es obligatorio).
      .filter((c) => !!c.vehicle_brand_id)
      .map((c) => ({
        part_id: partId,
        vehicle_brand_id: c.vehicle_brand_id || null,
        vehicle_model_id: c.vehicle_model_id || null,
        motor_id: c.motor_id || null,
        year_from: toYearOrNull(c.year_from),
        year_to: toYearOrNull(c.year_to),
      }))

    if (cleanCompat.length) {
      const { error } = await supabase.from('part_compatibility').insert(cleanCompat)
      if (error) throw error
    }
  }

  /**
   * saveGallery — sube las fotos nuevas y devuelve la lista ORDENADA de URLs
   * finales (la primera es la principal).
   *
   * `drafts` mezcla fotos que ya estaban en el bucket con archivos recién
   * elegidos; el orden del array ES el orden de la galería.
   *
   * `folderKey` es la carpeta dentro del bucket: el código de la pieza cuando lo
   * tiene y, desde que el código es opcional (0015), su id o un uuid nuevo cuando
   * no. Nunca un valor compartido: dos piezas sin código en la misma carpeta se
   * pisarían las fotos.
   *
   * Para NO dejar fotos huérfanas:
   *  1. Cada archivo nuevo sube a un path ÚNICO (`<carpeta>/<uuid>`). Con varias
   *     fotos por pieza un nombre fijo se sobrescribiría a sí mismo, y un path
   *     nuevo hace innecesario el cache-buster: la URL cambia sola.
   *  2. Si al editar cambió la carpeta destino (p. ej. le pusieron código a una
   *     pieza que no lo tenía), se vacía la carpeta anterior completa.
   *  3. Al final se borra del bucket todo lo que quedó en la carpeta y ya no
   *     aparece en la galería — las fotos que el admin quitó del formulario.
   */
  async function saveGallery(
    drafts: PartImageDraft[],
    folderKey: string,
    previousUrl?: string | null,
  ): Promise<string[]> {
    const safeKey = folderKey.trim().replace(/[^a-zA-Z0-9-_]/g, '-') || 'pieza'

    // (1) Sube lo nuevo, conservando el orden del formulario.
    const urls: string[] = []
    for (const draft of drafts) {
      if (!draft.file) {
        if (draft.url) urls.push(draft.url)
        continue
      }
      const path = `${safeKey}/${crypto.randomUUID()}`
      const { error } = await supabase.storage
        .from(BUCKET)
        .upload(path, draft.file, { upsert: true, contentType: draft.file.type })
      if (error) throw error
      const { data } = supabase.storage.from(BUCKET).getPublicUrl(path)
      urls.push(data.publicUrl)
    }

    // (2) La carpeta anterior, si la pieza se mudó de carpeta.
    const previousFolder = folderOfUrl(previousUrl)
    if (previousFolder && previousFolder !== safeKey) {
      await removeFolder(previousFolder)
    }

    // (3) Huérfanas: lo que sigue en la carpeta y ya no está en la galería.
    const keep = new Set(
      urls.map((u) => storagePathFromUrl(u)).filter((p): p is string => p !== null),
    )
    const { data: existing } = await supabase.storage.from(BUCKET).list(safeKey)
    const orphans = (existing ?? [])
      .map((f) => `${safeKey}/${f.name}`)
      .filter((path) => !keep.has(path))
    if (orphans.length) {
      await supabase.storage.from(BUCKET).remove(orphans)
    }

    return urls
  }

  /**
   * Reemplaza la galería de la pieza (0020) por la lista de URLs recibida, en ese
   * orden: `sort_order` 0 es la principal. Mismo criterio que replaceChildren —
   * borrar e insertar en vez de reconciliar fila por fila, que con un puñado de
   * fotos por pieza no aporta nada.
   *
   * Ojo: `parts.image_url` NO se toca aquí. Es la principal denormalizada y la
   * escribe el propio UPDATE/INSERT de la pieza (el formulario pone urls[0]),
   * así la fila y su galería se guardan en la misma operación.
   */
  async function replaceImages(partId: string, urls: string[]): Promise<void> {
    const del = await supabase.from('part_images').delete().eq('part_id', partId)
    if (del.error) throw del.error
    if (!urls.length) return

    const rows = urls.map((url, i) => ({ part_id: partId, url, sort_order: i }))
    const { error } = await supabase.from('part_images').insert(rows)
    if (error) throw error
  }

  return { createPart, updatePart, deletePart, saveGallery, replaceImages }
}

/** Convierte un Part cargado de la BD en el PartInput que edita el formulario. */
export function toPartInput(part: Part): PartInput {
  return {
    code: part.code,
    name: part.name,
    category_id: part.category_id,
    brand_id: part.brand_id,
    origin_type: part.origin_type,
    price: part.price,
    availability: part.availability,
    description: part.description,
    material: part.material,
    image_url: part.image_url,
    discount_amount: part.discount_amount ?? null,
    is_best_deal: part.is_best_deal ?? false,
    wholesale_price: part.wholesale_price ?? null,
    // La columna es NOT NULL con default 5 (0014); una pieza vieja sin valor
    // cargado en memoria vuelve al mismo 5 en vez de mandar null.
    wholesale_min_qty: part.wholesale_min_qty ?? 5,
    // Misma idea con la existencia (0018): NOT NULL con default 0 en la BD.
    stock_qty: part.stock_qty ?? 0,
  }
}
