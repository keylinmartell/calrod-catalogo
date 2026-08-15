<script setup lang="ts">
/**
 * CategoryIcon — ícono de línea por categoría, mapeado por slug.
 * Trazo limpio (currentColor) para heredar el color del contexto, en línea
 * con LogoMark. Si el slug no está mapeado, cae a un engrane genérico.
 */
withDefaults(defineProps<{ slug?: string | null; size?: number }>(), {
  size: 22,
})
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
    aria-hidden="true"
  >
    <!-- Alimentación e Inyección: bomba de combustible -->
    <template v-if="slug === 'alimentacion-e-inyeccion'">
      <path d="M4 20V6a2 2 0 0 1 2-2h5a2 2 0 0 1 2 2v14" />
      <path d="M3 20h11" />
      <path d="M6 11h5" />
      <path d="M13 9h3l3 3v5a1.5 1.5 0 0 1-3 0v-4" />
    </template>

    <!-- Carrocería: silueta de auto -->
    <template v-else-if="slug === 'carroceria'">
      <path d="M3 13l2-5a2 2 0 0 1 1.9-1.3h10.2A2 2 0 0 1 19 8l2 5" />
      <path d="M2.5 13h19v4a1 1 0 0 1-1 1h-1.5a1 1 0 0 1-1-1v-1H6v1a1 1 0 0 1-1 1H3.5a1 1 0 0 1-1-1z" />
      <path d="M6.5 15.5h.01M17.5 15.5h.01" />
    </template>

    <!-- Dirección y Suspensión: volante -->
    <template v-else-if="slug === 'direccion-y-suspension'">
      <circle cx="12" cy="12" r="9" />
      <circle cx="12" cy="12" r="2.5" />
      <path d="M12 9.5V3M9.9 13.4l-5.2 4M14.1 13.4l5.2 4" />
    </template>

    <!-- Freno: disco de freno con caliper -->
    <template v-else-if="slug === 'freno'">
      <circle cx="12" cy="12" r="8" />
      <circle cx="12" cy="12" r="3" />
      <path d="M16 6.5a6 6 0 0 1 0 11" />
    </template>

    <!-- Lubricantes: aceitera / gota -->
    <template v-else-if="slug === 'lubricantes'">
      <path d="M3 14v-3h6l3 2h4V9h2a2 2 0 0 1 2 2v4a1 1 0 0 1-1 1H5a2 2 0 0 1-2-2z" />
      <path d="M9 11V8h4" />
      <path d="M18 9l1.5-2.5" />
    </template>

    <!-- Motor: bloque de motor -->
    <template v-else-if="slug === 'motor'">
      <path d="M5 9h2V7h4v2h3l2 2h2v5a1 1 0 0 1-1 1h-1v-2h-3v2H7a2 2 0 0 1-2-2v-1H3v-3h2z" />
      <path d="M9 7V5h3" />
    </template>

    <!-- Sistema Eléctrico: rayo -->
    <template v-else-if="slug === 'sistema-electrico'">
      <path d="M13 2L4 14h7l-1 8 9-12h-7z" />
    </template>

    <!-- Sistema Escape: tubo de escape con humo -->
    <template v-else-if="slug === 'sistema-escape'">
      <path d="M3 14h11a3 3 0 0 1 3 3v0h4" />
      <path d="M3 14v3a1 1 0 0 0 1 1h10" />
      <path d="M19 9c1.2 0 1.2 1.5 2.4 1.5" />
      <path d="M17 6c1.2 0 1.2 1.5 2.4 1.5" />
    </template>

    <!-- Transmisión: engrane -->
    <template v-else-if="slug === 'transmision'">
      <circle cx="12" cy="12" r="3" />
      <path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M19.1 4.9L17 7M7 17l-2.1 2.1" />
    </template>

    <!-- Fallback: engrane genérico -->
    <template v-else>
      <circle cx="12" cy="12" r="3" />
      <path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M19.1 4.9L17 7M7 17l-2.1 2.1" />
    </template>
  </svg>
</template>
