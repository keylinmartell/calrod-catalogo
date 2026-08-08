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
/* Grid responsive: auto-fill, mínimo ~255px por tarjeta (§6). */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(255px, 1fr));
  gap: var(--space-5);
}

@media (max-width: 480px) {
  .grid {
    grid-template-columns: 1fr;
  }
}
</style>
