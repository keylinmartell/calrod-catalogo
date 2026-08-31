import { supabase } from '@/services/supabase'
import type { CompatInput, Part, PartInput, SpecInput } from '@/types/part'

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
    // specs y compatibilidad caen por `on delete cascade` (0001_init.sql).
    const { error } = await supabase.from('parts').delete().eq('id', id)
    if (error) throw error

    // La foto NO cae por cascade (vive en Storage, no en la tabla): la borramos
    // aparte para no dejarla huérfana en el bucket.
    const path = storagePathFromUrl(imageUrl)
    if (path) {
      await supabase.storage.from(BUCKET).remove([path])
    }
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
      .filter((c) => c.vehicle_brand.trim() && c.vehicle_model.trim())
      .map((c) => ({
        part_id: partId,
        vehicle_brand: c.vehicle_brand.trim(),
        vehicle_model: c.vehicle_model.trim(),
        // Un <input type="number"> vacío da "" (o NaN con .number), y Postgres
        // rechaza "" para una columna integer (error 22P02). Los años son
        // opcionales: normalizamos vacío/NaN a null.
        year_from: toYearOrNull(c.year_from),
        year_to: toYearOrNull(c.year_to),
        // Motor opcional: texto vacío → null (aplica sin importar el motor).
        motor: c.motor?.trim() || null,
      }))
    if (cleanCompat.length) {
      const { error } = await supabase.from('part_compatibility').insert(cleanCompat)
      if (error) throw error
    }
  }

  /**
   * uploadImage — sube el archivo al bucket `part-images` y devuelve la URL
   * pública. Para NO dejar fotos huérfanas:
   *  1. Borra todo lo que haya en la carpeta de la pieza (`<code>/…`), sin
   *     importar con qué nombre/extensión se subió antes (foto.jpg, photo, …).
   *  2. Si al editar cambió el código de la pieza, la carpeta destino cambia, así
   *     que además borramos el objeto de la URL anterior (previousUrl) esté donde
   *     esté.
   *  3. Sube la nueva al path fijo `<code>/photo` con upsert.
   */
  async function uploadImage(
    file: File,
    partCode: string,
    previousUrl?: string | null,
  ): Promise<string> {
    const safeCode = partCode.trim().replace(/[^a-zA-Z0-9-_]/g, '-') || 'pieza'
    const path = `${safeCode}/photo`

    // (1) Vacía la carpeta actual de la pieza.
    const { data: existing } = await supabase.storage
      .from('part-images')
      .list(safeCode)
    if (existing && existing.length) {
      await supabase.storage
        .from('part-images')
        .remove(existing.map((f) => `${safeCode}/${f.name}`))
    }

    // (2) Borra la foto anterior si vivía en otra ruta (p. ej. el código cambió).
    const prevPath = storagePathFromUrl(previousUrl)
    if (prevPath && prevPath !== path) {
      await supabase.storage.from('part-images').remove([prevPath])
    }

    // (3) Sube la nueva.
    const { error } = await supabase.storage
      .from('part-images')
      .upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error

    // Cache-buster: la URL pública es estable (mismo path), así que sin esto el
    // navegador seguiría mostrando la foto vieja cacheada tras reemplazarla.
    const { data } = supabase.storage.from('part-images').getPublicUrl(path)
    return `${data.publicUrl}?v=${Date.now()}`
  }

  return { createPart, updatePart, deletePart, uploadImage }
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
  }
}
