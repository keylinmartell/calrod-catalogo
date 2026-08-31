import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import CatalogView from '@/views/CatalogView.vue'
import { useAuthStore } from '@/stores/authStore'
import { useAuthPanel } from '@/composables/useAuthPanel'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'catalog',
    component: CatalogView,
    meta: {
      title: 'Repuestos CalRod — Catálogo de piezas',
      description:
        'Catálogo de piezas de auto: frenos, motor, suspensión, eléctrico, carrocería y filtros. Busca por marca y modelo compatible.',
    },
  },
  {
    path: '/pieza/:id',
    name: 'part-detail',
    // Lazy: la ficha de detalle no hace falta en la carga inicial del catálogo.
    component: () => import('@/views/PartDetailView.vue'),
    meta: {
      title: 'Pieza — Repuestos CalRod',
      description: 'Ficha técnica y compatibilidad de la pieza.',
    },
  },
  {
    // Panel admin. La cerradura real son las policies RLS de admin (0004);
    // este guard solo evita mostrar el panel a quien no es admin y abre el
    // login si hace falta. Lazy + noindex.
    path: '/admin',
    name: 'admin',
    component: () => import('@/views/AdminView.vue'),
    meta: {
      title: 'Panel — Repuestos CalRod',
      description: 'Acceso interno.',
      noindex: true,
      requiresAdmin: true,
    },
  },
  {
    path: '/terminos',
    name: 'terms',
    component: () => import('@/views/TermsView.vue'),
    meta: {
      title: 'Términos y Condiciones — Repuestos CalRod',
      description: 'Términos y condiciones de uso del catálogo de Repuestos CalRod.',
    },
  },
  {
    path: '/privacidad',
    name: 'privacy',
    component: () => import('@/views/PrivacyView.vue'),
    meta: {
      title: 'Política de Privacidad — Repuestos CalRod',
      description:
        'Cómo tratamos los datos personales y la autenticación con Google en Repuestos CalRod.',
    },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFoundView.vue'),
    meta: {
      title: 'Página no encontrada — Repuestos CalRod',
      description: 'La página que buscas no existe.',
    },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(_to, _from, savedPosition) {
    return savedPosition ?? { top: 0 }
  },
})

// Guard de acceso al panel admin. La seguridad real vive en las policies RLS
// (0004); esto solo evita renderizar el panel a quien no corresponde y, si no
// hay sesión, abre el panel de login en su lugar. El store/composable se
// resuelven en tiempo de navegación (pinia ya está instalado para entonces).
router.beforeEach(async (to) => {
  if (!to.meta.requiresAdmin) return true

  const auth = useAuthStore()
  const authPanel = useAuthPanel()

  // Aseguramos que la sesión guardada ya se resolvió antes de decidir.
  await auth.init()

  if (auth.isAdmin) return true

  if (!auth.isAuthenticated) {
    // Sin sesión: abrimos el login y no navegamos al panel.
    authPanel.openPanel('login')
  }
  // Autenticado pero sin rol admin (o tras abrir login): al catálogo.
  return { name: 'catalog' }
})

// SEO básico (§7): título y meta description por vista vía meta fields.
router.afterEach((to) => {
  const meta = to.meta as { title?: string; description?: string; noindex?: boolean }
  if (meta.title) document.title = meta.title
  if (meta.description) {
    let tag = document.querySelector('meta[name="description"]')
    if (!tag) {
      tag = document.createElement('meta')
      tag.setAttribute('name', 'description')
      document.head.appendChild(tag)
    }
    tag.setAttribute('content', meta.description)
  }

  // La ruta admin no debe indexarse. Añadimos/quitamos <meta name="robots">.
  let robots = document.querySelector('meta[name="robots"]')
  if (meta.noindex) {
    if (!robots) {
      robots = document.createElement('meta')
      robots.setAttribute('name', 'robots')
      document.head.appendChild(robots)
    }
    robots.setAttribute('content', 'noindex, nofollow')
  } else if (robots) {
    robots.remove()
  }
})

export default router
