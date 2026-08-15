<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useParts } from '@/composables/useParts'
import { useAdminCategories, slugify } from '@/composables/useAdminCategories'
import type { Category } from '@/types/part'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const { fetchCategories } = useParts()
const { createCategory, updateCategory, deleteCategory } = useAdminCategories()

const categories = ref<Category[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

// Formulario inline: si `editingId` es null, es alta; si no, edición.
const editingId = ref<string | null>(null)
const draft = reactive({ name: '' })
const saving = ref(false)

async function load() {
  loading.value = true
  error.value = null
  try {
    categories.value = await fetchCategories()
  } catch (e) {
    error.value = 'No pudimos cargar las categorías.'
    console.error('[CalRod] CategoryManager load:', e)
  } finally {
    loading.value = false
  }
}

function startNew() {
  editingId.value = null
  draft.name = ''
}

function startEdit(cat: Category) {
  editingId.value = cat.id
  draft.name = cat.name
}

async function save() {
  const name = draft.name.trim()
  if (!name) {
    error.value = 'El nombre de la categoría es obligatorio.'
    return
  }
  saving.value = true
  error.value = null
  try {
    const input = { name, slug: slugify(name) }
    if (editingId.value) {
      await updateCategory(editingId.value, input)
    } else {
      await createCategory(input)
    }
    draft.name = ''
    editingId.value = null
    await load()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe una categoría con ese nombre.'
    } else if (msg.includes('row-level security') || msg.includes('policy')) {
      error.value = 'Sin permisos. ¿Sigue tu sesión de admin activa?'
    } else {
      error.value = 'No se pudo guardar la categoría.'
    }
    console.error('[CalRod] CategoryManager save:', e)
  } finally {
    saving.value = false
  }
}

async function remove(cat: Category) {
  if (
    !confirm(
      `¿Borrar la categoría "${cat.name}"? Las piezas que la usan quedarán sin categoría.`,
    )
  )
    return
  try {
    await deleteCategory(cat.id)
    await load()
  } catch (e) {
    alert('No se pudo borrar la categoría. ¿Sigue tu sesión activa?')
    console.error('[CalRod] CategoryManager remove:', e)
  }
}

onMounted(load)
</script>

<template>
  <section class="cats">
    <form class="cats__form" @submit.prevent="save">
      <label class="field">
        <span class="field__label">
          {{ editingId ? 'Editar categoría' : 'Nueva categoría' }}
        </span>
        <div class="cats__form-row">
          <input
            v-model="draft.name"
            class="field__input"
            placeholder="Ej. Frenos"
          />
          <button type="submit" class="btn btn--primary" :disabled="saving">
            {{ saving ? 'Guardando…' : editingId ? 'Guardar' : 'Agregar' }}
          </button>
          <button
            v-if="editingId"
            type="button"
            class="btn btn--ghost"
            @click="startNew"
          >
            Cancelar
          </button>
        </div>
      </label>
    </form>

    <p v-if="error" class="cats__error" role="alert">{{ error }}</p>

    <div v-if="loading" class="cats__state">
      <GearSpinner :size="40" />
      <p>Cargando categorías…</p>
    </div>

    <p v-else-if="!categories.length" class="cats__state">
      Aún no hay categorías. Crea la primera arriba.
    </p>

    <ul v-else class="cats__list">
      <li v-for="cat in categories" :key="cat.id" class="cats__item">
        <div class="cats__info">
          <span class="cats__name">{{ cat.name }}</span>
          <span class="cats__slug mono">{{ cat.slug }}</span>
        </div>
        <div class="cats__actions">
          <button class="btn btn--ghost btn--sm" @click="startEdit(cat)">
            Editar
          </button>
          <button class="btn btn--danger btn--sm" @click="remove(cat)">
            Borrar
          </button>
        </div>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.cats {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.cats__form {
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  background: var(--surface);
  padding: var(--space-5);
}

.field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.field__label {
  font-size: 0.8rem;
  color: var(--charcoal);
  font-weight: 500;
}

.cats__form-row {
  display: flex;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.field__input {
  flex: 1;
  min-width: 200px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--cream);
  font-size: 0.92rem;
  padding: 0 var(--space-3);
  height: 42px;
  outline: none;
  transition: border-color 0.15s ease;
}

.field__input:focus {
  border-color: var(--blue);
}

.field__input::placeholder {
  color: var(--charcoal);
}

.cats__error {
  color: var(--danger);
  font-size: 0.9rem;
}

.cats__state {
  color: var(--charcoal);
  text-align: center;
  padding-block: var(--space-6);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

.cats__list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.cats__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-3) var(--space-4);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
}

.cats__item:hover {
  border-color: var(--border-strong);
}

.cats__info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.cats__name {
  font-weight: 600;
  color: var(--cream);
}

.cats__slug {
  font-size: 0.78rem;
  color: var(--charcoal);
}

.cats__actions {
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
  cursor: pointer;
}

.btn--sm {
  padding: var(--space-2) var(--space-4);
  font-size: 0.85rem;
}

.btn--primary {
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover:not(:disabled) {
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

.btn:disabled {
  opacity: 0.6;
  cursor: default;
}
</style>


