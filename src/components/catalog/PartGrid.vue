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
/* Grid responsive: auto-fill, tarjetas cuadradas compactas ~170px */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  gap: var(--space-3);
}

@media (max-width: 480px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-2);
  }
}
</style>
