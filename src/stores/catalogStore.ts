import { defineStore } from 'pinia'
import { useParts } from '@/composables/useParts'
import { useStoreSettings } from '@/composables/useStoreSettings'
import type {
  Brand,
  Category,
  Part,
  StoreSettings,
  VehicleBrand,
} from '@/types/part'

interface CatalogState {
  parts: Part[]
  categories: Category[]
  brands: Brand[]
  /** Nomenclador de marcas de auto (0013): las opciones del filtro por vehículo. */
  vehicleBrands: VehicleBrand[]
  allVehicles: { vehicle_brand: string; vehicle_model: string; motor: string | null }[]
  loading: boolean
  error: string | null
  search: string
  searchInResults: string
  viewMode: 'list' | 'grid'
  activeCategories: string[]
  /** Ids de marca de pieza (parts.brand_id) filtradas. */
  activeBrands: string[]
  /** Filtros por vehículo compatible (texto exacto). */
  vehicleBrand: string
  vehicleModel: string
  motor: string
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
    brands: [],
    vehicleBrands: [],
    allVehicles: [],
    loading: false,
    error: null,
    search: '',
    searchInResults: '',
    viewMode: 'grid',
    activeCategories: [],
    activeBrands: [],
    vehicleBrand: '',
    vehicleModel: '',
    motor: '',
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
          brands: this.activeBrands,
          vehicleBrand: this.vehicleBrand,
          vehicleModel: this.vehicleModel,
          motor: this.motor,
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

    /** Carga las marcas de pieza desde la BD (para el filtro global por marca). */
    async loadBrands() {
      const { fetchBrands } = useParts()
      try {
        this.brands = await fetchBrands()
      } catch (e) {
        this.brands = []
        console.error('[CalRod] loadBrands:', e)
      }
    },

    /**
     * Carga el nomenclador de marcas de auto (0013). Alimenta las opciones del
     * filtro por vehículo: antes eran una lista fija en el frontend.
     */
    async loadVehicleBrands() {
      const { fetchVehicleBrands } = useParts()
      try {
        this.vehicleBrands = await fetchVehicleBrands()
      } catch (e) {
        this.vehicleBrands = []
        console.error('[CalRod] loadVehicleBrands:', e)
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

    /** Filtro global por marca de pieza (toggle: click de nuevo la quita). */
    toggleBrand(brandId: string) {
      const i = this.activeBrands.indexOf(brandId)
      if (i === -1) this.activeBrands.push(brandId)
      else this.activeBrands.splice(i, 1)
      this.loadParts()
    },

    /** Carga todas las combinaciones de vehículos disponibles para poblar los filtros. */
    async loadAllVehicles() {
      const { fetchVehicleCompatibilities } = useParts()
      try {
        this.allVehicles = await fetchVehicleCompatibilities()
      } catch (e) {
        this.allVehicles = []
        console.error('[CalRod] loadAllVehicles:', e)
      }
    },

    setViewMode(mode: 'list' | 'grid') {
      this.viewMode = mode
    },

    setSearchInResults(value: string) {
      this.searchInResults = value
    },

    /** Toggle de marca de vehículo (click activa o desactiva). */
    toggleVehicleBrand(brand: string) {
      if (this.vehicleBrand.toLowerCase() === brand.toLowerCase()) {
        this.vehicleBrand = ''
      } else {
        this.vehicleBrand = brand
      }
      this.vehicleModel = ''
      this.loadParts()
    },

    /** Toggle de modelo de vehículo (click activa o desactiva). */
    toggleVehicleModel(model: string) {
      if (this.vehicleModel.toLowerCase() === model.toLowerCase()) {
        this.vehicleModel = ''
      } else {
        this.vehicleModel = model
      }
      this.loadParts()
    },

    /** Fija el motor (cadena vacía = cualquier motor). */
    setMotor(value: string) {
      this.motor = value
      this.loadParts()
    },

    clearFilters() {
      this.search = ''
      this.searchInResults = ''
      this.activeCategories = []
      this.activeBrands = []
      this.vehicleBrand = ''
      this.vehicleModel = ''
      this.motor = ''
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
