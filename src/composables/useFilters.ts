import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { CATEGORIES } from '@/types/part'
import type { PartCategory } from '@/types/part'

/**
 * useFilters — arma y expone el estado de los filtros (name/code, category).
 * Envuelve el catalogStore para que los componentes de UI no toquen el store directo.
 */
export function useFilters() {
  const store = useCatalogStore()
  const { search, activeCategories, parts, loading } = storeToRefs(store)

  function setSearch(value: string) {
    store.setSearch(value)
  }

  function toggleCategory(cat: PartCategory) {
    store.toggleCategory(cat)
  }

  function clearFilters() {
    store.clearFilters()
  }

  const hasActiveFilters = computed(
    () => search.value.trim().length > 0 || activeCategories.value.length > 0,
  )

  // Conteo por categoría sobre el resultado actual (para los chips de FilterBar).
  const categoryCounts = computed<Record<PartCategory, number>>(() => {
    const counts = {
      frenos: 0,
      motor: 0,
      suspension: 0,
      electrico: 0,
      carroceria: 0,
      filtros: 0,
    } as Record<PartCategory, number>
    for (const p of parts.value) counts[p.category]++
    return counts
  })

  return {
    categories: CATEGORIES,
    search,
    activeCategories,
    loading,
    hasActiveFilters,
    categoryCounts,
    setSearch,
    toggleCategory,
    clearFilters,
  }
}
