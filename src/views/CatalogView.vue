<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import WrenchWatermark from '@/components/brand/WrenchWatermark.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'
import MapPanel from '@/components/catalog/MapPanel.vue'
import FilterBar from '@/components/catalog/FilterBar.vue'
import PartGrid from '@/components/catalog/PartGrid.vue'

const store = useCatalogStore()
const { parts, loading, error, resultCount, isEmpty, storeSettings } =
  storeToRefs(store)

// Dialog de ubicación (solo se usa en móvil; el mapa inline se oculta ahí).
const showMapDialog = ref(false)

// El hero tiene UN solo botón: en escritorio "Explorar catálogo" (baja al
// catálogo); en móvil "Ubicación tienda" (abre el dialog del mapa). Detectamos
// el ancho con matchMedia — mismo breakpoint que el CSS (860px).
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
  if (e.key === 'Escape') showMapDialog.value = false
}
watch(showMapDialog, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
  if (open) window.addEventListener('keydown', onKeydown)
  else window.removeEventListener('keydown', onKeydown)
})

onMounted(() => {
  syncMobile(mq)
  mq.addEventListener('change', syncMobile)
  store.loadParts()
  store.loadCategories()
  store.loadStoreSettings()
})

// Limpieza por si el componente se destruye con el dialog abierto.
onBeforeUnmount(() => {
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onKeydown)
  mq.removeEventListener('change', syncMobile)
})
</script>

<template>
  <!-- Hero -->
  <section class="hero">
    <WrenchWatermark />
    <div class="container hero__inner">
      <div class="hero__copy">
        <h1 class="hero__title">
          Encuentra la pieza exacta para tu auto,
          <span class="hero__title-grad">sin adivinar.</span>
        </h1>
        <p class="hero__lead">
          Busca por nombre o número de parte y filtra por categoría. Cada pieza
          muestra compatibilidad real por marca, modelo y años.
        </p>
        <!-- Un solo botón: en escritorio explora el catálogo; en móvil abre la
             ubicación en un dialog. El icono cambia con el modo. -->
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

      <!-- El panel "CALROD · AL DÍA" (stats) se reemplaza por el mapa de ubicación. -->
      <!-- <HeroPanel
        :active-parts="stats?.activeParts ?? 0"
        :brands-covered="stats?.brandsCovered ?? 0"
        :availability-pct="stats?.availabilityPct ?? 0"
        :loading="statsLoading"
      /> -->
      <MapPanel
        v-if="storeSettings"
        class="hero__map"
        :lat="Number(storeSettings.lat)"
        :lng="Number(storeSettings.lng)"
        :address="storeSettings.address"
      />
    </div>
  </section>

  <!-- Catálogo -->
  <section id="catalogo" class="catalog container">
    <FilterBar :result-count="resultCount" />

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
    <div v-else-if="isEmpty" class="state">
      <p class="state__title">No encontramos piezas con esos filtros.</p>
      <button class="btn btn--ghost" @click="store.clearFilters()">
        Limpiar filtros
      </button>
    </div>

    <!-- Resultados -->
    <PartGrid v-else :parts="parts" />
  </section>

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
