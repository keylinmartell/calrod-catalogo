import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'

/**
 * useFilters — arma y expone el estado de los filtros (name/code, category).
 * Envuelve el catalogStore para que los componentes de UI no toquen el store directo.
 */
export function useFilters() {
  const store = useCatalogStore()
  const { search, activeCategories, categories, parts, loading } = storeToRefs(store)

  function setSearch(value: string) {
    store.setSearch(value)
  }

  function toggleCategory(catId: string) {
    store.toggleCategory(catId)
  }

  function clearFilters() {
    store.clearFilters()
  }

  const hasActiveFilters = computed(
    () => search.value.trim().length > 0 || activeCategories.value.length > 0,
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

  return {
    categories,
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
