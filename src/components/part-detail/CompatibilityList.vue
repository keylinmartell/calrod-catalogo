<script setup lang="ts">
import { computed } from 'vue'
import type { PartCompatibility } from '@/types/part'

const props = defineProps<{ items: PartCompatibility[] }>()

// Agrupamos por marca de vehículo para una lectura tipo ficha técnica.
const grouped = computed(() => {
  const map = new Map<string, PartCompatibility[]>()
  for (const item of props.items) {
    const list = map.get(item.vehicle_brand) ?? []
    list.push(item)
    map.set(item.vehicle_brand, list)
  }
  return Array.from(map.entries()).map(([brand, list]) => ({ brand, list }))
})

function yearRange(c: PartCompatibility) {
  return c.year_from === c.year_to
    ? `${c.year_from}`
    : `${c.year_from}–${c.year_to}`
}
</script>

<template>
  <div class="compat">
    <h2 class="compat__title">Compatibilidad</h2>

    <div v-if="grouped.length" class="compat__groups">
      <div v-for="group in grouped" :key="group.brand" class="compat__group">
        <h3 class="compat__brand">{{ group.brand }}</h3>
        <ul class="compat__models">
          <li v-for="c in group.list" :key="c.id" class="compat__model">
            <span>{{ c.vehicle_model }}</span>
            <span class="compat__years mono">{{ yearRange(c) }}</span>
          </li>
        </ul>
      </div>
    </div>

    <p v-else class="compat__empty">Sin compatibilidad registrada.</p>
  </div>
</template>

<style scoped>
.compat__title {
  font-size: 1.05rem;
  margin-bottom: var(--space-3);
}

.compat__groups {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.compat__brand {
  font-family: var(--font-display);
  font-size: 0.95rem;
  color: var(--orange-2);
  margin-bottom: var(--space-2);
}

.compat__models {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.compat__model {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-2) var(--space-3);
  background: var(--surface-2);
  border-radius: var(--radius-sm);
  font-size: 0.9rem;
}

.compat__years {
  color: var(--charcoal);
  font-size: 0.82rem;
}

.compat__empty {
  color: var(--charcoal);
  font-size: 0.9rem;
}
</style>
