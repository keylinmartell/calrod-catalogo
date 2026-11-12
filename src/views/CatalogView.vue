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
    <TireWatermark />
    <div class="container hero__inner">
      <!-- Columna izquierda: Título y acciones -->
      <div class="hero__copy">
        <div class="hero__badge mono">
          <span class="hero__badge-dot" aria-hidden="true"></span>
          <span>CATÁLOGO OFICIAL · STOCK Y ENCARGOS</span>
        </div>

        <h1 class="hero__title">
          Encuentre la pieza exacta para su auto,
          <span class="hero__title-grad">sin adivinar.</span>
        </h1>
        <p class="hero__lead">
          Cada repuesto muestra compatibilidad real garantizada, existencias actualizadas y opción de encargo directo.
        </p>

        <div class="hero__actions">
          <button type="button" class="btn btn--primary hero__cta" @click="scrollToCatalog">
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
            Ubicación tienda
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
            Encargar repuesto
          </button>
        </div>
      </div>

      <!-- Zona central: Ventajas clave que aprovechan el espacio en pantallas grandes y medianas -->
      <div class="hero__features" aria-label="Ventajas de Repuestos CalRod">
        <div class="hero-feat">
          <div class="hero-feat__icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <polyline points="9 12 11 14 15 10" />
            </svg>
          </div>
          <div class="hero-feat__body">
            <strong class="hero-feat__title">Compatibilidad Exacta</strong>
            <span class="hero-feat__desc">Filtrado real por marca, modelo, motor y año.</span>
          </div>
        </div>

        <div class="hero-feat">
          <div class="hero-feat__icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
              <line x1="7" y1="7" x2="7.01" y2="7" />
            </svg>
          </div>
          <div class="hero-feat__body">
            <strong class="hero-feat__title">Precios Mayoristas</strong>
            <span class="hero-feat__desc">Descuento directo por volumen desde 5 unidades.</span>
          </div>
        </div>

        <div class="hero-feat">
          <div class="hero-feat__icon hero-feat__icon--green" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
          </div>
          <div class="hero-feat__body">
            <strong class="hero-feat__title">Encargos en ~15 Días</strong>
            <span class="hero-feat__desc">¿Agotado o necesitas más? Lo traemos por WhatsApp.</span>
          </div>
        </div>
      </div>

      <!-- Columna derecha: Mapa de tienda física -->
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
.hero {
  position: relative;
  overflow: hidden;
  min-height: 256px;
  display: flex;
  align-items: center;
  padding-block: var(--space-5);
  border-bottom: 1px solid var(--border);
  background:
    radial-gradient(ellipse 680px 320px at 18% 50%, rgba(26, 61, 110, 0.14), transparent 70%),
    radial-gradient(ellipse 520px 260px at 52% 50%, rgba(74, 123, 184, 0.08), transparent 70%);
}

.hero__inner {
  display: grid;
  grid-template-columns: minmax(280px, 1.1fr) minmax(260px, 0.95fr) minmax(320px, 460px);
  gap: clamp(16px, 2.2vw, 32px);
  align-items: center;
  position: relative;
  z-index: 1;
}

.hero__badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 4px 10px;
  border-radius: 999px;
  background: rgba(26, 61, 110, 0.22);
  border: 1px solid rgba(74, 123, 184, 0.3);
  color: var(--blue-2);
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  margin-bottom: var(--space-2);
}

.hero__badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #25d366;
  box-shadow: 0 0 8px rgba(37, 211, 102, 0.8);
}

.hero__title {
  font-size: clamp(1.35rem, 2.2vw, 2.05rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  line-height: 1.15;
  max-width: 24ch;
}

.hero__title-grad {
  background: linear-gradient(100deg, var(--cream) 25%, var(--blue-2) 95%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.hero__lead {
  color: var(--charcoal);
  font-size: 0.88rem;
  max-width: 46ch;
  margin-block: var(--space-2) var(--space-3);
  line-height: 1.45;
}

.hero__actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--space-2);
}

/* Botón CTA del hero: mismo botón, icono + texto centrados. */
.hero__cta {
  gap: 8px;
  padding: 9px 16px;
  font-size: 0.84rem;
}

.hero__cta-icon {
  width: 17px;
  height: 17px;
  flex-shrink: 0;
}

/* Ventajas centrales del hero */
.hero__features {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.hero-feat {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 12px;
  border-radius: var(--radius-sm);
  background: rgba(17, 19, 24, 0.72);
  backdrop-filter: blur(8px);
  border: 1px solid var(--border);
  transition: border-color 0.15s ease, transform 0.15s ease;
}

:root[data-theme='light'] .hero-feat {
  background: rgba(255, 255, 255, 0.82);
}

.hero-feat:hover {
  border-color: rgba(74, 123, 184, 0.35);
  transform: translateX(2px);
}

.hero-feat__icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: grid;
  place-items: center;
  background: rgba(26, 61, 110, 0.25);
  color: var(--blue-2);
  flex-shrink: 0;
}

.hero-feat__icon--green {
  background: rgba(37, 211, 102, 0.14);
  color: #25d366;
}

.hero-feat__icon svg {
  width: 16px;
  height: 16px;
}

.hero-feat__body {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.hero-feat__title {
  font-family: var(--font-display);
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--cream);
  line-height: 1.2;
}

.hero-feat__desc {
  font-size: 0.7rem;
  color: var(--charcoal);
  line-height: 1.25;
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

.btn--wa {
  background: rgba(37, 211, 102, 0.14);
  border: 1px solid rgba(37, 211, 102, 0.4);
  color: #25d366;
}

.btn--wa:hover {
  background: #25d366;
  color: #fff;
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
   Título + Mapa arriba en 2 columnas, las 3 tarjetas de ventajas en fila abajo */
@media (max-width: 1180px) {
  .hero__inner {
    grid-template-columns: 1fr minmax(300px, 420px);
    row-gap: var(--space-4);
  }

  .hero__features {
    grid-column: 1 / -1;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: var(--space-2);
    order: 3;
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

/* Pantallas chicas (tablets verticales y móviles) */
@media (max-width: 860px) {
  .hero__inner {
    grid-template-columns: 1fr;
    gap: var(--space-3);
  }

  /* En móvil el mapa no va inline: se ve dentro del dialog. */
  .hero__map {
    display: none;
  }

  .hero {
    min-height: 196px;
    padding-block: var(--space-4);
  }

  .hero__features {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }

  .catalog {
    padding-block: var(--space-3) var(--space-5);
  }
}

@media (max-width: 640px) {
  .hero__badge {
    font-size: 0.62rem;
    padding: 3px 8px;
  }

  .hero__lead {
    font-size: 0.82rem;
  }

  .hero__actions {
    width: 100%;
  }

  .hero__cta {
    flex: 1 1 auto;
    padding: 8px 12px;
    font-size: 0.78rem;
  }

  .hero__features {
    grid-template-columns: 1fr;
    gap: 6px;
  }

  .hero-feat {
    padding: 7px 10px;
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
