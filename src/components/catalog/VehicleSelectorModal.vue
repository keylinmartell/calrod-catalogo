<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { useFilters } from '@/composables/useFilters'
import { useParts } from '@/composables/useParts'
import { useFavoriteVehicles } from '@/composables/useFavoriteVehicles'
import { useAuthStore } from '@/stores/authStore'
import { useAuthPanel } from '@/composables/useAuthPanel'
import type {
  FavoriteVehicle,
  VehicleBrand,
  VehicleModel,
  VehicleMotor,
} from '@/types/part'

const props = defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  selected: [vehicle: { brand: string; model?: string; motor?: string }]
}>()

const store = useCatalogStore()
const { vehicleBrands, allVehicles } = storeToRefs(store)
const {
  setVehicleFilter,
  vehicleBrand: currentBrand,
  vehicleModel: currentModel,
  motor: currentMotor,
} = useFilters()
const { fetchVehicleModels, fetchVehicleMotors } = useParts()
const { favorites, isFavorite, toggle, ensureLoaded, storage, error, load } =
  useFavoriteVehicles()
const auth = useAuthStore()
const { isAuthenticated } = storeToRefs(auth)
const { openPanel } = useAuthPanel()

ensureLoaded()

// Pestaña activa: 'saved' (Mis autos guardados) o 'explore' (Agregar / Explorar)
const activeTab = ref<'saved' | 'explore'>('saved')
const selectedBrandId = ref<string | null>(null)
const brandSearch = ref('')
const modelSearch = ref('')

const models = ref<VehicleModel[]>([])
const motors = ref<VehicleMotor[]>([])
const loadingModels = ref(false)

// Conteo de modelos/compatibilidades por marca
const brandCompatCounts = computed(() => {
  const map: Record<string, number> = {}
  for (const v of allVehicles.value) {
    if (v.vehicle_brand) {
      const key = v.vehicle_brand.trim().toLowerCase()
      map[key] = (map[key] ?? 0) + 1
    }
  }
  return map
})

function getBrandCount(brand: VehicleBrand): number {
  const key = brand.name.trim().toLowerCase()
  return brandCompatCounts.value[key] ?? 0
}

const filteredBrands = computed(() => {
  const q = brandSearch.value.trim().toLowerCase()
  if (!q) return vehicleBrands.value
  return vehicleBrands.value.filter((b) => b.name.toLowerCase().includes(q))
})

const selectedBrand = computed(() =>
  vehicleBrands.value.find((b) => b.id === selectedBrandId.value) ?? null,
)

const filteredModels = computed(() => {
  const q = modelSearch.value.trim().toLowerCase()
  if (!q) return models.value
  return models.value.filter((m) => m.name.toLowerCase().includes(q))
})

const filteredMotors = computed(() => {
  const q = modelSearch.value.trim().toLowerCase()
  if (!q) return motors.value
  return motors.value.filter((mo) => mo.name.toLowerCase().includes(q))
})

const filteredFavorites = computed(() => {
  const q = modelSearch.value.trim().toLowerCase()
  if (!q) return favorites.value
  return favorites.value.filter(
    (f) =>
      f.brandName.toLowerCase().includes(q) ||
      f.modelName.toLowerCase().includes(q) ||
      f.motorName.toLowerCase().includes(q),
  )
})

// Al abrir el modal:
watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      if (!vehicleBrands.value.length) void store.loadVehicleBrands()
      if (!allVehicles.value.length) void store.loadAllVehicles()

      if (favorites.value.length > 0) {
        activeTab.value = 'saved'
      } else {
        activeTab.value = 'explore'
      }

      if (currentBrand.value) {
        const match = vehicleBrands.value.find(
          (b) => b.name.toLowerCase() === currentBrand.value.toLowerCase(),
        )
        if (match) {
          selectBrand(match)
          return
        }
      }

      if (!selectedBrandId.value && vehicleBrands.value.length > 0) {
        selectBrand(vehicleBrands.value[0])
      }
    }
  },
  { immediate: true },
)

watch(
  vehicleBrands,
  (brands) => {
    if (props.open && !selectedBrandId.value && brands.length > 0) {
      selectBrand(brands[0])
    }
  },
)

async function selectBrand(b: VehicleBrand) {
  selectedBrandId.value = b.id
  modelSearch.value = ''
  loadingModels.value = true
  try {
    const [ms, mos] = await Promise.all([
      fetchVehicleModels(b.id),
      fetchVehicleMotors(b.id),
    ])
    models.value = ms
    motors.value = mos
  } catch (e) {
    console.error('[CalRod] VehicleSelectorModal selectBrand:', e)
  } finally {
    loadingModels.value = false
  }
}

function modelCandidate(m: VehicleModel): Omit<FavoriteVehicle, 'id'> {
  return {
    brandId: selectedBrand.value?.id ?? '',
    brandName: selectedBrand.value?.name ?? '',
    modelId: m.id,
    modelName: m.name,
    modelImageUrl: m.image_url ?? null,
    motorId: null,
    motorName: '',
  }
}

function motorCandidate(mo: VehicleMotor): Omit<FavoriteVehicle, 'id'> {
  return {
    brandId: selectedBrand.value?.id ?? '',
    brandName: selectedBrand.value?.name ?? '',
    modelId: null,
    modelName: '',
    modelImageUrl: null,
    motorId: mo.id,
    motorName: mo.name,
  }
}

function brandOnlyCandidate(): Omit<FavoriteVehicle, 'id'> | null {
  if (!selectedBrand.value) return null
  return {
    brandId: selectedBrand.value.id,
    brandName: selectedBrand.value.name,
    modelId: null,
    modelName: '',
    modelImageUrl: null,
    motorId: null,
    motorName: '',
  }
}

function saveVehicle(candidate: Omit<FavoriteVehicle, 'id'>) {
  void toggle(candidate)
}

/** Vuelve a intentar la subida a la cuenta de lo que quedó en el navegador. */
function retrySync() {
  void load()
}

function removeFavorite(e: Event, fav: FavoriteVehicle) {
  e.stopPropagation()
  void toggle(fav)
}

function isApplied(f: FavoriteVehicle): boolean {
  const eq = (a?: string, b?: string) =>
    (a ?? '').trim().toLowerCase() === (b ?? '').trim().toLowerCase()
  return (
    Boolean(f.brandName) &&
    eq(currentBrand.value, f.brandName) &&
    eq(currentModel.value, f.modelName) &&
    eq(currentMotor.value, f.motorName)
  )
}

function applyFavorite(f: FavoriteVehicle) {
  setVehicleFilter({ brand: f.brandName, model: f.modelName, motor: f.motorName })
  emit('selected', { brand: f.brandName, model: f.modelName, motor: f.motorName })
  close()
}

function brandLogoFor(brandName: string): string | null {
  const match = vehicleBrands.value.find(
    (b) => b.name.toLowerCase() === brandName.toLowerCase(),
  )
  return match?.logo_url ?? null
}

function close() {
  emit('update:open', false)
}
</script>

<template>
  <Teleport to="body">
    <div v-if="open" class="vmodal-backdrop" @click.self="close">
      <div class="vmodal" role="dialog" aria-modal="true" aria-labelledby="vmodal-title">
        <!-- Header -->
        <header class="vmodal__head">
          <div class="vmodal__head-main">
            <button
              v-if="activeTab === 'explore' && favorites.length > 0"
              type="button"
              class="vmodal__back-btn"
              title="Volver a mis autos guardados"
              aria-label="Volver a mis autos guardados"
              @click="activeTab = 'saved'"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M19 12H5M12 19l-7-7 7-7"/>
              </svg>
            </button>
            <div v-else class="vmodal__badge-icon">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.85 7h10.29l1.04 3H5.81l1.04-3zM19 17H5v-4.66l.12-.34h13.77l.11.34V17z"/>
                <circle cx="7.5" cy="14.5" r="1.5"/>
                <circle cx="16.5" cy="14.5" r="1.5"/>
              </svg>
            </div>
            <div>
              <h2 id="vmodal-title" class="vmodal__title">
                {{ activeTab === 'saved' ? 'Mis Autos Favoritos' : 'Agregar vehículo a mis autos' }}
              </h2>
              <p class="vmodal__subtitle">
                {{
                  activeTab === 'saved'
                    ? 'Filtra el catálogo con un clic según los autos que manejas o agregas.'
                    : 'Selecciona una marca y pulsa tu modelo o motor para guardarlo.'
                }}
              </p>
            </div>
          </div>

          <div class="vmodal__head-actions">
            <button
              v-if="activeTab === 'explore' && favorites.length > 0"
              type="button"
              class="btn-add-vehicle"
              @click="activeTab = 'saved'"
            >
              <span>← Mis autos ({{ favorites.length }})</span>
            </button>
            <button type="button" class="vmodal__close" aria-label="Cerrar ventana" @click="close">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          </div>
        </header>

        <!-- Main Body -->
        <div class="vmodal__body">
          <!-- ════════ PESTAÑA: MIS AUTOS GUARDADOS ════════ -->
          <section v-if="activeTab === 'saved'" class="vmodal__saved-view">
            <!-- Empty State -->
            <div v-if="!favorites.length" class="vmodal__empty-state">
              <div class="vmodal__empty-icon-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
              </div>
              <h3 class="vmodal__empty-title">Tu garaje está vacío</h3>
              <p class="vmodal__empty-text">
                Guarda tus autos para encontrar repuestos 100% compatibles sin tener que volver a configurar los filtros.
              </p>
              <p v-if="!isAuthenticated" class="vmodal__empty-sub">
                💡 Modo invitado: se guardarán en este navegador. <button type="button" class="vmodal__inline-auth-btn" @click="openPanel('login')">Inicia sesión</button> para sincronizarlos en la nube y BD.
              </p>
              <button
                type="button"
                class="btn-primary-action"
                @click="activeTab = 'explore'"
              >
                + Agregar auto
              </button>
            </div>

            <!-- Listado con Tarjetas Idénticas al selector de modelos -->
            <div v-else class="vmodal__saved-content">
              <div class="vmodal__saved-header">
                <div class="vmodal__saved-title-wrap">
                  <span class="vmodal__saved-label">Vehículos en tu garaje</span>
                  <span class="vmodal__saved-badge">{{ favorites.length }} {{ favorites.length === 1 ? 'guardado' : 'guardados' }}</span>

                  <!-- El estado se lee de los datos (¿tiene fila en la BD?), no
                       de "hay sesión": con sesión el guardado puede fallar. -->
                  <span v-if="storage === 'db'" class="vmodal__sync-tag vmodal__sync-tag--cloud" title="Guardado en tu cuenta y sincronizado en base de datos">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="vmodal__sync-icon">
                      <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/>
                    </svg>
                    <span>Guardado en BD</span>
                  </span>
                  <span
                    v-else-if="storage === 'mixed'"
                    class="vmodal__sync-tag vmodal__sync-tag--local"
                    title="Algunos autos no llegaron a tu cuenta y siguen solo en este navegador"
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="vmodal__sync-icon">
                      <path d="M12 9v4M12 17h.01M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                    </svg>
                    <span>Algunos solo en este navegador</span>
                  </span>
                  <button
                    v-else-if="isAuthenticated"
                    type="button"
                    class="vmodal__sync-tag vmodal__sync-tag--local"
                    title="No pudimos guardarlos en tu cuenta: siguen en este navegador. Haz clic para reintentar"
                    @click="retrySync"
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="vmodal__sync-icon">
                      <path d="M21 12a9 9 0 1 1-3.5-7.1M21 3v6h-6"/>
                    </svg>
                    <span>Sin guardar en BD · Reintentar</span>
                  </button>
                  <button
                    v-else
                    type="button"
                    class="vmodal__sync-tag vmodal__sync-tag--local"
                    title="Guardado localmente en este navegador. Haz clic para iniciar sesión y sincronizar en base de datos"
                    @click="openPanel('login')"
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="vmodal__sync-icon">
                      <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                      <line x1="8" y1="21" x2="16" y2="21"/>
                      <line x1="12" y1="17" x2="12" y2="21"/>
                    </svg>
                    <span>Local (Inicia sesión para BD)</span>
                  </button>
                </div>
                <button
                  type="button"
                  class="btn-add-vehicle"
                  @click="activeTab = 'explore'"
                >
                  <span class="btn-add-vehicle__plus">+</span>
                  <span>Agregar otro auto</span>
                </button>
              </div>

              <!-- Grid de Tarjetas (Formato unificado) -->
              <div class="vexplore-grid">
                <div
                  v-for="fav in filteredFavorites"
                  :key="fav.id ?? (fav.brandId + fav.modelId + fav.motorId)"
                  class="vexplore-card vexplore-card--saved"
                  :class="{ 'vexplore-card--active-filter': isApplied(fav) }"
                  role="button"
                  tabindex="0"
                  @click="applyFavorite(fav)"
                >
                  <!-- Header: Brand tag & Delete Heart -->
                  <div class="vexplore-card__header">
                    <div class="vexplore-card__brand-tag">
                      <img
                        v-if="brandLogoFor(fav.brandName)"
                        :src="brandLogoFor(fav.brandName)!"
                        :alt="fav.brandName"
                        class="vexplore-card__brand-tag-thumb"
                      />
                      <span class="vexplore-card__brand-tag-name">{{ fav.brandName }}</span>
                    </div>

                    <button
                      type="button"
                      class="vexplore-card__heart-btn vexplore-card__heart-btn--active"
                      title="Quitar de mis autos"
                      aria-label="Quitar de mis autos"
                      @click.stop="removeFavorite($event, fav)"
                    >
                      <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                      </svg>
                    </button>
                  </div>

                  <!-- Visual Hero -->
                  <div class="vexplore-card__visual">
                    <img
                      v-if="fav.modelImageUrl"
                      :src="fav.modelImageUrl"
                      :alt="fav.modelName"
                      class="vexplore-card__model-img"
                    />
                    <img
                      v-else-if="brandLogoFor(fav.brandName)"
                      :src="brandLogoFor(fav.brandName)!"
                      :alt="fav.brandName"
                      class="vexplore-card__brand-logo"
                    />
                    <div v-else-if="fav.motorName && !fav.modelName" class="vexplore-card__motor-art">
                      <span class="vexplore-card__gear-icon">⚙️</span>
                    </div>
                    <svg v-else class="vexplore-card__car-art" viewBox="0 0 160 60" fill="currentColor">
                      <path d="M148 40c-2 0-3.8 1.2-4.5 3-.9 2.5-3.5 4.2-6.5 4.2-3.8 0-7-3.1-7-7s3.1-7 7-7c1.5 0 3 .5 4.1 1.4.6.5 1.5.4 2-.2l2.8-3.2c.4-.5.4-1.3-.1-1.7C142 26 136 23.5 129 23.5h-15L99 9.5H45l-10 14H15c-5.5 0-10 4.5-10 10v11c0 1.4 1.1 2.5 2.5 2.5h11c.6 4.4 4.4 7.8 9.5 7.8s8.9-3.4 9.5-7.8h58c.6 4.4 4.4 7.8 9.5 7.8s8.9-3.4 9.5-7.8h14c1.4 0 2.5-1.1 2.5-2.5v-2.5c0-1.4-1.1-2.5-2.5-2.5zM27 52c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5zm58-30H50l8-9h27v9zm10 0V13h19l8.5 9H95zm32 30c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5z"/>
                    </svg>
                  </div>

                  <!-- Footer / Titulo / Accion -->
                  <div class="vexplore-card__footer">
                    <h4 class="vexplore-card__title">
                      {{ fav.modelName || (fav.motorName ? `Motor ${fav.motorName}` : 'Toda la marca') }}
                    </h4>
                    <p class="vexplore-card__subtitle">{{ fav.brandName }}</p>
                    <div class="vexplore-card__badge-row">
                      <span v-if="isApplied(fav)" class="vexplore-pill vexplore-pill--applied">
                        ● Filtro activo
                      </span>
                      <span v-else class="vexplore-pill vexplore-pill--action">
                        Ver repuestos →
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <!-- ════════ PESTAÑA: EXPLORAR Y AGREGAR (2 COLUMNAS) ════════ -->
          <section v-else-if="activeTab === 'explore'" class="vmodal__explore-view">
            <!-- Columna Izquierda: Marcas -->
            <aside class="vmodal__col-brands">
              <div class="vmodal__search-wrap">
                <input
                  v-model="brandSearch"
                  type="text"
                  class="vmodal__search-field"
                  placeholder="Buscar marca..."
                  aria-label="Buscar marca del vehículo"
                />
              </div>

              <div class="vmodal__brands-scroll">
                <button
                  v-for="b in filteredBrands"
                  :key="b.id"
                  type="button"
                  class="vbrand-item"
                  :class="{ 'vbrand-item--active': selectedBrandId === b.id }"
                  @click="selectBrand(b)"
                >
                  <div class="vbrand-item__icon-wrap">
                    <img v-if="b.logo_url" :src="b.logo_url" :alt="b.name" class="vbrand-item__logo" />
                    <span v-else class="vbrand-item__initials">{{ b.name.slice(0, 2).toUpperCase() }}</span>
                  </div>
                  <span class="vbrand-item__name">{{ b.name }}</span>
                  <span class="vbrand-item__count">({{ getBrandCount(b) }})</span>
                </button>
                <p v-if="!filteredBrands.length" class="vmodal__empty-search">
                  No se encontró "{{ brandSearch }}"
                </p>
              </div>
            </aside>

            <!-- Columna Derecha: Modelos y Motores -->
            <main class="vmodal__col-models">
              <div class="vmodal__models-toolbar">
                <input
                  v-model="modelSearch"
                  type="text"
                  class="vmodal__search-field vmodal__search-field--full"
                  :placeholder="`Buscar modelos o motores de ${selectedBrand?.name || 'la marca'}...`"
                  aria-label="Buscar modelo de vehículo"
                />
              </div>

              <div v-if="loadingModels" class="vmodal__state-box">
                <p>Cargando catálogo de {{ selectedBrand?.name }}…</p>
              </div>

              <div v-else-if="!filteredModels.length && !filteredMotors.length" class="vmodal__state-box">
                <p class="vmodal__state-title">{{ selectedBrand?.name }}</p>
                <p class="vmodal__state-sub">No hay modelos específicos cargados para esta marca.</p>
                <button
                  v-if="selectedBrand && brandOnlyCandidate()"
                  type="button"
                  class="btn-primary-action btn-primary-action--sm"
                  @click="saveVehicle(brandOnlyCandidate()!)"
                >
                  {{
                    isFavorite(brandOnlyCandidate()!)
                      ? `✓ ${selectedBrand.name} guardada en mis autos`
                      : `+ Guardar toda la marca ${selectedBrand.name}`
                  }}
                </button>
              </div>

              <div v-else class="vexplore-grid">
                <!-- Tarjeta "Toda la marca" -->
                <div
                  v-if="selectedBrand && brandOnlyCandidate()"
                  class="vexplore-card vexplore-card--brand-all"
                  :class="{ 'vexplore-card--saved': isFavorite(brandOnlyCandidate()!) }"
                  role="button"
                  tabindex="0"
                  @click="saveVehicle(brandOnlyCandidate()!)"
                >
                  <div class="vexplore-card__header">
                    <div class="vexplore-card__brand-tag">
                      <span class="vexplore-card__brand-tag-name">{{ selectedBrand.name }}</span>
                    </div>

                    <button
                      type="button"
                      class="vexplore-card__heart-btn"
                      :class="{ 'vexplore-card__heart-btn--active': isFavorite(brandOnlyCandidate()!) }"
                      :title="isFavorite(brandOnlyCandidate()!) ? 'Quitar de mis autos' : 'Guardar en mis autos'"
                      @click.stop="saveVehicle(brandOnlyCandidate()!)"
                    >
                      <svg viewBox="0 0 24 24" :fill="isFavorite(brandOnlyCandidate()!) ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                      </svg>
                    </button>
                  </div>

                  <div class="vexplore-card__visual">
                    <img
                      v-if="selectedBrand.logo_url"
                      :src="selectedBrand.logo_url"
                      :alt="selectedBrand.name"
                      class="vexplore-card__brand-logo"
                    />
                    <span v-else class="vexplore-card__brand-initials">
                      {{ selectedBrand.name.slice(0, 2).toUpperCase() }}
                    </span>
                  </div>

                  <div class="vexplore-card__footer">
                    <h4 class="vexplore-card__title">{{ selectedBrand.name }}</h4>
                    <p class="vexplore-card__subtitle">Cualquier modelo</p>
                    <div class="vexplore-card__badge-row">
                      <span class="vexplore-pill" :class="{ 'vexplore-pill--saved': isFavorite(brandOnlyCandidate()!) }">
                        {{ isFavorite(brandOnlyCandidate()!) ? '✓ Guardado' : '+ Guardar' }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Tarjetas de Modelos -->
                <div
                  v-for="model in filteredModels"
                  :key="model.id"
                  class="vexplore-card"
                  :class="{ 'vexplore-card--saved': isFavorite(modelCandidate(model)) }"
                  role="button"
                  tabindex="0"
                  @click="saveVehicle(modelCandidate(model))"
                >
                  <div class="vexplore-card__header">
                    <div class="vexplore-card__brand-tag">
                      <img
                        v-if="selectedBrand?.logo_url"
                        :src="selectedBrand.logo_url"
                        :alt="selectedBrand.name"
                        class="vexplore-card__brand-tag-thumb"
                      />
                      <span class="vexplore-card__brand-tag-name">{{ selectedBrand?.name }}</span>
                    </div>

                    <button
                      type="button"
                      class="vexplore-card__heart-btn"
                      :class="{ 'vexplore-card__heart-btn--active': isFavorite(modelCandidate(model)) }"
                      :title="isFavorite(modelCandidate(model)) ? 'Quitar de mis autos' : 'Guardar en mis autos'"
                      @click.stop="saveVehicle(modelCandidate(model))"
                    >
                      <svg viewBox="0 0 24 24" :fill="isFavorite(modelCandidate(model)) ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                      </svg>
                    </button>
                  </div>

                  <div class="vexplore-card__visual">
                    <img
                      v-if="model.image_url"
                      :src="model.image_url"
                      :alt="model.name"
                      class="vexplore-card__model-img"
                    />
                    <img
                      v-else-if="selectedBrand?.logo_url"
                      :src="selectedBrand.logo_url"
                      :alt="selectedBrand.name"
                      class="vexplore-card__brand-logo"
                    />
                    <svg v-else class="vexplore-card__car-art" viewBox="0 0 160 60" fill="currentColor">
                      <path d="M148 40c-2 0-3.8 1.2-4.5 3-.9 2.5-3.5 4.2-6.5 4.2-3.8 0-7-3.1-7-7s3.1-7 7-7c1.5 0 3 .5 4.1 1.4.6.5 1.5.4 2-.2l2.8-3.2c.4-.5.4-1.3-.1-1.7C142 26 136 23.5 129 23.5h-15L99 9.5H45l-10 14H15c-5.5 0-10 4.5-10 10v11c0 1.4 1.1 2.5 2.5 2.5h11c.6 4.4 4.4 7.8 9.5 7.8s8.9-3.4 9.5-7.8h58c.6 4.4 4.4 7.8 9.5 7.8s8.9-3.4 9.5-7.8h14c1.4 0 2.5-1.1 2.5-2.5v-2.5c0-1.4-1.1-2.5-2.5-2.5zM27 52c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5zm58-30H50l8-9h27v9zm10 0V13h19l8.5 9H95zm32 30c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5z"/>
                    </svg>
                  </div>

                  <div class="vexplore-card__footer">
                    <h4 class="vexplore-card__title">{{ model.name }}</h4>
                    <p class="vexplore-card__subtitle">{{ selectedBrand?.name }}</p>
                    <div class="vexplore-card__badge-row">
                      <span class="vexplore-pill" :class="{ 'vexplore-pill--saved': isFavorite(modelCandidate(model)) }">
                        {{ isFavorite(modelCandidate(model)) ? '✓ Guardado' : '+ Guardar' }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Tarjetas de Motores -->
                <div
                  v-for="motor in filteredMotors"
                  :key="motor.id"
                  class="vexplore-card vexplore-card--motor"
                  :class="{ 'vexplore-card--saved': isFavorite(motorCandidate(motor)) }"
                  role="button"
                  tabindex="0"
                  @click="saveVehicle(motorCandidate(motor))"
                >
                  <div class="vexplore-card__header">
                    <div class="vexplore-card__brand-tag">
                      <img
                        v-if="selectedBrand?.logo_url"
                        :src="selectedBrand.logo_url"
                        :alt="selectedBrand.name"
                        class="vexplore-card__brand-tag-thumb"
                      />
                      <span class="vexplore-card__brand-tag-name">{{ selectedBrand?.name }}</span>
                    </div>

                    <button
                      type="button"
                      class="vexplore-card__heart-btn"
                      :class="{ 'vexplore-card__heart-btn--active': isFavorite(motorCandidate(motor)) }"
                      :title="isFavorite(motorCandidate(motor)) ? 'Quitar de mis autos' : 'Guardar en mis autos'"
                      @click.stop="saveVehicle(motorCandidate(motor))"
                    >
                      <svg viewBox="0 0 24 24" :fill="isFavorite(motorCandidate(motor)) ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                      </svg>
                    </button>
                  </div>

                  <div class="vexplore-card__visual">
                    <img
                      v-if="selectedBrand?.logo_url"
                      :src="selectedBrand.logo_url"
                      :alt="selectedBrand.name"
                      class="vexplore-card__brand-logo"
                    />
                    <div v-else class="vexplore-card__motor-art">
                      <span class="vexplore-card__gear-icon">⚙️</span>
                    </div>
                  </div>

                  <div class="vexplore-card__footer">
                    <h4 class="vexplore-card__title">{{ motor.name }}</h4>
                    <p class="vexplore-card__subtitle">Motor · {{ selectedBrand?.name }}</p>
                    <div class="vexplore-card__badge-row">
                      <span class="vexplore-pill" :class="{ 'vexplore-pill--saved': isFavorite(motorCandidate(motor)) }">
                        {{ isFavorite(motorCandidate(motor)) ? '✓ Guardado' : '+ Guardar' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </main>
          </section>
        </div>

        <!-- Footer -->
        <footer class="vmodal__foot">
          <!-- El guardado puede fallar con sesión activa (RLS, red): se dice. -->
          <p v-if="error" class="vmodal__foot-error" role="alert">{{ error }}</p>
          <button type="button" class="btn-close-modal" @click="close">
            Cerrar
          </button>
        </footer>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
/* ── Backdrop ─────────────────────────────────────────────────────────────── */
.vmodal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(4, 7, 12, 0.82);
  backdrop-filter: blur(8px);
  z-index: 9999;
  display: grid;
  place-items: center;
  padding: var(--space-4);
  animation: modalFade 0.16s ease;
}

@keyframes modalFade {
  from { opacity: 0; }
  to   { opacity: 1; }
}

/* ── Ventana Principal ────────────────────────────────────────────────────── */
.vmodal {
  width: 100%;
  max-width: 980px;
  max-height: 88vh;
  background: #0f141c;
  color: var(--cream);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.7), 0 0 0 1px rgba(26, 61, 110, 0.2);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: modalPop 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes modalPop {
  from { transform: scale(0.96) translateY(8px); opacity: 0; }
  to   { transform: scale(1) translateY(0);       opacity: 1; }
}

/* ── Header ───────────────────────────────────────────────────────────────── */
.vmodal__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 24px 14px;
  background: #141b26;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  flex-shrink: 0;
}

.vmodal__head-main {
  display: flex;
  align-items: center;
  gap: 14px;
}

.vmodal__badge-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--blue-2), var(--blue));
  color: #fff;
  display: grid;
  place-items: center;
  flex-shrink: 0;
  box-shadow: 0 4px 16px rgba(26, 61, 110, 0.4);
}

.vmodal__badge-icon svg {
  width: 22px;
  height: 22px;
}

.vmodal__title {
  font-family: var(--font-display);
  font-size: 1.25rem;
  font-weight: 800;
  color: #f8fafc;
  letter-spacing: -0.01em;
  line-height: 1.2;
}

.vmodal__subtitle {
  font-size: 0.8rem;
  color: #94a3b8;
  margin-top: 2px;
}

.vmodal__close {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.04);
  color: #94a3b8;
  cursor: pointer;
  display: grid;
  place-items: center;
  transition: all 0.15s ease;
  flex-shrink: 0;
}

.vmodal__close:hover {
  background: rgba(239, 68, 68, 0.15);
  border-color: rgba(239, 68, 68, 0.4);
  color: #ef4444;
}

.vmodal__close svg {
  width: 16px;
  height: 16px;
}

.vmodal__head-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.vmodal__back-btn {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: var(--blue-2);
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: all 0.15s ease;
  flex-shrink: 0;
}

.vmodal__back-btn:hover {
  background: rgba(26, 61, 110, 0.2);
  border-color: var(--blue-2);
  color: #fff;
  transform: translateX(-2px);
}

.vmodal__back-btn svg {
  width: 20px;
  height: 20px;
}

/* ── Main Body ────────────────────────────────────────────────────────────── */
.vmodal__body {
  flex: 1;
  min-height: 440px;
  max-height: 62vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: #0b0f17;
}

/* ══════════════════════════════════════════════════════════════════════════════
   PESTAÑA: MIS AUTOS GUARDADOS (GARAJE)
   ══════════════════════════════════════════════════════════════════════════════ */
.vmodal__saved-view {
  flex: 1;
  overflow-y: auto;
  padding: 22px 26px;
  display: flex;
  flex-direction: column;
}

.vmodal__saved-view::-webkit-scrollbar { width: 5px; }
.vmodal__saved-view::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.15); border-radius: 4px; }

.vmodal__saved-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.vmodal__saved-title-wrap {
  display: flex;
  align-items: center;
  gap: 10px;
}

.vmodal__saved-label {
  font-size: 1.05rem;
  font-weight: 800;
  color: #f8fafc;
  letter-spacing: -0.01em;
}

.vmodal__saved-badge {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--blue-2);
  background: var(--blue-dim);
  border: 1px solid var(--blue);
  padding: 2px 8px;
  border-radius: 999px;
}

.btn-add-vehicle {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 7px 16px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #f8fafc;
  font-size: 0.82rem;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s ease;
}

.btn-add-vehicle:hover {
  background: rgba(26, 61, 110, 0.15);
  border-color: var(--blue-2);
  color: var(--blue-2);
  transform: translateY(-1px);
}

.btn-add-vehicle__plus {
  font-size: 1rem;
  line-height: 1;
}

/* ══════════════════════════════════════════════════════════════════════════════
   PESTAÑA: EXPLORAR Y AGREGAR (2 COLUMNAS)
   ══════════════════════════════════════════════════════════════════════════════ */
.vmodal__explore-view {
  flex: 1;
  display: grid;
  grid-template-columns: 240px 1fr;
  overflow: hidden;
}

/* Columna Izquierda: Marcas */
.vmodal__col-brands {
  border-right: 1px solid rgba(255, 255, 255, 0.07);
  display: flex;
  flex-direction: column;
  background: #111722;
  overflow: hidden;
}

.vmodal__search-wrap {
  padding: 14px 14px 10px;
  flex-shrink: 0;
}

.vmodal__search-field {
  width: 100%;
  height: 38px;
  background: #0b0f17;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 0 12px;
  font-size: 0.84rem;
  color: #f8fafc;
  font-family: inherit;
  outline: none;
  transition: all 0.15s ease;
}

.vmodal__search-field:focus {
  border-color: var(--blue-2);
  box-shadow: 0 0 0 2px rgba(26, 61, 110, 0.3);
}

.vmodal__search-field::placeholder {
  color: #64748b;
}

.vmodal__search-field--full {
  width: 100%;
}

.vmodal__brands-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 6px 10px 14px;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.vmodal__brands-scroll::-webkit-scrollbar { width: 4px; }
.vmodal__brands-scroll::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.15); border-radius: 4px; }

.vbrand-item {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 8px 10px;
  border-radius: 10px;
  border: 1px solid transparent;
  background: transparent;
  color: #94a3b8;
  font-size: 0.85rem;
  font-weight: 700;
  font-family: inherit;
  text-align: left;
  cursor: pointer;
  transition: all 0.14s ease;
}

.vbrand-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #f8fafc;
}

.vbrand-item--active {
  background: var(--blue) !important;
  color: #ffffff !important;
  box-shadow: 0 3px 12px rgba(26, 61, 110, 0.35);
}

.vbrand-item--active .vbrand-item__count {
  color: rgba(255, 255, 255, 0.75);
}

.vbrand-item__icon-wrap {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #ffffff;
  display: grid;
  place-items: center;
  overflow: hidden;
  flex-shrink: 0;
  padding: 2px;
}

.vbrand-item__logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.vbrand-item__initials {
  font-size: 0.62rem;
  font-weight: 800;
  color: #0f172a;
}

.vbrand-item__name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.vbrand-item__count {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
}

/* Columna Derecha: Modelos y Motores */
.vmodal__col-models {
  display: flex;
  flex-direction: column;
  background: #0b0f17;
  overflow: hidden;
}

.vmodal__models-toolbar {
  padding: 14px 20px 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
}

/* ══════════════════════════════════════════════════════════════════════════════
   REJILLA Y TARJETAS UNIFICADAS DE MODELOS Y FAVORITOS
   ══════════════════════════════════════════════════════════════════════════════ */
.vexplore-grid {
  padding: 16px 20px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(145px, 1fr));
  gap: 12px;
  overflow-y: auto;
  align-content: start;
}

.vexplore-grid::-webkit-scrollbar { width: 5px; }
.vexplore-grid::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.15); border-radius: 4px; }

/* Tarjetas Unificadas */
.vexplore-card {
  position: relative;
  background: linear-gradient(145deg, rgba(25, 34, 48, 0.75) 0%, rgba(15, 20, 29, 0.9) 100%);
  border: 1px solid rgba(255, 255, 255, 0.09);
  border-radius: 12px;
  padding: 10px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 6px;
  transition: all 0.18s cubic-bezier(0.16, 1, 0.3, 1);
  min-height: 125px;
}

.vexplore-card:hover {
  border-color: var(--blue-2);
  transform: translateY(-2px);
  box-shadow: 0 8px 22px rgba(0, 0, 0, 0.45), 0 0 16px rgba(26, 61, 110, 0.22);
}

.vexplore-card--saved {
  border-color: rgba(239, 68, 68, 0.45) !important;
  background: linear-gradient(145deg, rgba(60, 20, 25, 0.4) 0%, rgba(15, 20, 29, 0.88) 100%) !important;
}

.vexplore-card--active-filter {
  border-color: var(--blue-2) !important;
  box-shadow: 0 0 0 1.5px var(--blue-2), 0 8px 20px rgba(26, 61, 110, 0.3) !important;
}

.vexplore-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
}

.vexplore-card__brand-tag {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  max-width: calc(100% - 26px);
  overflow: hidden;
}

.vexplore-card__brand-tag-thumb {
  width: 14px;
  height: 14px;
  object-fit: contain;
  flex-shrink: 0;
}

.vexplore-card__brand-tag-name {
  font-size: 0.65rem;
  font-weight: 800;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.vexplore-card__heart-btn {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.35);
  color: #64748b;
  cursor: pointer;
  display: grid;
  place-items: center;
  transition: all 0.15s ease;
  z-index: 2;
  padding: 0;
}

.vexplore-card__heart-btn svg {
  width: 13px;
  height: 13px;
}

.vexplore-card__heart-btn:hover {
  color: #ef4444;
  border-color: rgba(239, 68, 68, 0.5);
  background: rgba(239, 68, 68, 0.12);
}

.vexplore-card__heart-btn--active {
  color: #ef4444 !important;
  background: rgba(239, 68, 68, 0.18) !important;
  border-color: rgba(239, 68, 68, 0.5) !important;
}

.vexplore-card__visual {
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-block: 2px;
}

.vexplore-card__car-art {
  width: 70px;
  height: 30px;
  color: var(--blue-2);
  opacity: 0.55;
  transition: opacity 0.15s ease, transform 0.15s ease;
}

.vexplore-card:hover .vexplore-card__car-art {
  opacity: 0.9;
  transform: scale(1.05);
}

.vexplore-card__model-img {
  max-width: 100%;
  max-height: 44px;
  object-fit: contain;
}

.vexplore-card__brand-logo {
  max-height: 36px;
  max-width: 80px;
  object-fit: contain;
  opacity: 0.9;
}

.vexplore-card__brand-initials {
  font-size: 0.95rem;
  font-weight: 800;
  color: var(--blue-2);
}

.vexplore-card__motor-art {
  display: flex;
  align-items: center;
  justify-content: center;
}

.vexplore-card__gear-icon {
  font-size: 1.5rem;
  opacity: 0.85;
}

.vexplore-card__footer {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-top: auto;
}

.vexplore-card__title {
  font-size: 0.85rem;
  font-weight: 800;
  color: #f8fafc;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.2;
}

.vexplore-card__subtitle {
  font-size: 0.68rem;
  color: #64748b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.2;
}

.vexplore-card__badge-row {
  margin-top: 4px;
}

.vexplore-pill {
  display: inline-block;
  font-size: 0.65rem;
  font-weight: 700;
  padding: 2px 7px;
  border-radius: 4px;
  background: var(--blue-dim);
  color: var(--blue-2);
  border: 1px solid var(--blue);
  transition: all 0.15s ease;
}

.vexplore-pill--saved {
  background: rgba(239, 68, 68, 0.15) !important;
  color: #f87171 !important;
  border-color: rgba(239, 68, 68, 0.3) !important;
}

.vexplore-pill--action {
  background: var(--blue-dim) !important;
  color: var(--blue-2) !important;
  border-color: var(--blue) !important;
}

.vexplore-pill--applied {
  background: rgba(34, 197, 94, 0.18) !important;
  color: #4ade80 !important;
  border-color: rgba(34, 197, 94, 0.4) !important;
}

/* ── Generic State & Buttons ──────────────────────────────────────────────── */
.btn-primary-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 22px;
  border-radius: 999px;
  background: linear-gradient(135deg, var(--blue) 0%, var(--blue-2) 100%);
  color: #ffffff;
  font-weight: 700;
  font-size: 0.88rem;
  font-family: inherit;
  cursor: pointer;
  border: none;
  box-shadow: 0 4px 16px rgba(26, 61, 110, 0.4);
  transition: all 0.15s ease;
}

.btn-primary-action:hover {
  background: linear-gradient(135deg, var(--blue-2) 0%, var(--blue) 100%);
  transform: translateY(-1px);
}

.btn-primary-action--sm {
  padding: 6px 14px;
  font-size: 0.78rem;
}

.btn-close-modal {
  height: 38px;
  padding-inline: 26px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #f8fafc;
  font-weight: 700;
  font-size: 0.88rem;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s ease;
}

.btn-close-modal:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.25);
}

/* Empty & Loading States */
.vmodal__empty-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 40px 20px;
  gap: 14px;
}

.vmodal__empty-icon-wrap {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: rgba(26, 61, 110, 0.12);
  color: var(--blue-2);
  display: grid;
  place-items: center;
  box-shadow: 0 0 25px rgba(26, 61, 110, 0.2);
}

.vmodal__empty-icon-wrap svg {
  width: 28px;
  height: 28px;
}

.vmodal__empty-title {
  font-size: 1.15rem;
  font-weight: 800;
  color: #f8fafc;
}

.vmodal__empty-text {
  font-size: 0.85rem;
  color: #94a3b8;
  max-width: 380px;
  line-height: 1.5;
}

.vmodal__state-box {
  padding: 40px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 10px;
  color: #94a3b8;
}

.vmodal__state-title {
  font-size: 1.1rem;
  font-weight: 800;
  color: #f8fafc;
}

.vmodal__state-sub {
  font-size: 0.82rem;
  color: #64748b;
}

.vmodal__empty-search {
  padding: 14px 10px;
  color: #64748b;
  font-size: 0.8rem;
  text-align: center;
}

/* ── Footer ───────────────────────────────────────────────────────────────── */
.vmodal__foot {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 14px;
  padding: 14px 24px;
  border-top: 1px solid rgba(255, 255, 255, 0.07);
  background: #141b26;
  flex-shrink: 0;
}

/* Empuja el botón Cerrar a su sitio sin tocar el layout cuando no hay error. */
.vmodal__foot-error {
  margin-right: auto;
  font-size: 0.78rem;
  line-height: 1.35;
  color: #fca5a5;
}

/* ── Sync status indicator ────────────────────────────────────────────────── */
.vmodal__sync-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.74rem;
  font-weight: 500;
  padding: 3px 10px;
  border-radius: 9999px;
  text-decoration: none;
  border: 1px solid transparent;
  transition: all 0.2s ease;
}

.vmodal__sync-icon {
  width: 13px;
  height: 13px;
  flex-shrink: 0;
}

.vmodal__sync-tag--cloud {
  background: rgba(16, 185, 129, 0.12);
  color: #34d399;
  border-color: rgba(16, 185, 129, 0.28);
}

.vmodal__sync-tag--local {
  background: rgba(245, 158, 11, 0.1);
  color: #fbbf24;
  border-color: rgba(245, 158, 11, 0.25);
  cursor: pointer;
  font-family: inherit;
}

.vmodal__sync-tag--local:hover {
  background: rgba(245, 158, 11, 0.2);
  border-color: rgba(245, 158, 11, 0.45);
  color: #fef08a;
  transform: translateY(-1px);
}

.vmodal__empty-sub {
  font-size: 0.8rem;
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.03);
  border: 1px dashed rgba(255, 255, 255, 0.12);
  padding: 10px 14px;
  border-radius: 8px;
  max-width: 380px;
  line-height: 1.4;
  margin: 0;
}

.vmodal__inline-auth-btn {
  background: none;
  border: none;
  padding: 0;
  color: var(--blue-2);
  font-weight: 600;
  font-size: inherit;
  font-family: inherit;
  cursor: pointer;
  text-decoration: underline;
}

.vmodal__inline-auth-btn:hover {
  color: var(--blue-2);
}

/* ── Responsive ───────────────────────────────────────────────────────────── */
@media (max-width: 720px) {
  .vmodal__explore-view {
    grid-template-columns: 1fr;
    grid-template-rows: auto 1fr;
  }
  .vmodal__col-brands {
    border-right: none;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    max-height: 170px;
  }
  .vexplore-grid {
    grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  }
}

/* Teléfono: la ventana pasa a hoja casi a pantalla completa y las cabeceras
   internas dejan de forzar una sola fila (se apilan / envuelven). */
@media (max-width: 560px) {
  .vmodal-backdrop {
    padding: var(--space-2);
  }
  .vmodal {
    max-width: 100%;
    max-height: 94vh;
    border-radius: 16px;
  }
  .vmodal__body {
    min-height: 0;
    max-height: none;
    flex: 1;
  }

  .vmodal__head {
    padding: 14px 16px 12px;
  }
  .vmodal__head-main {
    gap: 10px;
  }
  .vmodal__badge-icon,
  .vmodal__back-btn {
    width: 34px;
    height: 34px;
  }
  .vmodal__title {
    font-size: 1.05rem;
  }
  .vmodal__subtitle {
    font-size: 0.74rem;
  }
  /* El botón de texto "← Mis autos" duplica la flecha de volver: sobra en móvil. */
  .vmodal__head-actions .btn-add-vehicle {
    display: none;
  }

  .vmodal__saved-view {
    padding: 16px;
  }
  .vmodal__saved-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  .vmodal__saved-title-wrap {
    flex-wrap: wrap;
  }
  .vmodal__saved-header .btn-add-vehicle {
    width: 100%;
    justify-content: center;
  }

  .vexplore-grid {
    padding: 14px;
    gap: 10px;
  }
  .vmodal__models-toolbar {
    padding: 12px 14px 8px;
  }
}
</style>
