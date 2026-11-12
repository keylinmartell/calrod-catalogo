<script setup lang="ts">
/**
 * TireWatermark — llanta que entra rodando de DERECHA a IZQUIERDA, rebota y se
 * queda girando continuamente en su posición final.
 */
import { ref, watch } from 'vue'
import { useAppLoading } from '@/composables/useAppLoading'

const { booting } = useAppLoading()

const play = ref(!booting.value)
if (!play.value) {
  const stop = watch(booting, (b) => {
    if (!b) {
      play.value = true
      stop()
    }
  })
}
</script>

<template>
  <div class="tire-watermark" :class="{ 'is-playing': play }" aria-hidden="true">
    <div class="tire-travel">
      <div class="tire-bounce">
        <svg class="tire-rotate" viewBox="0 0 200 200">
          <defs>
            <radialGradient id="tw-rubber" cx="35%" cy="30%" r="75%">
              <stop offset="0%"  stop-color="var(--tw-r0)"/>
              <stop offset="35%" stop-color="var(--tw-r1)"/>
              <stop offset="80%" stop-color="var(--tw-r2)"/>
              <stop offset="100%" stop-color="var(--tw-r3)"/>
            </radialGradient>
            <radialGradient id="tw-rim" cx="35%" cy="30%" r="75%">
              <stop offset="0%"  stop-color="var(--tw-rim0)"/>
              <stop offset="35%" stop-color="var(--tw-rim1)"/>
              <stop offset="65%" stop-color="var(--tw-rim2)"/>
              <stop offset="100%" stop-color="var(--tw-rim3)"/>
            </radialGradient>
            <linearGradient id="tw-spoke" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%"  stop-color="var(--tw-sp0)" stop-opacity="0.9"/>
              <stop offset="55%" stop-color="var(--tw-sp1)" stop-opacity="0.5"/>
              <stop offset="100%" stop-color="var(--tw-sp2)" stop-opacity="0.9"/>
            </linearGradient>
            <radialGradient id="tw-hub" cx="35%" cy="30%" r="75%">
              <stop offset="0%"  stop-color="var(--tw-h0)"/>
              <stop offset="45%" stop-color="var(--tw-h1)"/>
              <stop offset="100%" stop-color="var(--tw-h2)"/>
            </radialGradient>
          </defs>

          <circle cx="100" cy="100" r="92" fill="url(#tw-rubber)"/>
          <circle cx="100" cy="100" r="86" fill="none" :stroke="'var(--tw-tread)'" stroke-width="10" stroke-dasharray="7 5" opacity="0.55"/>
          <circle cx="100" cy="100" r="70" fill="none" :stroke="'var(--tw-tread)'" stroke-width="3"/>
          <circle cx="100" cy="100" r="58" fill="url(#tw-rim)" stroke="var(--tw-rim3)" stroke-width="1.5"/>

          <g v-for="a in [0,72,144,216,288]" :key="a" :transform="`rotate(${a} 100 100)`">
            <path d="M100,100 L100,50 A8,8 0 0 1 108,58 L104,96 Z" fill="url(#tw-spoke)"/>
          </g>

          <circle cx="100" cy="100" r="17" fill="url(#tw-hub)" stroke="var(--tw-rim3)" stroke-width="1.5"/>
          <circle cx="100" cy="100" r="6" fill="var(--tw-r2)"/>
        </svg>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Carril: cubre el hero (que ya tiene overflow:hidden) para recortar la entrada. */
.tire-watermark {
  position: absolute;
  inset: 0;
  opacity: 0.24;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;

  /* Paleta de la llanta — modo oscuro (default). */
  --tw-r0: #4a4d52;  --tw-r1: #25272b;  --tw-r2: #111214;  --tw-r3: #020203;
  --tw-rim0: #f4f5f7; --tw-rim1: #c9ccd1; --tw-rim2: #8d9096; --tw-rim3: #54565b;
  --tw-sp0: #ffffff; --tw-sp1: #b7bac0; --tw-sp2: #54565b;
  --tw-h0: #ffffff;  --tw-h1: #cfd2d7;  --tw-h2: #6b6e73;
  --tw-tread: #050506;
}

/* Modo claro: llanta más oscura, con tonos negro profundo y grafito de alto impacto */
:root[data-theme='light'] .tire-watermark {
  opacity: 0.85;
  --tw-r0: #2d323b;
  --tw-r1: #16191f;
  --tw-r2: #090b0e;
  --tw-r3: #000000;
  --tw-rim0: #858e9c;
  --tw-rim1: #4e5563;
  --tw-rim2: #242933;
  --tw-rim3: #0d1015;
  --tw-sp0: #858e9c;
  --tw-sp1: #414754;
  --tw-sp2: #14171e;
  --tw-h0: #858e9c;
  --tw-h1: #414754;
  --tw-h2: #0d1015;
  --tw-tread: #000000;
}

:root[data-theme='light'] .tire-rotate {
  filter: drop-shadow(0 10px 22px rgba(0, 0, 0, 0.22));
}

/* Posición de la llanta en el hueco libre entre los botones de acción y la línea central */
.tire-travel {
  --tw-size: clamp(140px, 13.5vw, 188px);
  position: absolute;
  bottom: 10px;
  left: clamp(245px, 23vw, 390px);
  width: var(--tw-size);
  height: var(--tw-size);
  transform: translateX(70vw);
  opacity: 0;
}

.is-playing .tire-travel {
  animation: tire-travel 3.2s cubic-bezier(.22,.61,.28,1) forwards;
}

@keyframes tire-travel {
  0%   { transform: translateX(70vw); opacity: 0; }
  5%   { opacity: 1; }
  100% { transform: translateX(0);    opacity: 1; }
}

/* Rebote vertical al entrar */
.tire-bounce {
  width: 100%;
  height: 100%;
  transform-origin: 50% 100%;
}

.is-playing .tire-bounce {
  animation: tire-bounce 3.2s linear forwards;
}

@keyframes tire-bounce {
  0%   { transform: translateY(-56px) scale(1, 1.04); }
  18%  { transform: translateY(0)     scale(1.06, 0.92); }
  32%  { transform: translateY(-32px) scale(1, 1.02); }
  46%  { transform: translateY(0)     scale(1.05, 0.94); }
  58%  { transform: translateY(-16px) scale(1, 1.01); }
  72%  { transform: translateY(0)     scale(1.03, 0.96); }
  82%  { transform: translateY(-6px)  scale(1, 1); }
  92%  { transform: translateY(0)     scale(1.01, 0.99); }
  100% { transform: translateY(0)     scale(1, 1); }
}

/* Giro continuo e infinito */
.tire-rotate {
  width: 100%;
  height: 100%;
  transform-origin: 50% 50%;
  filter: drop-shadow(0 6px 12px rgba(0,0,0,0.45));
}

.is-playing .tire-rotate {
  animation: tire-spin-continuous 5.5s linear infinite;
}

@keyframes tire-spin-continuous {
  0%   { transform: rotate(0deg); }
  100% { transform: rotate(-360deg); }
}

@media (prefers-reduced-motion: reduce) {
  .tire-travel,
  .tire-bounce,
  .tire-rotate {
    animation: none;
  }
  .tire-travel {
    transform: none;
    opacity: 1;
  }
}

/* Móvil y tablet: llanta anclada en la esquina inferior derecha del hero */
@media (max-width: 960px) {
  .tire-travel {
    --tw-size: clamp(130px, 32vw, 175px);
    bottom: -28px;
    left: auto;
    right: -28px;
  }
}
</style>
