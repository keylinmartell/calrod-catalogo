<script setup lang="ts">
import { computed, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { useFilters } from '@/composables/useFilters'
import { useParts } from '@/composables/useParts'
import { useFavoriteVehicles } from '@/composables/useFavoriteVehicles'
import { useAuthPanel } from '@/composables/useAuthPanel'
import { useAuthStore } from '@/stores/authStore'
import { useNotification } from '@/composables/useNotification'
import VehicleSelectorModal from '@/components/catalog/VehicleSelectorModal.vue'
import {
  favoriteVehicleKey,
  favoriteVehicleLabel,
  type FavoriteVehicle,
  type VehicleBrand,
  type VehicleModel,
  type VehicleMotor,
} from '@/types/part'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const store = useCatalogStore()
const { vehicleBrands } = storeToRefs(store)
const { vehicleBrand, vehicleModel, motor, setVehicleFilter } = useFilters()
const { fetchVehicleModels, fetchVehicleMotors } = useParts()
const { favorites, error, ensureLoaded, isFavorite, toggle, remove } =
  useFavoriteVehicles()
const { openPanel } = useAuthPanel()
const { showAuthAlert } = useNotification()
const auth = useAuthStore()

ensureLoaded()

const modalOpen = ref(false)
const open = ref(false)
const brandSearch = ref('')
const pickedBrand = ref<VehicleBrand | null>(null)
const models = ref<VehicleModel[]>([])
const motors = ref<VehicleMotor[]>([])
const childLoading = ref(false)
const childError = ref<string | null>(null)

const filteredBrands = computed(() => {
  const q = brandSearch.value.trim().toLowerCase()
  if (!q) return vehicleBrands.value
  return vehicleBrands.value.filter((b) => b.name.toLowerCase().includes(q))
})

/** Qué se ofrece en el segundo paso: modelos si la marca tiene, si no motores. */
const childKind = computed<'model' | 'motor' | 'none'>(() =>
  models.value.length ? 'model' : motors.value.length ? 'motor' : 'none',
)

function resetPicker() {
  pickedBrand.value = null
  brandSearch.value = ''
  models.value = []
  motors.value = []
  childError.value = null
}

function togglePicker() {
  open.value = !open.value
  if (!open.value) resetPicker()
  else if (!vehicleBrands.value.length) void store.loadVehicleBrands()
}

async function pickBrand(b: VehicleBrand) {
  pickedBrand.value = b
  childLoading.value = true
  childError.value = null
  try {
    const [ms, mos] = await Promise.all([
      fetchVehicleModels(b.id),
      fetchVehicleMotors(b.id),
    ])
    models.value = ms
    motors.value = mos
  } catch (e) {
    childError.value = 'No pudimos cargar los modelos de esta marca.'
    console.error('[CalRod] favoritos pickBrand:', e)
  } finally {
    childLoading.value = false
  }
}

/** Candidato "toda la marca": el favorito más amplio, sin modelo ni motor. */
const brandOnly = computed(() => {
  const b = pickedBrand.value
  if (!b) return null
  return {
    brandId: b.id,
    brandName: b.name,
    modelId: null,
    modelName: '',
    modelImageUrl: null,
    motorId: null,
    motorName: '',
  }
})

function modelCandidate(m: VehicleModel) {
  return {
    brandId: pickedBrand.value?.id ?? '',
    brandName: pickedBrand.value?.name ?? '',
    modelId: m.id,
    modelName: m.name,
    modelImageUrl: m.image_url ?? null,
    motorId: null,
    motorName: '',
  }
}

function motorCandidate(mo: VehicleMotor) {
  return {
    brandId: pickedBrand.value?.id ?? '',
    brandName: pickedBrand.value?.name ?? '',
    modelId: null,
    modelName: '',
    modelImageUrl: null,
    motorId: mo.id,
    motorName: mo.name,
  }
}

/** ¿Este favorito es exactamente el filtro aplicado ahora mismo? */
function isApplied(f: FavoriteVehicle): boolean {
  const eq = (a: string, b: string) =>
    a.trim().toLowerCase() === b.trim().toLowerCase()
  return (
    !!f.brandName &&
    eq(vehicleBrand.value, f.brandName) &&
    eq(vehicleModel.value, f.modelName) &&
    eq(motor.value, f.motorName)
  )
}

/** Un clic aplica el auto como filtro; el segundo lo levanta. */
function applyFavorite(f: FavoriteVehicle) {
  if (isApplied(f)) setVehicleFilter({ brand: '', model: '', motor: '' })
  else setVehicleFilter({ brand: f.brandName, model: f.modelName, motor: f.motorName })
}

async function onMark(e: Event, candidate: Omit<FavoriteVehicle, 'id'>) {
  if (!auth.isAuthenticated) {
    const el = e.target as HTMLInputElement | null
    if (el) el.checked = false
    showAuthAlert('Debes iniciar sesión para agregar vehículos a tus favoritos.')
    return
  }
  await toggle(candidate)
  const el = e.target as HTMLInputElement | null
  if (el) el.checked = isFavorite(candidate)
}
</script>

<template>
  <section class="favs" aria-label="Mis autos favoritos">
    <!-- Botón principal "Mis autos favoritos" estilo tarjeta/selector -->
    <button
      type="button"
      class="favs__hero-btn"
      @click="modalOpen = true"
    >
      <div class="favs__car-icon">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.85 7h10.29l1.04 3H5.81l1.04-3zM19 17H5v-4.66l.12-.34h13.77l.11.34V17z"/>
          <circle cx="7.5" cy="14.5" r="1.5"/>
          <circle cx="16.5" cy="14.5" r="1.5"/>
        </svg>
      </div>
      <div class="favs__hero-text">
        <span class="favs__hero-title">Mis autos favoritos</span>
        <span class="favs__hero-sub">Busca piezas por tu auto</span>
      </div>
      <svg class="favs__hero-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M9 18l6-6-6-6" />
      </svg>
    </button>

    <!-- Modal "Busca los repuestos para tu auto" -->
    <VehicleSelectorModal v-model:open="modalOpen" />

    <div class="favs__header">
      <h3 class="favs__title">Autos guardados</h3>
      <span v-if="favorites.length" class="favs__count mono">
        {{ favorites.length }}
      </span>
    </div>

    <!-- La barra: abre y cierra el selector rápido de marca → modelo/motor. -->
    <button
      type="button"
      class="favs__bar"
      :class="{ 'favs__bar--open': open }"
      :aria-expanded="open"
      @click="togglePicker"
    >
      <svg class="favs__bar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M12 20s-7-4.6-7-9.4A3.9 3.9 0 0 1 12 8a3.9 3.9 0 0 1 7 2.6C19 15.4 12 20 12 20Z" />
      </svg>
      <span class="favs__bar-text">Añadir rápido</span>
      <svg
        class="favs__bar-chevron"
        :class="{ 'favs__bar-chevron--up': open }"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
      >
        <path d="M6 9l6 6 6-6" />
      </svg>
    </button>

    <!-- Paso 1: marcas del nomenclador -->
    <div v-if="open && !pickedBrand" class="favs__picker">
      <div class="favs__search">
        <input
          v-model="brandSearch"
          type="text"
          class="favs__search-input"
          placeholder="Buscar marca..."
          aria-label="Buscar marca de auto"
        />
        <svg class="favs__search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </div>

      <div class="favs__list">
        <button
          v-for="b in filteredBrands"
          :key="b.id"
          type="button"
          class="favs__brand"
          @click="pickBrand(b)"
        >
          <span class="favs__brand-name">{{ b.name }}</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 6l6 6-6 6" />
          </svg>
        </button>
        <p v-if="!filteredBrands.length" class="favs__empty">
          {{ brandSearch ? `No se encontró "${brandSearch}"` : 'No hay marcas registradas todavía.' }}
        </p>
      </div>
    </div>

    <!-- Paso 2: los modelos de la marca; si no tiene, sus motores -->
    <div v-else-if="open && pickedBrand" class="favs__picker">
      <button type="button" class="favs__back" @click="resetPicker">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 6l-6 6 6 6" />
        </svg>
        {{ pickedBrand.name }}
      </button>

      <p v-if="childLoading" class="favs__empty">
        <GearSpinner :size="24" />
        <span>Cargando…</span>
      </p>
      <p v-else-if="childError" class="favs__error">{{ childError }}</p>
      <template v-else>
        <p class="favs__hint">
          <template v-if="childKind === 'model'">Marca los modelos que quieras guardar.</template>
          <template v-else-if="childKind === 'motor'">
            Esta marca se trabaja por motor: marca los que quieras guardar.
          </template>
          <template v-else>
            Esta marca no tiene modelos ni motores registrados: puedes guardarla
            completa.
          </template>
        </p>

        <div class="favs__list">
          <!-- Siempre disponible: el auto "cualquier modelo de esta marca". -->
          <label
            v-if="brandOnly"
            class="favs__check"
            :class="{ 'favs__check--on': isFavorite(brandOnly) }"
          >
            <input
              type="checkbox"
              class="favs__box"
              :checked="isFavorite(brandOnly)"
              @change="onMark($event, brandOnly)"
            />
            <span class="favs__check-name">Toda la marca ({{ pickedBrand.name }})</span>
          </label>

          <template v-if="childKind === 'model'">
            <label
              v-for="m in models"
              :key="m.id"
              class="favs__check"
              :class="{ 'favs__check--on': isFavorite(modelCandidate(m)) }"
            >
              <input
                type="checkbox"
                class="favs__box"
                :checked="isFavorite(modelCandidate(m))"
                @change="onMark($event, modelCandidate(m))"
              />
              <span class="favs__check-name">{{ m.name }}</span>
            </label>
          </template>

          <template v-else-if="childKind === 'motor'">
            <label
              v-for="mo in motors"
              :key="mo.id"
              class="favs__check"
              :class="{ 'favs__check--on': isFavorite(motorCandidate(mo)) }"
            >
              <input
                type="checkbox"
                class="favs__box"
                :checked="isFavorite(motorCandidate(mo))"
                @change="onMark($event, motorCandidate(mo))"
              />
              <span class="favs__check-name">{{ mo.name }}</span>
            </label>
          </template>

        </div>
      </template>
    </div>

    <!-- Autos guardados: marcar la casilla filtra el catálogo con ese auto. -->
    <p v-if="!favorites.length" class="favs__empty">
      <template v-if="auth.isAuthenticated">
        Aún no has guardado autos. Márcalos y filtra el catálogo con un clic.
      </template>
      <template v-else>
        <button type="button" class="favs__link" @click="openPanel('login')">Inicia sesión</button> para guardar tus autos favoritos en tu garaje.
      </template>
    </p>
    <ul v-else class="favs__saved">
      <li
        v-for="f in favorites"
        :key="f.id ?? favoriteVehicleKey(f)"
        class="favs__item"
        :class="{ 'favs__item--on': isApplied(f) }"
      >
        <label class="favs__item-label">
          <input
            type="checkbox"
            class="favs__box"
            :checked="isApplied(f)"
            @change="applyFavorite(f)"
          />
          <span class="favs__item-name">{{ favoriteVehicleLabel(f) }}</span>
        </label>
        <button
          type="button"
          class="favs__del"
          :aria-label="`Quitar ${favoriteVehicleLabel(f)} de favoritos`"
          @click="remove(f)"
        >
          ✕
        </button>
      </li>
    </ul>

    <p v-if="error" class="favs__error">{{ error }}</p>

    <p v-if="!auth.isAuthenticated" class="favs__hint">
      <button type="button" class="favs__link" @click="openPanel('login')">
        Inicia sesión
      </button>
      para sincronizar tus vehículos en tu cuenta.
    </p>



  </section>
</template>

<style scoped>
/* Mismo lenguaje que las facetas del sidebar (tarjeta de borde fino, título en la
   display, listas con su propio scroll). Lo único con color de marca es la barra:
   es la acción de la sección, y así se distingue de las listas de filtro. */
.favs {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

/* ── Botón Principal estilo selector modal ─────────────────────────────── */
.favs__hero-btn {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  width: 100%;
  padding: 10px 12px;
  background: linear-gradient(135deg, rgba(26, 61, 110, 0.28), rgba(26, 61, 110, 0.12));
  border: 1px solid var(--blue);
  border-radius: var(--radius);
  cursor: pointer;
  text-align: left;
  transition: all 0.18s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.favs__hero-btn:hover {
  background: linear-gradient(135deg, rgba(26, 61, 110, 0.42), rgba(26, 61, 110, 0.2));
  border-color: var(--blue-2);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 61, 110, 0.25);
}

.favs__car-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: var(--blue);
  color: #eceef2;
  display: grid;
  place-items: center;
  flex-shrink: 0;
}

.favs__car-icon svg {
  width: 18px;
  height: 18px;
}

.favs__hero-text {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
}

.favs__hero-title {
  font-size: 0.92rem;
  font-weight: 700;
  color: var(--cream);
  line-height: 1.2;
}

.favs__hero-sub {
  font-size: 0.72rem;
  color: var(--blue-2);
  margin-top: 2px;
}

.favs__hero-arrow {
  width: 16px;
  height: 16px;
  color: var(--charcoal);
  flex-shrink: 0;
  transition: transform 0.15s ease, color 0.15s ease;
}

.favs__hero-btn:hover .favs__hero-arrow {
  color: var(--cream);
  transform: translateX(2px);
}

.favs__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.favs__title {
  font-family: var(--font-display);
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--cream);
}

.favs__count {
  font-size: 0.75rem;
  color: var(--charcoal);
}

/* ── La barra "Agregar a favoritos" ─────────────────────────────────────── */
.favs__bar {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  width: 100%;
  height: 38px;
  padding-inline: var(--space-3);
  border-radius: var(--radius-sm);
  background: rgba(26, 61, 110, 0.14);
  border: 1px solid var(--blue);
  color: var(--blue-2);
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s ease, border-color 0.15s ease;
}

.favs__bar:hover {
  background: rgba(26, 61, 110, 0.22);
}

.favs__bar--open {
  border-color: var(--border-strong);
}

.favs__bar-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.favs__bar-text {
  flex: 1;
  text-align: left;
}

.favs__bar-chevron {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
  transition: transform 0.15s ease;
}

.favs__bar-chevron--up {
  transform: rotate(180deg);
}

/* ── Selector de dos pasos ──────────────────────────────────────────────── */
.favs__picker {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding-top: var(--space-3);
  border-top: 1px dashed var(--border);
}

.favs__search {
  position: relative;
  display: flex;
  align-items: center;
}

.favs__search-input {
  width: 100%;
  height: 34px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 0 28px 0 var(--space-3);
  font-size: 0.82rem;
  color: var(--cream);
  outline: none;
  transition: border-color 0.15s ease;
}

.favs__search-input:focus {
  border-color: var(--blue);
}

.favs__search-input::placeholder {
  color: var(--charcoal);
}

.favs__search-icon {
  position: absolute;
  right: 8px;
  width: 14px;
  height: 14px;
  color: var(--charcoal);
  pointer-events: none;
}

.favs__list {
  display: flex;
  flex-direction: column;
  gap: 6px;
  max-height: 220px;
  overflow-y: auto;
  padding-right: 4px;
  scrollbar-width: thin;
  scrollbar-color: var(--border-strong) transparent;
}

.favs__list::-webkit-scrollbar {
  width: 4px;
}

.favs__list::-webkit-scrollbar-thumb {
  background: var(--border-strong);
  border-radius: 4px;
}

/* Fila de marca del paso 1: lleva al paso 2, por eso es botón con flecha. */
.favs__brand {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  width: 100%;
  padding: 6px;
  border-radius: var(--radius-sm);
  color: var(--cream);
  font-size: 0.85rem;
  text-align: left;
  cursor: pointer;
  transition: background 0.12s ease;
}

.favs__brand:hover {
  background: var(--surface-2);
}

.favs__brand-name {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.favs__brand svg {
  width: 14px;
  height: 14px;
  color: var(--charcoal);
  flex-shrink: 0;
}

.favs__back {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  align-self: flex-start;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--blue-2);
  cursor: pointer;
}

.favs__back svg {
  width: 14px;
  height: 14px;
}

/* Fila marcable (paso 2) y fila de auto guardado comparten el checkbox. */
.favs__check,
.favs__item-label {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: 4px 6px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  user-select: none;
  transition: background 0.12s ease;
}

.favs__check:hover,
.favs__item-label:hover {
  background: var(--surface-2);
}

.favs__check--on {
  background: rgba(26, 61, 110, 0.14);
}

.favs__box {
  appearance: none;
  width: 16px;
  height: 16px;
  border: 1px solid var(--border-strong);
  border-radius: 4px;
  background: var(--surface-2);
  cursor: pointer;
  display: grid;
  place-content: center;
  flex-shrink: 0;
  transition: all 0.15s ease;
}

.favs__box:checked {
  background: var(--blue);
  border-color: var(--blue-2);
}

.favs__box:checked::before {
  content: '';
  width: 9px;
  height: 6px;
  border-left: 2px solid #fff;
  border-bottom: 2px solid #fff;
  transform: rotate(-45deg) translate(1px, -1px);
}

.favs__check-name,
.favs__item-name {
  font-size: 0.85rem;
  color: var(--cream);
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ── Autos guardados ────────────────────────────────────────────────────── */
.favs__saved {
  display: flex;
  flex-direction: column;
  gap: 6px;
  max-height: 200px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--border-strong) transparent;
}

.favs__saved::-webkit-scrollbar {
  width: 4px;
}

.favs__saved::-webkit-scrollbar-thumb {
  background: var(--border-strong);
  border-radius: 4px;
}

.favs__item {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  border-radius: var(--radius-sm);
}

.favs__item-label {
  flex: 1;
  min-width: 0;
}

.favs__item--on {
  background: rgba(26, 61, 110, 0.14);
}

.favs__del {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
  border-radius: 50%;
  color: var(--charcoal);
  font-size: 0.75rem;
  cursor: pointer;
  transition: color 0.15s ease, background 0.15s ease;
}

.favs__del:hover {
  color: var(--danger);
  background: var(--surface-2);
}

/* ── Textos de apoyo ────────────────────────────────────────────────────── */
.favs__hint,
.favs__empty {
  font-size: 0.78rem;
  color: var(--charcoal);
  line-height: 1.45;
}

.favs__error {
  font-size: 0.78rem;
  color: var(--danger);
}

.favs__link {
  color: var(--blue-2);
  font-size: 0.78rem;
  font-weight: 600;
  text-decoration: underline;
  text-underline-offset: 2px;
  cursor: pointer;
}
</style>
