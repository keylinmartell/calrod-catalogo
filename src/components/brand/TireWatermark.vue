<script setup lang="ts">
/**
 * TireWatermark — llanta que entra rodando de DERECHA a IZQUIERDA, rebota y se
 * detiene FIJA en el mismo lugar donde vivía el engrane (WrenchWatermark):
 * arriba-izquierda del hero. Sustituye por completo a esa marca de agua.
 *
 * Es una animación de ENTRADA (corre una sola vez, `forwards`): no hace loop ni
 * desaparece. Los colores de los degradados salen de variables CSS para poder
 * retunearlos en modo claro (ver bloque html[data-theme='light']).
 *
 * IMPORTANTE: la animación NO arranca hasta que el overlay de carga global
 * (useAppLoading) desaparece. Así la rueda "entra rodando" cuando el usuario ya
 * está viendo el hero, no escondida detrás del "Cargando la página…".
 */
import { ref, watch } from 'vue'
import { useAppLoading } from '@/composables/useAppLoading'

const { booting } = useAppLoading()

// `play` activa las clases de animación. Si ya se terminó de cargar cuando este
// componente se monta, arranca de una vez; si no, espera a que booting → false.
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
  opacity: 0.14;
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

/* Modo claro: sobre fondo casi blanco, los grises medios se lavaban. Subimos
   el contraste — goma en grises azulados profundos (llanta oscura de verdad) y
   aro/rayos plateados brillantes con más rango tonal — y bajamos la opacidad
   para que siga siendo marca de agua sutil, no una mancha. */
:root[data-theme='light'] .tire-watermark {
  opacity: 0.3;
  --tw-r0: #3a4049;  --tw-r1: #23272e;  --tw-r2: #101318;  --tw-r3: #030405;
  --tw-rim0: #ffffff; --tw-rim1: #d3d8df; --tw-rim2: #949ba6; --tw-rim3: #5b626d;
  --tw-sp0: #ffffff; --tw-sp1: #b9bec7; --tw-sp2: #626975;
  --tw-h0: #ffffff;  --tw-h1: #cbd0d7;  --tw-h2: #767d89;
  --tw-tread: #030405;
}

/* Reposo = misma posición/tamaño que tenía el engrane (WrenchWatermark). */
.tire-travel {
  position: absolute;
  top: -46px;
  left: clamp(-40px, 4vw, 96px);
  width: clamp(300px, 36vw, 470px);
  height: clamp(300px, 36vw, 470px);
  /* Estado previo a la animación: fuera de pantalla e invisible, igual que el
     frame 0% de tire-travel. Así no hay "parpadeo" mientras esperamos la carga. */
  transform: translateX(92vw);
  opacity: 0;
}
/* La animación solo corre cuando la carga global terminó (is-playing). */
.is-playing .tire-travel {
  animation: tire-travel 3.4s cubic-bezier(.22,.61,.28,1) forwards;
}

@keyframes tire-travel {
  0%   { transform: translateX(92vw); opacity: 0; }
  5%   { opacity: 1; }
  100% { transform: translateX(0);    opacity: 1; }
}

/* Rebote vertical amortiguado: cae, golpea y va perdiendo altura hasta el reposo. */
.tire-bounce {
  width: 100%;
  height: 100%;
  transform-origin: 50% 100%;
}
.is-playing .tire-bounce {
  animation: tire-bounce 3.4s linear forwards;
}

@keyframes tire-bounce {
  0%   { transform: translateY(-140px) scale(1, 1.05); }
  18%  { transform: translateY(0)      scale(1.08, 0.9); }  /* 1er impacto */
  30%  { transform: translateY(-70px)  scale(1, 1.03); }
  45%  { transform: translateY(0)      scale(1.06, 0.92); } /* 2do impacto */
  56%  { transform: translateY(-34px)  scale(1, 1.02); }
  70%  { transform: translateY(0)      scale(1.05, 0.94); } /* 3er impacto */
  80%  { transform: translateY(-12px)  scale(1, 1.01); }
  90%  { transform: translateY(0)      scale(1.03, 0.97); }
  100% { transform: translateY(0)      scale(1, 1); }       /* reposo */
}

/* Giro antihorario (rueda hacia la izquierda) que desacelera y se detiene. */
.tire-rotate {
  width: 100%;
  height: 100%;
  transform-origin: 50% 50%;
  filter: drop-shadow(0 6px 10px rgba(0,0,0,0.4));
}
.is-playing .tire-rotate {
  animation: tire-rotate 3.4s cubic-bezier(.22,.61,.28,1) forwards;
}

@keyframes tire-rotate {
  0%   { transform: rotate(0deg); }
  100% { transform: rotate(-720deg); }
}

/* Accesibilidad: sin animación, aparece ya en su lugar de reposo. */
@media (prefers-reduced-motion: reduce) {
  .tire-travel,
  .tire-bounce,
  .tire-rotate {
    animation: none;
  }
  /* Anula el estado "fuera de pantalla" (frame 0%) para que se vea en reposo. */
  .tire-travel {
    transform: none;
    opacity: 1;
  }
}

/* Móvil: la llanta SÍ se muestra (más pequeña y arrinconada), a diferencia del
   engrane que se ocultaba. Se reduce el tamaño y se recoloca para no tapar la
   copia del hero. */
@media (max-width: 960px) {
  .tire-travel {
    top: -20px;
    left: -22vw;
    width: clamp(200px, 52vw, 300px);
    height: clamp(200px, 52vw, 300px);
  }
}
</style>
