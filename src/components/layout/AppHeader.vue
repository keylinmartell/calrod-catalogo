<script setup lang="ts">
import { RouterLink, useRoute } from 'vue-router'
import { computed } from 'vue'
import SearchBar from '@/components/catalog/SearchBar.vue'

const route = useRoute()
// El buscador del header solo tiene sentido en el catálogo (donde filtra el store).
const showSearch = computed(() => route.name === 'catalog')
</script>

<template>
  <header class="header">
    <div class="container header__inner">
      <RouterLink to="/" class="brand" aria-label="Respuestos CalRod, inicio">
        <img class="brand__logo" src="/logo.png" alt="Respuestos CalRod" />
      </RouterLink>

      <div v-if="showSearch" class="header__search">
        <SearchBar />
      </div>

      <nav class="header__nav" aria-label="Principal">
        <RouterLink to="/" class="header__link">Catálogo</RouterLink>
      </nav>
    </div>
  </header>
</template>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(21, 19, 15, 0.85);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
}

.header__inner {
  display: flex;
  align-items: center;
  gap: var(--space-5);
  min-height: var(--header-h);
}

.brand {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.brand__logo {
  height: 180px;
  width: auto;
  margin-top: -56px;
  margin-bottom: -56px;
  margin-left: -12px;
}

.header__search {
  flex: 1;
  max-width: 520px;
}

.header__nav {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  margin-left: auto;
}

.header__link {
  font-weight: 500;
  color: var(--cream);
  padding: var(--space-2) 0;
  border-bottom: 2px solid transparent;
}

.header__link.router-link-active {
  color: var(--orange-2);
  border-bottom-color: var(--orange);
}

/* Tablet/móvil: el buscador colapsa fuera del header (§6, va full-width en la vista). */
@media (max-width: 860px) {
  .header__search {
    display: none;
  }
}

@media (max-width: 520px) {
  .brand__logo {
    height: 150px;
    margin-top: -41px;
    margin-bottom: -41px;
  }
  .header__inner {
    gap: var(--space-3);
  }
}
</style>
