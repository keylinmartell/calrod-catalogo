<script setup lang="ts">
import type { PartSpec } from '@/types/part'

defineProps<{ specs: PartSpec[]; material?: string | null }>()
</script>

<template>
  <div class="specsheet">
    <h2 class="specsheet__title">Especificaciones</h2>
    <table class="specsheet__table">
      <tbody>
        <tr v-if="material">
          <th scope="row">Material</th>
          <td class="mono">{{ material }}</td>
        </tr>
        <tr v-for="spec in specs" :key="spec.id">
          <th scope="row">{{ spec.label }}</th>
          <td class="mono">{{ spec.value }}</td>
        </tr>
      </tbody>
    </table>
    <p v-if="!specs.length && !material" class="specsheet__empty">
      Sin especificaciones registradas.
    </p>
  </div>
</template>

<style scoped>
.specsheet__title {
  font-size: 1.05rem;
  margin-bottom: var(--space-3);
}

.specsheet__table {
  width: 100%;
  border-collapse: collapse;
}

.specsheet__table th,
.specsheet__table td {
  text-align: left;
  padding: var(--space-3) 0;
  border-bottom: 1px solid var(--border);
  vertical-align: top;
}

.specsheet__table th {
  color: var(--charcoal);
  font-weight: 500;
  width: 40%;
}

.specsheet__table td {
  color: var(--cream);
}

.specsheet__empty {
  color: var(--charcoal);
  font-size: 0.9rem;
}
</style>
