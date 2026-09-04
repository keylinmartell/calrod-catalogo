import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { motorName, vehicleBrandName, vehicleModelName } from '@/types/part'

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
    vehicleBrands,
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

  /** Aplica marca + modelo/motor de una vez (usado por los autos favoritos). */
  function setVehicleFilter(v: {
    brand: string
    model?: string | null
    motor?: string | null
  }) {
    store.setVehicleFilter(v)
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
  // Las marcas salen del nomenclador que administra el panel (0013), no de una
  // lista fija: lo que el admin registra es exactamente lo que ofrece el filtro.
  // Si el nomenclador no cargó (red caída), caemos a las marcas presentes en los
  // datos ya traídos para no dejar el filtro vacío.
  const allVehicleBrandOptions = computed<string[]>(() => {
    const fromNomenclador = vehicleBrands.value.map((b) => b.name)
    if (fromNomenclador.length) {
      return [...fromNomenclador].sort((a, b) => a.localeCompare(b))
    }

    const set = new Set<string>()
    for (const v of allVehicles.value) {
      if (v.vehicle_brand) set.add(v.vehicle_brand)
    }
    for (const p of parts.value) {
      for (const c of p.part_compatibility ?? []) {
        const name = vehicleBrandName(c)
        if (name) set.add(name)
      }
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
        if (vb && vehicleBrandName(c).toLowerCase() !== vb) continue
        const model = vehicleModelName(c)
        if (model) set.add(model)
      }
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b))
  })

  // Motores presentes en el resultado (solo los no nulos).
  const motorOptions = computed<string[]>(() => {
    const set = new Set<string>()
    for (const p of parts.value) {
      for (const c of p.part_compatibility ?? []) {
        const m = motorName(c)
        if (m) set.add(m)
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
          vehicleBrandName(c).toLowerCase().includes(q) ||
          vehicleModelName(c).toLowerCase().includes(q) ||
          motorName(c).toLowerCase().includes(q),
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
    setVehicleFilter,
    clearFilters,
  }
}
