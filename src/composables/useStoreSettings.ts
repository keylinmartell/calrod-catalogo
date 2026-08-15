import { supabase } from '@/services/supabase'
import type { StoreSettings, StoreSettingsInput } from '@/types/part'

/**
 * useStoreSettings — ubicación de la tienda (tabla store_settings, fila id=1).
 * Lectura pública para el mapa del catálogo; escritura solo admin (RLS 0007).
 */
export function useStoreSettings() {
  /** Devuelve la ubicación actual, o null si aún no está sembrada. */
  async function fetchStoreSettings(): Promise<StoreSettings | null> {
    const { data, error } = await supabase
      .from('store_settings')
      .select('*')
      .eq('id', 1)
      .maybeSingle()
    if (error) throw error
    return (data as StoreSettings) ?? null
  }

  /** Actualiza la única fila (id=1). No inserta: la fila la crea la migración. */
  async function updateStoreSettings(input: StoreSettingsInput): Promise<void> {
    const { error } = await supabase
      .from('store_settings')
      .update({ ...input, updated_at: new Date().toISOString() })
      .eq('id', 1)
    if (error) throw error
  }

  return { fetchStoreSettings, updateStoreSettings }
}
