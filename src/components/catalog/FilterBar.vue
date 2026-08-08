<script setup lang="ts">
import { useFilters } from '@/composables/useFilters'

defineProps<{ resultCount: number }>()

const {
  categories,
  activeCategories,
  categoryCounts,
  hasActiveFilters,
  toggleCategory,
  clearFilters,
} = useFilters()
</script>

<template>
  <div class="filterbar">
    <div class="filterbar__chips" role="group" aria-label="Filtrar por categoría">
      <button
        v-for="cat in categories"
        :key="cat.value"
        class="chip"
        :class="{ 'chip--active': activeCategories.includes(cat.value) }"
        :aria-pressed="activeCategories.includes(cat.value)"
        @click="toggleCategory(cat.value)"
      >
        {{ cat.label }}
        <span class="chip__count mono">{{ categoryCounts[cat.value] }}</span>
      </button>
    </div>

    <div class="filterbar__meta">
      <span class="filterbar__count mono">{{ resultCount }} resultados</span>
      <button
        v-if="hasActiveFilters"
        class="filterbar__clear"
        @click="clearFilters"
      >
        Limpiar filtros
      </button>
    </div>
  </div>
</template>

<style scoped>
.filterbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.filterbar__chips {
  display: flex;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.chip {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  border-radius: 999px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--cream);
  font-size: 0.88rem;
  font-weight: 500;
  transition: all 0.15s ease;
}

.chip:hover {
  border-color: var(--border-strong);
}

.chip--active {
  background: rgba(226, 118, 42, 0.16);
  border-color: var(--orange);
  color: var(--orange-2);
}

.chip__count {
  font-size: 0.75rem;
  color: var(--charcoal);
}

.chip--active .chip__count {
  color: var(--orange-2);
}

.filterbar__meta {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.filterbar__count {
  color: var(--charcoal);
  font-size: 0.85rem;
}

.filterbar__clear {
  color: var(--orange-2);
  font-size: 0.85rem;
  font-weight: 500;
  text-decoration: underline;
  text-underline-offset: 3px;
}

/* Móvil: chips con scroll horizontal (§6). */
@media (max-width: 640px) {
  .filterbar__chips {
    flex-wrap: nowrap;
    overflow-x: auto;
    padding-bottom: var(--space-2);
    -webkit-overflow-scrolling: touch;
  }
  .chip {
    flex-shrink: 0;
  }
}
</style>
