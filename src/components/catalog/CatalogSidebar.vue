<script setup lang="ts">
import { computed, ref } from 'vue'
import { useFilters } from '@/composables/useFilters'

const {
  categories,
  brands,
  activeCategories,
  activeBrands,
  vehicleBrand,
  vehicleModel,
  vehicleBrandOptions,
  vehicleModelOptions,
  categoryCounts,
  brandCounts,
  toggleCategory,
  toggleBrand,
  toggleVehicleBrand,
  toggleVehicleModel,
  hasActiveFilters,
  clearFilters,
  displayParts,
} = useFilters()

// Búsquedas internas para filtrar las listas largas de opciones en el sidebar
const brandSearch = ref('')
const modelSearch = ref('')
const categorySearch = ref('')

const filteredBrandOptions = computed(() => {
  const q = brandSearch.value.trim().toLowerCase()
  if (!q) return vehicleBrandOptions.value
  return vehicleBrandOptions.value.filter((b) => b.toLowerCase().includes(q))
})

const filteredModelOptions = computed(() => {
  const q = modelSearch.value.trim().toLowerCase()
  if (!q) return vehicleModelOptions.value
  return vehicleModelOptions.value.filter((m) => m.toLowerCase().includes(q))
})

const filteredCategories = computed(() => {
  const q = categorySearch.value.trim().toLowerCase()
  if (!q) return categories.value
  return categories.value.filter((c) => c.name.toLowerCase().includes(q))
})

// Título dinámico del panel superior según selección
const currentBannerTitle = computed(() => {
  if (activeCategories.value.length === 1) {
    const cat = categories.value.find((c) => c.id === activeCategories.value[0])
    if (cat) return `${cat.name}: Rendimiento y Seguridad para tu Vehículo`
  }
  if (vehicleBrand.value && vehicleModel.value) {
    return `Repuestos para ${vehicleBrand.value} ${vehicleModel.value}`
  }
  if (vehicleBrand.value) {
    return `Repuestos y Piezas para ${vehicleBrand.value}`
  }
  return 'Catálogo de Repuestos'
})
</script>

<template>
  <aside class="sidebar" aria-label="Filtros del catálogo">
    <!-- Tarjeta informativa superior (estilo SEO/Resultados de la referencia) -->
    <div class="sidebar__banner">
      <h2 class="sidebar__banner-title">{{ currentBannerTitle }}</h2>
      <p class="sidebar__banner-results mono">
        Resultados ({{ displayParts.length }})
      </p>
      <button
        v-if="hasActiveFilters"
        type="button"
        class="sidebar__clear-btn mono"
        @click="clearFilters"
      >
        Limpiar todos los filtros
      </button>
    </div>


    <!-- Sección: Marca del vehículo -->
    <div class="facet-group">
      <div class="facet-group__header">
        <h3 class="facet-group__title">Marca</h3>
        <button
          v-if="vehicleBrand"
          type="button"
          class="facet-group__clear"
          @click="toggleVehicleBrand(vehicleBrand)"
        >
          Borrar
        </button>
      </div>

      <!-- Buscador de marcas -->
      <div class="facet-search">
        <input
          v-model="brandSearch"
          type="text"
          class="facet-search__input"
          placeholder="Buscar marca..."
          aria-label="Buscar marca de vehículo"
        />
        <svg
          class="facet-search__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </div>

      <!-- Lista de checkboxes desplazable -->
      <div class="facet-list">
        <label
          v-for="b in filteredBrandOptions"
          :key="b"
          class="facet-item"
          :class="{ 'facet-item--active': vehicleBrand.toLowerCase() === b.toLowerCase() }"
        >
          <input
            type="checkbox"
            class="facet-checkbox"
            :checked="vehicleBrand.toLowerCase() === b.toLowerCase()"
            @change="toggleVehicleBrand(b)"
          />
          <span class="facet-name">{{ b }}</span>
        </label>
        <p v-if="!filteredBrandOptions.length" class="facet-empty">
          No se encontró "{{ brandSearch }}"
        </p>
      </div>
    </div>

    <!-- Sección: Modelo de vehículo (siempre disponible o al seleccionar marca) -->
    <div v-if="filteredModelOptions.length" class="facet-group">
      <div class="facet-group__header">
        <h3 class="facet-group__title">
          Modelo
          <span v-if="vehicleBrand" class="facet-group__sub">({{ vehicleBrand }})</span>
        </h3>
        <button
          v-if="vehicleModel"
          type="button"
          class="facet-group__clear"
          @click="toggleVehicleModel(vehicleModel)"
        >
          Borrar
        </button>
      </div>

      <!-- Buscador de modelos -->
      <div class="facet-search">
        <input
          v-model="modelSearch"
          type="text"
          class="facet-search__input"
          placeholder="Buscar modelo..."
          aria-label="Buscar modelo de vehículo"
        />
        <svg
          class="facet-search__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </div>

      <!-- Lista de checkboxes de modelo -->
      <div class="facet-list">
        <label
          v-for="m in filteredModelOptions"
          :key="m"
          class="facet-item"
          :class="{ 'facet-item--active': vehicleModel.toLowerCase() === m.toLowerCase() }"
        >
          <input
            type="checkbox"
            class="facet-checkbox"
            :checked="vehicleModel.toLowerCase() === m.toLowerCase()"
            @change="toggleVehicleModel(m)"
          />
          <span class="facet-name">{{ m }}</span>
        </label>
        <p v-if="!filteredModelOptions.length" class="facet-empty">
          No se encontró "{{ modelSearch }}"
        </p>
      </div>
    </div>

    <!-- Sección: Producto / Categoría -->
    <div v-if="categories.length" class="facet-group">
      <div class="facet-group__header">
        <h3 class="facet-group__title">Producto</h3>
        <button
          v-if="activeCategories.length"
          type="button"
          class="facet-group__clear"
          @click="activeCategories.forEach((id) => toggleCategory(id))"
        >
          Borrar
        </button>
      </div>

      <!-- Buscador de categorías si hay varias -->
      <div v-if="categories.length > 5" class="facet-search">
        <input
          v-model="categorySearch"
          type="text"
          class="facet-search__input"
          placeholder="Buscar tipo de repuesto..."
          aria-label="Buscar categoría"
        />
        <svg
          class="facet-search__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
      </div>

      <div class="facet-list">
        <label
          v-for="c in filteredCategories"
          :key="c.id"
          class="facet-item"
          :class="{ 'facet-item--active': activeCategories.includes(c.id) }"
        >
          <input
            type="checkbox"
            class="facet-checkbox"
            :checked="activeCategories.includes(c.id)"
            @change="toggleCategory(c.id)"
          />
          <span class="facet-name">{{ c.name }}</span>
          <span v-if="categoryCounts[c.id]" class="facet-count mono">
            ({{ categoryCounts[c.id] }})
          </span>
        </label>
      </div>
    </div>

    <!-- Sección: Marca de Repuesto (Fabricante: Wurtex, STP, etc.) -->
    <div v-if="brands.length" class="facet-group">
      <div class="facet-group__header">
        <h3 class="facet-group__title">Marca de Repuesto</h3>
        <button
          v-if="activeBrands.length"
          type="button"
          class="facet-group__clear"
          @click="activeBrands.forEach((id) => toggleBrand(id))"
        >
          Borrar
        </button>
      </div>

      <div class="facet-list">
        <label
          v-for="b in brands"
          :key="b.id"
          class="facet-item"
          :class="{ 'facet-item--active': activeBrands.includes(b.id) }"
        >
          <input
            type="checkbox"
            class="facet-checkbox"
            :checked="activeBrands.includes(b.id)"
            @change="toggleBrand(b.id)"
          />
          <span class="facet-name">{{ b.name }}</span>
          <span v-if="brandCounts[b.id]" class="facet-count mono">
            ({{ brandCounts[b.id] }})
          </span>
        </label>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  width: 100%;
}

/* Tarjeta informativa superior */
.sidebar__banner {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.sidebar__banner-title {
  font-family: var(--font-display);
  font-size: 1.05rem;
  font-weight: 700;
  line-height: 1.35;
  color: var(--cream);
}

.sidebar__banner-results {
  font-size: 0.85rem;
  color: var(--charcoal);
}

.sidebar__clear-btn {
  margin-top: var(--space-2);
  align-self: flex-start;
  font-size: 0.8rem;
  color: var(--blue-2);
  background: none;
  border: none;
  text-decoration: underline;
  text-underline-offset: 3px;
  cursor: pointer;
  padding: 0;
}

.sidebar__clear-btn:hover {
  color: var(--cream);
}

/* Grupo de facetas / sección de filtros */
.facet-group {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.facet-group__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.facet-group__title {
  font-family: var(--font-display);
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--cream);
}

.facet-group__sub {
  font-size: 0.8rem;
  font-weight: 400;
  color: var(--blue-2);
  margin-left: 4px;
}

.facet-group__clear {
  font-size: 0.75rem;
  color: var(--blue-2);
  background: none;
  border: none;
  cursor: pointer;
  text-decoration: underline;
  padding: 0;
}

/* Buscador de faceta */
.facet-search {
  position: relative;
  display: flex;
  align-items: center;
}

.facet-search__input {
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

.facet-search__input:focus {
  border-color: var(--blue);
}

.facet-search__input::placeholder {
  color: var(--charcoal);
}

.facet-search__icon {
  position: absolute;
  right: 8px;
  width: 14px;
  height: 14px;
  color: var(--charcoal);
  pointer-events: none;
}

/* Lista de opciones con scroll vertical */
.facet-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
  max-height: 220px;
  overflow-y: auto;
  padding-right: 4px;
  scrollbar-width: thin;
  scrollbar-color: var(--border-strong) transparent;
}

.facet-list::-webkit-scrollbar {
  width: 4px;
}

.facet-list::-webkit-scrollbar-thumb {
  background: var(--border-strong);
  border-radius: 4px;
}

.facet-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: 4px 6px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  user-select: none;
  transition: background 0.12s ease;
}

.facet-item:hover {
  background: var(--surface-2);
}

.facet-item--active {
  background: rgba(26, 61, 110, 0.14);
}

.facet-checkbox {
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

.facet-checkbox:checked {
  background: var(--blue);
  border-color: var(--blue-2);
}

.facet-checkbox:checked::before {
  content: '';
  width: 9px;
  height: 6px;
  border-left: 2px solid #fff;
  border-bottom: 2px solid #fff;
  transform: rotate(-45deg) translate(1px, -1px);
}

.facet-name {
  font-size: 0.85rem;
  color: var(--cream);
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.facet-count {
  font-size: 0.75rem;
  color: var(--charcoal);
}

.facet-empty {
  font-size: 0.8rem;
  color: var(--charcoal);
  padding: var(--space-2) 0;
}
</style>
