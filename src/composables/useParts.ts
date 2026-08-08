import { supabase } from '@/services/supabase'
import type { Part, PartCategory } from '@/types/part'

export interface PartQueryOptions {
  search?: string
  categories?: PartCategory[]
}

/**
 * useParts — capa de consulta a Supabase (ya no lee JSON local).
 * El filtro por nombre/código se resuelve con `ilike` en el servidor (§4.2),
 * así funciona igual sin importar cuántas piezas tenga el catálogo.
 */
export function useParts() {
  async function fetchParts(opts: PartQueryOptions = {}): Promise<Part[]> {
    let query = supabase
      .from('parts')
      .select('*, part_specs(*), part_compatibility(*)')
      .order('created_at', { ascending: false })

    const search = opts.search?.trim()
    if (search) {
      query = query.or(`name.ilike.%${search}%,code.ilike.%${search}%`)
    }

    if (opts.categories && opts.categories.length > 0) {
      query = query.in('category', opts.categories)
    }

    const { data, error } = await query
    if (error) throw error
    return (data ?? []) as Part[]
  }

  async function fetchPartById(id: string): Promise<Part | null> {
    const { data, error } = await supabase
      .from('parts')
      .select('*, part_specs(*), part_compatibility(*)')
      .eq('id', id)
      .maybeSingle()

    if (error) throw error
    return (data as Part) ?? null
  }

  /** Números del panel "CalRod al día" — vienen de la BD, no hardcodeados (§6). */
  async function fetchStats(): Promise<{
    activeParts: number
    brandsCovered: number
    availabilityPct: number
  }> {
    const [activeRes, brandRows, availRes] = await Promise.all([
      supabase.from('parts').select('*', { count: 'exact', head: true }),
      supabase.from('part_compatibility').select('vehicle_brand'),
      supabase.from('parts').select('availability'),
    ])

    if (activeRes.error) throw activeRes.error
    if (brandRows.error) throw brandRows.error
    if (availRes.error) throw availRes.error

    const activeParts = activeRes.count ?? 0

    const brands = new Set(
      (brandRows.data ?? []).map((r) => (r as { vehicle_brand: string }).vehicle_brand),
    )
    const brandsCovered = brands.size

    const avail = availRes.data ?? []
    const disponibles = avail.filter(
      (r) => (r as { availability: string }).availability === 'disponible',
    ).length
    const availabilityPct = avail.length
      ? Math.round((disponibles / avail.length) * 100)
      : 0

    return { activeParts, brandsCovered, availabilityPct }
  }

  return { fetchParts, fetchPartById, fetchStats }
}
