<script setup lang="ts">
/**
 * WrenchWatermark — rueda dentada de marca usada como marca de agua sutil
 * detrás de la copia del hero (§5, ref. de diseño "ver figura").
 * Los dientes son un anillo de trazo grueso con dash: el "zigzag punteado".
 * r = 79.577 hace la circunferencia = 500, así el dash de 12.5 cierra exacto
 * (20 dientes, sin costura). Se oculta en móvil (§6).
 */
</script>

<template>
  <svg
    class="watermark"
    viewBox="0 0 200 200"
    fill="none"
    aria-hidden="true"
    xmlns="http://www.w3.org/2000/svg"
  >
    <g stroke="var(--cream)">
      <!-- Dientes: anillo grueso punteado (zigzag). -->
      <circle
        cx="100"
        cy="100"
        r="79.577"
        stroke-width="17"
        stroke-dasharray="12.5 12.5"
      />
      <!-- Borde interior de la corona. -->
      <circle cx="100" cy="100" r="68" stroke-width="2.5" />
      <!-- Cubo central. -->
      <circle cx="100" cy="100" r="27" stroke-width="2.5" />
    </g>
  </svg>
</template>

<style scoped>
.watermark {
  position: absolute;
  top: -46px;
  left: clamp(-40px, 4vw, 96px);
  width: clamp(300px, 36vw, 470px);
  height: auto;
  opacity: 0.06;
  pointer-events: none;
  z-index: 0;
}


</style>
