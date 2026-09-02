import { supabase } from '@/services/supabase'
import type { VehicleMotor, VehicleMotorInput } from '@/types/part'

/**
 * useAdminVehicleMotors — CRUD del nomenclador de MOTORES (0016; escritura sujeta
 * a las RLS de admin).
 *
 * Un motor pertenece a un modelo, no a una marca: el "1.8L" de un Corolla y el
 * "1.8L" de un Civic son entradas distintas. Eso es lo que permite que el panel
 * ofrezca solo los motores reales del modelo elegido, y lo que la FK compuesta de
 * part_compatibility garantiza a nivel de BD.
 *
 * El motor sigue siendo OPCIONAL en la compatibilidad: no todas las piezas
 * dependen de él. Borrar un motor en uso está bloqueado (`on delete restrict`).
 */
export function useAdminVehicleMotors() {
  async function createVehicleMotor(
    input: VehicleMotorInput,
  ): Promise<VehicleMotor> {
    const { data, error } = await supabase
      .from('vehicle_motors')
      .insert(input)
      .select('*, vehicle_brands(*)')
      .single()
    if (error) throw error
    return data as VehicleMotor
  }

  async function updateVehicleMotor(
    id: string,
    input: { name: string; slug: string },
  ): Promise<void> {
    const { error } = await supabase
      .from('vehicle_motors')
      .update(input)
      .eq('id', id)
    if (error) throw error
  }

  async function deleteVehicleMotor(id: string): Promise<void> {
    const { error } = await supabase.from('vehicle_motors').delete().eq('id', id)
    if (error) throw error
  }

  /** Cuántas filas de compatibilidad usan cada motor, por id. */
  async function fetchUsageCounts(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('motor_id')
    if (error) throw error
    const counts: Record<string, number> = {}
    for (const row of data ?? []) {
      // motor_id es nullable: las filas sin motor no cuentan para nadie.
      const id = (row as { motor_id: string | null }).motor_id
      if (id) counts[id] = (counts[id] ?? 0) + 1
    }
    return counts
  }

  return {
    createVehicleMotor,
    updateVehicleMotor,
    deleteVehicleMotor,
    fetchUsageCounts,
  }
}
