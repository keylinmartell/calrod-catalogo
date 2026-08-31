import { supabase } from '@/services/supabase'
import type { Brand, Category, Part } from '@/types/part'

export interface PartQueryOptions {
  search?: string
  /** Ids de categoría a filtrar (parts.category_id). */
  categories?: string[]
  /** Ids de marca de pieza a filtrar (parts.brand_id). */
  brands?: string[]
  /** Marca del vehículo compatible (part_compatibility.vehicle_brand). */
  vehicleBrand?: string
  /** Modelo del vehículo compatible (part_compatibility.vehicle_model). */
  vehicleModel?: string
  /** Motor compatible (part_compatibility.motor). */
  motor?: string
}

// Traemos categoría y marca embebidas por su FK, más specs y compatibilidad.
const PART_SELECT =
  '*, categories(*), brands(*), part_specs(*), part_compatibility(*)'

/**
 * useParts — capa de consulta a Supabase (ya no lee JSON local).
 * El filtro por nombre/código se resuelve con `ilike` en el servidor (§4.2),
 * así funciona igual sin importar cuántas piezas tenga el catálogo.
 */
export function useParts() {
  /**
   * Busca piezas cuya compatibilidad matchee texto libre en cualquiera de sus
   * campos (marca/modelo/motor del vehículo). Como esos campos viven en la tabla
   * hija part_compatibility, se resuelve en dos pasos: primero los part_id que
   * matchean, luego se filtra el query principal por esos ids. Devuelve null si
   * no hay término (para no filtrar) o [] si no hubo coincidencias.
   */
  async function compatPartIds(term: string): Promise<string[] | null> {
    const t = term.trim()
    if (!t) return null
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('part_id')
      .or(
        `vehicle_brand.ilike.%${t}%,vehicle_model.ilike.%${t}%,motor.ilike.%${t}%`,
      )
    if (error) throw error
    const ids = (data ?? []).map((r) => (r as { part_id: string }).part_id)
    return Array.from(new Set(ids))
  }

  /** part_id de la compatibilidad que matchea un campo exacto (marca/modelo/motor). */
  async function compatPartIdsBy(
    column: 'vehicle_brand' | 'vehicle_model' | 'motor',
    value: string,
  ): Promise<string[]> {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('part_id')
      .eq(column, value)
    if (error) throw error
    const ids = (data ?? []).map((r) => (r as { part_id: string }).part_id)
    return Array.from(new Set(ids))
  }

  async function fetchParts(opts: PartQueryOptions = {}): Promise<Part[]> {
    // ── Filtros por tabla hija (compatibilidad): resolvemos part_ids primero ──
    // Cada filtro activo aporta un conjunto de ids; la intersección son las piezas
    // que cumplen TODOS. `null` = filtro inactivo (no restringe).
    const idSets: string[][] = []

    const search = opts.search?.trim()
    if (search) {
      // La búsqueda de texto libre matchea nombre/código (tabla parts) O
      // marca/modelo/motor del vehículo (tabla hija). Unimos ambos conjuntos.
      const compatIds = (await compatPartIds(search)) ?? []
      const { data: nameData, error: nameErr } = await supabase
        .from('parts')
        .select('id')
        .or(`name.ilike.%${search}%,code.ilike.%${search}%`)
      if (nameErr) throw nameErr
      const nameIds = (nameData ?? []).map((r) => (r as { id: string }).id)
      idSets.push(Array.from(new Set([...nameIds, ...compatIds])))
    }

    if (opts.vehicleBrand?.trim()) {
      idSets.push(await compatPartIdsBy('vehicle_brand', opts.vehicleBrand.trim()))
    }
    if (opts.vehicleModel?.trim()) {
      idSets.push(await compatPartIdsBy('vehicle_model', opts.vehicleModel.trim()))
    }
    if (opts.motor?.trim()) {
      idSets.push(await compatPartIdsBy('motor', opts.motor.trim()))
    }

    // Intersección de todos los conjuntos de ids activos.
    let restrictIds: string[] | null = null
    if (idSets.length > 0) {
      restrictIds = idSets.reduce((acc, set) => {
        const s = new Set(set)
        return acc.filter((id) => s.has(id))
      })
      // Si algún filtro no matcheó nada, el resultado es vacío: cortamos aquí.
      if (restrictIds.length === 0) return []
    }

    let query = supabase
      .from('parts')
      .select(PART_SELECT)
      .order('created_at', { ascending: false })

    if (restrictIds) {
      query = query.in('id', restrictIds)
    }

    if (opts.categories && opts.categories.length > 0) {
      query = query.in('category_id', opts.categories)
    }

    if (opts.brands && opts.brands.length > 0) {
      query = query.in('brand_id', opts.brands)
    }

    const { data, error } = await query
    if (error) throw error
    return (data ?? []) as Part[]
  }

  async function fetchPartById(id: string): Promise<Part | null> {
    const { data, error } = await supabase
      .from('parts')
      .select(PART_SELECT)
      .eq('id', id)
      .maybeSingle()

    if (error) throw error
    return (data as Part) ?? null
  }

  /** Lista de categorías (para filtros del catálogo y selects del panel). */
  async function fetchCategories(): Promise<Category[]> {
    const { data, error } = await supabase
      .from('categories')
      .select('*')
      .order('name', { ascending: true })
    if (error) throw error
    return (data ?? []) as Category[]
  }

  /** Lista de marcas de pieza (para el filtro global y el select del panel). */
  async function fetchBrands(): Promise<Brand[]> {
    const { data, error } = await supabase
      .from('brands')
      .select('*')
      .order('name', { ascending: true })
    if (error) throw error
    return (data ?? []) as Brand[]
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

  /** Trae todas las combinaciones de vehículo (marca/modelo/motor) para poblar los filtros laterales. */
  async function fetchVehicleCompatibilities(): Promise<
    { vehicle_brand: string; vehicle_model: string; motor: string | null }[]
  > {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('vehicle_brand, vehicle_model, motor')
    if (error) {
      console.warn('[CalRod] fetchVehicleCompatibilities error:', error)
      return []
    }
    return (data ?? []) as {
      vehicle_brand: string
      vehicle_model: string
      motor: string | null
    }[]
  }

  return {
    fetchParts,
    fetchPartById,
    fetchCategories,
    fetchBrands,
    fetchStats,
    fetchVehicleCompatibilities,
  }
}
