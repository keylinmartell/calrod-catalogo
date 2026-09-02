<script setup lang="ts">
import type { PartCompatibility } from '@/types/part'
import { motorName, vehicleBrandName, vehicleModelName } from '@/types/part'

// Marca, modelo y motor llegan embebidos por las FK del nomenclador (0013/0016),
// de ahí los helpers en vez de leer campos de texto.
defineProps<{ items: PartCompatibility[] }>()

// Rango de años legible aunque falte alguno (o los dos): "2015–2020", "2015+",
// "hasta 2020" o vacío. Los años son opcionales en la BD.
function yearRange(from: number | null, to: number | null): string {
  if (from && to) return from === to ? `${from}` : `${from}–${to}`
  if (from) return `${from}+`
  if (to) return `hasta ${to}`
  return ''
}
</script>

<template>
  <section class="tech-block">
    <h2 class="panel-title">
      <span class="panel-icon">
        <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--blue-2)" stroke-width="1.7">
          <path d="M3 12h4l2-4 4 8 2-4h6"/>
        </svg>
      </span>
      Compatibilidad
      <span v-if="items.length" class="panel-count mono">{{ items.length }}</span>
    </h2>

    <ul v-if="items.length" class="compat-list">
      <li v-for="(item, i) in items" :key="i" class="compat-row">
        <span class="compat-vehicle">
          <b class="compat-brand">{{ vehicleBrandName(item) }}</b>
          <template v-if="vehicleModelName(item)"> {{ vehicleModelName(item) }}</template>
          <span v-if="motorName(item)" class="compat-motor"> · {{ motorName(item) }}</span>
        </span>
        <span
          v-if="yearRange(item.year_from, item.year_to)"
          class="compat-years mono"
        >{{ yearRange(item.year_from, item.year_to) }}</span>
      </li>
    </ul>
    <p v-else class="empty-note">Sin compatibilidad registrada todavía.</p>
  </section>
</template>

<style scoped>
/* Mismo bloque plano que PartSpecSheet: cada vehículo es un renglón, no una
   tarjeta. Antes cada fila traía fondo + borde + radio y una lista de cinco
   compatibilidades se leía como cinco cajas apiladas. */
.tech-block { min-width: 0; }

.panel-title {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  font-family: var(--font-display);
  color: var(--charcoal);
  margin-bottom: var(--space-4);
}
.panel-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}
.panel-count {
  margin-left: auto;
  font-size: 0.72rem;
  letter-spacing: 0.04em;
  color: var(--blue-2);
}

.compat-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
}
.compat-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: var(--space-4);
  padding: 10px 0;
  border-bottom: 1px dotted var(--border);
  font-size: 0.86rem;
}
.compat-row:last-child { border-bottom: none; }
.compat-vehicle { color: var(--text-dim); min-width: 0; }
.compat-brand { color: var(--cream); font-weight: 600; }
.compat-motor { color: var(--blue-2); }
.compat-years { color: var(--charcoal); font-size: 0.78rem; white-space: nowrap; }
.empty-note { color: var(--charcoal); font-size: 0.82rem; font-style: italic; margin: 0; }
</style>
