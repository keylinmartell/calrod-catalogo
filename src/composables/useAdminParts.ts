import { supabase } from '@/services/supabase'
import type { CompatInput, Part, PartInput, SpecInput } from '@/types/part'

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
    const { error } = await supabase.from('parts').update(input).eq('id', id)
    if (error) throw error
    await replaceChildren(id, specs, compat)
  }

  async function deletePart(id: string): Promise<void> {
    // specs y compatibilidad caen por `on delete cascade` (0001_init.sql).
    const { error } = await supabase.from('parts').delete().eq('id', id)
    if (error) throw error
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
        year_from: c.year_from,
        year_to: c.year_to,
      }))
    if (cleanCompat.length) {
      const { error } = await supabase.from('part_compatibility').insert(cleanCompat)
      if (error) throw error
    }
  }

  /**
   * uploadImage — sube el archivo al bucket `part-images` y devuelve la URL
   * pública oficial que genera Supabase Storage. Esa URL se guarda en
   * parts.image_url. `upsert: true` permite reemplazar la foto de una pieza.
   */
  async function uploadImage(file: File, partCode: string): Promise<string> {
    const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg'
    const safeCode = partCode.trim().replace(/[^a-zA-Z0-9-_]/g, '-') || 'pieza'
    // Nombre estable por pieza para que reemplazar la foto pise la anterior.
    const path = `${safeCode}/foto.${ext}`

    const { error } = await supabase.storage
      .from('part-images')
      .upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error

    const { data } = supabase.storage.from('part-images').getPublicUrl(path)
    return data.publicUrl
  }

  return { createPart, updatePart, deletePart, uploadImage }
}

/** Convierte un Part cargado de la BD en el PartInput que edita el formulario. */
export function toPartInput(part: Part): PartInput {
  return {
    code: part.code,
    name: part.name,
    category: part.category,
    brand: part.brand,
    origin_type: part.origin_type,
    price: part.price,
    availability: part.availability,
    description: part.description,
    material: part.material,
    image_url: part.image_url,
  }
}
