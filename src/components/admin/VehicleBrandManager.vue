<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useParts } from '@/composables/useParts'
import {
  useAdminVehicleBrands,
  slugify,
} from '@/composables/useAdminVehicleBrands'
import { useAdminVehicleModels } from '@/composables/useAdminVehicleModels'
import { useAdminVehicleMotors } from '@/composables/useAdminVehicleMotors'
import type { VehicleBrand, VehicleModel, VehicleMotor } from '@/types/part'
import GearSpinner from '@/components/brand/GearSpinner.vue'

/**
 * VehicleBrandManager — Gestor visual jerárquico del vehículo (0013, 0016):
 *   Marca (Toyota) ──▶ Modelos (Corolla, Yaris) ──▶ Motores (1.8L, 2.0L)
 *
 * Permite administrar marcas, modelos y motores en un solo lugar con
 * validaciones seguras de borrado (FK restrict para no romper compatibilidades).
 */
const { fetchVehicleBrands, fetchVehicleModels, fetchVehicleMotors } = useParts()
const {
  createVehicleBrand,
  updateVehicleBrand,
  deleteVehicleBrand,
  uploadBrandLogo,
  fetchUsageCounts: fetchBrandUsage,
} = useAdminVehicleBrands()

const {
  createVehicleModel,
  updateVehicleModel,
  deleteVehicleModel,
  uploadModelImage,
  fetchUsageCounts: fetchModelUsage,
} = useAdminVehicleModels()

const {
  createVehicleMotor,
  updateVehicleMotor,
  deleteVehicleMotor,
  fetchUsageCounts: fetchMotorUsage,
} = useAdminVehicleMotors()

// Listas maestras
const brands = ref<VehicleBrand[]>([])
const models = ref<VehicleModel[]>([])
const motors = ref<VehicleMotor[]>([])

// Conteo de uso en compatibilidades de piezas
const brandUsage = ref<Record<string, number>>({})
const modelUsage = ref<Record<string, number>>({})
const motorUsage = ref<Record<string, number>>({})

const loading = ref(false)
const error = ref<string | null>(null)
const saving = ref(false)

// Expansión de acordeones
const expandedBrandIds = ref<Set<string>>(new Set())
const expandedModelIds = ref<Set<string>>(new Set())

function toggleBrand(id: string) {
  if (expandedBrandIds.value.has(id)) {
    expandedBrandIds.value.delete(id)
  } else {
    expandedBrandIds.value.add(id)
  }
}

function toggleModel(id: string) {
  if (expandedModelIds.value.has(id)) {
    expandedModelIds.value.delete(id)
  } else {
    expandedModelIds.value.add(id)
  }
}

// ── CRUD Marcas ─────────────────────────────────────────────────────────────
const editingBrandId = ref<string | null>(null)
const brandDraft = reactive<{ name: string; logo_url: string | null }>({ name: '', logo_url: null })
const brandLogoFile = ref<File | null>(null)
const brandLogoPreview = ref<string | null>(null)

function onBrandLogoChange(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    brandLogoFile.value = file
    brandLogoPreview.value = URL.createObjectURL(file)
  }
}

function clearBrandLogo() {
  brandLogoFile.value = null
  brandLogoPreview.value = null
  brandDraft.logo_url = null
}

function startNewBrand() {
  editingBrandId.value = null
  brandDraft.name = ''
  clearBrandLogo()
}

function startEditBrand(brand: VehicleBrand) {
  editingBrandId.value = brand.id
  brandDraft.name = brand.name
  brandDraft.logo_url = brand.logo_url ?? null
  brandLogoFile.value = null
  brandLogoPreview.value = brand.logo_url ?? null
}

async function saveBrand() {
  const name = brandDraft.name.trim()
  if (!name) {
    error.value = 'El nombre de la marca de auto es obligatorio.'
    return
  }
  saving.value = true
  error.value = null
  try {
    const slug = slugify(name)
    let finalLogo = brandDraft.logo_url
    if (brandLogoFile.value) {
      finalLogo = await uploadBrandLogo(brandLogoFile.value, slug)
    }

    const input = { name, slug, logo_url: finalLogo }
    if (editingBrandId.value) {
      await updateVehicleBrand(editingBrandId.value, input)
    } else {
      const created = await createVehicleBrand(input)
      expandedBrandIds.value.add(created.id)
    }
    startNewBrand()
    await load()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe una marca de auto con ese nombre.'
    } else {
      error.value = 'No se pudo guardar la marca de auto.'
    }
    console.error('[CalRod] saveBrand:', e)
  } finally {
    saving.value = false
  }
}

async function removeBrand(brand: VehicleBrand) {
  const used = brandUsage.value[brand.id] ?? 0
  if (used > 0) {
    error.value = `“${brand.name}” está en uso en ${used} compatibilidad(es) de piezas. Quítala de esas piezas antes de borrarla.`
    return
  }
  const brandModels = modelsOf(brand.id)
  if (brandModels.length > 0) {
    if (
      !confirm(
        `La marca "${brand.name}" tiene ${brandModels.length} modelo(s) registrado(s). ¿Deseas borrarla junto con todos sus modelos y motores?`,
      )
    )
      return
  } else {
    if (!confirm(`¿Borrar la marca de auto "${brand.name}"?`)) return
  }

  error.value = null
  try {
    await deleteVehicleBrand(brand.id)
    expandedBrandIds.value.delete(brand.id)
    await load()
  } catch (e) {
    error.value = 'No se pudo borrar la marca. Asegúrate de que sus modelos no estén en uso.'
    console.error('[CalRod] removeBrand:', e)
  }
}

// ── CRUD Modelos ────────────────────────────────────────────────────────────
const addingModelToBrandId = ref<string | null>(null)
const editingModelId = ref<string | null>(null)
const modelDraft = reactive<{ name: string; image_url: string | null }>({ name: '', image_url: null })
const modelImageFile = ref<File | null>(null)
const modelImagePreview = ref<string | null>(null)

function onModelImageChange(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    modelImageFile.value = file
    modelImagePreview.value = URL.createObjectURL(file)
  }
}

function clearModelImage() {
  modelImageFile.value = null
  modelImagePreview.value = null
  modelDraft.image_url = null
}

function startAddModel(brandId: string) {
  addingModelToBrandId.value = brandId
  editingModelId.value = null
  modelDraft.name = ''
  clearModelImage()
  expandedBrandIds.value.add(brandId)
}

function startEditModel(model: VehicleModel) {
  editingModelId.value = model.id
  addingModelToBrandId.value = null
  modelDraft.name = model.name
  modelDraft.image_url = model.image_url ?? null
  modelImageFile.value = null
  modelImagePreview.value = model.image_url ?? null
}

function cancelModelAction() {
  addingModelToBrandId.value = null
  editingModelId.value = null
  modelDraft.name = ''
  clearModelImage()
}

async function saveModel(brandId?: string) {
  const name = modelDraft.name.trim()
  if (!name) {
    error.value = 'El nombre del modelo es obligatorio.'
    return
  }
  saving.value = true
  error.value = null
  try {
    const slug = slugify(name)
    let finalImage = modelDraft.image_url
    if (modelImageFile.value) {
      finalImage = await uploadModelImage(modelImageFile.value, slug)
    }

    if (editingModelId.value) {
      await updateVehicleModel(editingModelId.value, {
        name,
        slug,
        image_url: finalImage,
      })
    } else if (brandId) {
      const created = await createVehicleModel({
        vehicle_brand_id: brandId,
        name,
        slug,
        image_url: finalImage,
      })
      expandedModelIds.value.add(created.id)
    }
    cancelModelAction()
    await load()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe un modelo con ese nombre en esta marca.'
    } else {
      error.value = 'No se pudo guardar el modelo.'
    }
    console.error('[CalRod] saveModel:', e)
  } finally {
    saving.value = false
  }
}

async function removeModel(model: VehicleModel) {
  const used = modelUsage.value[model.id] ?? 0
  if (used > 0) {
    error.value = `“${model.name}” está en uso en ${used} compatibilidad(es) de piezas. Quítalo de esas piezas antes de borrarlo.`
    return
  }
  if (!confirm(`¿Borrar el modelo "${model.name}" y sus motores asociados?`)) return
  error.value = null
  try {
    await deleteVehicleModel(model.id)
    expandedModelIds.value.delete(model.id)
    await load()
  } catch (e) {
    error.value = 'No se pudo borrar el modelo. ¿Sigue tu sesión activa?'
    console.error('[CalRod] removeModel:', e)
  }
}

// ── CRUD Motores ────────────────────────────────────────────────────────────
const addingMotorToModelId = ref<string | null>(null)
const addingMotorToBrandId = ref<string | null>(null)
const editingMotorId = ref<string | null>(null)
const motorDraft = reactive({ name: '' })

function startAddMotor(modelId: string) {
  addingMotorToModelId.value = modelId
  addingMotorToBrandId.value = null
  editingMotorId.value = null
  motorDraft.name = ''
  expandedModelIds.value.add(modelId)
}

function startAddMotorToBrand(brandId: string) {
  addingMotorToBrandId.value = brandId
  addingMotorToModelId.value = null
  editingMotorId.value = null
  motorDraft.name = ''
  expandedBrandIds.value.add(brandId)
}

function startEditMotor(motor: VehicleMotor) {
  editingMotorId.value = motor.id
  addingMotorToModelId.value = null
  addingMotorToBrandId.value = null
  motorDraft.name = motor.name
}

function cancelMotorAction() {
  addingMotorToModelId.value = null
  addingMotorToBrandId.value = null
  editingMotorId.value = null
  motorDraft.name = ''
}

async function saveMotor(brandId?: string, modelId?: string) {
  const name = motorDraft.name.trim()
  if (!name) {
    error.value = 'El nombre del motor es obligatorio (ej. 1.8L, 2.0 TDI, 22R).'
    return
  }
  if (!editingMotorId.value && !brandId) {
    error.value = 'Se requiere al menos una marca para crear el motor.'
    return
  }
  saving.value = true
  error.value = null
  try {
    if (editingMotorId.value) {
      await updateVehicleMotor(editingMotorId.value, {
        name,
        slug: slugify(name),
      })
    } else {
      await createVehicleMotor({
        vehicle_brand_id: brandId!,
        vehicle_model_id: modelId ?? null,
        name,
        slug: slugify(name),
      })
    }
    cancelMotorAction()
    await load()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe este motor registrado. '
    } else {
      error.value = 'No se pudo guardar el motor.'
    }
    console.error('[CalRod] saveMotor:', e)
  } finally {
    saving.value = false
  }
}

async function removeMotor(motor: VehicleMotor) {
  const used = motorUsage.value[motor.id] ?? 0
  if (used > 0) {
    error.value = `El motor "${motor.name}" está en uso en ${used} compatibilidad(es). Quítalo de esas piezas antes de borrarlo.`
    return
  }
  if (!confirm(`¿Borrar el motor "${motor.name}"?`)) return
  error.value = null
  try {
    await deleteVehicleMotor(motor.id)
    await load()
  } catch (e) {
    error.value = 'No se pudo borrar el motor.'
    console.error('[CalRod] removeMotor:', e)
  }
}

// ── Filtros y helpers ───────────────────────────────────────────────────────
const filter = ref('')
const visibleBrands = computed(() => {
  const q = filter.value.trim().toLowerCase()
  if (!q) return brands.value
  return brands.value.filter((b) => b.name.toLowerCase().includes(q))
})

function modelsOf(brandId: string): VehicleModel[] {
  return models.value.filter((m) => m.vehicle_brand_id === brandId)
}

function motorsOf(modelId: string): VehicleMotor[] {
  return motors.value.filter((mo) => mo.vehicle_model_id === modelId)
}

/** Motores asignados directamente a la Marca (sin modelo). */
function motorsOfBrand(brandId: string): VehicleMotor[] {
  return motors.value.filter(
    (mo) => mo.vehicle_brand_id === brandId && !mo.vehicle_model_id,
  )
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const [
      brandList,
      modelList,
      motorList,
      brandCounts,
      modelCounts,
      motorCounts,
    ] = await Promise.all([
      fetchVehicleBrands(),
      fetchVehicleModels(),
      fetchVehicleMotors(),
      fetchBrandUsage(),
      fetchModelUsage(),
      fetchMotorUsage(),
    ])
    brands.value = brandList
    models.value = modelList
    motors.value = motorList
    brandUsage.value = brandCounts
    modelUsage.value = modelCounts
    motorUsage.value = motorCounts
  } catch (e) {
    error.value = 'No pudimos cargar los datos de vehículos.'
    console.error('[CalRod] VehicleManager load:', e)
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <section class="veh-mgr">
    <!-- Formulario superior para Marca de Auto -->
    <form class="veh-mgr__form" @submit.prevent="saveBrand">
      <label class="field">
        <span class="field__label">
          {{ editingBrandId ? 'Editar marca de auto' : 'Nueva marca de auto' }}
        </span>
        <div class="veh-mgr__form-row">
          <input
            v-model="brandDraft.name"
            class="field__input"
            placeholder="Ej. Toyota, Nissan, Chevrolet…"
          />

          <label class="btn btn--ghost btn--logo-upload">
            <span v-if="brandLogoPreview">Cambiar Logo</span>
            <span v-else>Subir Logo</span>
            <input type="file" accept="image/*" class="file-hidden" @change="onBrandLogoChange" />
          </label>

          <div v-if="brandLogoPreview" class="logo-preview-wrap">
            <img :src="brandLogoPreview" alt="Logo preview" class="logo-preview-img" />
            <button type="button" class="logo-clear-btn" title="Quitar logo" @click="clearBrandLogo">✕</button>
          </div>

          <button type="submit" class="btn btn--primary" :disabled="saving">
            {{ saving ? 'Guardando…' : editingBrandId ? 'Guardar' : 'Agregar marca' }}
          </button>
          <button
            v-if="editingBrandId"
            type="button"
            class="btn btn--ghost"
            @click="startNewBrand"
          >
            Cancelar
          </button>
        </div>
      </label>
      <p class="veh-mgr__hint">
        Administra la jerarquía completa: <b>Marca → Modelos → Motores</b>.
        Despliega cada marca para gestionar sus modelos y los motores de cada uno.
      </p>
    </form>

    <p v-if="error" class="veh-mgr__error" role="alert">{{ error }}</p>

    <div v-if="loading" class="veh-mgr__state">
      <GearSpinner :size="40" />
      <p>Cargando árbol de vehículos…</p>
    </div>

    <p v-else-if="!brands.length" class="veh-mgr__state">
      El nomenclador está vacío. Crea la primera marca de auto arriba.
    </p>

    <template v-else>
      <div class="veh-mgr__toolbar">
        <input
          v-model="filter"
          class="field__input veh-mgr__search"
          placeholder="Buscar marca de auto…"
          aria-label="Buscar marca de auto"
        />
        <span class="veh-mgr__count mono">
          {{ visibleBrands.length }} marcas registradas
        </span>
      </div>

      <p v-if="!visibleBrands.length" class="veh-mgr__state">
        Ninguna marca coincide con “{{ filter }}”.
      </p>

      <!-- Lista jerárquica de Marcas -->
      <div v-else class="tree">
        <article
          v-for="brand in visibleBrands"
          :key="brand.id"
          class="tree__brand"
          :class="{ 'tree__brand--open': expandedBrandIds.has(brand.id) }"
        >
          <!-- Cabecera de la Marca -->
          <div class="tree__brand-header">
            <button
              type="button"
              class="tree__expand-btn"
              :aria-expanded="expandedBrandIds.has(brand.id)"
              :title="expandedBrandIds.has(brand.id) ? 'Ocultar modelos' : 'Ver modelos'"
              @click="toggleBrand(brand.id)"
            >
              <span class="tree__chevron">{{ expandedBrandIds.has(brand.id) ? '▼' : '▶' }}</span>
              <img v-if="brand.logo_url" :src="brand.logo_url" :alt="brand.name" class="brand-logo-img" />
              <span v-else class="brand-logo-placeholder">{{ brand.name.slice(0, 2).toUpperCase() }}</span>
              <span class="tree__brand-name">{{ brand.name }}</span>
            </button>

            <div class="tree__badges">
              <span class="badge badge--models">
                {{ modelsOf(brand.id).length }} {{ modelsOf(brand.id).length === 1 ? 'modelo' : 'modelos' }}
              </span>
              <span v-if="brandUsage[brand.id]" class="badge badge--usage">
                {{ brandUsage[brand.id] }} {{ brandUsage[brand.id] === 1 ? 'pieza' : 'piezas' }}
              </span>
            </div>

            <div class="tree__actions">
              <button
                type="button"
                class="btn btn--ghost btn--xs"
                @click="startAddModel(brand.id)"
              >
                + Modelo
              </button>
              <button
                type="button"
                class="btn btn--ghost btn--xs btn--motor-brand"
                @click="startAddMotorToBrand(brand.id)"
              >
                + Motor de marca
              </button>
              <button
                type="button"
                class="btn btn--ghost btn--xs"
                @click="startEditBrand(brand)"
              >
                Editar
              </button>
              <button
                type="button"
                class="btn btn--danger btn--xs"
                :disabled="(brandUsage[brand.id] ?? 0) > 0"
                :title="
                  (brandUsage[brand.id] ?? 0) > 0
                    ? 'En uso por piezas del catálogo'
                    : 'Borrar marca'
                "
                @click="removeBrand(brand)"
              >
                Borrar
              </button>
            </div>
          </div>

          <!-- Contenido desplegable de la Marca -->
          <div v-if="expandedBrandIds.has(brand.id)" class="tree__brand-body">
            <!-- Motores a nivel de MARCA (sin modelo) -->
            <div class="tree__brand-motors-section">
              <div class="tree__brand-motors-header">
                <span class="tree__brand-motors-title">
                  🔧 Motores de la marca (sin modelo específico)
                </span>
                <button
                  v-if="addingMotorToBrandId !== brand.id"
                  type="button"
                  class="btn btn--ghost btn--xs"
                  @click="startAddMotorToBrand(brand.id)"
                >
                  + Agregar motor de marca
                </button>
              </div>

              <form
                v-if="addingMotorToBrandId === brand.id"
                class="inline-form"
                @submit.prevent="saveMotor(brand.id, undefined)"
              >
                <span class="inline-form__title">Motor de la marca {{ brand.name }} (sin modelo):</span>
                <div class="inline-form__row">
                  <input
                    v-model="motorDraft.name"
                    class="field__input field__input--sm"
                    placeholder="Ej. 22R, 350 V8, 1.8T, GA16…"
                    autofocus
                  />
                  <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">
                    Guardar motor
                  </button>
                  <button type="button" class="btn btn--ghost btn--xs" @click="cancelMotorAction">
                    Cancelar
                  </button>
                </div>
                <p class="inline-form__hint">Este motor aplica a cualquier modelo de {{ brand.name }}.</p>
              </form>

              <ul v-if="motorsOfBrand(brand.id).length" class="tree__motors-list tree__motors-list--brand">
                <li
                  v-for="motor in motorsOfBrand(brand.id)"
                  :key="motor.id"
                  class="tree__motor-item"
                >
                  <form
                    v-if="editingMotorId === motor.id"
                    class="inline-form inline-form--tight"
                    @submit.prevent="saveMotor(motor.vehicle_brand_id ?? undefined)"
                  >
                    <input v-model="motorDraft.name" class="field__input field__input--sm" autofocus />
                    <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">Guardar</button>
                    <button type="button" class="btn btn--ghost btn--xs" @click="cancelMotorAction">Cancelar</button>
                  </form>
                  <template v-else>
                    <div class="tree__motor-info">
                      <span class="tree__motor-name mono">{{ motor.name }}</span>
                      <span class="badge badge--brand-motor">nivel marca</span>
                      <span v-if="motorUsage[motor.id]" class="badge badge--usage">
                        {{ motorUsage[motor.id] }} compat.
                      </span>
                    </div>
                    <div class="tree__actions">
                      <button type="button" class="btn btn--ghost btn--xs" @click="startEditMotor(motor)">Editar</button>
                      <button
                        type="button"
                        class="btn btn--danger btn--xs"
                        :disabled="(motorUsage[motor.id] ?? 0) > 0"
                        @click="removeMotor(motor)"
                      >Borrar</button>
                    </div>
                  </template>
                </li>
              </ul>
              <p v-else-if="addingMotorToBrandId !== brand.id" class="tree__empty-sub tree__empty-sub--hint">
                Sin motores de marca. Los motores de marca se pueden usar en piezas sin especificar modelo.
              </p>
            </div>

            <!-- Formulario inline para agregar modelo a esta marca -->
            <form
              v-if="addingModelToBrandId === brand.id"
              class="inline-form"
              @submit.prevent="saveModel(brand.id)"
            >
              <span class="inline-form__title">Nuevo modelo para {{ brand.name }}:</span>
              <div class="inline-form__row">
                <input
                  v-model="modelDraft.name"
                  class="field__input field__input--sm"
                  placeholder="Ej. Corolla, Hilux, RAV4…"
                  autofocus
                />
                <label class="btn btn--ghost btn--xs btn--logo-upload">
                  <span v-if="modelImagePreview">Cambiar Foto</span>
                  <span v-else>Subir Foto</span>
                  <input type="file" accept="image/*" class="file-hidden" @change="onModelImageChange" />
                </label>
                <div v-if="modelImagePreview" class="logo-preview-wrap">
                  <img :src="modelImagePreview" alt="Foto modelo" class="logo-preview-img logo-preview-img--sm" />
                  <button type="button" class="logo-clear-btn" title="Quitar foto" @click="clearModelImage">✕</button>
                </div>
                <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">
                  Guardar modelo
                </button>
                <button type="button" class="btn btn--ghost btn--xs" @click="cancelModelAction">
                  Cancelar
                </button>
              </div>
            </form>

            <div v-if="!modelsOf(brand.id).length && addingModelToBrandId !== brand.id" class="tree__empty">
              <span>Esta marca aún no tiene modelos.</span>
              <button
                type="button"
                class="btn btn--ghost btn--xs"
                @click="startAddModel(brand.id)"
              >
                + Agregar primer modelo
              </button>
            </div>

            <!-- Lista de Modelos -->
            <div v-else class="tree__model-list">
              <div
                v-for="model in modelsOf(brand.id)"
                :key="model.id"
                class="tree__model-card"
                :class="{ 'tree__model-card--open': expandedModelIds.has(model.id) }"
              >
                <!-- Edición inline del modelo -->
                <form
                  v-if="editingModelId === model.id"
                  class="inline-form"
                  @submit.prevent="saveModel()"
                >
                  <span class="inline-form__title">Editar modelo:</span>
                  <div class="inline-form__row">
                    <input
                      v-model="modelDraft.name"
                      class="field__input field__input--sm"
                      autofocus
                    />
                    <label class="btn btn--ghost btn--xs btn--logo-upload">
                      <span v-if="modelImagePreview">Cambiar Foto</span>
                      <span v-else>Subir Foto</span>
                      <input type="file" accept="image/*" class="file-hidden" @change="onModelImageChange" />
                    </label>
                    <div v-if="modelImagePreview" class="logo-preview-wrap">
                      <img :src="modelImagePreview" alt="Foto modelo" class="logo-preview-img logo-preview-img--sm" />
                      <button type="button" class="logo-clear-btn" title="Quitar foto" @click="clearModelImage">✕</button>
                    </div>
                    <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">
                      Guardar
                    </button>
                    <button type="button" class="btn btn--ghost btn--xs" @click="cancelModelAction">
                      Cancelar
                    </button>
                  </div>
                </form>

                <!-- Vista normal del Modelo -->
                <div v-else class="tree__model-header">
                  <button
                    type="button"
                    class="tree__expand-btn tree__expand-btn--model"
                    :aria-expanded="expandedModelIds.has(model.id)"
                    @click="toggleModel(model.id)"
                  >
                    <span class="tree__chevron tree__chevron--sm">
                      {{ expandedModelIds.has(model.id) ? '▼' : '▶' }}
                    </span>
                    <img v-if="model.image_url" :src="model.image_url" :alt="model.name" class="model-thumb-img" />
                    <span class="tree__model-name">{{ model.name }}</span>
                  </button>

                  <div class="tree__badges">
                    <span class="badge badge--motors">
                      {{ motorsOf(model.id).length }} {{ motorsOf(model.id).length === 1 ? 'motor' : 'motores' }}
                    </span>
                    <span v-if="modelUsage[model.id]" class="badge badge--usage">
                      {{ modelUsage[model.id] }} compat.
                    </span>
                  </div>

                  <div class="tree__actions">
                    <button
                      type="button"
                      class="btn btn--ghost btn--xs"
                      @click="startAddMotor(model.id)"
                    >
                      + Motor
                    </button>
                    <button
                      type="button"
                      class="btn btn--ghost btn--xs"
                      @click="startEditModel(model)"
                    >
                      Editar
                    </button>
                    <button
                      type="button"
                      class="btn btn--danger btn--xs"
                      :disabled="(modelUsage[model.id] ?? 0) > 0"
                      :title="
                        (modelUsage[model.id] ?? 0) > 0
                          ? 'En uso por piezas del catálogo'
                          : 'Borrar modelo'
                      "
                      @click="removeModel(model)"
                    >
                      Borrar
                    </button>
                  </div>
                </div>

                <!-- Contenido desplegable del Modelo: Motores -->
                <div v-if="expandedModelIds.has(model.id)" class="tree__motors-box">
                  <!-- Formulario inline para agregar motor -->
                  <form
                    v-if="addingMotorToModelId === model.id"
                    class="inline-form"
                    @submit.prevent="saveMotor(model.id)"
                  >
                    <span class="inline-form__title">Nuevo motor para {{ model.name }}:</span>
                    <div class="inline-form__row">
                      <input
                        v-model="motorDraft.name"
                        class="field__input field__input--sm"
                        placeholder="Ej. 1.8L, 2.0 TDI, V6 3.5, 1.6 16V…"
                        autofocus
                      />
                      <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">
                        Guardar motor
                      </button>
                      <button type="button" class="btn btn--ghost btn--xs" @click="cancelMotorAction">
                        Cancelar
                      </button>
                    </div>
                  </form>

                  <div v-if="!motorsOf(model.id).length && addingMotorToModelId !== model.id" class="tree__empty-sub">
                    <span>Sin motores registrados (la pieza aplicará a cualquier motor).</span>
                    <button
                      type="button"
                      class="btn btn--ghost btn--xs"
                      @click="startAddMotor(model.id)"
                    >
                      + Agregar motor específico
                    </button>
                  </div>

                  <!-- Lista de Motores -->
                  <ul v-else class="tree__motors-list">
                    <li
                      v-for="motor in motorsOf(model.id)"
                      :key="motor.id"
                      class="tree__motor-item"
                    >
                      <!-- Edición inline del motor -->
                      <form
                        v-if="editingMotorId === motor.id"
                        class="inline-form inline-form--tight"
                        @submit.prevent="saveMotor()"
                      >
                        <input
                          v-model="motorDraft.name"
                          class="field__input field__input--sm"
                          autofocus
                        />
                        <button type="submit" class="btn btn--primary btn--xs" :disabled="saving">
                          Guardar
                        </button>
                        <button type="button" class="btn btn--ghost btn--xs" @click="cancelMotorAction">
                          Cancelar
                        </button>
                      </form>

                      <!-- Vista normal del motor -->
                      <template v-else>
                        <div class="tree__motor-info">
                          <span class="tree__motor-name mono">{{ motor.name }}</span>
                          <span v-if="motorUsage[motor.id]" class="badge badge--usage">
                            {{ motorUsage[motor.id] }} compat.
                          </span>
                        </div>
                        <div class="tree__actions">
                          <button
                            type="button"
                            class="btn btn--ghost btn--xs"
                            @click="startEditMotor(motor)"
                          >
                            Editar
                          </button>
                          <button
                            type="button"
                            class="btn btn--danger btn--xs"
                            :disabled="(motorUsage[motor.id] ?? 0) > 0"
                            :title="
                              (motorUsage[motor.id] ?? 0) > 0
                                ? 'En uso en piezas'
                                : 'Borrar motor'
                            "
                            @click="removeMotor(motor)"
                          >
                            Borrar
                          </button>
                        </div>
                      </template>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </article>
      </div>
    </template>
  </section>
</template>

<style scoped>
.veh-mgr {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.veh-mgr__form {
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  background: var(--surface);
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
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

.veh-mgr__form-row {
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

.field__input--sm {
  height: 34px;
  font-size: 0.88rem;
  padding: 0 var(--space-2);
}

.field__input::placeholder {
  color: var(--charcoal);
}

.veh-mgr__hint {
  color: var(--charcoal);
  font-size: 0.82rem;
  max-width: 75ch;
  line-height: 1.4;
}

.veh-mgr__toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.veh-mgr__search {
  max-width: 320px;
}

.veh-mgr__count {
  font-size: 0.8rem;
  color: var(--charcoal);
}

.veh-mgr__error {
  color: var(--danger);
  font-size: 0.9rem;
  background: rgba(217, 92, 74, 0.1);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius);
  border: 1px solid rgba(217, 92, 74, 0.3);
}

.veh-mgr__state {
  color: var(--charcoal);
  text-align: center;
  padding-block: var(--space-6);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

/* ── Árbol Jerárquico ──────────────────────────────────────────────────────── */
.tree {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.tree__brand {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: border-color 0.15s ease;
}

.tree__brand--open {
  border-color: var(--border-strong);
}

.tree__brand-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  background: var(--surface);
}

.tree__expand-btn {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  background: transparent;
  border: none;
  color: var(--cream);
  cursor: pointer;
  text-align: left;
  font-family: inherit;
  padding: 0;
  flex: 1;
}

.tree__chevron {
  font-size: 0.72rem;
  color: var(--blue-2);
  width: 14px;
  display: inline-block;
  transition: transform 0.15s ease;
}

.tree__chevron--sm {
  font-size: 0.65rem;
}

.tree__brand-name {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--cream);
}

.tree__badges {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.badge {
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 999px;
  font-weight: 600;
  white-space: nowrap;
}

.badge--models {
  background: rgba(92, 138, 255, 0.12);
  color: var(--blue-2);
  border: 1px solid rgba(92, 138, 255, 0.25);
}

.badge--motors {
  background: rgba(240, 160, 60, 0.12);
  color: var(--orange-2);
  border: 1px solid rgba(240, 160, 60, 0.25);
}

.badge--usage {
  background: rgba(255, 255, 255, 0.06);
  color: var(--charcoal);
  font-family: var(--font-mono);
  font-size: 0.72rem;
}

.tree__actions {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.tree__brand-body {
  border-top: 1px solid var(--border);
  background: var(--surface-2);
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.tree__empty {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  color: var(--charcoal);
  font-size: 0.88rem;
  padding: var(--space-2) var(--space-3);
  background: var(--surface);
  border-radius: var(--radius);
  border: 1px dashed var(--border);
}

.tree__empty-sub {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  color: var(--charcoal);
  font-size: 0.82rem;
  padding: var(--space-2) var(--space-3);
  background: var(--surface-2);
  border-radius: var(--radius);
}

/* ── Modelos ───────────────────────────────────────────────────────────────── */
.tree__model-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.tree__model-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
}

.tree__model-card--open {
  border-color: var(--border-strong);
}

.tree__model-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-2) var(--space-3);
}

.tree__expand-btn--model {
  font-size: 0.95rem;
}

.tree__model-name {
  font-weight: 600;
  color: var(--cream);
}

.tree__motors-box {
  border-top: 1px solid var(--border);
  background: rgba(0, 0, 0, 0.15);
  padding: var(--space-3) var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

/* ── Motores ───────────────────────────────────────────────────────────────── */
.tree__motors-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  margin: 0;
  padding: 0;
}

.tree__motor-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-2) var(--space-3);
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
}

.tree__motor-info {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.tree__motor-name {
  font-size: 0.88rem;
  font-weight: 600;
  color: var(--orange-2);
}

/* ── Formularios Inline ────────────────────────────────────────────────────── */
.inline-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-3);
  background: var(--surface);
  border: 1px dashed var(--blue);
  border-radius: var(--radius);
}

.inline-form--tight {
  flex-direction: row;
  align-items: center;
  padding: var(--space-1);
  border: none;
  background: transparent;
  flex: 1;
}

.inline-form__title {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--blue-2);
}

.inline-form__row {
  display: flex;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.inline-form__hint {
  font-size: 0.75rem;
  color: var(--charcoal);
  font-style: italic;
  margin: 0;
}

/* ── Sección de motores de Marca ──────────────────────────────────────────── */
.tree__brand-motors-section {
  background: rgba(240, 160, 60, 0.04);
  border: 1px dashed rgba(240, 160, 60, 0.25);
  border-radius: var(--radius);
  padding: var(--space-3) var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.tree__brand-motors-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.tree__brand-motors-title {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--orange-2);
}

.tree__motors-list--brand {
  margin-top: var(--space-1);
}

.tree__empty-sub--hint {
  font-style: italic;
  opacity: 0.7;
}

.badge--brand-motor {
  background: rgba(240, 160, 60, 0.18);
  color: var(--orange-2);
  border: 1px solid rgba(240, 160, 60, 0.35);
  font-size: 0.68rem;
}

.btn--motor-brand {
  border-color: rgba(240, 160, 60, 0.45);
  color: var(--orange-2);
}

.btn--motor-brand:hover:not(:disabled) {
  border-color: var(--orange-2);
  background: rgba(240, 160, 60, 0.08);
}

/* ── Botones ───────────────────────────────────────────────────────────────── */
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
  border: none;
  font-family: inherit;
}

.btn--sm {
  padding: var(--space-2) var(--space-4);
  font-size: 0.85rem;
}

.btn--xs {
  padding: 4px 10px;
  font-size: 0.78rem;
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

.btn--ghost:hover:not(:disabled) {
  border-color: var(--blue);
  color: #ffffff;
}

.btn--danger {
  background: rgba(217, 92, 74, 0.14);
  border: 1px solid rgba(217, 92, 74, 0.4);
  color: var(--danger);
}

.btn--danger:hover:not(:disabled) {
  background: rgba(217, 92, 74, 0.22);
}

.btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

/* ── Logos y Fotos ───────────────────────────────────────────────────────── */
.brand-logo-img {
  width: 28px;
  height: 28px;
  object-fit: contain;
  background: #fff;
  border-radius: 50%;
  padding: 2px;
  border: 1px solid var(--border);
  flex-shrink: 0;
}

.brand-logo-placeholder {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--blue-2);
  font-size: 0.65rem;
  font-weight: 700;
  display: grid;
  place-items: center;
  flex-shrink: 0;
}

.model-thumb-img {
  width: 36px;
  height: 24px;
  object-fit: contain;
  border-radius: 4px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  flex-shrink: 0;
}

.file-hidden {
  display: none;
}

.btn--logo-upload {
  cursor: pointer;
  align-self: center;
}

.logo-preview-wrap {
  position: relative;
  display: inline-flex;
  align-items: center;
  align-self: center;
}

.logo-preview-img {
  width: 40px;
  height: 40px;
  object-fit: contain;
  border-radius: var(--radius-sm);
  background: var(--surface-2);
  border: 1px solid var(--blue);
  padding: 2px;
}

.logo-preview-img--sm {
  width: 32px;
  height: 32px;
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

@media (max-width: 640px) {
  .tree__brand-header,
  .tree__model-header,
  .tree__motor-item {
    flex-direction: column;
    align-items: flex-start;
  }
  .tree__actions {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>
