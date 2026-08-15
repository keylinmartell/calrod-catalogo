<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useFilters } from '@/composables/useFilters'
import CategoryIcon from '@/components/catalog/CategoryIcon.vue'
import SearchBar from '@/components/catalog/SearchBar.vue'

const { categories, activeCategories, toggleCategory } = useFilters()

const scroller = ref<HTMLElement | null>(null)

/**
 * En escritorio: mientras el cursor está sobre la barra, la rueda SIEMPRE
 * desplaza horizontal — aunque ya estés en el inicio o el final. El scroll
 * vertical de la página solo vuelve cuando el cursor sale de la barra.
 */
function onWheel(e: WheelEvent) {
  const el = scroller.value
  if (!el) return
  // Gestos horizontales de trackpad ya funcionan solos; no los tocamos.
  if (Math.abs(e.deltaX) > Math.abs(e.deltaY)) return

  // Si no hay overflow horizontal, no hay nada que capturar.
  if (el.scrollWidth <= el.clientWidth) return

  // Normalizamos: algunos ratones reportan deltaY en líneas (deltaMode=1) o
  // páginas (2), con valores pequeños. Sin esto el scroll sería casi nulo.
  const factor = e.deltaMode === 1 ? 16 : e.deltaMode === 2 ? el.clientWidth : 1
  const delta = e.deltaY * factor

  // Capturamos siempre: la barra "atrapa" la rueda hasta que el cursor la deje.
  e.preventDefault()
  el.scrollBy({ left: delta, behavior: 'auto' })
}

// Registramos el listener manualmente con { passive: false }: si se declara en
// el template (@wheel), el navegador puede marcarlo passive y entonces
// preventDefault() se ignora — por eso el scroll horizontal "no funcionaba".
watch(scroller, (el, prev) => {
  prev?.removeEventListener('wheel', onWheel)
  el?.addEventListener('wheel', onWheel, { passive: false })
})

onMounted(() => {
  scroller.value?.addEventListener('wheel', onWheel, { passive: false })
})

onBeforeUnmount(() => {
  scroller.value?.removeEventListener('wheel', onWheel)
})
</script>

<template>
  <nav
    v-if="categories.length"
    class="catbar"
    aria-label="Categorías / sistemas"
  >
    <div class="container catbar__wrap">
      <!-- Buscador: solo en móvil, encima de las categorías. -->
      <div class="catbar__search">
        <SearchBar />
      </div>

      <div ref="scroller" class="catbar__inner">
        <button
          v-for="cat in categories"
          :key="cat.id"
          class="catbar__item"
          :class="{ 'catbar__item--active': activeCategories.includes(cat.id) }"
          :aria-pressed="activeCategories.includes(cat.id)"
          @click="toggleCategory(cat.id)"
        >
          <CategoryIcon :slug="cat.slug" class="catbar__icon" />
          <span class="catbar__label">{{ cat.name }}</span>
        </button>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.catbar {
  background: var(--surface-glass);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: var(--header-h);
  z-index: 15;
}

/* El buscador dentro de la barra solo aparece en móvil/tablet (el del header
   colapsa ahí). En escritorio queda oculto. */
.catbar__search {
  display: none;
}

.catbar__inner {
  display: flex;
  gap: var(--space-2);
  overflow-x: auto;
  overflow-y: hidden;
  padding-block: var(--space-3);
  -webkit-overflow-scrolling: touch;
  /* El swipe horizontal no debe encadenar al scroll de la página. */
  overscroll-behavior-x: contain;
  /* Scroll-snap suave: cada chip "ancla" al desplazar (patrón estándar móvil). */
  scroll-snap-type: x proximity;
  scroll-padding-left: var(--space-2);
  scrollbar-width: none; /* Firefox: barra oculta, se navega por swipe/rueda. */
  -ms-overflow-style: none;
  /* Fade en los extremos: pista visual de que hay más chips para desplazar. */
  -webkit-mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 var(--space-4),
    #000 calc(100% - var(--space-5)),
    transparent 100%
  );
  mask-image: linear-gradient(
    to right,
    transparent 0,
    #000 var(--space-4),
    #000 calc(100% - var(--space-5)),
    transparent 100%
  );
}

/* WebKit (Chrome/Safari/Edge): ocultamos la barra nativa tosca. */
.catbar__inner::-webkit-scrollbar {
  display: none;
}

.catbar__item {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  flex-shrink: 0;
  scroll-snap-align: start;
  padding: var(--space-2) var(--space-4);
  border-radius: 999px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--cream);
  font-size: 0.88rem;
  font-weight: 500;
  white-space: nowrap;
  transition: all 0.15s ease;
}

.catbar__item:hover {
  border-color: var(--border-strong);
}

.catbar__icon {
  color: var(--chrome);
  transition: color 0.15s ease;
}

.catbar__item--active {
  background: rgba(26, 61, 110, 0.14);
  border-color: var(--blue);
  color: var(--blue-2);
}

.catbar__item--active .catbar__icon {
  color: var(--blue-2);
}

@media (max-width: 860px) {
  /* Buscador encima de las categorías en móvil/tablet. */
  .catbar__search {
    display: block;
    padding-top: var(--space-3);
  }
  .catbar__inner {
    padding-top: var(--space-2);
  }
}

@media (max-width: 520px) {
  /* Chips más compactos que el buscador: menos padding, texto e ícono chicos. */
  .catbar__inner {
    gap: var(--space-1);
  }

  .catbar__item {
    gap: 6px;
    padding: 5px var(--space-2);
    font-size: 0.72rem;
    border-radius: var(--radius);
  }

  /* El CategoryIcon recibe size=22 por prop; lo achicamos vía CSS en móvil. */
  .catbar__icon {
    width: 16px;
    height: 16px;
  }
}
</style>
