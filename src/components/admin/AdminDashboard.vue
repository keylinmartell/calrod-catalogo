<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useParts } from '@/composables/useParts'
import { useAdminParts } from '@/composables/useAdminParts'
import type { Part } from '@/types/part'
import { AVAILABILITY_LABELS } from '@/types/part'
import PartForm from '@/components/admin/PartForm.vue'
import CategoryManager from '@/components/admin/CategoryManager.vue'
import StoreLocationManager from '@/components/admin/StoreLocationManager.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const auth = useAuthStore()
const { fetchParts } = useParts()
const { deletePart } = useAdminParts()

const parts = ref<Part[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

// Pestaña activa del panel: catálogo de piezas, categorías o ubicación.
const tab = ref<'parts' | 'categories' | 'location'>('parts')

// Vista: 'list' | 'edit'. En 'edit', `editing` es null para "nueva pieza".
const view = ref<'list' | 'edit'>('list')
const editing = ref<Part | null>(null)

const priceFmt = (n: number) =>
  new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'USD' }).format(n)

async function loadList() {
  loading.value = true
  error.value = null
  try {
    parts.value = await fetchParts()
  } catch (e) {
    error.value = 'No pudimos cargar las piezas. Revisa tu conexión e intenta de nuevo.'
    console.error('[CalRod] admin loadList:', e)
  } finally {
    loading.value = false
  }
}

function newPart() {
  editing.value = null
  view.value = 'edit'
}

function editPart(part: Part) {
  editing.value = part
  view.value = 'edit'
}

async function removePart(part: Part) {
  if (!confirm(`¿Borrar "${part.name}"? Esta acción no se puede deshacer.`)) return
  try {
    await deletePart(part.id)
    await loadList()
  } catch (e) {
    alert('No se pudo borrar la pieza. ¿Sigue tu sesión activa?')
    console.error('[CalRod] admin removePart:', e)
  }
}

// Al guardar o cancelar en el formulario, volvemos a la lista y recargamos.
async function onSaved() {
  view.value = 'list'
  editing.value = null
  await loadList()
}

function onCancel() {
  view.value = 'list'
  editing.value = null
}

onMounted(loadList)
</script>

<template>
  <div class="dash">
    <!-- Barra superior -->
    <header class="dash__top">
      <div>
        <p class="dash__eyebrow mono">Panel CalRod</p>
        <h1 class="dash__title">Administrar catálogo</h1>
      </div>
      <div class="dash__actions">
        <button
          v-if="tab === 'parts' && view === 'list'"
          class="btn btn--primary"
          @click="newPart"
        >
          + Nueva pieza
        </button>
        <button class="btn btn--ghost" @click="auth.signOut()">Cerrar sesión</button>
      </div>
    </header>

    <!-- Pestañas: Piezas | Categorías -->
    <nav class="dash__tabs" aria-label="Secciones del panel">
      <button
        class="dash__tab"
        :class="{ 'dash__tab--active': tab === 'parts' }"
        @click="tab = 'parts'"
      >
        Piezas
      </button>
      <button
        class="dash__tab"
        :class="{ 'dash__tab--active': tab === 'categories' }"
        @click="tab = 'categories'"
      >
        Categorías
      </button>
      <button
        class="dash__tab"
        :class="{ 'dash__tab--active': tab === 'location' }"
        @click="tab = 'location'"
      >
        Ubicación
      </button>
    </nav>

    <!-- Sección: categorías -->
    <CategoryManager v-if="tab === 'categories'" />

    <!-- Sección: ubicación de la tienda -->
    <StoreLocationManager v-else-if="tab === 'location'" />

    <!-- Sección: piezas -->
    <template v-else>
      <!-- Formulario de alta/edición -->
      <PartForm
        v-if="view === 'edit'"
        :part="editing"
        @saved="onSaved"
        @cancel="onCancel"
      />

      <!-- Lista -->
      <template v-else>
        <div v-if="loading" class="dash__state">
          <GearSpinner :size="44" />
          <p>Cargando piezas…</p>
        </div>

        <div v-else-if="error" class="dash__state dash__state--error" role="alert">
          <p>{{ error }}</p>
          <button class="btn btn--ghost" @click="loadList">Reintentar</button>
        </div>

        <p v-else-if="!parts.length" class="dash__state">
          Aún no hay piezas. Crea la primera con “Nueva pieza”.
        </p>

        <div v-else class="dash__list">
          <div v-for="part in parts" :key="part.id" class="row">
            <div class="row__media">
              <img
                v-if="part.image_url"
                :src="part.image_url"
                :alt="part.name"
                class="row__img"
              />
              <div v-else class="row__img row__img--empty" aria-hidden="true">
                <span class="mono">—</span>
              </div>
            </div>

            <div class="row__info">
              <h2 class="row__name">{{ part.name }}</h2>
              <p class="row__meta mono">
                {{ part.code }} · {{ priceFmt(part.price) }} ·
                {{ AVAILABILITY_LABELS[part.availability] }}
              </p>
            </div>

            <div class="row__actions">
              <button class="btn btn--ghost btn--sm" @click="editPart(part)">
                Editar
              </button>
              <button class="btn btn--danger btn--sm" @click="removePart(part)">
                Borrar
              </button>
            </div>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<style scoped>
.dash {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.dash__top {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.dash__eyebrow {
  color: var(--blue-2);
  font-size: 0.75rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: var(--space-2);
}

.dash__title {
  font-size: clamp(1.5rem, 3vw, 2rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}

.dash__actions {
  display: flex;
  gap: var(--space-3);
}

.dash__tabs {
  display: flex;
  gap: var(--space-2);
  border-bottom: 1px solid var(--border);
}

.dash__tab {
  padding: var(--space-3) var(--space-4);
  color: var(--charcoal);
  font-weight: 500;
  border-bottom: 2px solid transparent;
  margin-bottom: -1px;
  transition: color 0.15s ease, border-color 0.15s ease;
}

.dash__tab:hover {
  color: var(--cream);
}

.dash__tab--active {
  color: var(--blue-2);
  border-bottom-color: var(--blue);
}

.dash__state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding-block: var(--space-8);
  color: var(--charcoal);
  text-align: center;
}

.dash__state--error {
  color: var(--danger);
}

.dash__list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.row {
  display: grid;
  grid-template-columns: 64px 1fr auto;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-3) var(--space-4);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
}

.row:hover {
  border-color: var(--border-strong);
}

.row__img {
  width: 64px;
  height: 48px;
  object-fit: cover;
  border-radius: var(--radius-sm);
  background: var(--surface-2);
}

.row__img--empty {
  display: grid;
  place-items: center;
  color: var(--charcoal);
}

.row__name {
  font-size: 0.98rem;
  font-weight: 600;
  color: var(--cream);
}

.row__meta {
  font-size: 0.8rem;
  color: var(--charcoal);
  margin-top: 2px;
}

.row__actions {
  display: flex;
  gap: var(--space-2);
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.15s ease;
}

.btn--sm {
  padding: var(--space-2) var(--space-4);
  font-size: 0.85rem;
}

.btn--primary {
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover {
  background: var(--blue-2);
}

.btn--ghost {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

.btn--ghost:hover {
  border-color: var(--blue);
}

.btn--danger {
  background: rgba(217, 92, 74, 0.14);
  border: 1px solid rgba(217, 92, 74, 0.4);
  color: var(--danger);
}

.btn--danger:hover {
  background: rgba(217, 92, 74, 0.22);
}

@media (max-width: 640px) {
  .row {
    grid-template-columns: 48px 1fr;
    grid-template-areas:
      'media info'
      'actions actions';
  }
  .row__media {
    grid-area: media;
  }
  .row__info {
    grid-area: info;
  }
  .row__actions {
    grid-area: actions;
    justify-content: flex-end;
  }
  .row__img {
    width: 48px;
    height: 40px;
  }
}
</style>
