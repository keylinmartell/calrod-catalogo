<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useFilters } from '@/composables/useFilters'
import CategoryIcon from '@/components/catalog/CategoryIcon.vue'
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
    aria-label="Categorías / sistemas"
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
          <!-- Grupo principal de categorías -->
          <div class="catbar__group">
            <button
              v-for="cat in categories"
              :key="`g1-${cat.id}`"
              class="catbar__item"
              :class="{ 'catbar__item--active': activeCategories.includes(cat.id) }"
              :aria-pressed="activeCategories.includes(cat.id)"
              @click="toggleCategory(cat.id)"
            >
              <CategoryIcon :slug="cat.slug" :size="20" class="catbar__icon" />
              <span class="catbar__label">{{ cat.name }}</span>
            </button>
          </div>

          <!-- Grupo duplicado idéntico para ticker continuo infinito -->
          <div class="catbar__group" aria-hidden="true">
            <button
              v-for="cat in categories"
              :key="`g2-${cat.id}`"
              class="catbar__item"
              :class="{ 'catbar__item--active': activeCategories.includes(cat.id) }"
              :aria-pressed="activeCategories.includes(cat.id)"
              tabindex="-1"
              @click="toggleCategory(cat.id)"
            >
              <CategoryIcon :slug="cat.slug" :size="20" class="catbar__icon" />
              <span class="catbar__label">{{ cat.name }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.catbar {
  background: var(--surface-glass);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: var(--header-h);
  z-index: 15;
}

/* El buscador dentro de la barra solo aparece en móvil/tablet. */
.catbar__search {
  display: none;
}

.catbar__inner {
  display: flex;
  overflow-x: auto;
  overflow-y: hidden;
  padding-block: var(--space-3);
  -webkit-overflow-scrolling: touch;
  overscroll-behavior-x: contain;
  scrollbar-width: none;
  -ms-overflow-style: none;
  /* Fade elegante en los bordes para una transición suave del ticker */
  -webkit-mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 32px,
    #000 calc(100% - 32px),
    transparent 100%
  );
  mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 32px,
    #000 calc(100% - 32px),
    transparent 100%
  );
}

.catbar__inner::-webkit-scrollbar {
  display: none;
}

/* Ticker continuo */
.catbar__track {
  display: flex;
  width: max-content;
  will-change: transform;
  animation: cat-ticker 44s linear infinite;
}

.catbar__track:hover,
.catbar__track.is-paused,
.catbar__track:focus-within {
  animation-play-state: paused;
}

.catbar__group {
  display: flex;
  align-items: center;
  gap: var(--space-5);
  padding-right: var(--space-5);
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

/* Diseño limpio, abierto y moderno — sin cajas/cápsulas pesadas */
.catbar__item {
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
  padding: 8px 14px;
  background: transparent;
  border: none;
  border-radius: var(--radius-sm);
  color: var(--silver);
  font-size: 0.95rem;
  font-weight: 500;
  letter-spacing: 0.01em;
  white-space: nowrap;
  cursor: pointer;
  transition: color 0.2s ease, background 0.2s ease, transform 0.2s ease;
}

/* Línea indicadora luminosa inferior */
.catbar__item::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 12px;
  right: 12px;
  height: 2px;
  background: var(--blue-2);
  border-radius: 2px;
  transform: scaleX(0);
  opacity: 0;
  box-shadow: 0 0 8px var(--blue-2);
  transition: transform 0.22s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.2s ease;
}

.catbar__icon {
  color: var(--chrome);
  transition: color 0.2s ease, transform 0.2s ease;
}

.catbar__item:hover {
  color: #ffffff;
  background: rgba(236, 238, 242, 0.05);
  transform: translateY(-1px);
}

.catbar__item:hover .catbar__icon {
  color: var(--blue-2);
  transform: scale(1.12);
}

.catbar__item:hover::after {
  transform: scaleX(0.5);
  opacity: 0.5;
}

.catbar__item--active {
  color: #ffffff;
  font-weight: 600;
  background: rgba(74, 123, 184, 0.12);
}

.catbar__item--active .catbar__icon {
  color: var(--blue-2);
}

.catbar__item--active::after {
  transform: scaleX(1);
  opacity: 1;
}

/* Modo claro */
:root[data-theme='light'] .catbar__item {
  color: var(--charcoal);
}

:root[data-theme='light'] .catbar__item:hover {
  color: var(--cream);
  background: rgba(0, 0, 0, 0.04);
}

:root[data-theme='light'] .catbar__item--active {
  color: var(--blue);
  background: rgba(26, 61, 110, 0.07);
}

:root[data-theme='light'] .catbar__item--active .catbar__icon {
  color: var(--blue);
}

:root[data-theme='light'] .catbar__item::after {
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
    padding-top: var(--space-2);
    padding-bottom: var(--space-2);
  }
}

@media (max-width: 520px) {
  .catbar__group {
    gap: var(--space-3);
    padding-right: var(--space-3);
  }

  .catbar__item {
    gap: 6px;
    padding: 6px 10px;
    font-size: 0.82rem;
  }

  .catbar__icon {
    width: 16px;
    height: 16px;
  }
}
</style>
