import { supabase } from '@/services/supabase'
import type { VehicleBrand, VehicleBrandInput } from '@/types/part'

/** Convierte un nombre en slug estable: minúsculas, sin acentos, guiones. */
export function slugify(name: string): string {
  return name
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '') // quita acentos (marcas combinantes)
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

/**
 * useAdminVehicleBrands — CRUD del nomenclador de marcas de auto (0013;
 * escritura sujeta a las RLS de admin).
 *
 * Desde 0016 la marca es la raíz de la jerarquía marca → modelo → motor, y la
 * compatibilidad ya no la referencia directamente: apunta al modelo. Por eso el
 * uso de una marca se cuenta a través de sus modelos.
 *
 * A diferencia de categorías y marcas de pieza, borrar aquí no es libre: los
 * modelos caen por cascada, pero si alguno está usado por una pieza la FK
 * `on delete restrict` de part_compatibility aborta el borrado completo. Por eso
 * el panel consulta primero cuántas filas la usan y lo avisa en vez de
 * estrellarse contra el error de la FK.
 */
export function useAdminVehicleBrands() {

  async function createVehicleBrand(
    input: VehicleBrandInput,
  ): Promise<VehicleBrand> {
    const { data, error } = await supabase
      .from('vehicle_brands')
      .insert(input)
      .select('*')
      .single()
    if (error) throw error
    return data as VehicleBrand
  }

  async function updateVehicleBrand(
    id: string,
    input: VehicleBrandInput,
  ): Promise<void> {
    const { error } = await supabase
      .from('vehicle_brands')
      .update(input)
      .eq('id', id)
    if (error) throw error
  }

  async function deleteVehicleBrand(id: string): Promise<void> {
    const { error } = await supabase.from('vehicle_brands').delete().eq('id', id)
    if (error) throw error
  }

  /**
   * Cuántas filas de compatibilidad usan cada marca, por id. Desde 0016 la fila
   * no guarda la marca, así que se cuenta a través del modelo: cada fila aporta
   * uno a la marca de su modelo.
   */
  async function fetchUsageCounts(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('vehicle_models(vehicle_brand_id)')
    if (error) throw error
    const rows = (data ?? []) as unknown as {
      vehicle_models: { vehicle_brand_id: string } | null
    }[]
    const counts: Record<string, number> = {}
    for (const row of rows) {
      const id = row.vehicle_models?.vehicle_brand_id
      if (id) counts[id] = (counts[id] ?? 0) + 1
    }
    return counts
  }

  /** Cuántos modelos tiene cada marca, por id (para la lista del panel). */
  async function fetchModelCounts(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('vehicle_models')
      .select('vehicle_brand_id')
    if (error) throw error
    const counts: Record<string, number> = {}
    for (const row of data ?? []) {
      const id = (row as { vehicle_brand_id: string }).vehicle_brand_id
      counts[id] = (counts[id] ?? 0) + 1
    }
    return counts
  }

  async function uploadBrandLogo(file: File, slug: string): Promise<string> {
    const ext = file.name.split('.').pop() || 'png'
    const path = `vehicle-brands/${slug}-${crypto.randomUUID().slice(0, 8)}.${ext}`
    const { error } = await supabase.storage
      .from('part-images')
      .upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error
    const { data } = supabase.storage.from('part-images').getPublicUrl(path)
    return data.publicUrl
  }

  return {
    createVehicleBrand,
    updateVehicleBrand,
    deleteVehicleBrand,
    uploadBrandLogo,
    fetchUsageCounts,
    fetchModelCounts,
  }
}

