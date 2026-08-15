<script setup lang="ts">
import { RouterLink, useRoute } from 'vue-router'
import { computed } from 'vue'
import SearchBar from '@/components/catalog/SearchBar.vue'
import { useTheme } from '@/composables/useTheme'

const route = useRoute()
// El buscador del header solo tiene sentido en el catálogo (donde filtra el store).
const showSearch = computed(() => route.name === 'catalog')

const { theme, toggleTheme } = useTheme()
</script>

<template>
  <header class="header">
    <div class="container header__inner">
      <RouterLink to="/" class="brand" aria-label="Repuestos CalRod, inicio">
        <img class="brand__logo" src="/logo-new.png" alt="Repuestos CalRod" />
      </RouterLink>

      <div v-if="showSearch" class="header__search">
        <SearchBar />
      </div>

      <nav class="header__nav" aria-label="Principal">
        <RouterLink to="/" class="header__link">Catálogo</RouterLink>
        <button
          type="button"
          class="header__theme"
          :aria-label="theme === 'dark' ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'"
          :title="theme === 'dark' ? 'Modo claro' : 'Modo oscuro'"
          @click="toggleTheme"
        >
          <!-- Sol (mostrar en oscuro: invita a aclarar) -->
          <svg
            v-if="theme === 'dark'"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <circle cx="12" cy="12" r="4" />
            <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
          </svg>
          <!-- Luna (mostrar en claro: invita a oscurecer) -->
          <svg
            v-else
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8Z" />
          </svg>
        </button>
      </nav>
    </div>
  </header>
</template>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: var(--surface-glass);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  overflow: visible;
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

/* Logo grande sin alterar la altura del header: márgenes negativos
   colapsan la caja de layout a la altura de la barra y overflow:visible
   deja que el logo sobresalga. */
.brand__logo {
  height: 172px;
  width: auto;
  margin-block: -56px;
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
  color: var(--blue-2);
  border-bottom-color: var(--blue);
}

/* Toggle de tema: botón redondo con el icono sol/luna. */
.header__theme {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  flex-shrink: 0;
  border-radius: 50%;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--cream);
  transition: border-color 0.15s ease, color 0.15s ease;
}

.header__theme:hover {
  border-color: var(--blue);
  color: var(--blue-2);
}

.header__theme svg {
  width: 18px;
  height: 18px;
}

/* Tablet/móvil: el buscador colapsa fuera del header (§6, va full-width en la vista). */
@media (max-width: 860px) {
  .header__search {
    display: none;
  }
}

@media (max-width: 520px) {
  .brand__logo {
    height: 148px;
    margin-block: -44px;
  }
  .header__inner {
    gap: var(--space-3);
  }
}
</style>
