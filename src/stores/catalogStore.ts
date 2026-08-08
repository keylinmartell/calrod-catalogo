import { defineStore } from 'pinia'
import { useParts } from '@/composables/useParts'
import type { Part, PartCategory } from '@/types/part'

interface CatalogState {
  parts: Part[]
  loading: boolean
  error: string | null
  search: string
  activeCategories: PartCategory[]
  stats: {
    activeParts: number
    brandsCovered: number
    availabilityPct: number
  } | null
  statsLoading: boolean
}

let searchTimer: ReturnType<typeof setTimeout> | null = null

export const useCatalogStore = defineStore('catalog', {
  state: (): CatalogState => ({
    parts: [],
    loading: false,
    error: null,
    search: '',
    activeCategories: [],
    stats: null,
    statsLoading: false,
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

    /** Búsqueda con debounce ~300ms (§6): consulta Supabase, no filtra en el navegador. */
    setSearch(value: string) {
      this.search = value
      if (searchTimer) clearTimeout(searchTimer)
      searchTimer = setTimeout(() => {
        this.loadParts()
      }, 300)
    },

    toggleCategory(cat: PartCategory) {
      const i = this.activeCategories.indexOf(cat)
      if (i === -1) this.activeCategories.push(cat)
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
  },
})

// ── Fase 2 ────────────────────────────────────────────────────────────────
// El carrito vive en su propio store (cartStore.ts), no aquí, para que la
// tienda entre sin tocar el catálogo. Ver sección 10 del brief.
