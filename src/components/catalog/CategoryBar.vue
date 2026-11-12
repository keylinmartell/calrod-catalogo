<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useFilters } from '@/composables/useFilters'
import SearchBar from '@/components/catalog/SearchBar.vue'

const { categories, activeCategories, toggleCategory } = useFilters()

const scroller = ref<HTMLElement | null>(null)
const isHovered = ref(false)
const isInteracting = ref(false)
let touchTimeout: number | undefined

function onTouchStart() {
  isInteracting.value = true
  if (touchTimeout) clearTimeout(touchTimeout)
}

function onTouchEnd() {
  if (touchTimeout) clearTimeout(touchTimeout)
  touchTimeout = window.setTimeout(() => {
    isInteracting.value = false
  }, 1200)
}

/**
 * En escritorio: mientras el cursor está sobre la barra, la rueda desplaza horizontal.
 */
function onWheel(e: WheelEvent) {
  const el = scroller.value
  if (!el) return
  if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) return
  if (el.scrollWidth <= el.clientWidth) return

  const factor = e.deltaMode === 1 ? 16 : e.deltaMode === 2 ? el.clientWidth : 1
  const delta = e.deltaY * factor

  e.preventDefault()
  el.scrollBy({ left: delta, behavior: 'auto' })

  isInteracting.value = true
  if (touchTimeout) clearTimeout(touchTimeout)
  touchTimeout = window.setTimeout(() => {
    isInteracting.value = false
  }, 1000)
}

watch(scroller, (el, prev) => {
  prev?.removeEventListener('wheel', onWheel)
  el?.addEventListener('wheel', onWheel, { passive: false })
})

onMounted(() => {
  scroller.value?.addEventListener('wheel', onWheel, { passive: false })
})

onBeforeUnmount(() => {
  if (touchTimeout) clearTimeout(touchTimeout)
  scroller.value?.removeEventListener('wheel', onWheel)
})
</script>

<template>
  <nav
    v-if="categories.length"
    class="catbar"
    aria-label="Categorías del catálogo"
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
  >
    <div class="container catbar__wrap">
      <!-- Buscador: solo en móvil, encima de las categorías. -->
      <div class="catbar__search">
        <SearchBar />
      </div>

      <div
        ref="scroller"
        class="catbar__inner"
        @touchstart.passive="onTouchStart"
        @touchend.passive="onTouchEnd"
      >
        <div
          class="catbar__track"
          :class="{ 'is-paused': isHovered || isInteracting }"
        >
          <!-- Grupo 1: solo nombres con tipografía display moderna -->
          <div class="catbar__group">
            <template v-for="cat in categories" :key="`g1-${cat.id}`">
              <button
                type="button"
                class="catbar__item"
                :class="{ 'catbar__item--active': activeCategories.includes(cat.id) }"
                :aria-pressed="activeCategories.includes(cat.id)"
                @click="toggleCategory(cat.id)"
              >
                <span class="catbar__label">{{ cat.name }}</span>
              </button>
              <span class="catbar__slash" aria-hidden="true">/</span>
            </template>
          </div>

          <!-- Grupo 2: duplicado idéntico para loop continuo -->
          <div class="catbar__group" aria-hidden="true">
            <template v-for="cat in categories" :key="`g2-${cat.id}`">
              <button
                type="button"
                class="catbar__item"
                :class="{ 'catbar__item--active': activeCategories.includes(cat.id) }"
                :aria-pressed="activeCategories.includes(cat.id)"
                tabindex="-1"
                @click="toggleCategory(cat.id)"
              >
                <span class="catbar__label">{{ cat.name }}</span>
              </button>
              <span class="catbar__slash" aria-hidden="true">/</span>
            </template>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<style scoped>
/* ── Barra con Borde Luminoso Moderno (Dual Hairline Specular) ───────────── */
.catbar {
  position: sticky;
  top: var(--header-h);
  z-index: 15;
  background: rgba(9, 11, 16, 0.88);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.6);
}

/* Línea de luz láser sutil en el borde inferior del ticker */
.catbar::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(74, 123, 184, 0.2) 20%,
    rgba(96, 165, 250, 0.65) 50%,
    rgba(74, 123, 184, 0.2) 80%,
    transparent 100%
  );
  pointer-events: none;
}

:root[data-theme='light'] .catbar {
  background: rgba(255, 255, 255, 0.9);
  border-top-color: rgba(15, 23, 42, 0.05);
  border-bottom-color: rgba(15, 23, 42, 0.08);
  box-shadow: 0 6px 20px -8px rgba(15, 23, 42, 0.07);
}

:root[data-theme='light'] .catbar::after {
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(26, 61, 110, 0.15) 20%,
    rgba(37, 99, 235, 0.45) 50%,
    rgba(26, 61, 110, 0.15) 80%,
    transparent 100%
  );
}

/* El buscador dentro de la barra solo aparece en móvil/tablet. */
.catbar__search {
  display: none;
}

.catbar__inner {
  display: flex;
  overflow-x: auto;
  overflow-y: hidden;
  padding-block: 11px;
  -webkit-overflow-scrolling: touch;
  overscroll-behavior-x: contain;
  scrollbar-width: none;
  -ms-overflow-style: none;
  -webkit-mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 56px,
    #000 calc(100% - 56px),
    transparent 100%
  );
  mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 56px,
    #000 calc(100% - 56px),
    transparent 100%
  );
}

.catbar__inner::-webkit-scrollbar {
  display: none;
}

/* ── Track & Animación ───────────────────────────────────────────────────── */
.catbar__track {
  display: flex;
  width: max-content;
  will-change: transform;
  animation: cat-ticker 42s linear infinite;
}

.catbar__track:hover,
.catbar__track.is-paused,
.catbar__track:focus-within {
  animation-play-state: paused;
}

.catbar__group {
  display: flex;
  align-items: center;
  gap: 22px;
  padding-right: 22px;
  flex-shrink: 0;
}

@keyframes cat-ticker {
  0% {
    transform: translate3d(0, 0, 0);
  }
  100% {
    transform: translate3d(-50%, 0, 0);
  }
}

/* Divisor oblicuo técnico minimalista */
.catbar__slash {
  font-family: var(--font-mono);
  font-size: 0.72rem;
  font-weight: 400;
  color: rgba(148, 163, 184, 0.22);
  user-select: none;
  flex-shrink: 0;
}

:root[data-theme='light'] .catbar__slash {
  color: rgba(15, 23, 42, 0.2);
}

/* ── Tipografía Pura Pro (Sora Display) ──────────────────────────────────── */
.catbar__item {
  position: relative;
  display: inline-flex;
  align-items: center;
  padding: 4px 2px;
  background: transparent;
  border: none;
  font-family: var(--font-display);
  font-size: 0.78rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.09em;
  color: var(--chrome);
  white-space: nowrap;
  cursor: pointer;
  transition: color 0.2s ease, transform 0.2s ease, text-shadow 0.2s ease;
}

/* Indicador láser inferior en el ítem activo/hover */
.catbar__item::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -2px;
  height: 2px;
  border-radius: 2px;
  background: linear-gradient(90deg, transparent, #60a5fa, transparent);
  transform: scaleX(0);
  opacity: 0;
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.2s ease;
}

.catbar__item:hover {
  color: #ffffff;
  text-shadow: 0 0 18px rgba(96, 165, 250, 0.45);
}

.catbar__item:hover::after {
  transform: scaleX(0.6);
  opacity: 0.65;
}

.catbar__item--active {
  color: #60a5fa;
  font-weight: 700;
  text-shadow: 0 0 20px rgba(59, 130, 246, 0.6);
}

.catbar__item--active::after {
  background: #3b82f6;
  box-shadow: 0 0 10px #3b82f6;
  transform: scaleX(1);
  opacity: 1;
}

/* Modo claro */
:root[data-theme='light'] .catbar__item {
  color: var(--charcoal);
}

:root[data-theme='light'] .catbar__item:hover {
  color: var(--blue);
  text-shadow: none;
}

:root[data-theme='light'] .catbar__item--active {
  color: var(--blue);
  text-shadow: none;
}

:root[data-theme='light'] .catbar__item--active::after {
  background: var(--blue);
  box-shadow: none;
}

@media (prefers-reduced-motion: reduce) {
  .catbar__track {
    animation: none;
  }
}

@media (max-width: 860px) {
  .catbar__search {
    display: block;
    padding-top: var(--space-3);
  }
  .catbar__inner {
    padding-block: 9px;
  }
}

@media (max-width: 520px) {
  .catbar__group {
    gap: 16px;
    padding-right: 16px;
  }

  .catbar__item {
    font-size: 0.72rem;
    letter-spacing: 0.07em;
  }
}
</style>
