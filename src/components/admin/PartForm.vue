<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useAdminParts, toPartInput } from '@/composables/useAdminParts'
import { useParts } from '@/composables/useParts'
import {
  AVAILABILITY_LABELS,
  ORIGIN_LABELS,
} from '@/types/part'
import type {
  Availability,
  Category,
  CompatInput,
  OriginType,
  Part,
  PartInput,
  SpecInput,
} from '@/types/part'

const props = defineProps<{ part: Part | null }>()
const emit = defineEmits<{ saved: []; cancel: [] }>()

const { createPart, updatePart, uploadImage } = useAdminParts()
const { fetchCategories } = useParts()

const isEdit = props.part !== null

// Categorías para el select (cargadas de la BD, ya no hardcodeadas).
const categories = ref<Category[]>([])
onMounted(async () => {
  try {
    categories.value = await fetchCategories()
  } catch (e) {
    console.error('[CalRod] PartForm fetchCategories:', e)
  }
})

// Estado del formulario. En edición partimos de la pieza; en alta, de vacíos.
const form = reactive<PartInput>(
  props.part
    ? toPartInput(props.part)
    : {
        code: '',
        name: '',
        category_id: null,
        brand: '',
        origin_type: 'original',
        price: 0,
        availability: 'disponible',
        description: null,
        material: null,
        image_url: null,
      },
)

const specs = reactive<SpecInput[]>(
  props.part?.part_specs?.map((s) => ({ label: s.label, value: s.value })) ?? [],
)

const compat = reactive<CompatInput[]>(
  props.part?.part_compatibility?.map((c) => ({
    vehicle_brand: c.vehicle_brand,
    vehicle_model: c.vehicle_model,
    year_from: c.year_from,
    year_to: c.year_to,
  })) ?? [],
)

// Selects tipados a partir de los mismos catálogos que usa la UI pública.
const origins = Object.entries(ORIGIN_LABELS) as [OriginType, string][]
const availabilities = Object.entries(AVAILABILITY_LABELS) as [Availability, string][]

// ── Foto ────────────────────────────────────────────────────────────────────
const imageFile = ref<File | null>(null)
const preview = ref<string | null>(props.part?.image_url ?? null)

function onFileChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0] ?? null
  imageFile.value = file
  if (file) preview.value = URL.createObjectURL(file)
}

// ── Specs / compatibilidad dinámicas ─────────────────────────────────────────
function addSpec() {
  specs.push({ label: '', value: '' })
}
function removeSpec(i: number) {
  specs.splice(i, 1)
}
function addCompat() {
  const y = 2020
  compat.push({ vehicle_brand: '', vehicle_model: '', year_from: y, year_to: y })
}
function removeCompat(i: number) {
  compat.splice(i, 1)
}

// ── Guardar ──────────────────────────────────────────────────────────────────
const saving = ref(false)
const error = ref<string | null>(null)

async function onSubmit() {
  error.value = null

  if (!form.code.trim() || !form.name.trim() || !form.brand.trim()) {
    error.value = 'Código, nombre y marca son obligatorios.'
    return
  }
  if (form.price < 0 || Number.isNaN(form.price)) {
    error.value = 'El precio debe ser un número válido.'
    return
  }

  saving.value = true
  try {
    // Si hay archivo nuevo, se sube primero y su URL pública va a image_url.
    if (imageFile.value) {
      form.image_url = await uploadImage(imageFile.value, form.code)
    }

    // Normalizamos textos opcionales vacíos a null.
    const payload: PartInput = {
      ...form,
      code: form.code.trim(),
      name: form.name.trim(),
      brand: form.brand.trim(),
      description: form.description?.trim() || null,
      material: form.material?.trim() || null,
    }

    if (isEdit && props.part) {
      await updatePart(props.part.id, payload, [...specs], [...compat])
    } else {
      await createPart(payload, [...specs], [...compat])
    }
    emit('saved')
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe una pieza con ese código.'
    } else if (msg.includes('row-level security') || msg.includes('policy')) {
      error.value = 'Sin permisos para guardar. ¿Sigue tu sesión de admin activa?'
    } else {
      error.value = 'No se pudo guardar la pieza. Intenta de nuevo.'
    }
    console.error('[CalRod] PartForm submit:', e)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="form" @submit.prevent="onSubmit">
    <div class="form__head">
      <h2 class="form__title">{{ isEdit ? 'Editar pieza' : 'Nueva pieza' }}</h2>
      <button type="button" class="form__back" @click="emit('cancel')">
        ← Volver a la lista
      </button>
    </div>

    <!-- Datos principales -->
    <fieldset class="block">
      <legend class="block__legend">Datos de la pieza</legend>
      <div class="grid">
        <label class="field">
          <span class="field__label">Código / SKU *</span>
          <input v-model="form.code" class="field__input" placeholder="BR-4471-C" />
        </label>
        <label class="field">
          <span class="field__label">Nombre *</span>
          <input v-model="form.name" class="field__input" placeholder="Balata delantera" />
        </label>
        <label class="field">
          <span class="field__label">Marca *</span>
          <input v-model="form.brand" class="field__input" placeholder="CalRod Original" />
        </label>
        <label class="field">
          <span class="field__label">Precio (USD) *</span>
          <input
            v-model.number="form.price"
            type="number"
            min="0"
            step="0.01"
            class="field__input"
          />
        </label>
        <label class="field">
          <span class="field__label">Categoría</span>
          <select v-model="form.category_id" class="field__input">
            <option :value="null">— Sin categoría —</option>
            <option v-for="c in categories" :key="c.id" :value="c.id">
              {{ c.name }}
            </option>
          </select>
        </label>
        <label class="field">
          <span class="field__label">Origen</span>
          <select v-model="form.origin_type" class="field__input">
            <option v-for="[value, label] in origins" :key="value" :value="value">
              {{ label }}
            </option>
          </select>
        </label>
        <label class="field">
          <span class="field__label">Disponibilidad</span>
          <select v-model="form.availability" class="field__input">
            <option v-for="[value, label] in availabilities" :key="value" :value="value">
              {{ label }}
            </option>
          </select>
        </label>
        <label class="field">
          <span class="field__label">Material</span>
          <input v-model="form.material" class="field__input" placeholder="Cerámica" />
        </label>
      </div>

      <label class="field field--full">
        <span class="field__label">Descripción</span>
        <textarea
          v-model="form.description"
          class="field__input field__textarea"
          rows="3"
          placeholder="Detalle breve de la pieza."
        ></textarea>
      </label>
    </fieldset>

    <!-- Foto -->
    <fieldset class="block">
      <legend class="block__legend">Foto</legend>
      <div class="photo">
        <div class="photo__preview">
          <img v-if="preview" :src="preview" alt="Vista previa" class="photo__img" />
          <div v-else class="photo__img photo__img--empty" aria-hidden="true">
            <span class="mono">Sin imagen</span>
          </div>
        </div>
        <div class="photo__control">
          <label class="btn btn--ghost">
            {{ preview ? 'Cambiar foto' : 'Subir foto' }}
            <input
              type="file"
              accept="image/*"
              class="photo__file"
              @change="onFileChange"
            />
          </label>
          <p class="photo__hint">
            Se sube al bucket <code>part-images</code> al guardar. La URL pública se
            genera sola.
          </p>
        </div>
      </div>
    </fieldset>

    <!-- Especificaciones -->
    <fieldset class="block">
      <legend class="block__legend">Especificaciones</legend>
      <div v-if="specs.length" class="rows">
        <div v-for="(spec, i) in specs" :key="i" class="rows__item">
          <input v-model="spec.label" class="field__input" placeholder="Diámetro" />
          <input v-model="spec.value" class="field__input" placeholder="280mm" />
          <button
            type="button"
            class="rows__remove"
            aria-label="Quitar especificación"
            @click="removeSpec(i)"
          >
            ×
          </button>
        </div>
      </div>
      <p v-else class="block__empty">Sin especificaciones. Agrega las que apliquen.</p>
      <button type="button" class="btn btn--ghost btn--sm" @click="addSpec">
        + Agregar especificación
      </button>
    </fieldset>

    <!-- Compatibilidad -->
    <fieldset class="block">
      <legend class="block__legend">Compatibilidad</legend>
      <div v-if="compat.length" class="rows">
        <div v-for="(c, i) in compat" :key="i" class="rows__item rows__item--compat">
          <input v-model="c.vehicle_brand" class="field__input" placeholder="Nissan" />
          <input v-model="c.vehicle_model" class="field__input" placeholder="Sentra" />
          <input
            v-model.number="c.year_from"
            type="number"
            class="field__input"
            placeholder="Desde"
          />
          <input
            v-model.number="c.year_to"
            type="number"
            class="field__input"
            placeholder="Hasta"
          />
          <button
            type="button"
            class="rows__remove"
            aria-label="Quitar compatibilidad"
            @click="removeCompat(i)"
          >
            ×
          </button>
        </div>
      </div>
      <p v-else class="block__empty">Sin compatibilidad. Agrega marca, modelo y años.</p>
      <button type="button" class="btn btn--ghost btn--sm" @click="addCompat">
        + Agregar compatibilidad
      </button>
    </fieldset>

    <!-- Acciones -->
    <p v-if="error" class="form__error" role="alert">{{ error }}</p>
    <div class="form__actions">
      <button type="button" class="btn btn--ghost" @click="emit('cancel')">
        Cancelar
      </button>
      <button type="submit" class="btn btn--primary" :disabled="saving">
        {{ saving ? 'Guardando…' : isEdit ? 'Guardar cambios' : 'Crear pieza' }}
      </button>
    </div>
  </form>
</template>

<style scoped>
.form {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.form__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.form__title {
  font-size: 1.4rem;
  font-weight: 800;
  letter-spacing: -0.02em;
}

.form__back {
  color: var(--blue-2);
  font-weight: 500;
  font-size: 0.9rem;
}

.form__back:hover {
  text-decoration: underline;
  text-underline-offset: 3px;
}

.block {
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  background: var(--surface);
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.block__legend {
  font-family: var(--font-display);
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--blue-2);
  padding: 0 var(--space-2);
}

.block__empty {
  color: var(--charcoal);
  font-size: 0.88rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--space-4);
}

.field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.field--full {
  grid-column: 1 / -1;
}

.field__label {
  font-size: 0.8rem;
  color: var(--charcoal);
  font-weight: 500;
}

.field__input {
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--cream);
  font-size: 0.92rem;
  padding: 0 var(--space-3);
  height: 42px;
  outline: none;
  transition: border-color 0.15s ease;
  width: 100%;
}

.field__input:focus {
  border-color: var(--blue);
}

.field__input::placeholder {
  color: var(--charcoal);
}

.field__textarea {
  height: auto;
  padding: var(--space-3);
  resize: vertical;
  font-family: inherit;
  line-height: 1.5;
}

select.field__input {
  appearance: none;
  cursor: pointer;
}

/* Foto */
.photo {
  display: flex;
  gap: var(--space-5);
  align-items: center;
  flex-wrap: wrap;
}

.photo__img {
  width: 160px;
  aspect-ratio: 4 / 3;
  object-fit: cover;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  background: var(--surface-2);
}

.photo__img--empty {
  display: grid;
  place-items: center;
  color: var(--charcoal);
  font-size: 0.8rem;
}

.photo__control {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.photo__file {
  display: none;
}

.photo__hint {
  color: var(--charcoal);
  font-size: 0.82rem;
  max-width: 40ch;
}

.photo__hint code {
  font-family: var(--font-mono);
  color: var(--blue-2);
}

/* Filas dinámicas */
.rows {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.rows__item {
  display: grid;
  grid-template-columns: 1fr 1fr auto;
  gap: var(--space-2);
  align-items: center;
}

.rows__item--compat {
  grid-template-columns: 1.2fr 1.2fr 0.8fr 0.8fr auto;
}

.rows__remove {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-sm);
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--charcoal);
  font-size: 1.2rem;
  line-height: 1;
  transition: all 0.15s ease;
}

.rows__remove:hover {
  border-color: var(--danger);
  color: var(--danger);
}

/* Botones */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.15s ease;
  align-self: flex-start;
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
  cursor: pointer;
}

.btn--ghost:hover {
  border-color: var(--blue);
}

.btn:disabled {
  opacity: 0.6;
  cursor: default;
}

.form__error {
  color: var(--danger);
  font-size: 0.9rem;
}

.form__actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
}

@media (max-width: 640px) {
  .grid {
    grid-template-columns: 1fr;
  }
  .rows__item--compat {
    grid-template-columns: 1fr 1fr;
  }
}
</style>
