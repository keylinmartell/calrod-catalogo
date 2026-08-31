<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { useFilters } from '@/composables/useFilters'
import { useAppLoading } from '@/composables/useAppLoading'
import TireWatermark from '@/components/brand/TireWatermark.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'
import MapPanel from '@/components/catalog/MapPanel.vue'
import CatalogSidebar from '@/components/catalog/CatalogSidebar.vue'
import CatalogToolbar from '@/components/catalog/CatalogToolbar.vue'
import PartListView from '@/components/catalog/PartListView.vue'
import PartGrid from '@/components/catalog/PartGrid.vue'

const store = useCatalogStore()
const { loading, error, storeSettings } = storeToRefs(store)
const { viewMode, displayParts, clearFilters } = useFilters()
const { finishBoot } = useAppLoading()

// Dialog de ubicación (solo se usa en móvil; el mapa inline se oculta ahí).
const showMapDialog = ref(false)
// Toggle de filtros en pantallas móviles
const showMobileFilters = ref(false)

const isMobile = ref(false)
const mq = window.matchMedia('(max-width: 860px)')
const syncMobile = (e: MediaQueryList | MediaQueryListEvent) => {
  isMobile.value = e.matches
}

function onHeroCta() {
  if (isMobile.value && storeSettings.value) {
    showMapDialog.value = true
  } else {
    document.getElementById('catalogo')?.scrollIntoView({ behavior: 'smooth' })
  }
}

// Cerrar con Escape y bloquear el scroll del fondo mientras está abierto.
function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    showMapDialog.value = false
    showMobileFilters.value = false
  }
}
watch([showMapDialog, showMobileFilters], ([mapOpen, filterOpen]) => {
  document.body.style.overflow = mapOpen || filterOpen ? 'hidden' : ''
  if (mapOpen || filterOpen) window.addEventListener('keydown', onKeydown)
  else window.removeEventListener('keydown', onKeydown)
})

onMounted(async () => {
  syncMobile(mq)
  mq.addEventListener('change', syncMobile)
  await Promise.allSettled([
    store.loadParts(),
    store.loadCategories(),
    store.loadBrands(),
    store.loadAllVehicles(),
    store.loadStoreSettings(),
  ])
  finishBoot()
})

onBeforeUnmount(() => {
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onKeydown)
  mq.removeEventListener('change', syncMobile)
})
</script>

<template>
  <!-- Hero -->
  <section class="hero">
    <TireWatermark />
    <div class="container hero__inner">
      <div class="hero__copy">
        <h1 class="hero__title">
          Encuentre la pieza exacta para su auto,
          <span class="hero__title-grad">sin adivinar.</span>
        </h1>
        <p class="hero__lead">
          Busque por marca, modelo o número de parte. Cada pieza muestra compatibilidad
          real garantizada.
        </p>
        <button type="button" class="btn btn--primary hero__cta" @click="onHeroCta">
          <template v-if="isMobile && storeSettings">
            <svg
              class="hero__cta-icon"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <path d="M12 21s-6-5.3-6-10a6 6 0 0 1 12 0c0 4.7-6 10-6 10Z" />
              <circle cx="12" cy="11" r="2.2" />
            </svg>
            Ubicación tienda
          </template>
          <template v-else>
            <svg
              class="hero__cta-icon"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <rect x="3" y="4" width="7" height="7" rx="1" />
              <rect x="14" y="4" width="7" height="7" rx="1" />
              <rect x="3" y="15" width="7" height="5" rx="1" />
              <rect x="14" y="15" width="7" height="5" rx="1" />
            </svg>
            Explorar catálogo
          </template>
        </button>
      </div>

      <MapPanel
        v-if="storeSettings"
        class="hero__map"
        :lat="Number(storeSettings.lat)"
        :lng="Number(storeSettings.lng)"
        :address="storeSettings.address"
      />
    </div>
  </section>

  <!-- Catálogo Principal con Layout 2 Columnas -->
  <section id="catalogo" class="catalog container">
    <!-- Botón de filtros para móvil -->
    <div class="mobile-filter-trigger">
      <button
        type="button"
        class="btn btn--ghost mobile-filter-btn"
        @click="showMobileFilters = true"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="4" y1="21" x2="4" y2="14" />
          <line x1="4" y1="10" x2="4" y2="3" />
          <line x1="12" y1="21" x2="12" y2="12" />
          <line x1="12" y1="8" x2="12" y2="3" />
          <line x1="20" y1="21" x2="20" y2="16" />
          <line x1="20" y1="12" x2="20" y2="3" />
          <line x1="1" y1="14" x2="7" y2="14" />
          <line x1="9" y1="8" x2="15" y2="8" />
          <line x1="17" y1="16" x2="23" y2="16" />
        </svg>
        Filtros de búsqueda
      </button>
    </div>

    <div class="catalog__layout">
      <!-- Columna izquierda: Sidebar de filtros -->
      <div class="catalog__sidebar-col">
        <CatalogSidebar />
      </div>

      <!-- Columna derecha: Toolbar + Resultados -->
      <div class="catalog__main-col">
        <CatalogToolbar />

        <!-- Estado: cargando -->
        <div v-if="loading" class="state" aria-live="polite">
          <GearSpinner :size="44" />
          <p>Cargando piezas…</p>
        </div>

        <!-- Estado: error de red -->
        <div v-else-if="error" class="state state--error" role="alert">
          <p>{{ error }}</p>
          <button class="btn btn--ghost" @click="store.loadParts()">Reintentar</button>
        </div>

        <!-- Estado: vacío -->
        <div v-else-if="!displayParts.length" class="state">
          <p class="state__title">No encontramos piezas con esos filtros.</p>
          <button class="btn btn--ghost" @click="clearFilters">
            Limpiar filtros
          </button>
        </div>

        <!-- Resultados: Vista Lista o Vista Cuadrícula -->
        <template v-else>
          <PartListView v-if="viewMode === 'list'" :parts="displayParts" />
          <PartGrid v-else :parts="displayParts" />
        </template>
      </div>
    </div>
  </section>

  <!-- Drawer de filtros para móvil -->
  <Teleport to="body">
    <div
      v-if="showMobileFilters"
      class="mobile-filter-drawer"
      role="dialog"
      aria-modal="true"
      aria-label="Filtros del catálogo"
    >
      <div class="mobile-filter-drawer__backdrop" @click="showMobileFilters = false" />
      <div class="mobile-filter-drawer__content">
        <div class="mobile-filter-drawer__header">
          <h3 class="mobile-filter-drawer__title">Filtros</h3>
          <button
            type="button"
            class="mobile-filter-drawer__close"
            aria-label="Cerrar filtros"
            @click="showMobileFilters = false"
          >
            ✕
          </button>
        </div>
        <div class="mobile-filter-drawer__body">
          <CatalogSidebar />
        </div>
        <div class="mobile-filter-drawer__footer">
          <button
            type="button"
            class="btn btn--primary"
            style="width: 100%"
            @click="showMobileFilters = false"
          >
            Ver {{ displayParts.length }} resultados
          </button>
        </div>
      </div>
    </div>
  </Teleport>

  <!-- Dialog de ubicación (móvil): se abre desde "Ubicación tienda". -->
  <Teleport to="body">
    <div
      v-if="showMapDialog && storeSettings"
      class="map-dialog"
      role="dialog"
      aria-modal="true"
      aria-label="Ubicación de la tienda"
      @click.self="showMapDialog = false"
    >
      <div class="map-dialog__box">
        <button
          type="button"
          class="map-dialog__close"
          aria-label="Cerrar"
          @click="showMapDialog = false"
        >
          ✕
        </button>
        <MapPanel
          :lat="Number(storeSettings.lat)"
          :lng="Number(storeSettings.lng)"
          :address="storeSettings.address"
        />
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.hero {
  position: relative;
  overflow: hidden;
  padding-block: var(--space-7) var(--space-5);
  border-bottom: 1px solid var(--border);
}

.hero__inner {
  display: grid;
  grid-template-columns: 1.4fr 0.9fr;
  gap: var(--space-7);
  align-items: center;
  position: relative;
  z-index: 1;
}

.hero__eyebrow {
  display: none;
}

.hero__title {
  font-size: clamp(1.9rem, 4vw, 3rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  max-width: 16ch;
}

.hero__title-grad {
  background: linear-gradient(100deg, var(--cream) 25%, var(--blue-2) 95%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.hero__lead {
  color: var(--charcoal);
  font-size: 1.05rem;
  max-width: 48ch;
  margin-block: var(--space-4) var(--space-5);
}

/* Botón CTA del hero: mismo botón, icono + texto centrados. */
.hero__cta {
  gap: var(--space-2);
}

.hero__cta-icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.15s ease;
}

.btn--primary {
  background: var(--blue);
  /* El botón es azul oscuro en ambos temas → texto siempre claro (no --cream,
     que en modo claro se vuelve oscuro y no contrastaría). */
  color: #eceef2;
}

.btn--primary:hover {
  background: var(--blue-2);
}

.btn--ghost {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

.btn--ghost:hover {
  border-color: var(--blue);
}

.catalog {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
  padding-block: var(--space-5) var(--space-7);
}

.catalog__layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: var(--space-5);
  align-items: start;
}

.catalog__sidebar-col {
  position: sticky;
  top: calc(var(--header-h) + 16px);
  max-height: calc(100vh - var(--header-h) - 32px);
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--border-strong) transparent;
}

.catalog__sidebar-col::-webkit-scrollbar {
  width: 4px;
}

.catalog__sidebar-col::-webkit-scrollbar-thumb {
  background: var(--border-strong);
  border-radius: 4px;
}

.catalog__main-col {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  min-width: 0;
}

.mobile-filter-trigger {
  display: none;
}

.mobile-filter-btn {
  width: 100%;
  gap: var(--space-2);
  font-size: 0.9rem;
}

.mobile-filter-btn svg {
  width: 18px;
  height: 18px;
}

.state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding-block: var(--space-8);
  text-align: center;
  color: var(--charcoal);
}

.state__title {
  font-family: var(--font-display);
  font-size: 1.1rem;
  color: var(--cream);
}

.state--error {
  color: var(--danger);
}

@media (max-width: 960px) {
  .catalog__layout {
    grid-template-columns: 1fr;
  }

  .catalog__sidebar-col {
    display: none;
  }

  .mobile-filter-trigger {
    display: block;
  }
}

@media (max-width: 860px) {
  .hero__inner {
    grid-template-columns: 1fr;
    gap: var(--space-6);
  }

  /* En móvil el mapa no va inline: se ve dentro del dialog. */
  .hero__map {
    display: none;
  }

  /* Sin el mapa inline, el hero queda muy alto: recortamos el aire inferior
     y el superior del catálogo para que las piezas queden más cerca del CTA. */
  .hero {
    padding-block: var(--space-6) var(--space-5);
  }

  .catalog {
    padding-block: var(--space-5);
  }
}

/* ── Mobile Filter Drawer ────────────────────────────────────────────────── */
.mobile-filter-drawer {
  position: fixed;
  inset: 0;
  z-index: 1100;
  display: flex;
}

.mobile-filter-drawer__backdrop {
  position: absolute;
  inset: 0;
  background: var(--overlay);
  backdrop-filter: blur(4px);
}

.mobile-filter-drawer__content {
  position: relative;
  width: 85%;
  max-width: 340px;
  height: 100%;
  background: var(--surface);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  z-index: 1;
  box-shadow: var(--shadow-card);
}

.mobile-filter-drawer__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4);
  border-bottom: 1px solid var(--border);
}

.mobile-filter-drawer__title {
  font-family: var(--font-display);
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--cream);
  margin: 0;
}

.mobile-filter-drawer__close {
  background: none;
  border: none;
  font-size: 1.2rem;
  color: var(--charcoal);
  cursor: pointer;
  padding: 4px 8px;
}

.mobile-filter-drawer__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-4);
}

.mobile-filter-drawer__footer {
  padding: var(--space-4);
  border-top: 1px solid var(--border);
  background: var(--surface-2);
}

/* ── Dialog de ubicación (móvil) ─────────────────────────────────────────── */
.map-dialog {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: grid;
  place-items: center;
  padding: var(--space-4);
  background: var(--overlay);
  backdrop-filter: blur(4px);
}

.map-dialog__box {
  position: relative;
  width: 100%;
  max-width: 460px;
  /* Deja aire arriba para que la ✕ no se monte sobre el panel. */
  margin-top: 52px;
}

.map-dialog__close {
  position: absolute;
  top: -48px;
  right: 0;
  z-index: 1;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
  font-size: 1.05rem;
  cursor: pointer;
  transition: border-color 0.15s ease, background 0.15s ease;
}

.map-dialog__close:hover {
  border-color: var(--blue);
  background: var(--surface);
}
</style>
