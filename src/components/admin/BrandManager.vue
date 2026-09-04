<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useParts } from '@/composables/useParts'
import { useAdminBrands, slugify } from '@/composables/useAdminBrands'
import type { Brand } from '@/types/part'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const { fetchBrands } = useParts()
const { createBrand, updateBrand, deleteBrand, uploadBrandLogo } = useAdminBrands()

const brands = ref<Brand[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

// Formulario inline: si `editingId` es null, es alta; si no, edición.
const editingId = ref<string | null>(null)
const draft = reactive<{ name: string; logo_url: string | null }>({ name: '', logo_url: null })
const logoFile = ref<File | null>(null)
const logoPreview = ref<string | null>(null)
const saving = ref(false)

async function load() {
  loading.value = true
  error.value = null
  try {
    brands.value = await fetchBrands()
  } catch (e) {
    error.value = 'No pudimos cargar las marcas.'
    console.error('[CalRod] BrandManager load:', e)
  } finally {
    loading.value = false
  }
}

function onLogoChange(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    logoFile.value = file
    logoPreview.value = URL.createObjectURL(file)
  }
}

function clearLogo() {
  logoFile.value = null
  logoPreview.value = null
  draft.logo_url = null
}

function startNew() {
  editingId.value = null
  draft.name = ''
  clearLogo()
}

function startEdit(brand: Brand) {
  editingId.value = brand.id
  draft.name = brand.name
  draft.logo_url = brand.logo_url ?? null
  logoFile.value = null
  logoPreview.value = brand.logo_url ?? null
}

async function save() {
  const name = draft.name.trim()
  if (!name) {
    error.value = 'El nombre de la marca es obligatorio.'
    return
  }
  saving.value = true
  error.value = null
  try {
    const slug = slugify(name)
    let finalLogo = draft.logo_url
    if (logoFile.value) {
      finalLogo = await uploadBrandLogo(logoFile.value, slug)
    }

    const input = { name, slug, logo_url: finalLogo }
    if (editingId.value) {
      await updateBrand(editingId.value, input)
    } else {
      await createBrand(input)
    }
    startNew()
    await load()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe una marca con ese nombre.'
    } else if (msg.includes('row-level security') || msg.includes('policy')) {
      error.value = 'Sin permisos. ¿Sigue tu sesión de admin activa?'
    } else {
      error.value = 'No se pudo guardar la marca.'
    }
    console.error('[CalRod] BrandManager save:', e)
  } finally {
    saving.value = false
  }
}

async function remove(brand: Brand) {
  if (
    !confirm(
      `¿Borrar la marca "${brand.name}"? Las piezas que la usan quedarán sin marca.`,
    )
  )
    return
  try {
    await deleteBrand(brand.id)
    await load()
  } catch (e) {
    alert('No se pudo borrar la marca. ¿Sigue tu sesión activa?')
    console.error('[CalRod] BrandManager remove:', e)
  }
}

onMounted(load)
</script>

<template>
  <section class="cats">
    <form class="cats__form" @submit.prevent="save">
      <label class="field">
        <span class="field__label">
          {{ editingId ? 'Editar marca de repuesto' : 'Nueva marca de repuesto' }}
        </span>
        <div class="cats__form-row">
          <input
            v-model="draft.name"
            class="field__input"
            placeholder="Ej. STP"
          />

          <label class="btn btn--ghost btn--logo-upload">
            <span v-if="logoPreview">Cambiar Logo</span>
            <span v-else>Subir Logo</span>
            <input type="file" accept="image/*" class="file-hidden" @change="onLogoChange" />
          </label>

          <div v-if="logoPreview" class="logo-preview-wrap">
            <img :src="logoPreview" alt="Logo preview" class="logo-preview-img" />
            <button type="button" class="logo-clear-btn" title="Quitar logo" @click="clearLogo">✕</button>
          </div>

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
      <p>Cargando marcas…</p>
    </div>

    <p v-else-if="!brands.length" class="cats__state">
      Aún no hay marcas. Crea la primera arriba.
    </p>

    <ul v-else class="cats__list">
      <li v-for="brand in brands" :key="brand.id" class="cats__item">
        <div class="cats__main-col">
          <div v-if="brand.logo_url" class="brand-logo-thumb">
            <img :src="brand.logo_url" :alt="brand.name" />
          </div>
          <div v-else class="brand-logo-thumb brand-logo-thumb--empty">
            <span>{{ brand.name.slice(0, 2).toUpperCase() }}</span>
          </div>
          <div class="cats__info">
            <span class="cats__name">{{ brand.name }}</span>
            <span class="cats__slug mono">{{ brand.slug }}</span>
          </div>
        </div>
        <div class="cats__actions">
          <button class="btn btn--ghost btn--sm" @click="startEdit(brand)">
            Editar
          </button>
          <button class="btn btn--danger btn--sm" @click="remove(brand)">
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

.cats__main-col {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.brand-logo-thumb {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  background: var(--surface-2);
  border: 1px solid var(--border);
  display: grid;
  place-items: center;
  overflow: hidden;
  flex-shrink: 0;
}

.brand-logo-thumb img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 3px;
}

.brand-logo-thumb--empty {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--charcoal);
  font-family: var(--font-display);
}

.file-hidden {
  display: none;
}

.btn--logo-upload {
  cursor: pointer;
  height: 42px;
}

.logo-preview-wrap {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.logo-preview-img {
  width: 42px;
  height: 42px;
  object-fit: contain;
  border-radius: var(--radius-sm);
  background: var(--surface-2);
  border: 1px solid var(--blue);
  padding: 2px;
}

.logo-clear-btn {
  position: absolute;
  top: -6px;
  right: -6px;
  width: 18px;
  height: 18px;
  background: var(--danger);
  color: #fff;
  border: none;
  border-radius: 50%;
  font-size: 0.7rem;
  cursor: pointer;
  display: grid;
  place-items: center;
}

.btn:disabled {
  opacity: 0.6;
  cursor: default;
}
</style>
