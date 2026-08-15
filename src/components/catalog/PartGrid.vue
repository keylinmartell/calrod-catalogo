<script setup lang="ts">
import type { Part } from '@/types/part'
import PartCard from './PartCard.vue'

defineProps<{ parts: Part[] }>()
</script>

<template>
  <div class="grid">
    <PartCard v-for="part in parts" :key="part.id" :part="part" />
  </div>
</template>

<style scoped>
/* Grid responsive: auto-fill, mínimo ~215px por tarjeta (más chicas en grande). */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(215px, 1fr));
  gap: var(--space-4);
}

@media (max-width: 480px) {
  .grid {
    grid-template-columns: 1fr;
  }
}
</style>
