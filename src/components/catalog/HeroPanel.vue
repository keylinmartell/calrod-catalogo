<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  activeParts: number
  brandsCovered: number
  availabilityPct: number
  loading?: boolean
}>()

const totalParts = computed(() => props.loading ? '—' : props.activeParts.toLocaleString('es-MX'))
const totalBrands = computed(() => props.loading ? '—' : props.brandsCovered.toLocaleString('es-MX'))
const availDisplay = computed(() => props.loading ? '—' : `${props.availabilityPct}%`)
</script>

<template>
  <aside class="status-panel" aria-label="CalRod al día">
    <span class="corner tl"></span>
    <span class="corner tr"></span>
    <span class="corner bl"></span>
    <span class="corner br"></span>

    <div class="status-header">
      <span class="pulse"></span>
      <span>CALROD · ESTADO EN VIVO</span>
    </div>

    <div class="status-metrics">
      <div class="metric">
        <span class="metric-label">Piezas activas</span>
        <b class="metric-value">{{ totalParts }}</b>
      </div>

      <div class="metric">
        <span class="metric-label">Marcas cubiertas</span>
        <b class="metric-value">{{ totalBrands }}</b>
      </div>

      <div class="metric metric--availability">
        <span class="metric-label">Disponibilidad</span>
        <b class="metric-value accent">{{ availDisplay }}</b>
        <div class="metric-bar">
          <div class="metric-bar-fill" :style="{ width: `${loading ? 0 : availabilityPct}%` }"></div>
        </div>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.status-panel {
  position: relative;
  background: linear-gradient(165deg, var(--surface), color-mix(in srgb, var(--surface) 85%, black));
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-5) var(--space-5) var(--space-4);
  z-index: 1;
  overflow: hidden;
}

/* HUD corner marks — reemplazan el borde cerrado de "tarjeta" por algo mas tecnico */
.corner {
  position: absolute;
  width: 14px;
  height: 14px;
  border: 1.5px solid rgba(240, 140, 63, 0.55);
}
.corner.tl { top: 10px; left: 10px; border-right: none; border-bottom: none; }
.corner.tr { top: 10px; right: 10px; border-left: none; border-bottom: none; }
.corner.bl { bottom: 10px; left: 10px; border-right: none; border-top: none; }
.corner.br { bottom: 10px; right: 10px; border-left: none; border-top: none; }

.status-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.7rem;
  letter-spacing: 0.09em;
  color: var(--charcoal);
  margin-bottom: var(--space-5);
  padding-left: 2px;
}

.pulse {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ok);
  box-shadow: 0 0 0 0 rgba(107, 191, 123, 0.6);
  animation: pulse-ring 2s infinite;
}
@keyframes pulse-ring {
  0%   { box-shadow: 0 0 0 0 rgba(107, 191, 123, 0.55); }
  70%  { box-shadow: 0 0 0 6px rgba(107, 191, 123, 0); }
  100% { box-shadow: 0 0 0 0 rgba(107, 191, 123, 0); }
}

/* Sin cajas: metricas separadas por hairline vertical, no por bordes cerrados */
.status-metrics {
  display: flex;
}
.metric {
  flex: 1;
  padding: 0 var(--space-4);
  border-left: 1px solid var(--border);
}
.metric:first-child {
  padding-left: 2px;
  border-left: none;
}

.metric-label {
  display: block;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.68rem;
  color: var(--charcoal);
  letter-spacing: 0.02em;
  margin-bottom: 8px;
}

.metric-value {
  display: block;
  font-family: 'Sora', sans-serif;
  font-weight: 700;
  font-size: 1.9rem;
  line-height: 1;
  color: var(--cream);
  font-variant-numeric: tabular-nums;
}
.metric-value.accent { color: var(--orange-2); }

/* Unica barra de progreso: solo donde el numero es un porcentaje, no decoracion repetida */
.metric-bar {
  margin-top: 10px;
  height: 3px;
  border-radius: 2px;
  background: var(--border);
  overflow: hidden;
}
.metric-bar-fill {
  height: 100%;
  background: var(--orange-2);
  border-radius: 2px;
  transition: width 0.8s cubic-bezier(.2,.8,.2,1);
}
</style>