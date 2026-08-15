<script setup lang="ts">
/**
 * GearSpinner — indicador de carga con una tuerca/engrane girando.
 * Reutiliza el motivo de marca (engrane) en trazo limpio con currentColor,
 * así hereda el color del contexto. Reemplaza al spinner circular genérico.
 */
withDefaults(defineProps<{ size?: number }>(), { size: 40 })
</script>

<template>
  <svg
    class="gear-spinner"
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
    role="status"
    aria-label="Cargando"
  >
    <!-- Engrane: aro dentado + cubo central. Gira sobre su centro. -->
    <circle cx="12" cy="12" r="3.2" />
    <path
      d="M12 1.8v3M12 19.2v3M1.8 12h3M19.2 12h3M4.8 4.8l2.1 2.1M17.1 17.1l2.1 2.1M19.2 4.8L17.1 6.9M6.9 17.1L4.8 19.2"
    />
  </svg>
</template>

<style scoped>
.gear-spinner {
  color: var(--blue-2);
  animation: gear-spin 1.6s linear infinite;
  transform-origin: 50% 50%;
}

@keyframes gear-spin {
  to {
    transform: rotate(360deg);
  }
}

@media (prefers-reduced-motion: reduce) {
  .gear-spinner {
    animation: none;
  }
}
</style>
