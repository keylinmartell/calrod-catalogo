<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import { useFilters } from '@/composables/useFilters'
import { useAppLoading } from '@/composables/useAppLoading'
import { WHATSAPP_PHONE } from '@/composables/useWhatsApp'
import TireWatermark from '@/components/brand/TireWatermark.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'
import MapPanel from '@/components/catalog/MapPanel.vue'
import CatalogSidebar from '@/components/catalog/CatalogSidebar.vue'
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

function scrollToCatalog() {
  document.getElementById('catalogo')?.scrollIntoView({ behavior: 'smooth' })
}

function openCustomOrderWhatsApp() {
  const text = encodeURIComponent(
    'Hola, estoy buscando un repuesto en el catálogo CalRod y quisiera consultar disponibilidad o hacer un encargo.',
  )
  window.open(`https://wa.me/${WHATSAPP_PHONE}?text=${text}`, '_blank', 'noopener,noreferrer')
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
    store.loadVehicleBrands(),
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
    <div class="hero__ambient" aria-hidden="true"></div>
    <TireWatermark />

    <div class="container hero__inner">
      <!-- Columna 1: Propuesta de Valor & Acciones -->
      <div class="hero__copy">
        <div class="hero__eyebrow">
          <span class="hero__eyebrow-badge mono">
            <span class="hero__badge-dot" aria-hidden="true"></span>
            <span>CATÁLOGO OFICIAL</span>
          </span>
          <span class="hero__eyebrow-divider" aria-hidden="true"></span>
          <span class="hero__eyebrow-sub mono">STOCK EN TIEMPO REAL &amp; ENCARGOS</span>
        </div>

        <h1 class="hero__title">
          Encuentre la pieza exacta para su auto,
          <span class="hero__title-grad">sin adivinar.</span>
        </h1>

        <p class="hero__lead">
          Cada repuesto muestra compatibilidad real garantizada, existencias actualizadas y opción de encargo directo.
        </p>

        <div class="hero__actions">
          <button type="button" class="btn btn--primary hero__cta hero__cta--primary" @click="scrollToCatalog">
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
              <rect x="3" y="4" width="7" height="7" rx="1.5" />
              <rect x="14" y="4" width="7" height="7" rx="1.5" />
              <rect x="3" y="15" width="7" height="5" rx="1.5" />
              <rect x="14" y="15" width="7" height="5" rx="1.5" />
            </svg>
            <span>Explorar catálogo</span>
            <svg class="hero__cta-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="M12 5v14M19 12l-7 7-7-7" />
            </svg>
          </button>

          <button
            v-if="isMobile && storeSettings"
            type="button"
            class="btn btn--ghost hero__cta"
            @click="showMapDialog = true"
          >
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
            <span>Ubicación tienda</span>
          </button>

          <button
            type="button"
            class="btn btn--wa hero__cta"
            @click="openCustomOrderWhatsApp"
          >
            <svg class="hero__cta-icon" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
              <path
                d="M16.004 3.2c-7.06 0-12.8 5.74-12.8 12.8 0 2.258.594 4.462 1.72 6.4L3.2 28.8l6.56-1.72a12.74 12.74 0 0 0 6.244 1.62h.006c7.06 0 12.8-5.74 12.8-12.8 0-3.42-1.332-6.634-3.75-9.052A12.72 12.72 0 0 0 16.004 3.2Zm0 23.36h-.004a10.56 10.56 0 0 1-5.384-1.474l-.386-.23-3.894 1.02 1.04-3.796-.252-.39a10.55 10.55 0 0 1-1.616-5.62c0-5.868 4.776-10.64 10.648-10.64a10.57 10.57 0 0 1 7.524 3.12 10.56 10.56 0 0 1 3.116 7.526c0 5.868-4.776 10.64-10.642 10.64Zm5.834-7.964c-.32-.16-1.892-.934-2.184-1.04-.293-.107-.507-.16-.72.16-.213.32-.826 1.04-1.013 1.253-.187.213-.373.24-.693.08-.32-.16-1.35-.498-2.57-1.586-.95-.847-1.592-1.894-1.778-2.214-.187-.32-.02-.493.14-.652.144-.143.32-.373.48-.56.16-.187.213-.32.32-.533.107-.213.053-.4-.027-.56-.08-.16-.72-1.734-.986-2.374-.26-.624-.523-.54-.72-.55l-.613-.01c-.213 0-.56.08-.853.4-.293.32-1.12 1.094-1.12 2.667 0 1.574 1.146 3.094 1.306 3.307.16.213 2.253 3.44 5.46 4.826.763.33 1.358.527 1.822.674.766.244 1.463.21 2.014.127.615-.092 1.892-.774 2.158-1.52.267-.747.267-1.387.187-1.52-.08-.134-.293-.214-.613-.374Z"
              />
            </svg>
            <span>Encargar repuesto</span>
          </button>
        </div>
      </div>

      <!-- Columna 2: Editorial Timeline de Garantías (Sin cajas/cards, solo escritorio y tablet grande) -->
      <div class="hero__pillars" aria-label="Garantías de Repuestos CalRod">
        <div class="pillar">
          <div class="pillar__marker" aria-hidden="true">
            <span class="pillar__num mono">01</span>
          </div>
          <div class="pillar__content">
            <div class="pillar__head">
              <strong class="pillar__title">Compatibilidad Exacta</strong>
              <span class="pillar__meta mono">FIT 100%</span>
            </div>
            <p class="pillar__desc">Filtrado real por marca, modelo, motor y año.</p>
          </div>
        </div>

        <div class="pillar">
          <div class="pillar__marker" aria-hidden="true">
            <span class="pillar__num mono">02</span>
          </div>
          <div class="pillar__content">
            <div class="pillar__head">
              <strong class="pillar__title">Precios Mayoristas</strong>
              <span class="pillar__meta mono">5+ UDS</span>
            </div>
            <p class="pillar__desc">Descuento directo por volumen desde 5 unidades.</p>
          </div>
        </div>

        <div class="pillar">
          <div class="pillar__marker" aria-hidden="true">
            <span class="pillar__num mono">03</span>
          </div>
          <div class="pillar__content">
            <div class="pillar__head">
              <strong class="pillar__title">Encargos en ~15 Días</strong>
              <span class="pillar__meta pillar__meta--green mono">WHATSAPP</span>
            </div>
            <p class="pillar__desc">¿Agotado o necesitas más? Lo traemos bajo pedido.</p>
          </div>
        </div>
      </div>

      <!-- Columna 3: Mapa Interactivo de Tienda Física -->
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

      <!-- Columna derecha: Resultados -->
      <div class="catalog__main-col">
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
/* ── Hero Section ────────────────────────────────────────────────────────── */
.hero {
  position: relative;
  overflow: hidden;
  min-height: 268px;
  display: flex;
  align-items: center;
  padding-block: clamp(20px, 2.5vw, 32px);
  border-bottom: 1px solid var(--border);
  background:
    radial-gradient(ellipse 750px 360px at 14% 45%, rgba(37, 99, 235, 0.14), transparent 70%),
    radial-gradient(ellipse 620px 320px at 84% 55%, rgba(30, 64, 175, 0.1), transparent 70%);
}

/* Textura arquitectónica de precisión en el fondo del Hero */
.hero__ambient {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  opacity: 0.28;
  background-image:
    linear-gradient(to right, rgba(255, 255, 255, 0.03) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
  background-size: 36px 36px;
  mask-image: radial-gradient(ellipse 85% 90% at 50% 50%, #000 30%, transparent 100%);
  -webkit-mask-image: radial-gradient(ellipse 85% 90% at 50% 50%, #000 30%, transparent 100%);
}

:root[data-theme='light'] .hero__ambient {
  background-image:
    linear-gradient(to right, rgba(15, 23, 42, 0.04) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(15, 23, 42, 0.04) 1px, transparent 1px);
}

.hero__inner {
  display: grid;
  grid-template-columns: minmax(380px, 1.35fr) minmax(240px, 0.85fr) minmax(350px, 430px);
  gap: clamp(20px, 2.4vw, 36px);
  align-items: center;
  position: relative;
  z-index: 1;
}

/* Eyebrow compuesto estilo consola OEM */
.hero__eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 4px 12px 4px 5px;
  border-radius: 999px;
  background: rgba(15, 23, 42, 0.65);
  border: 1px solid rgba(148, 163, 184, 0.16);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(8px);
  margin-bottom: 12px;
}

:root[data-theme='light'] .hero__eyebrow {
  background: rgba(255, 255, 255, 0.85);
  border-color: rgba(26, 61, 110, 0.18);
}

.hero__eyebrow-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 9px;
  border-radius: 999px;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(29, 78, 216, 0.16));
  border: 1px solid rgba(96, 165, 250, 0.35);
  color: #93c5fd;
  font-size: 0.63rem;
  font-weight: 700;
  letter-spacing: 0.07em;
}

:root[data-theme='light'] .hero__eyebrow-badge {
  background: rgba(26, 61, 110, 0.1);
  border-color: rgba(26, 61, 110, 0.25);
  color: var(--blue);
}

.hero__badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 8px #22c55e;
}

.hero__eyebrow-divider {
  width: 1px;
  height: 11px;
  background: rgba(148, 163, 184, 0.24);
}

.hero__eyebrow-sub {
  font-size: 0.62rem;
  font-weight: 600;
  letter-spacing: 0.07em;
  color: var(--silver);
}

.hero__title {
  font-size: clamp(1.5rem, 2.35vw, 2.2rem);
  font-weight: 800;
  letter-spacing: -0.028em;
  line-height: 1.12;
  max-width: 23ch;
  color: var(--cream);
}

.hero__title-grad {
  background: linear-gradient(105deg, #ffffff 10%, #93c5fd 52%, #3b82f6 95%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

:root[data-theme='light'] .hero__title-grad {
  background: linear-gradient(105deg, #1a3d6e 10%, #2563eb 90%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.hero__lead {
  color: var(--text-dim);
  font-size: 0.9rem;
  max-width: 48ch;
  margin-block: 10px 18px;
  line-height: 1.5;
}

.hero__actions {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  gap: 10px;
}

.hero__cta {
  gap: 8px;
  padding: 10px 16px;
  font-size: 0.84rem;
  border-radius: 11px;
  white-space: nowrap;
}

.hero__cta--primary {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  border: 1px solid rgba(147, 197, 253, 0.32);
  color: #ffffff;
  box-shadow:
    0 8px 22px -6px rgba(37, 99, 235, 0.55),
    inset 0 1px 0 rgba(255, 255, 255, 0.22);
}

.hero__cta--primary:hover {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  transform: translateY(-1px);
  box-shadow:
    0 12px 26px -6px rgba(59, 130, 246, 0.68),
    inset 0 1px 0 rgba(255, 255, 255, 0.32);
}

.hero__cta-icon {
  width: 17px;
  height: 17px;
  flex-shrink: 0;
}

.hero__cta-arrow {
  width: 14px;
  height: 14px;
  opacity: 0.8;
  transition: transform 0.2s ease;
}

.hero__cta--primary:hover .hero__cta-arrow {
  transform: translateY(2px);
}

/* ── Columna Central: Editorial Architectural Ledger (Cero Cards/Cajas) ─── */
.hero__pillars {
  position: relative;
  display: flex;
  flex-direction: column;
  padding-left: 22px;
  /* Línea vertical continua estilo editorial de alta precisión */
  border-left: 1px solid rgba(148, 163, 184, 0.14);
}

.hero__pillars::before {
  content: '';
  position: absolute;
  left: -1px;
  top: 0;
  bottom: 0;
  width: 1px;
  background: linear-gradient(
    180deg,
    transparent 0%,
    rgba(59, 130, 246, 0.65) 25%,
    rgba(59, 130, 246, 0.65) 75%,
    transparent 100%
  );
}

.pillar {
  position: relative;
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding-block: 11px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  transition: transform 0.2s ease;
}

:root[data-theme='light'] .pillar {
  border-bottom-color: rgba(15, 23, 42, 0.07);
}

.pillar:first-child {
  padding-top: 2px;
}

.pillar:last-child {
  padding-bottom: 2px;
  border-bottom: none;
}

.pillar:hover {
  transform: translateX(3px);
}

.pillar__marker {
  padding-top: 2px;
  flex-shrink: 0;
}

.pillar__num {
  font-size: 0.66rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  color: var(--blue-2);
  opacity: 0.85;
}

.pillar__content {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
  flex: 1;
}

.pillar__head {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pillar__title {
  font-family: var(--font-display);
  font-size: 0.84rem;
  font-weight: 700;
  color: var(--cream);
  letter-spacing: -0.01em;
  line-height: 1.2;
}

.pillar__meta {
  font-size: 0.56rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: #60a5fa;
  opacity: 0.9;
}

.pillar__meta--green {
  color: #4ade80;
}

:root[data-theme='light'] .pillar__meta {
  color: #1d4ed8;
}

:root[data-theme='light'] .pillar__meta--green {
  color: #15803d;
}

.pillar__desc {
  font-size: 0.75rem;
  color: var(--charcoal);
  line-height: 1.35;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.18s cubic-bezier(0.16, 1, 0.3, 1);
}

.btn--primary {
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover {
  background: var(--blue-2);
}

.btn--wa {
  background: rgba(34, 197, 94, 0.12);
  border: 1px solid rgba(34, 197, 94, 0.38);
  color: #4ade80;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.06);
}

:root[data-theme='light'] .btn--wa {
  background: rgba(22, 163, 74, 0.1);
  border-color: rgba(22, 163, 74, 0.35);
  color: #15803d;
}

.btn--wa:hover {
  background: #22c55e;
  border-color: #22c55e;
  color: #fff;
  transform: translateY(-1px);
  box-shadow: 0 8px 20px -6px rgba(34, 197, 94, 0.5);
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
  scroll-margin-top: calc(var(--header-h) + 64px);
}

.catalog__layout {
  display: grid;
  grid-template-columns: clamp(235px, 19vw, 280px) minmax(0, 1fr);
  gap: clamp(16px, 2vw, 24px);
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

/* Pantallas medianas (laptops compactas / tablets horizontales):
   Se oculta la columna intermedia para mantener limpieza entre título y mapa */
@media (max-width: 1180px) {
  .hero__inner {
    grid-template-columns: 1fr minmax(320px, 430px);
  }

  .hero__pillars {
    display: none;
  }
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

/* Pantallas chicas (tablets verticales y móviles): sin ítems extra ni mapa inline */
@media (max-width: 860px) {
  .hero__inner {
    grid-template-columns: 1fr;
    gap: var(--space-3);
  }

  .hero__map,
  .hero__pillars {
    display: none;
  }

  .hero {
    min-height: 196px;
    padding-block: var(--space-4);
  }

  .catalog {
    padding-block: var(--space-3) var(--space-5);
  }
}

  @media (max-width: 640px) {
    .hero__eyebrow-sub,
    .hero__eyebrow-divider {
      display: none;
    }

    .hero__eyebrow {
      padding: 3px;
    }

    .hero__lead {
      font-size: 0.82rem;
    }

    .hero__actions {
      width: 100%;
      flex-wrap: wrap;
    }

    .hero__cta {
      flex: 1 1 auto;
      padding: 9px 12px;
      font-size: 0.79rem;
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
