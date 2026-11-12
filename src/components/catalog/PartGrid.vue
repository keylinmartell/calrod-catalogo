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
/* Grid responsive: tarjetas compactas que aprovechan todo el ancho */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(175px, 1fr));
  gap: var(--space-3);
}

@media (max-width: 1024px) {
  .grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  }
}

@media (max-width: 560px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: var(--space-2);
  }
}
</style>
