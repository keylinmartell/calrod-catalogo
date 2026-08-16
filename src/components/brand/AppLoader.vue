<script setup lang="ts">
/**
 * AppLoader — overlay de arranque a pantalla completa.
 *
 * Se muestra sobre toda la vista mientras `booting` es true (ver useAppLoading).
 * Reutiliza la LLANTA del hero (misma geometría que TireWatermark) pero pequeña
 * y girando en bucle, más el texto "Cargando…". Cuando la primera vista termina
 * de cargar sus endpoints, `booting` pasa a false y el overlay se desvanece.
 */
import { useAppLoading } from '@/composables/useAppLoading'

const { booting: show } = useAppLoading()
</script>

<template>
  <Transition name="app-loader-fade">
    <div v-if="show" class="app-loader" role="status" aria-live="polite" aria-label="Cargando catálogo">
      <div class="app-loader__inner">
        <svg class="loader-tire" viewBox="0 0 200 200" aria-hidden="true">
          <defs>
            <radialGradient id="al-rubber" cx="35%" cy="30%" r="75%">
              <stop offset="0%" stop-color="var(--al-r0)" />
              <stop offset="35%" stop-color="var(--al-r1)" />
              <stop offset="80%" stop-color="var(--al-r2)" />
              <stop offset="100%" stop-color="var(--al-r3)" />
            </radialGradient>
            <radialGradient id="al-rim" cx="35%" cy="30%" r="75%">
              <stop offset="0%" stop-color="var(--al-rim0)" />
              <stop offset="35%" stop-color="var(--al-rim1)" />
              <stop offset="65%" stop-color="var(--al-rim2)" />
              <stop offset="100%" stop-color="var(--al-rim3)" />
            </radialGradient>
            <linearGradient id="al-spoke" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="var(--al-sp0)" stop-opacity="0.9" />
              <stop offset="55%" stop-color="var(--al-sp1)" stop-opacity="0.5" />
              <stop offset="100%" stop-color="var(--al-sp2)" stop-opacity="0.9" />
            </linearGradient>
            <radialGradient id="al-hub" cx="35%" cy="30%" r="75%">
              <stop offset="0%" stop-color="var(--al-h0)" />
              <stop offset="45%" stop-color="var(--al-h1)" />
              <stop offset="100%" stop-color="var(--al-h2)" />
            </radialGradient>
          </defs>

          <circle cx="100" cy="100" r="92" fill="url(#al-rubber)" />
          <circle cx="100" cy="100" r="86" fill="none" stroke="var(--al-tread)" stroke-width="10" stroke-dasharray="7 5" opacity="0.55" />
          <circle cx="100" cy="100" r="70" fill="none" stroke="var(--al-tread)" stroke-width="3" />
          <circle cx="100" cy="100" r="58" fill="url(#al-rim)" stroke="var(--al-rim3)" stroke-width="1.5" />

          <g v-for="a in [0, 72, 144, 216, 288]" :key="a" :transform="`rotate(${a} 100 100)`">
            <path d="M100,100 L100,50 A8,8 0 0 1 108,58 L104,96 Z" fill="url(#al-spoke)" />
          </g>

          <circle cx="100" cy="100" r="17" fill="url(#al-hub)" stroke="var(--al-rim3)" stroke-width="1.5" />
          <circle cx="100" cy="100" r="6" fill="var(--al-r2)" />
        </svg>

        <p class="app-loader__text">Cargando catálogo…</p>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.app-loader {
  position: fixed;
  inset: 0;
  z-index: 2000;
  display: grid;
  place-items: center;
  background: var(--bg);
  /* Refuerzo del degradado del body para que el overlay no se vea plano. */
  background-image:
    radial-gradient(ellipse 900px 520px at 10% -8%, rgba(26, 61, 110, 0.05), transparent 60%),
    radial-gradient(ellipse 640px 480px at 100% 4%, rgba(184, 190, 200, 0.04), transparent 60%);
}

.app-loader__inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
}

/* Misma paleta de la llanta que TireWatermark (modo oscuro por defecto). */
.loader-tire {
  width: 72px;
  height: 72px;
  transform-origin: 50% 50%;
  animation: loader-tire-spin 1.4s linear infinite;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.4));

  --al-r0: #4a4d52;  --al-r1: #25272b;  --al-r2: #111214;  --al-r3: #020203;
  --al-rim0: #f4f5f7; --al-rim1: #c9ccd1; --al-rim2: #8d9096; --al-rim3: #54565b;
  --al-sp0: #ffffff; --al-sp1: #b7bac0; --al-sp2: #54565b;
  --al-h0: #ffffff;  --al-h1: #cfd2d7;  --al-h2: #6b6e73;
  --al-tread: #050506;
}

:root[data-theme='light'] .loader-tire {
  --al-r0: #3a4049;  --al-r1: #23272e;  --al-r2: #101318;  --al-r3: #030405;
  --al-rim0: #ffffff; --al-rim1: #d3d8df; --al-rim2: #949ba6; --al-rim3: #5b626d;
  --al-sp0: #ffffff; --al-sp1: #b9bec7; --al-sp2: #626975;
  --al-h0: #ffffff;  --al-h1: #cbd0d7;  --al-h2: #767d89;
  --al-tread: #030405;
}

@keyframes loader-tire-spin {
  to {
    transform: rotate(-360deg);
  }
}

.app-loader__text {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  letter-spacing: 0.06em;
  color: var(--charcoal);
}

/* Desvanecido de salida cuando termina la carga. */
.app-loader-fade-leave-active {
  transition: opacity 0.4s ease;
}
.app-loader-fade-leave-to {
  opacity: 0;
}

@media (prefers-reduced-motion: reduce) {
  .loader-tire {
    animation: none;
  }
}
</style>
