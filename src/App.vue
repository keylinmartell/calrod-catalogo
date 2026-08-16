<script setup lang="ts">
import { computed } from 'vue'
import { RouterView, useRoute } from 'vue-router'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import CategoryBar from '@/components/catalog/CategoryBar.vue'
import AppLoader from '@/components/brand/AppLoader.vue'

const route = useRoute()
// La barra de categorías/sistemas solo tiene sentido en el catálogo.
const showCategoryBar = computed(() => route.name === 'catalog')
</script>

<template>
  <a href="#main" class="skip-link">Saltar al contenido</a>
  <AppLoader />
  <div class="app-shell">
    <AppHeader />
    <CategoryBar v-if="showCategoryBar" />
    <main id="main" class="app-main">
      <RouterView />
    </main>
    <AppFooter />
  </div>
</template>

<style scoped>
/* Sticky footer: la envoltura ocupa toda la altura y el main crece para
   empujar el footer al fondo, aunque el contenido sea corto (p. ej. la lista
   de piezas del panel admin cuando hay pocas piezas). */
.app-shell {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-main {
  flex: 1 0 auto;
}

.skip-link {
  position: absolute;
  left: var(--space-4);
  top: -48px;
  background: var(--blue);
  color: #eceef2;
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-sm);
  font-weight: 600;
  z-index: 100;
  transition: top 0.15s ease;
}

.skip-link:focus {
  top: var(--space-3);
}
</style>
