<script setup lang="ts">
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { computed, ref, onBeforeUnmount } from 'vue'
import { storeToRefs } from 'pinia'
import SearchBar from '@/components/catalog/SearchBar.vue'
import { useTheme } from '@/composables/useTheme'
import { useAuthStore } from '@/stores/authStore'
import { useAuthPanel } from '@/composables/useAuthPanel'

const route = useRoute()
const router = useRouter()
// El buscador del header solo tiene sentido en el catálogo (donde filtra el store).
const showSearch = computed(() => route.name === 'catalog')

const { theme, toggleTheme } = useTheme()

const auth = useAuthStore()
const { isAuthenticated, isAdmin, profile } = storeToRefs(auth)
const { openPanel } = useAuthPanel()

// Menú de usuario (avatar → desplegable). Solo visible con sesión.
const menuOpen = ref(false)
function toggleMenu() {
  menuOpen.value = !menuOpen.value
}
function closeMenu() {
  menuOpen.value = false
}

// Inicial para el avatar: primera letra del correo, o "U" si aún no cargó.
const initial = computed(() => (profile.value?.email?.[0] ?? 'U').toUpperCase())

async function onSignOut() {
  closeMenu()
  await auth.signOut()
  // Si estaba en el panel admin, lo devolvemos al catálogo.
  if (route.name === 'admin') router.push('/')
}

function goAdmin() {
  closeMenu()
  router.push('/admin')
}

// Cerrar el menú al hacer click fuera.
function onDocClick(e: MouseEvent) {
  if (!(e.target as HTMLElement).closest('.header__user')) closeMenu()
}
document.addEventListener('click', onDocClick)
onBeforeUnmount(() => document.removeEventListener('click', onDocClick))
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

        <!-- Sin sesión: botón Acceder (abre el panel de login deslizante). -->
        <button
          v-if="!isAuthenticated"
          type="button"
          class="header__access"
          @click="openPanel('login')"
        >
          Acceder
        </button>

        <!-- Con sesión: avatar con menú de usuario. -->
        <div v-else class="header__user">
          <button
            type="button"
            class="header__avatar"
            :aria-expanded="menuOpen"
            aria-haspopup="menu"
            aria-label="Menú de usuario"
            @click.stop="toggleMenu"
          >
            {{ initial }}
          </button>

          <div v-if="menuOpen" class="header__menu" role="menu">
            <p class="header__menu-email" :title="profile?.email ?? ''">
              {{ profile?.email ?? 'Mi cuenta' }}
            </p>
            <button
              v-if="isAdmin"
              type="button"
              class="header__menu-item"
              role="menuitem"
              @click="goAdmin"
            >
              Panel de administración
            </button>
            <button
              type="button"
              class="header__menu-item header__menu-item--danger"
              role="menuitem"
              @click="onSignOut"
            >
              Cerrar sesión
            </button>
          </div>
        </div>
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

/* Botón "Acceder": pill azul de marca. */
.header__access {
  display: inline-flex;
  align-items: center;
  height: 38px;
  padding-inline: var(--space-4);
  border-radius: 999px;
  background: var(--blue);
  color: #eceef2;
  font-weight: 600;
  font-size: 0.9rem;
  flex-shrink: 0;
  transition: background 0.15s ease;
}

.header__access:hover {
  background: var(--blue-2);
}

/* Menú de usuario: avatar redondo + desplegable. */
.header__user {
  position: relative;
  flex-shrink: 0;
}

.header__avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: var(--blue);
  color: #eceef2;
  font-weight: 700;
  font-size: 0.95rem;
  border: 1px solid var(--border-strong);
  transition: border-color 0.15s ease;
}

.header__avatar:hover {
  border-color: var(--blue-2);
}

.header__menu {
  position: absolute;
  top: calc(100% + var(--space-2));
  right: 0;
  min-width: 220px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-card);
  padding: var(--space-2);
  z-index: 30;
}

.header__menu-email {
  padding: var(--space-2) var(--space-3);
  font-size: 0.82rem;
  color: var(--charcoal);
  border-bottom: 1px solid var(--border);
  margin-bottom: var(--space-1);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.header__menu-item {
  display: block;
  width: 100%;
  text-align: left;
  padding: var(--space-3);
  border-radius: var(--radius-sm);
  font-size: 0.9rem;
  color: var(--cream);
  transition: background 0.15s ease;
}

.header__menu-item:hover {
  background: var(--surface-2);
}

.header__menu-item--danger {
  color: var(--danger);
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
  /* Pega el logo al borde izquierdo: contrarresta el padding-inline del
     .container para ganar espacio en la barra estrecha. */
  .brand {
    margin-left: calc(-1 * var(--space-4));
  }
  .header__inner {
    gap: var(--space-3);
  }
}
</style>
