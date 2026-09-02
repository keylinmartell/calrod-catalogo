<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'

/**
 * PartGallery — foto principal grande + tira de miniaturas.
 *
 * Recibe las URLs YA ordenadas (la primera es la principal): quien decide de
 * dónde salen es `partGallery()` en types/part.ts, no este componente. Aquí solo
 * vive la interacción: qué foto está activa, el paso circular y el visor a
 * pantalla completa.
 */
const props = defineProps<{
  images: string[]
  /** Nombre de la pieza; alimenta el alt de cada foto. */
  name: string
}>()

const index = ref(0)
const viewerOpen = ref(false)
const viewerEl = ref<HTMLElement | null>(null)

// Al navegar de una ficha a otra la vista no se desmonta: si no reseteáramos,
// la galería intentaría seguir en una posición que la pieza nueva quizá no tiene.
watch(
  () => props.images,
  () => {
    index.value = 0
  },
)

const current = computed<string | null>(() => props.images[index.value] ?? null)
const hasMany = computed(() => props.images.length > 1)

function select(i: number) {
  if (!props.images.length) return
  index.value = Math.min(Math.max(i, 0), props.images.length - 1)
}

/** Paso circular: desde la última, "siguiente" vuelve a la primera. */
function step(delta: number) {
  const n = props.images.length
  if (!n) return
  index.value = (index.value + delta + n) % n
}

async function openViewer() {
  if (!current.value) return
  viewerOpen.value = true
  // El visor tapa la página entera: sin esto el fondo sigue scrolleando detrás.
  document.body.style.overflow = 'hidden'
  // El foco entra al overlay para que Esc y las flechas lleguen sin listeners
  // globales, y para que el lector de pantalla anuncie el diálogo.
  await Promise.resolve()
  viewerEl.value?.focus()
}

function closeViewer() {
  viewerOpen.value = false
  document.body.style.overflow = ''
}

// Si la vista se desmonta con el visor abierto (p. ej. el usuario usa el botón
// atrás del navegador), el scroll del body tiene que volver de todas formas.
onBeforeUnmount(() => {
  document.body.style.overflow = ''
})
</script>

<template>
  <!-- Sin fotos: un hueco tranquilo, mismas proporciones que la foto real para
       que la ficha no salte cuando la pieza sí las tenga. -->
  <div v-if="!images.length" class="gallery gallery--empty">
    <div class="stage stage--empty" aria-hidden="true">
      <svg viewBox="0 0 24 24" width="38" height="38" fill="none" stroke="currentColor" stroke-width="1.3">
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <circle cx="8.5" cy="10" r="1.6" />
        <path d="M21 15l-5-4-4.5 4L8 12l-5 5" />
      </svg>
      <span class="mono">Foto próximamente</span>
    </div>
  </div>

  <div v-else class="gallery" :class="{ 'gallery--single': !hasMany }">
    <!-- Miniaturas: solo si hay más de una foto. Botones reales, no divs con
         @click, para que el teclado y los lectores de pantalla las alcancen. -->
    <div
      v-if="hasMany"
      class="rail"
      role="group"
      aria-label="Fotos de la pieza"
      @keydown.up.prevent="step(-1)"
      @keydown.down.prevent="step(1)"
    >
      <button
        v-for="(src, i) in images"
        :key="src"
        type="button"
        class="thumb"
        :class="{ 'thumb--on': i === index }"
        :aria-label="`Ver foto ${i + 1} de ${images.length}`"
        :aria-current="i === index ? 'true' : undefined"
        @click="select(i)"
        @mouseenter="select(i)"
      >
        <img :src="src" :alt="`${name} — miniatura ${i + 1}`" loading="lazy" />
      </button>
    </div>

    <!-- Foto principal. El div es focusable para que las flechas funcionen sin
         tener que pasar antes por las miniaturas. -->
    <div
      class="stage"
      tabindex="0"
      role="group"
      :aria-label="`Foto ${index + 1} de ${images.length} de ${name}`"
      @keydown.left.prevent="step(-1)"
      @keydown.right.prevent="step(1)"
      @keydown.enter="openViewer"
    >
      <button
        type="button"
        class="stage__btn"
        :aria-label="`Ampliar foto ${index + 1} de ${name}`"
        @click="openViewer"
      >
        <!-- :key fuerza el remonte para que el fundido corra en cada cambio. -->
        <img
          v-if="current"
          :key="current"
          :src="current"
          :alt="`${name} — foto ${index + 1}`"
          class="stage__img"
        />
      </button>

      <!-- Flechas: aparecen al pasar el mouse, discretas, sin caja alrededor. -->
      <template v-if="hasMany">
        <button
          type="button"
          class="nav nav--prev"
          aria-label="Foto anterior"
          @click="step(-1)"
        >
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M15 6l-6 6 6 6" />
          </svg>
        </button>
        <button
          type="button"
          class="nav nav--next"
          aria-label="Foto siguiente"
          @click="step(1)"
        >
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 6l6 6-6 6" />
          </svg>
        </button>
        <span class="counter mono" aria-hidden="true">{{ index + 1 }}/{{ images.length }}</span>
      </template>

      <span class="zoom-hint mono" aria-hidden="true">Clic para ampliar</span>
    </div>
  </div>

  <!-- Visor a pantalla completa -->
  <Teleport to="body">
    <div
      v-if="viewerOpen"
      ref="viewerEl"
      class="viewer"
      role="dialog"
      aria-modal="true"
      :aria-label="`${name} — foto ${index + 1} de ${images.length}`"
      tabindex="-1"
      @click.self="closeViewer"
      @keydown.esc="closeViewer"
      @keydown.left.prevent="step(-1)"
      @keydown.right.prevent="step(1)"
    >
      <button type="button" class="viewer__close" aria-label="Cerrar" @click="closeViewer">
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M6 6l12 12M18 6L6 18" />
        </svg>
      </button>

      <button
        v-if="hasMany"
        type="button"
        class="viewer__nav viewer__nav--prev"
        aria-label="Foto anterior"
        @click.stop="step(-1)"
      >
        <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M15 6l-6 6 6 6" />
        </svg>
      </button>

      <img v-if="current" :key="current" :src="current" :alt="`${name} — foto ${index + 1}`" class="viewer__img" />

      <button
        v-if="hasMany"
        type="button"
        class="viewer__nav viewer__nav--next"
        aria-label="Foto siguiente"
        @click.stop="step(1)"
      >
        <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M9 6l6 6-6 6" />
        </svg>
      </button>

      <div v-if="hasMany" class="viewer__dots" role="group" aria-label="Fotos">
        <button
          v-for="(src, i) in images"
          :key="src"
          type="button"
          class="dot"
          :class="{ 'dot--on': i === index }"
          :aria-label="`Ver foto ${i + 1}`"
          :aria-current="i === index ? 'true' : undefined"
          @click.stop="select(i)"
        />
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
/*
 * Sin marcos. La foto se apoya sobre un halo radial casi imperceptible en vez de
 * un rectángulo con borde: da profundidad y deja de leerse como "otra caja"
 * dentro de la página.
 */
.gallery {
  display: grid;
  grid-template-columns: 68px minmax(0, 1fr);
  gap: var(--space-4);
  align-items: start;
}
.gallery--single,
.gallery--empty {
  grid-template-columns: minmax(0, 1fr);
}

/* ---------- tira de miniaturas ---------- */
.rail {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.thumb {
  position: relative;
  width: 68px;
  height: 68px;
  padding: 6px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--surface);
  cursor: pointer;
  transition:
    border-color 0.18s ease,
    transform 0.18s ease,
    opacity 0.18s ease;
  opacity: 0.62;
}
.thumb img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
}
.thumb:hover {
  opacity: 1;
  transform: translateY(-1px);
}
/* La activa se marca con el azul de marca y una barra a la izquierda, no con
   una caja más gruesa: se distingue sin agregar peso visual. */
.thumb--on {
  opacity: 1;
  border-color: var(--blue-2);
}
.thumb--on::before {
  content: '';
  position: absolute;
  inset-block: 8px;
  left: -1px;
  width: 2px;
  border-radius: 2px;
  background: var(--blue-2);
}
.thumb:focus-visible {
  outline: 2px solid var(--blue-2);
  outline-offset: 2px;
}

/* ---------- foto principal ---------- */
.stage {
  position: relative;
  border-radius: var(--radius-lg);
  /* El halo: centro apenas más claro que el fondo, sin bordes duros. */
  background: radial-gradient(
    120% 90% at 50% 42%,
    var(--surface-2) 0%,
    transparent 72%
  );
}
.stage:focus-visible {
  outline: 2px solid var(--blue-2);
  outline-offset: 4px;
}

.stage__btn {
  display: block;
  width: 100%;
  padding: var(--space-5);
  background: none;
  border: none;
  cursor: zoom-in;
}

.stage__img {
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: contain;
  object-position: center;
  display: block;
  filter: drop-shadow(0 10px 22px rgba(0, 0, 0, 0.42));
  animation: fade-in 0.22s ease;
}
@keyframes fade-in {
  from {
    opacity: 0;
    transform: scale(0.985);
  }
  to {
    opacity: 1;
    transform: none;
  }
}
/* Respeta a quien pidió menos movimiento en el sistema. */
@media (prefers-reduced-motion: reduce) {
  .stage__img { animation: none; }
  .thumb { transition: none; }
}

.stage--empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  aspect-ratio: 1 / 1;
  color: var(--charcoal);
  font-size: 0.8rem;
}

/* ---------- flechas y contador ---------- */
.nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  border: none;
  border-radius: 50%;
  background: var(--surface-glass);
  color: var(--cream);
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.18s ease, background 0.18s ease;
}
.nav--prev { left: 2px; }
.nav--next { right: 2px; }
.stage:hover .nav,
.stage:focus-within .nav {
  opacity: 0.85;
}
.nav:hover { opacity: 1; background: var(--surface-2); }
.nav:focus-visible {
  opacity: 1;
  outline: 2px solid var(--blue-2);
  outline-offset: 2px;
}

.counter {
  position: absolute;
  right: var(--space-4);
  bottom: var(--space-3);
  font-size: 0.7rem;
  color: var(--charcoal);
  letter-spacing: 0.05em;
}

.zoom-hint {
  position: absolute;
  left: var(--space-4);
  bottom: var(--space-3);
  font-size: 0.68rem;
  color: var(--charcoal);
  letter-spacing: 0.04em;
  opacity: 0;
  transition: opacity 0.18s ease;
}
.stage:hover .zoom-hint { opacity: 0.75; }

/* ---------- visor a pantalla completa ---------- */
.viewer {
  position: fixed;
  inset: 0;
  z-index: 100;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) auto;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-6);
  background: rgba(8, 9, 12, 0.94);
  backdrop-filter: blur(3px);
}
.viewer:focus { outline: none; }

.viewer__img {
  grid-column: 2;
  max-width: 100%;
  max-height: 88vh;
  margin-inline: auto;
  object-fit: contain;
  animation: fade-in 0.2s ease;
}

.viewer__close {
  position: absolute;
  top: var(--space-4);
  right: var(--space-4);
  width: 40px;
  height: 40px;
  display: grid;
  place-items: center;
  border: 1px solid var(--border-strong);
  border-radius: 50%;
  background: transparent;
  color: var(--silver);
  cursor: pointer;
}
.viewer__close:hover { color: #eceef2; border-color: var(--blue-2); }

.viewer__nav {
  width: 46px;
  height: 46px;
  display: grid;
  place-items: center;
  border: none;
  border-radius: 50%;
  background: transparent;
  color: var(--silver);
  cursor: pointer;
}
.viewer__nav:hover { color: #eceef2; }
.viewer__nav--prev { grid-column: 1; }
.viewer__nav--next { grid-column: 3; }
.viewer__close:focus-visible,
.viewer__nav:focus-visible,
.dot:focus-visible {
  outline: 2px solid var(--blue-2);
  outline-offset: 2px;
}

.viewer__dots {
  position: absolute;
  bottom: var(--space-5);
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
}
.dot {
  width: 7px;
  height: 7px;
  padding: 0;
  border: none;
  border-radius: 50%;
  background: var(--chrome);
  opacity: 0.4;
  cursor: pointer;
}
.dot--on { background: var(--blue-2); opacity: 1; }

/* ---------- responsive: miniaturas debajo, en fila ---------- */
@media (max-width: 640px) {
  .gallery {
    grid-template-columns: minmax(0, 1fr);
  }
  .rail {
    grid-row: 2;
    flex-direction: row;
    overflow-x: auto;
    padding-bottom: 4px;
    scrollbar-width: thin;
  }
  .thumb { flex: 0 0 auto; }
  .thumb--on::before {
    inset-block: auto;
    inset-inline: 8px;
    left: auto;
    bottom: -1px;
    width: auto;
    height: 2px;
  }
  .nav { opacity: 0.85; }
}
</style>
