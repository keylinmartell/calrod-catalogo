import { supabase } from '@/services/supabase'
import type {
  Brand,
  Category,
  Part,
  VehicleBrand,
  VehicleModel,
  VehicleMotor,
} from '@/types/part'

export interface PartQueryOptions {
  search?: string
  /** Ids de categoría a filtrar (parts.category_id). */
  categories?: string[]
  /** Ids de marca de pieza a filtrar (parts.brand_id). */
  brands?: string[]
  /** Marca del vehículo compatible, por NOMBRE del nomenclador (0013). */
  vehicleBrand?: string
  /** Modelo del vehículo compatible, por NOMBRE del nomenclador (0016). */
  vehicleModel?: string
  /** Motor compatible, por NOMBRE del nomenclador (0016). */
  motor?: string
}

// Traemos categoría y marca embebidas por su FK, más specs y compatibilidad.
// La compatibilidad arrastra su modelo — y dentro de él la marca de auto — más su
// motor. Desde 0016 la fila no guarda ninguno de los tres nombres: los traen las
// FK, y la marca cuelga del modelo.
const PART_SELECT =
  '*, categories(*), brands(*), part_specs(*), ' +
  'part_compatibility(*, vehicle_brands(*), vehicle_models(*, vehicle_brands(*)), vehicle_motors(*, vehicle_brands(*)))'

// El select de la FICHA: lo mismo que el catálogo más la galería de fotos (0020).
// Va aparte a propósito — el catálogo pinta cientos de tarjetas y a cada una le
// basta la principal denormalizada en `parts.image_url`, así que no le cargamos
// un join que solo la ficha usa.
const PART_DETAIL_SELECT = PART_SELECT + ', part_images(*)'


/**
 * useParts — capa de consulta a Supabase (ya no lee JSON local).
 * El filtro por nombre/código se resuelve con `ilike` en el servidor (§4.2),
 * así funciona igual sin importar cuántas piezas tenga el catálogo.
 */
export function useParts() {
  const uniq = (ids: string[]) => Array.from(new Set(ids))

  /**
   * Ids de un nomenclador cuyo `name` matchea un término. `exact` distingue los
   * dos usos: los filtros del catálogo comparan el nombre completo (el que la UI
   * muestra), la búsqueda de texto libre usa `ilike` parcial.
   *
   * Desde 0016 los tres campos del vehículo son FK, así que TODA búsqueda por
   * marca, modelo o motor empieza resolviendo ids aquí.
   */
  async function nomencladorIds(
    table: 'vehicle_brands' | 'vehicle_models' | 'vehicle_motors',
    name: string,
    exact: boolean,
  ): Promise<string[]> {
    const base = supabase.from(table).select('id')
    const { data, error } = await (exact
      ? base.eq('name', name)
      : base.ilike('name', `%${name}%`))
    if (error) throw error
    return uniq((data ?? []).map((r) => (r as { id: string }).id))
  }

  /** Ids de los modelos que pertenecen a estas marcas. */
  async function modelIdsOfBrands(brandIds: string[]): Promise<string[]> {
    if (!brandIds.length) return []
    const { data, error } = await supabase
      .from('vehicle_models')
      .select('id')
      .in('vehicle_brand_id', brandIds)
    if (error) throw error
    return uniq((data ?? []).map((r) => (r as { id: string }).id))
  }

  /** part_id de las filas de compatibilidad que apuntan a una de estas FK. */
  async function compatPartIdsByFk(
    column: 'vehicle_brand_id' | 'vehicle_model_id' | 'motor_id',
    ids: string[],
  ): Promise<string[]> {
    if (!ids.length) return []
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('part_id')
      .in(column, ids)
    if (error) throw error
    return uniq((data ?? []).map((r) => (r as { part_id: string }).part_id))
  }


  /**
   * Busca piezas cuya compatibilidad matchee texto libre en cualquiera de sus
   * campos de vehículo (marca/modelo/motor). Como esos campos son FK a los
   * nomencladores y viven en la tabla hija part_compatibility, se resuelve en dos
   * pasos: primero los ids que matchean el término, luego los part_id que los
   * usan. Devuelve null si no hay término (para no filtrar).
   */
  async function compatPartIds(term: string): Promise<string[] | null> {
    const t = term.trim()
    if (!t) return null

    const [brandIds, modelsByOwnName, motorIds] = await Promise.all([
      nomencladorIds('vehicle_brands', t, false),
      nomencladorIds('vehicle_models', t, false),
      nomencladorIds('vehicle_motors', t, false),
    ])

    // "toyota" no matchea ningún modelo por nombre, pero sí todos los modelos de
    // Toyota: los dos caminos hacia un modelo se unen aquí.
    const modelIds = uniq([
      ...modelsByOwnName,
      ...(await modelIdsOfBrands(brandIds)),
    ])

    const [byBrand, byModel, byMotor] = await Promise.all([
      compatPartIdsByFk('vehicle_brand_id', brandIds),
      compatPartIdsByFk('vehicle_model_id', modelIds),
      compatPartIdsByFk('motor_id', motorIds),
    ])
    return uniq([...byBrand, ...byModel, ...byMotor])
  }

  /**
   * part_id compatibles con una marca de auto dada por nombre exacto.
   */
  async function compatPartIdsByVehicleBrand(name: string): Promise<string[]> {
    const brandIds = await nomencladorIds('vehicle_brands', name, true)
    if (!brandIds.length) return []
    const [byBrand, byModel] = await Promise.all([
      compatPartIdsByFk('vehicle_brand_id', brandIds),
      compatPartIdsByFk('vehicle_model_id', await modelIdsOfBrands(brandIds)),
    ])
    return uniq([...byBrand, ...byModel])
  }

  /** part_id compatibles con un modelo dado por nombre exacto. */
  async function compatPartIdsByVehicleModel(name: string): Promise<string[]> {
    return compatPartIdsByFk(
      'vehicle_model_id',
      await nomencladorIds('vehicle_models', name, true),
    )
  }

  /** part_id compatibles con un motor dado por nombre exacto. */
  async function compatPartIdsByMotor(name: string): Promise<string[]> {
    return compatPartIdsByFk(
      'motor_id',
      await nomencladorIds('vehicle_motors', name, true),
    )
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
      idSets.push(await compatPartIdsByVehicleBrand(opts.vehicleBrand.trim()))
    }
    if (opts.vehicleModel?.trim()) {
      idSets.push(await compatPartIdsByVehicleModel(opts.vehicleModel.trim()))
    }
    if (opts.motor?.trim()) {
      idSets.push(await compatPartIdsByMotor(opts.motor.trim()))
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
    // Doble cast: con un select tan anidado como PART_SELECT (compatibilidad →
    // modelo → marca) supabase-js no logra inferir la forma y cae a
    // GenericStringError[], que no solapa con Part. Pasar por `unknown` es la
    // salida estándar; el contrato real lo fija PART_SELECT + Part.
    return (data ?? []) as unknown as Part[]
  }

  async function fetchPartById(id: string): Promise<Part | null> {
    const { data, error } = await supabase
      .from('parts')
      .select(PART_DETAIL_SELECT)
      .eq('id', id)
      .maybeSingle()

    if (error) throw error
    // Mismo caso que fetchParts: PART_SELECT no es inferible, se castea por unknown.
    return (data as unknown as Part | null) ?? null
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

  /**
   * Nomenclador de marcas de auto (0013): alimenta el filtro del catálogo y el
   * select de compatibilidad del panel. Reemplaza la lista fija que vivía en
   * useFilters.ts.
   */
  async function fetchVehicleBrands(): Promise<VehicleBrand[]> {
    const { data, error } = await supabase
      .from('vehicle_brands')
      .select('*')
      .order('name', { ascending: true })
    if (error) throw error
    return (data ?? []) as VehicleBrand[]
  }

  /**
   * Nomenclador de modelos (0016). Sin `brandId` trae todos (con su marca
   * embebida, que es lo que "Mis autos" necesita para etiquetarlos); con
   * `brandId` solo los de esa marca, para los selects dependientes del panel.
   */
  async function fetchVehicleModels(brandId?: string): Promise<VehicleModel[]> {
    let query = supabase
      .from('vehicle_models')
      .select('*, vehicle_brands(*)')
      .order('name', { ascending: true })
    if (brandId) query = query.eq('vehicle_brand_id', brandId)
    const { data, error } = await query
    if (error) throw error
    return (data ?? []) as VehicleModel[]
  }

  /** Nomenclador de motores (0016/0019). Permite filtrar por marca y/o modelo. */
  async function fetchVehicleMotors(
    brandId?: string,
    modelId?: string,
  ): Promise<VehicleMotor[]> {
    let query = supabase
      .from('vehicle_motors')
      .select('*, vehicle_brands(*)')
      .order('name', { ascending: true })
    if (brandId) query = query.eq('vehicle_brand_id', brandId)
    if (modelId) query = query.eq('vehicle_model_id', modelId)
    const { data, error } = await query
    if (error) throw error
    return (data ?? []) as VehicleMotor[]
  }


  /** Números del panel "CalRod al día" — vienen de la BD, no hardcodeados (§6). */
  async function fetchStats(): Promise<{
    activeParts: number
    brandsCovered: number
    availabilityPct: number
  }> {
    const [activeRes, brandRows, availRes] = await Promise.all([
      supabase.from('parts').select('*', { count: 'exact', head: true }),
      // La marca ya no está en la fila de compatibilidad (0016): cuelga del
      // modelo, así que se pide anidada.
      supabase.from('part_compatibility').select('vehicle_models(vehicle_brand_id)'),
      supabase.from('parts').select('availability'),
    ])

    if (activeRes.error) throw activeRes.error
    if (brandRows.error) throw brandRows.error
    if (availRes.error) throw availRes.error

    const activeParts = activeRes.count ?? 0

    // Marcas de auto realmente cubiertas por el catálogo: ids distintos vistos a
    // través de los modelos compatibles (no el nomenclador completo, que puede
    // tener marcas sin piezas todavía).
    const brands = new Set(
      ((brandRows.data ?? []) as unknown as {
        vehicle_models: { vehicle_brand_id: string } | null
      }[])
        .map((r) => r.vehicle_models?.vehicle_brand_id)
        .filter((id): id is string => !!id),
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

  /**
   * Trae todas las combinaciones de vehículo (marca/modelo/motor) para poblar
   * los filtros laterales. Los tres nombres llegan anidados por las FK (0016) y
   * se aplanan a texto, que es lo que consumen el store y los facets.
   */
  async function fetchVehicleCompatibilities(): Promise<
    { vehicle_brand: string; vehicle_model: string; motor: string | null }[]
  > {
    const { data, error } = await supabase
      .from('part_compatibility')
      .select('vehicle_models(name, vehicle_brands(name)), vehicle_motors(name)')
    if (error) {
      console.warn('[CalRod] fetchVehicleCompatibilities error:', error)
      return []
    }
    const rows = (data ?? []) as unknown as {
      vehicle_models: { name: string; vehicle_brands: { name: string } | null } | null
      vehicle_motors: { name: string } | null
    }[]
    return rows.map((r) => ({
      vehicle_brand: r.vehicle_models?.vehicle_brands?.name ?? '',
      vehicle_model: r.vehicle_models?.name ?? '',
      motor: r.vehicle_motors?.name ?? null,
    }))
  }

  return {
    fetchParts,
    fetchPartById,
    fetchCategories,
    fetchBrands,
    fetchVehicleBrands,
    fetchVehicleModels,
    fetchVehicleMotors,
    fetchStats,
    fetchVehicleCompatibilities,
  }
}

