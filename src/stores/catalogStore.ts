import { defineStore } from 'pinia'
import { useParts } from '@/composables/useParts'
import { useStoreSettings } from '@/composables/useStoreSettings'
import type { Category, Part, StoreSettings } from '@/types/part'

interface CatalogState {
  parts: Part[]
  categories: Category[]
  loading: boolean
  error: string | null
  search: string
  activeCategories: string[]
  stats: {
    activeParts: number
    brandsCovered: number
    availabilityPct: number
  } | null
  statsLoading: boolean
  storeSettings: StoreSettings | null
}

let searchTimer: ReturnType<typeof setTimeout> | null = null

export const useCatalogStore = defineStore('catalog', {
  state: (): CatalogState => ({
    parts: [],
    categories: [],
    loading: false,
    error: null,
    search: '',
    activeCategories: [],
    stats: null,
    statsLoading: false,
    storeSettings: null,
  }),

  getters: {
    resultCount: (state) => state.parts.length,
    isEmpty: (state) => !state.loading && !state.error && state.parts.length === 0,
  },

  actions: {
    async loadParts() {
      const { fetchParts } = useParts()
      this.loading = true
      this.error = null
      try {
        this.parts = await fetchParts({
          search: this.search,
          categories: this.activeCategories,
        })
      } catch (e) {
        // Estado de error claro, nunca pantalla en blanco (§7).
        this.error =
          'No pudimos cargar el catálogo. Revisa tu conexión e intenta de nuevo.'
        this.parts = []
        console.error('[CalRod] loadParts:', e)
      } finally {
        this.loading = false
      }
    },

    /** Carga las categorías desde la BD (para los chips de filtro dinámicos). */
    async loadCategories() {
      const { fetchCategories } = useParts()
      try {
        this.categories = await fetchCategories()
      } catch (e) {
        this.categories = []
        console.error('[CalRod] loadCategories:', e)
      }
    },

    /** Búsqueda con debounce ~300ms (§6): consulta Supabase, no filtra en el navegador. */
    setSearch(value: string) {
      this.search = value
      if (searchTimer) clearTimeout(searchTimer)
      searchTimer = setTimeout(() => {
        this.loadParts()
      }, 300)
    },

    toggleCategory(catId: string) {
      const i = this.activeCategories.indexOf(catId)
      if (i === -1) this.activeCategories.push(catId)
      else this.activeCategories.splice(i, 1)
      this.loadParts()
    },

    clearFilters() {
      this.search = ''
      this.activeCategories = []
      this.loadParts()
    },

    async loadStats() {
      const { fetchStats } = useParts()
      this.statsLoading = true
      try {
        this.stats = await fetchStats()
      } catch (e) {
        this.stats = null
        console.error('[CalRod] loadStats:', e)
      } finally {
        this.statsLoading = false
      }
    },

    /** Ubicación de la tienda para el mapa del catálogo (store_settings, 0007). */
    async loadStoreSettings() {
      const { fetchStoreSettings } = useStoreSettings()
      try {
        this.storeSettings = await fetchStoreSettings()
      } catch (e) {
        this.storeSettings = null
        console.error('[CalRod] loadStoreSettings:', e)
      }
    },
  },
})

// ── Fase 2 ────────────────────────────────────────────────────────────────
// El carrito vive en su propio store (cartStore.ts), no aquí, para que la
// tienda entre sin tocar el catálogo. Ver sección 10 del brief.
