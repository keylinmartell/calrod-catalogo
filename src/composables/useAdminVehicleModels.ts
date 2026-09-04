import { supabase } from '@/services/supabase'
import type { VehicleModel, VehicleModelInput } from '@/types/part'

/**
 * useAdminVehicleModels — CRUD del nomenclador de MODELOS de auto (0016;
 * escritura sujeta a las RLS de admin).
 *
 * Un modelo pertenece siempre a una marca y su slug es único DENTRO de esa marca:
 * dos marcas pueden tener un modelo con el mismo nombre y son modelos distintos.
 *
 * Sobre el borrado: part_compatibility apunta al modelo con `on delete restrict`,
 * así que un modelo en uso por alguna pieza no se puede borrar y el panel lo
 * avisa antes de intentarlo. Un modelo SIN piezas sí se borra, y al hacerlo se
 * lleva por cascada sus motores y los autos guardados que lo usaban (0017).
 */
export function useAdminVehicleModels() {
  async function createVehicleModel(
    input: VehicleModelInput,
  ): Promise<VehicleModel> {
    const { data, error } = await supabase
      .from('vehicle_models')
      .insert(input)
      .select('*')
      .single()
    if (error) throw error
    return data as VehicleModel
  }

  /** Permite actualizar nombre, slug e imagen del modelo. */
  async function updateVehicleModel(
    id: string,
    input: { name: string; slug: string; image_url?: string | null },
  ): Promise<void> {
    const { error } = await supabase
      .from('vehicle_models')
      .update(input)
      .eq('id', id)
    if (error) throw error
  }

  async function uploadModelImage(file: File, slug: string): Promise<string> {
    const ext = file.name.split('.').pop() || 'png'
    const path = `vehicle-models/${slug}-${crypto.randomUUID().slice(0, 8)}.${ext}`
    const { error } = await supabase.storage
      .from('part-images')
      .upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error
    const { data } = supabase.storage.from('part-images').getPublicUrl(path)
    return data.publicUrl
  }

  async function deleteVehicleModel(id: string): Promise<void> {
    const { error } = await supabase.from('vehicle_models').delete().eq('id', id)
    if (error) throw error
  }

  /**
   * Cuántas filas de compatibilidad usan cada modelo, por id. Sirve para mostrar
   * el uso en la lista y para explicar por qué un modelo no se puede borrar.
   */
  async function fetchUsageCounts(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('vehicle_model_id')
    if (error) throw error
    const counts: Record<string, number> = {}
    for (const row of data ?? []) {
      const id = (row as { vehicle_model_id: string }).vehicle_model_id
      counts[id] = (counts[id] ?? 0) + 1
    }
    return counts
  }

  /** Cuántos motores tiene cada modelo, por id (para la lista del panel). */
  async function fetchMotorCounts(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('vehicle_motors')
      .select('vehicle_model_id')
    if (error) throw error
    const counts: Record<string, number> = {}
    for (const row of data ?? []) {
      const id = (row as { vehicle_model_id: string }).vehicle_model_id
      counts[id] = (counts[id] ?? 0) + 1
    }
    return counts
  }

  return {
    createVehicleModel,
    updateVehicleModel,
    deleteVehicleModel,
    uploadModelImage,
    fetchUsageCounts,
    fetchMotorCounts,
  }
}
