<script setup lang="ts">
import { computed } from 'vue'
import { useFilters } from '@/composables/useFilters'

const {
  categories,
  activeCategories,
  vehicleBrand,
  vehicleModel,
  searchInResults,
  viewMode,
  setSearchInResults,
  setViewMode,
} = useFilters()

const currentCategoryName = computed(() => {
  if (!activeCategories.value.length) return ''
  const cat = categories.value.find((c) => c.id === activeCategories.value[0])
  return cat ? cat.name : ''
})

function onSearchInput(e: Event) {
  setSearchInResults((e.target as HTMLInputElement).value)
}

function clearSearch() {
  setSearchInResults('')
}
</script>

<template>
  <div class="toolbar">
    <!-- Fila superior: Breadcrumb + Tag pills + Toggle lista/grid + Buscador en resultado -->
    <div class="toolbar__row">
      <!-- Breadcrumbs -->
      <nav class="breadcrumb" aria-label="Ruta de navegación">
        <span class="breadcrumb__item">Inicio</span>
        <span class="breadcrumb__sep">/</span>
        <span v-if="currentCategoryName" class="breadcrumb__item">
          {{ currentCategoryName }}
        </span>
        <span v-else class="breadcrumb__item">Catálogo</span>
        <template v-if="vehicleBrand">
          <span class="breadcrumb__sep">/</span>
          <span class="breadcrumb__item">{{ vehicleBrand }}</span>
        </template>
        <template v-if="vehicleModel">
          <span class="breadcrumb__sep">/</span>
          <span class="breadcrumb__item breadcrumb__item--active">{{ vehicleModel }}</span>
        </template>
      </nav>

      <!-- Controles de la derecha: Grid/List switch + Buscador en resultado -->
      <div class="toolbar__right">
        <!-- Switch vista Grid / Lista -->
        <div class="view-switch" role="group" aria-label="Cambiar vista">
          <button
            type="button"
            class="view-switch__btn"
            :class="{ 'view-switch__btn--active': viewMode === 'grid' }"
            aria-label="Vista en cuadrícula"
            title="Vista en cuadrícula"
            @click="setViewMode('grid')"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="7" height="7" rx="1" />
              <rect x="14" y="3" width="7" height="7" rx="1" />
              <rect x="3" y="14" width="7" height="7" rx="1" />
              <rect x="14" y="14" width="7" height="7" rx="1" />
            </svg>
          </button>
          <button
            type="button"
            class="view-switch__btn"
            :class="{ 'view-switch__btn--active': viewMode === 'list' }"
            aria-label="Vista en lista"
            title="Vista en lista"
            @click="setViewMode('list')"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="8" y1="6" x2="21" y2="6" stroke-linecap="round" />
              <line x1="8" y1="12" x2="21" y2="12" stroke-linecap="round" />
              <line x1="8" y1="18" x2="21" y2="18" stroke-linecap="round" />
              <line x1="3" y1="6" x2="3.01" y2="6" stroke-linecap="round" stroke-width="3" />
              <line x1="3" y1="12" x2="3.01" y2="12" stroke-linecap="round" stroke-width="3" />
              <line x1="3" y1="18" x2="3.01" y2="18" stroke-linecap="round" stroke-width="3" />
            </svg>
          </button>
        </div>

        <!-- Buscador dentro del resultado -->
        <div class="result-search">
          <input
            type="text"
            class="result-search__input"
            placeholder="Buscar en el resultado"
            :value="searchInResults"
            aria-label="Buscar en el resultado"
            @input="onSearchInput"
          />
          <button
            v-if="searchInResults"
            type="button"
            class="result-search__clear"
            aria-label="Limpiar búsqueda"
            @click="clearSearch"
          >
            ✕
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.toolbar {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: var(--space-3) var(--space-4);
  width: 100%;
}

.toolbar__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  flex-wrap: wrap;
}

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.84rem;
  color: var(--charcoal);
  white-space: nowrap;
}

.breadcrumb__item {
  color: var(--charcoal);
  font-weight: 500;
}

.breadcrumb__item--active {
  color: var(--cream);
  font-weight: 600;
}

.breadcrumb__sep {
  color: var(--border-strong);
  font-size: 0.75rem;
}

/* Controles derechos */
.toolbar__right {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-left: auto;
}

/* Switch Grid / List */
.view-switch {
  display: flex;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 2px;
  gap: 2px;
}

.view-switch__btn {
  display: grid;
  place-content: center;
  width: 30px;
  height: 30px;
  border-radius: calc(var(--radius-sm) - 2px);
  border: none;
  background: none;
  color: var(--charcoal);
  cursor: pointer;
  transition: all 0.12s ease;
}

.view-switch__btn svg {
  width: 16px;
  height: 16px;
}

.view-switch__btn:hover {
  color: var(--cream);
}

.view-switch__btn--active {
  background: var(--surface);
  color: var(--blue-2);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
}

/* Buscador en el resultado */
.result-search {
  position: relative;
  display: flex;
  align-items: center;
  min-width: 180px;
}

.result-search__input {
  width: 100%;
  height: 34px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 0 26px 0 var(--space-3);
  font-size: 0.82rem;
  color: var(--cream);
  outline: none;
  transition: border-color 0.15s ease;
}

.result-search__input:focus {
  border-color: var(--blue);
}

.result-search__input::placeholder {
  color: var(--charcoal);
}

.result-search__clear {
  position: absolute;
  right: 6px;
  background: none;
  border: none;
  color: var(--charcoal);
  font-size: 0.8rem;
  cursor: pointer;
  padding: 2px 4px;
  display: grid;
  place-content: center;
}

.result-search__clear:hover {
  color: var(--cream);
}

@media (max-width: 768px) {
  .toolbar__right {
    width: 100%;
    justify-content: space-between;
    margin-left: 0;
  }
  .result-search {
    flex: 1;
  }
}
</style>
