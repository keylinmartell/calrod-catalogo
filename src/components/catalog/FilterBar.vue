<script setup lang="ts">
import { useFilters } from '@/composables/useFilters'

defineProps<{ resultCount: number }>()

const { hasActiveFilters, clearFilters } = useFilters()
</script>

<template>
  <div class="filterbar">
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
  justify-content: flex-end;
  gap: var(--space-4);
  flex-wrap: wrap;
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
  color: var(--blue-2);
  font-size: 0.85rem;
  font-weight: 500;
  text-decoration: underline;
  text-underline-offset: 3px;
}
</style>
