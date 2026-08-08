<script setup lang="ts">
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useCatalogStore } from '@/stores/catalogStore'
import WrenchWatermark from '@/components/brand/WrenchWatermark.vue'
import HeroPanel from '@/components/catalog/HeroPanel.vue'
import SearchBar from '@/components/catalog/SearchBar.vue'
import FilterBar from '@/components/catalog/FilterBar.vue'
import PartGrid from '@/components/catalog/PartGrid.vue'

const store = useCatalogStore()
const { parts, loading, error, stats, statsLoading, resultCount, isEmpty } =
  storeToRefs(store)

onMounted(() => {
  store.loadParts()
  store.loadStats()
})
</script>

<template>
  <!-- Hero -->
  <section class="hero">
    <WrenchWatermark />
    <div class="container hero__inner">
      <div class="hero__copy">
        <span class="hero__eyebrow">
          <span class="hero__eyebrow-dot" aria-hidden="true"></span>
          Catálogo actualizado esta semana
        </span>
        <h1 class="hero__title">
          Encuentra la pieza exacta para tu auto,
          <span class="hero__title-grad">sin adivinar.</span>
        </h1>
        <p class="hero__lead">
          Busca por nombre o número de parte y filtra por categoría. Cada pieza
          muestra compatibilidad real por marca, modelo y años.
        </p>
        <a href="#catalogo" class="btn btn--primary">Explorar catálogo</a>
      </div>

      <HeroPanel
        :active-parts="stats?.activeParts ?? 0"
        :brands-covered="stats?.brandsCovered ?? 0"
        :availability-pct="stats?.availabilityPct ?? 0"
        :loading="statsLoading"
      />
    </div>
  </section>

  <!-- Catálogo -->
  <section id="catalogo" class="catalog container">
    <div class="catalog__search">
      <SearchBar />
    </div>

    <FilterBar :result-count="resultCount" />

    <!-- Estado: cargando -->
    <div v-if="loading" class="state" aria-live="polite">
      <div class="spinner" aria-hidden="true"></div>
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
</template>

<style scoped>
.hero {
  position: relative;
  overflow: hidden;
  padding-block: var(--space-8);
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
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  font-family: var(--font-mono);
  color: var(--orange-2);
  background: var(--orange-dim);
  border: 1px solid rgba(226, 118, 42, 0.32);
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 0.72rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  margin-bottom: var(--space-4);
}

.hero__eyebrow-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--orange);
}

.hero__title {
  font-size: clamp(1.9rem, 4vw, 3rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  max-width: 16ch;
}

.hero__title-grad {
  background: linear-gradient(100deg, var(--cream) 25%, var(--orange-2) 95%);
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
  background: var(--orange);
  color: #1a1206;
}

.btn--primary:hover {
  background: var(--orange-2);
}

.btn--ghost {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

.btn--ghost:hover {
  border-color: var(--orange);
}

.catalog {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
  padding-block: var(--space-7);
}

/* El buscador dedicado de la vista se muestra en tablet/móvil (el del header colapsa). */
.catalog__search {
  display: none;
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

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--surface-2);
  border-top-color: var(--orange);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 860px) {
  .hero__inner {
    grid-template-columns: 1fr;
    gap: var(--space-6);
  }
  .catalog__search {
    display: block;
  }
  .hero__eyebrow {
    display: none;
  }
}
</style>
