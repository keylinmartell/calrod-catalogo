<script setup lang="ts">
/**
 * LogoMark — ícono de marca CalRod: engrane + llave en trazo limpio de línea,
 * sin la textura grunge del logo físico (§5). El engrane usa el color charcoal
 * y la llave el naranja de marca.
 */
withDefaults(defineProps<{ size?: number }>(), { size: 40 })
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 48 48"
    fill="none"
    role="img"
    aria-label="Logo CalRod"
    xmlns="http://www.w3.org/2000/svg"
  >
    <!-- Engrane: aro dentado en trazo limpio -->
    <g
      stroke="var(--charcoal)"
      stroke-width="2.2"
      stroke-linejoin="round"
      stroke-linecap="round"
    >
      <path
        d="M24 4.5l2.8 3.9 4.7-1.3 1 4.8 4.8 1 -1.3 4.7 3.9 2.8 -3.9 2.8 1.3 4.7 -4.8 1 -1 4.8 -4.7-1.3 -2.8 3.9 -2.8-3.9 -4.7 1.3 -1-4.8 -4.8-1 1.3-4.7L6.5 24l3.9-2.8 -1.3-4.7 4.8-1 1-4.8 4.7 1.3z"
      />
      <circle cx="24" cy="24" r="8.2" />
    </g>
    <!-- Llave: cruza el engrane, en naranja de marca -->
    <path
      d="M30.5 17.5a5 5 0 0 1-6.6 6.6L15 33l-2.2-2.2 8.9-8.9a5 5 0 0 1 6.6-6.6l-3 3 2.2 2.2 3-3z"
      fill="var(--orange)"
      stroke="var(--orange)"
      stroke-width="1"
      stroke-linejoin="round"
    />
  </svg>
</template>
