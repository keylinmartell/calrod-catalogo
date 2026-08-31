import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'

// Lista de marcas vehiculares habituales en el mercado para garantizar un catálogo completo
const COMMON_VEHICLE_BRANDS = [
  'Asia',
  'Audi',
  'Byd',
  'Changan',
  'Chery',
  'Chevrolet',
  'Citroen',
  'Daewoo',
  'Daihatsu',
  'Dodge',
  'Fiat',
  'Ford',
  'Geely',
  'Great Wall',
  'Haval',
  'Honda',
  'Hyundai',
  'JAC',
  'Jeep',
  'Kia',
  'Mazda',
  'Mercedes-Benz',
  'MG',
  'Mitsubishi',
  'Nissan',
  'Peugeot',
  'Renault',
  'Seat',
  'Skoda',
  'Subaru',
  'Suzuki',
  'Toyota',
  'Volkswagen',
]

/**
 * useFilters — arma y expone el estado de los filtros (name/code, categoría,
 * marca de pieza, y vehículo compatible: marca/modelo/motor).
 * Envuelve el catalogStore para que los componentes de UI no toquen el store directo.
 */
export function useFilters() {
  const store = useCatalogStore()
  const {
    search,
    searchInResults,
    viewMode,
    activeCategories,
    activeBrands,
    vehicleBrand,
    vehicleModel,
    motor,
    categories,
    brands,
    parts,
    allVehicles,
    loading,
  } = storeToRefs(store)

  function setSearch(value: string) {
    store.setSearch(value)
  }

  function setSearchInResults(value: string) {
    store.setSearchInResults(value)
  }

  function setViewMode(mode: 'list' | 'grid') {
    store.setViewMode(mode)
  }

  function toggleCategory(catId: string) {
    store.toggleCategory(catId)
  }

  function toggleBrand(brandId: string) {
    store.toggleBrand(brandId)
  }

  function setVehicleBrand(value: string) {
    store.toggleVehicleBrand(value)
  }

  function toggleVehicleBrand(brand: string) {
    store.toggleVehicleBrand(brand)
  }

  function setVehicleModel(value: string) {
    store.toggleVehicleModel(value)
  }

  function toggleVehicleModel(model: string) {
    store.toggleVehicleModel(model)
  }

  function setMotor(value: string) {
    store.setMotor(value)
  }

  function clearFilters() {
    store.clearFilters()
  }

  const hasActiveFilters = computed(
    () =>
      search.value.trim().length > 0 ||
      searchInResults.value.trim().length > 0 ||
      activeCategories.value.length > 0 ||
      activeBrands.value.length > 0 ||
      vehicleBrand.value.trim().length > 0 ||
      vehicleModel.value.trim().length > 0 ||
      motor.value.trim().length > 0,
  )

  // Conteo por categoría (id) sobre el resultado actual (para los chips de FilterBar).
  const categoryCounts = computed<Record<string, number>>(() => {
    const counts: Record<string, number> = {}
    for (const c of categories.value) counts[c.id] = 0
    for (const p of parts.value) {
      if (p.category_id && p.category_id in counts) counts[p.category_id]++
    }
    return counts
  })

  // Conteo por marca de repuesto
  const brandCounts = computed<Record<string, number>>(() => {
    const counts: Record<string, number> = {}
    for (const b of brands.value) counts[b.id] = 0
    for (const p of parts.value) {
      if (p.brand_id && p.brand_id in counts) counts[p.brand_id]++
    }
    return counts
  })

  // ── Facetas de vehículo completas (incluso antes de filtrar) ────────────────
  const allVehicleBrandOptions = computed<string[]>(() => {
    const set = new Set<string>()
    // 1. De la BD cargada
    for (const v of allVehicles.value) {
      if (v.vehicle_brand) set.add(v.vehicle_brand)
    }
    // 2. De las piezas actuales
    for (const p of parts.value) {
      for (const c of p.part_compatibility ?? []) {
        if (c.vehicle_brand) set.add(c.vehicle_brand)
      }
    }
    // 3. Fallback de marcas comunes si no hay muchas
    for (const cb of COMMON_VEHICLE_BRANDS) {
      set.add(cb)
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b))
  })

  // Modelos de auto: si hay marca seleccionada, los de esa marca; si no, todos los conocidos
  const availableVehicleModelOptions = computed<string[]>(() => {
    const set = new Set<string>()
    const vb = vehicleBrand.value.trim().toLowerCase()
    // De allVehicles
    for (const v of allVehicles.value) {
      if (vb && v.vehicle_brand?.toLowerCase() !== vb) continue
      if (v.vehicle_model) set.add(v.vehicle_model)
    }
    // De parts
    for (const p of parts.value) {
      for (const c of p.part_compatibility ?? []) {
        if (vb && c.vehicle_brand?.toLowerCase() !== vb) continue
        if (c.vehicle_model) set.add(c.vehicle_model)
      }
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b))
  })

  // Motores presentes en el resultado (solo los no nulos).
  const motorOptions = computed<string[]>(() => {
    const set = new Set<string>()
    for (const p of parts.value) {
      for (const c of p.part_compatibility ?? []) {
        if (c.motor) set.add(c.motor)
      }
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b))
  })

  // Piezas filtradas por búsqueda en resultado si el usuario usa el input secundario
  const displayParts = computed(() => {
    const q = searchInResults.value.trim().toLowerCase()
    if (!q) return parts.value
    return parts.value.filter((p) => {
      const matchName = p.name?.toLowerCase().includes(q)
      const matchCode = p.code?.toLowerCase().includes(q)
      const matchBrand = p.brands?.name?.toLowerCase().includes(q)
      const matchDesc = p.description?.toLowerCase().includes(q)
      const matchCompat = p.part_compatibility?.some(
        (c) =>
          c.vehicle_brand?.toLowerCase().includes(q) ||
          c.vehicle_model?.toLowerCase().includes(q) ||
          c.motor?.toLowerCase().includes(q),
      )
      return matchName || matchCode || matchBrand || matchDesc || matchCompat
    })
  })

  return {
    categories,
    brands,
    search,
    searchInResults,
    viewMode,
    activeCategories,
    activeBrands,
    vehicleBrand,
    vehicleModel,
    motor,
    parts,
    displayParts,
    loading,
    hasActiveFilters,
    categoryCounts,
    brandCounts,
    vehicleBrandOptions: allVehicleBrandOptions,
    vehicleModelOptions: availableVehicleModelOptions,
    motorOptions,
    setSearch,
    setSearchInResults,
    setViewMode,
    toggleCategory,
    toggleBrand,
    setVehicleBrand,
    toggleVehicleBrand,
    setVehicleModel,
    toggleVehicleModel,
    setMotor,
    clearFilters,
  }
}
