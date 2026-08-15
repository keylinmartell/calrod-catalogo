import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import CatalogView from '@/views/CatalogView.vue'

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
    // Panel admin: no enlazada desde header ni footer. Ocultarla es comodidad;
    // la cerradura real son las policies RLS de admin (0004). Lazy + noindex.
    path: '/admin-calrod',
    name: 'admin',
    component: () => import('@/views/AdminView.vue'),
    meta: {
      title: 'Panel — Repuestos CalRod',
      description: 'Acceso interno.',
      noindex: true,
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
