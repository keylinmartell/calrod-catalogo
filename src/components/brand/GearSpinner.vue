<script setup lang="ts">
/**
 * GearSpinner / TireSpinner — indicador de carga oficial de CalRod (llanta girando en bucle).
 * Reemplaza los cargadores genéricos en todas las vistas y componentes del proyecto.
 */
import { useId } from 'vue'

withDefaults(defineProps<{ size?: number }>(), { size: 44 })

const uid = useId()
</script>

<template>
  <svg
    class="tire-spinner"
    :width="size"
    :height="size"
    viewBox="0 0 200 200"
    role="status"
    aria-label="Cargando"
  >
    <defs>
      <radialGradient :id="`ts-rubber-${uid}`" cx="35%" cy="30%" r="75%">
        <stop offset="0%" stop-color="var(--ts-r0)" />
        <stop offset="35%" stop-color="var(--ts-r1)" />
        <stop offset="80%" stop-color="var(--ts-r2)" />
        <stop offset="100%" stop-color="var(--ts-r3)" />
      </radialGradient>
      <radialGradient :id="`ts-rim-${uid}`" cx="35%" cy="30%" r="75%">
        <stop offset="0%" stop-color="var(--ts-rim0)" />
        <stop offset="35%" stop-color="var(--ts-rim1)" />
        <stop offset="65%" stop-color="var(--ts-rim2)" />
        <stop offset="100%" stop-color="var(--ts-rim3)" />
      </radialGradient>
      <linearGradient :id="`ts-spoke-${uid}`" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stop-color="var(--ts-sp0)" stop-opacity="0.95" />
        <stop offset="55%" stop-color="var(--ts-sp1)" stop-opacity="0.6" />
        <stop offset="100%" stop-color="var(--ts-sp2)" stop-opacity="0.95" />
      </linearGradient>
      <radialGradient :id="`ts-hub-${uid}`" cx="35%" cy="30%" r="75%">
        <stop offset="0%" stop-color="var(--ts-h0)" />
        <stop offset="45%" stop-color="var(--ts-h1)" />
        <stop offset="100%" stop-color="var(--ts-h2)" />
      </radialGradient>
    </defs>

    <circle cx="100" cy="100" r="92" :fill="`url(#ts-rubber-${uid})`" />
    <circle
      cx="100"
      cy="100"
      r="86"
      fill="none"
      stroke="var(--ts-tread)"
      stroke-width="10"
      stroke-dasharray="7 5"
      opacity="0.6"
    />
    <circle cx="100" cy="100" r="70" fill="none" stroke="var(--ts-tread)" stroke-width="3" />
    <circle
      cx="100"
      cy="100"
      r="58"
      :fill="`url(#ts-rim-${uid})`"
      stroke="var(--ts-rim3)"
      stroke-width="1.5"
    />

    <g v-for="a in [0, 72, 144, 216, 288]" :key="a" :transform="`rotate(${a} 100 100)`">
      <path d="M100,100 L100,50 A8,8 0 0 1 108,58 L104,96 Z" :fill="`url(#ts-spoke-${uid})`" />
    </g>

    <circle
      cx="100"
      cy="100"
      r="17"
      :fill="`url(#ts-hub-${uid})`"
      stroke="var(--ts-rim3)"
      stroke-width="1.5"
    />
    <circle cx="100" cy="100" r="6" fill="var(--ts-r2)" />
  </svg>
</template>

<style scoped>
.tire-spinner {
  display: inline-block;
  transform-origin: 50% 50%;
  animation: tire-spin 1.4s linear infinite;
  filter: drop-shadow(0 4px 10px rgba(0, 0, 0, 0.35));
  flex-shrink: 0;

  /* Paleta modo oscuro */
  --ts-r0: #4a4d52;
  --ts-r1: #25272b;
  --ts-r2: #111214;
  --ts-r3: #020203;
  --ts-rim0: #f4f5f7;
  --ts-rim1: #c9ccd1;
  --ts-rim2: #8d9096;
  --ts-rim3: #54565b;
  --ts-sp0: #ffffff;
  --ts-sp1: #b7bac0;
  --ts-sp2: #54565b;
  --ts-h0: #ffffff;
  --ts-h1: #cfd2d7;
  --ts-h2: #6b6e73;
  --ts-tread: #050506;
}

/* Paleta modo claro */
:root[data-theme='light'] .tire-spinner {
  filter: drop-shadow(0 6px 14px rgba(0, 0, 0, 0.2));
  --ts-r0: #3a3f47;
  --ts-r1: #1f2227;
  --ts-r2: #0f1114;
  --ts-r3: #040507;
  --ts-rim0: #f8fafc;
  --ts-rim1: #c4ccd8;
  --ts-rim2: #7b8595;
  --ts-rim3: #303744;
  --ts-sp0: #ffffff;
  --ts-sp1: #a8b3c4;
  --ts-sp2: #424b5a;
  --ts-h0: #ffffff;
  --ts-h1: #a8b3c4;
  --ts-h2: #303744;
  --ts-tread: #000000;
}

@keyframes tire-spin {
  to {
    transform: rotate(360deg);
  }
}

@media (prefers-reduced-motion: reduce) {
  .tire-spinner {
    animation: none;
  }
}
</style>
