<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useAdminParts, toPartInput } from '@/composables/useAdminParts'
import { useParts } from '@/composables/useParts'
import { money } from '@/composables/usePartPricing'
import {
  AVAILABILITY_LABELS,
  ORIGIN_LABELS,
  partGallery,
} from '@/types/part'
import type {
  Availability,
  Brand,
  Category,
  CompatInput,
  OriginType,
  Part,
  PartImageDraft,
  PartInput,
  SpecInput,
  VehicleBrand,
  VehicleModel,
  VehicleMotor,
} from '@/types/part'

const props = defineProps<{ part: Part | null }>()
const emit = defineEmits<{ saved: []; cancel: [] }>()

const { createPart, updatePart, saveGallery, replaceImages } = useAdminParts()
const { fetchCategories, fetchBrands, fetchVehicleBrands, fetchVehicleModels, fetchVehicleMotors } =
  useParts()

const isEdit = props.part !== null

// Categorías, marcas de pieza y nomenclador del vehículo (marca → modelo →
// motor) para los selects; todo desde la BD, ya no hay listas fijas en el código.
const categories = ref<Category[]>([])
const brands = ref<Brand[]>([])
const vehicleBrands = ref<VehicleBrand[]>([])
const vehicleModels = ref<VehicleModel[]>([])
const vehicleMotors = ref<VehicleMotor[]>([])
onMounted(async () => {
  try {
    ;[
      categories.value,
      brands.value,
      vehicleBrands.value,
      vehicleModels.value,
      vehicleMotors.value,
    ] = await Promise.all([
      fetchCategories(),
      fetchBrands(),
      fetchVehicleBrands(),
      fetchVehicleModels(),
      fetchVehicleMotors(),
    ])
  } catch (e) {
    console.error('[CalRod] PartForm carga catálogos:', e)
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
        brand_id: null,
        origin_type: 'original',
        price: 0,
        availability: 'disponible',
        description: null,
        material: null,
        image_url: null,
        discount_amount: null,
        is_best_deal: false,
        wholesale_price: null,
        // Mismo default que la BD (0014): mayorista desde 5 unidades.
        wholesale_min_qty: 5,
        // Mismo default que la BD (0018): sin existencia cargada, 0.
        stock_qty: 0,
      },
)

const specs = reactive<SpecInput[]>(
  props.part?.part_specs?.map((s) => ({ label: s.label, value: s.value })) ?? [],
)

// La fila guarda marca (0019), modelo opcional y motor opcional.
const compat = reactive<CompatInput[]>(
  props.part?.part_compatibility?.map((c) => ({
    vehicle_brand_id:
      c.vehicle_brand_id ??
      c.vehicle_models?.vehicle_brand_id ??
      c.vehicle_motors?.vehicle_brand_id ??
      null,
    vehicle_model_id: c.vehicle_model_id,
    motor_id: c.motor_id,
    year_from: c.year_from,
    year_to: c.year_to,
  })) ?? [],
)

// Selects tipados a partir de los mismos catálogos que usa la UI pública.
const origins = Object.entries(ORIGIN_LABELS) as [OriginType, string][]
const availabilities = Object.entries(AVAILABILITY_LABELS) as [Availability, string][]

// ── Fotos (galería, 0020) ───────────────────────────────────────────────────
// El orden del array ES el orden de la galería: la primera es la PRINCIPAL (la
// que se ve en el catálogo y abre la ficha). En edición partimos de las fotos que
// ya tiene la pieza; partGallery() se encarga de las piezas viejas que solo
// tienen image_url.
const gallery = reactive<PartImageDraft[]>(
  props.part
    ? partGallery(props.part).map((url) => ({ url, file: null, preview: url }))
    : [],
)

watch(
  () => props.part,
  (newPart) => {
    if (newPart) {
      Object.assign(form, toPartInput(newPart))
      specs.splice(
        0,
        specs.length,
        ...(newPart.part_specs?.map((s) => ({ label: s.label, value: s.value })) ?? []),
      )
      compat.splice(
        0,
        compat.length,
        ...(newPart.part_compatibility?.map((c) => ({
          vehicle_brand_id:
            c.vehicle_brand_id ??
            c.vehicle_models?.vehicle_brand_id ??
            c.vehicle_motors?.vehicle_brand_id ??
            null,
          vehicle_model_id: c.vehicle_model_id,
          motor_id: c.motor_id,
          year_from: c.year_from,
          year_to: c.year_to,
        })) ?? []),
      )
      gallery.splice(
        0,
        gallery.length,
        ...partGallery(newPart).map((url) => ({ url, file: null, preview: url })),
      )
    }
  },
  { deep: true },
)

/** Object URLs creados para las previsualizaciones, para revocarlos al salir. */
const objectUrls: string[] = []

function onFilesChange(e: Event) {
  const input = e.target as HTMLInputElement
  for (const file of Array.from(input.files ?? [])) {
    const preview = URL.createObjectURL(file)
    objectUrls.push(preview)
    gallery.push({ url: null, file, preview })
  }
  // El input se limpia para que elegir otra vez el MISMO archivo vuelva a
  // disparar el change (si no, el navegador lo considera sin cambios).
  input.value = ''
}

function removeImage(i: number) {
  gallery.splice(i, 1)
}

/** Mueve una foto una posición; así se elige cuál es la principal. */
function moveImage(i: number, delta: number) {
  const j = i + delta
  if (j < 0 || j >= gallery.length) return
  const [item] = gallery.splice(i, 1)
  gallery.splice(j, 0, item)
}

function makeMain(i: number) {
  if (i === 0) return
  const [item] = gallery.splice(i, 1)
  gallery.unshift(item)
}

onBeforeUnmount(() => {
  for (const url of objectUrls) URL.revokeObjectURL(url)
})

// ── Specs / compatibilidad dinámicas ─────────────────────────────────────────
function addSpec() {
  specs.push({ label: '', value: '' })
}
function removeSpec(i: number) {
  specs.splice(i, 1)
}
function addCompat() {
  compat.push({
    vehicle_brand_id: null,
    vehicle_model_id: null,
    motor_id: null,
    year_from: null,
    year_to: null,
  })
}
function removeCompat(i: number) {
  compat.splice(i, 1)
}

// ── Cascada marca → modelo → motor ───────────────────────────────────────────
function modelsFor(brandId: string | null) {
  if (!brandId) return []
  return vehicleModels.value.filter((m) => m.vehicle_brand_id === brandId)
}

function motorsFor(brandId: string | null, modelId: string | null) {
  if (modelId) {
    return vehicleMotors.value.filter(
      (mo) =>
        mo.vehicle_model_id === modelId ||
        (brandId && mo.vehicle_brand_id === brandId && !mo.vehicle_model_id),
    )
  }
  if (brandId) {
    return vehicleMotors.value.filter(
      (mo) =>
        mo.vehicle_brand_id === brandId ||
        (mo.vehicle_models && mo.vehicle_models.vehicle_brand_id === brandId),
    )
  }
  return []
}

function onBrandChange(c: CompatInput) {
  c.vehicle_model_id = null
  c.motor_id = null
}
function onModelChange(c: CompatInput) {
  // Si se cambia de modelo, se resetea el motor solo si pertenecía exclusivamente al modelo anterior
  if (c.motor_id) {
    const currentMotor = vehicleMotors.value.find((mo) => mo.id === c.motor_id)
    if (currentMotor?.vehicle_model_id && currentMotor.vehicle_model_id !== c.vehicle_model_id) {
      c.motor_id = null
    }
  }
}

// ── Guardar ──────────────────────────────────────────────────────────────────
const saving = ref(false)
const error = ref<string | null>(null)

// Vista previa de la oferta en el formulario: mismo cálculo que la tarjeta.
// El precio que captura el admin es el precio NORMAL; el descuento es un monto
// FIJO en USD que se le resta:
//   final = price - discount_amount ; ahorro = discount_amount
// El formateador sale de usePartPricing, así el panel y el catálogo muestran
// exactamente el mismo número.

/**
 * Un <input type="number"> con v-model.number deja "" (string) cuando se vacía,
 * no null, y `Number("")` es 0. Normalizamos a number|null para validar y
 * calcular sin guardar ceros fantasma.
 */
function numberOrNull(raw: number | string | null | undefined): number | null {
  if (raw === null || raw === undefined) return null
  if (typeof raw === 'string' && raw.trim() === '') return null
  const n = Number(raw)
  return Number.isFinite(n) ? n : null
}

const discountAmount = computed<number | null>(() =>
  numberOrNull(form.discount_amount as number | string | null),
)

const wholesalePrice = computed<number | null>(() =>
  numberOrNull(form.wholesale_price as number | string | null),
)

const wholesaleMinQty = computed<number | null>(() =>
  numberOrNull(form.wholesale_min_qty as number | string | null),
)

const stockQty = computed<number | null>(() =>
  numberOrNull(form.stock_qty as number | string | null),
)

/**
 * El precio, ya normalizado. El campo se puede dejar vacío (solo el nombre es
 * obligatorio) y la columna `price` es NOT NULL, así que vacío significa 0: una
 * pieza se puede dar de alta sin precio y ponérselo después. Todo lo que calcula
 * con el precio usa este valor, nunca `form.price` crudo, que puede ser "".
 */
const priceNow = computed<number>(() =>
  Math.max(0, numberOrNull(form.price as number | string | null) ?? 0),
)

/** Precio final al detalle con lo que hay ahora mismo en el formulario. */
const retailNow = computed(() => {
  const save = discountAmount.value
  if (save === null || save <= 0 || save >= priceNow.value) return priceNow.value
  return priceNow.value - save
})

const offerPreview = computed(() => {
  const save = discountAmount.value
  if (save === null || save <= 0 || priceNow.value <= 0 || save >= priceNow.value) return null
  const original = priceNow.value
  const final = original - save
  return {
    finalFmt: money.format(final),
    originalFmt: money.format(original),
    saveFmt: money.format(save),
  }
})

// Vista previa del mayorista: solo cuenta si de verdad conviene contra el precio
// al detalle (misma regla que partWholesale usa en el catálogo).
const wholesalePreview = computed(() => {
  const wp = wholesalePrice.value
  if (wp === null || wp <= 0 || retailNow.value <= 0 || wp >= retailNow.value) {
    return null
  }
  return {
    priceFmt: money.format(wp),
    qty: wholesaleMinQty.value ?? 5,
    retailFmt: money.format(retailNow.value),
    saveFmt: money.format(retailNow.value - wp),
  }
})

async function onSubmit() {
  error.value = null

  // El NOMBRE es el único campo obligatorio: es lo mínimo con que una pieza se
  // puede reconocer en el mostrador. Todo lo demás (código desde 0015, marca,
  // categoría, precio, compatibilidad) se puede dejar vacío y completar después,
  // así el alta no se frena cuando el dato todavía no está a mano.
  if (!form.name.trim()) {
    error.value = 'El nombre es obligatorio.'
    return
  }
  // Un precio vacío es válido (vale 0). Solo se rechaza lo que no es un número.
  if (numberOrNull(form.price as number | string | null) !== null && form.price < 0) {
    error.value = 'El precio no puede ser negativo.'
    return
  }
  // El descuento es opcional. Solo validamos si el admin escribió algo: un campo
  // vacío (discountAmount === null) es válido y significa "sin oferta". Si hay
  // valor, debe ser > 0 y menor que el precio (para no dejar un final ≤ 0).
  if (discountAmount.value !== null) {
    if (discountAmount.value <= 0) {
      error.value = 'El descuento debe ser un monto en USD mayor que 0, o dejarse vacío.'
      return
    }
    if (discountAmount.value >= priceNow.value) {
      error.value = 'El descuento no puede ser igual o mayor que el precio.'
      return
    }
  }
  // Mayorista opcional (0014). Si el admin escribió un precio, tiene que ser un
  // precio mejor que el del detalle: si no, no es un mayorista, es un error de
  // captura que el catálogo no mostraría.
  if (wholesalePrice.value !== null) {
    if (wholesalePrice.value <= 0) {
      error.value =
        'El precio mayorista debe ser un monto en USD mayor que 0, o dejarse vacío.'
      return
    }
    if (wholesalePrice.value >= retailNow.value) {
      error.value =
        `El precio mayorista debe ser menor que el precio al detalle (${money.format(retailNow.value)}).`
      return
    }
    if (wholesaleMinQty.value === null || wholesaleMinQty.value < 2) {
      error.value = 'La cantidad mínima para el precio mayorista debe ser 2 o más.'
      return
    }
  }
  // Existencia (0018): unidades, no dinero. Vacío es válido y significa 0 (el
  // mismo default de la BD); si hay valor tiene que ser entero y no negativo,
  // que es justo lo que acepta la columna.
  if (stockQty.value !== null) {
    if (!Number.isInteger(stockQty.value) || stockQty.value < 0) {
      error.value = 'La existencia debe ser un número entero de 0 o más.'
      return
    }
  }
  // Compatibilidad: una fila sin marca de auto no describe nada (y la columna es
  // NOT NULL desde 0013), así que no bloquea el guardado: se descarta al escribir
  // los hijos. Modelo, años y motor siguen siendo opcionales.

  saving.value = true
  try {
    // Las fotos van primero: suben al bucket y de ahí sale la lista ordenada de
    // URLs. Carpeta del bucket: el código cuando lo tiene y, desde que es
    // opcional (0015), el id de la pieza en edición o un uuid nuevo en alta.
    // Nunca un valor compartido: dos piezas sin código se pisarían las fotos.
    const folderKey = form.code?.trim() || props.part?.id || crypto.randomUUID()
    const imageUrls = await saveGallery(
      [...gallery],
      folderKey,
      props.part?.image_url ?? null,
    )

    // Normalizamos textos opcionales vacíos a null.
    const payload: PartInput = {
      ...form,
      // Código vacío → null, nunca cadena vacía: el UNIQUE de parts trata cada
      // null como distinto (varias piezas pueden no tener código) pero dos ''
      // chocarían, y el CHECK parts_code_not_blank de 0015 los rechaza.
      code: form.code?.trim() || null,
      name: form.name.trim(),
      description: form.description?.trim() || null,
      material: form.material?.trim() || null,
      // Precio vacío → 0 (la columna es NOT NULL): la pieza se da de alta sin
      // precio y se le pone después.
      price: priceNow.value,
      // Descuento vacío o inválido → null (sin oferta). Usamos el valor ya
      // normalizado (discountAmount), no el crudo del input que puede ser "".
      discount_amount: discountAmount.value,
      // Mayorista: precio vacío → null (la pieza no tiene mayorista). La
      // cantidad mínima es NOT NULL en la BD, así que vacía vuelve al 5 default.
      wholesale_price: wholesalePrice.value,
      wholesale_min_qty:
        wholesaleMinQty.value && wholesaleMinQty.value >= 2
          ? wholesaleMinQty.value
          : 5,
      // Existencia vacía → 0, mismo default que la columna (0018).
      stock_qty: stockQty.value ?? 0,
      // La principal denormalizada (0020): la primera foto de la galería, o null
      // si la pieza se quedó sin ninguna. Va en el mismo UPDATE/INSERT que la
      // fila, así que fila y galería nunca discrepan.
      image_url: imageUrls[0] ?? null,
    }

    // La galería se escribe después de la fila: en alta el part_id no existe
    // hasta que createPart devuelve el id.
    if (isEdit && props.part) {
      await updatePart(props.part.id, payload, [...specs], [...compat])
      await replaceImages(props.part.id, imageUrls)
    } else {
      const newId = await createPart(payload, [...specs], [...compat])
      await replaceImages(newId, imageUrls)
    }
    emit('saved')
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('duplicate') || msg.includes('unique')) {
      error.value = 'Ya existe una pieza con ese código.'
    } else if (msg.includes('row-level security') || msg.includes('policy')) {
      error.value = 'Sin permisos para guardar. ¿Sigue tu sesión de admin activa?'
    } else if (msg.includes('null value') || msg.includes('not-null')) {
      // La columna que falta la dice el propio mensaje de Postgres: si un campo
      // que aquí es opcional sigue siendo NOT NULL en la BD, hay que verlo, no
      // esconderlo tras un "no se pudo guardar".
      error.value = `La base de datos exige un campo que quedó vacío. Detalle: ${(e as Error).message}`
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
          <span class="field__label">Código / SKU</span>
          <input v-model="form.code" class="field__input" placeholder="Opcional — BR-4471-C" />
        </label>
        <label class="field">
          <span class="field__label">Nombre *</span>
          <input v-model="form.name" class="field__input" placeholder="Balata delantera" />
        </label>
        <label class="field">
          <span class="field__label">Marca</span>
          <select v-model="form.brand_id" class="field__input">
            <option :value="null">— Sin marca —</option>
            <option v-for="b in brands" :key="b.id" :value="b.id">
              {{ b.name }}
            </option>
          </select>
        </label>
        <label class="field">
          <span class="field__label">Precio (USD)</span>
          <input
            v-model.number="form.price"
            type="number"
            min="0"
            step="0.01"
            class="field__input"
            placeholder="0.00"
          />
          <span class="field__hint">Vacío se guarda como 0.</span>
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
          <span class="field__label">En existencia (unidades)</span>
          <input
            v-model.number="form.stock_qty"
            type="number"
            min="0"
            step="1"
            class="field__input"
            placeholder="0"
          />
          <span class="field__hint">
            Se captura a mano. No cambia sola la disponibilidad de arriba.
          </span>
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

    <!-- Oferta (opcional): descuento y "mejor oferta" para la tarjeta del catálogo. -->
    <fieldset class="block">
      <legend class="block__legend">Oferta (opcional)</legend>
      <div class="grid">
        <label class="field">
          <span class="field__label">Descuento (USD)</span>
          <input
            v-model.number="form.discount_amount"
            type="number"
            min="0"
            step="0.01"
            class="field__input"
            placeholder="Ej. 3.50 — vacío = sin oferta"
          />
        </label>
        <label class="field field--check">
          <input v-model="form.is_best_deal" type="checkbox" class="field__check" />
          <span class="field__label">Marcar como “Mejor oferta” (cinta destacada)</span>
        </label>
      </div>
      <p v-if="offerPreview" class="offer-hint">
        Precio final <b>{{ offerPreview.finalFmt }}</b> ·
        antes <s>{{ offerPreview.originalFmt }}</s> ·
        <span class="offer-hint__save">ahorras {{ offerPreview.saveFmt }}</span>
      </p>
      <p v-else class="block__empty">
        Sin descuento: la tarjeta muestra solo el precio normal. El precio de
        arriba es el normal; el descuento en USD se le resta para el precio final.
      </p>
    </fieldset>

    <!-- Mayorista (opcional): otro precio por unidad al llevar varias piezas. -->
    <fieldset class="block">
      <legend class="block__legend">Precio mayorista (opcional)</legend>
      <div class="grid">
        <label class="field">
          <span class="field__label">Precio mayorista por unidad (USD)</span>
          <input
            v-model.number="form.wholesale_price"
            type="number"
            min="0"
            step="0.01"
            class="field__input"
            placeholder="Ej. 8.90 — vacío = sin mayorista"
          />
        </label>
        <label class="field">
          <span class="field__label">Desde cuántas unidades</span>
          <input
            v-model.number="form.wholesale_min_qty"
            type="number"
            min="2"
            step="1"
            class="field__input"
            placeholder="5"
          />
        </label>
      </div>
      <p v-if="wholesalePreview" class="offer-hint">
        Mayorista <b>{{ wholesalePreview.priceFmt }}</b> por unidad desde
        {{ wholesalePreview.qty }} u. · al detalle {{ wholesalePreview.retailFmt }} ·
        <span class="offer-hint__save">
          ahorro {{ wholesalePreview.saveFmt }} por unidad
        </span>
      </p>
      <p v-else class="block__empty">
        Sin precio mayorista: la pieza se muestra solo con su precio al detalle.
        Para que aplique, el mayorista tiene que ser menor que ese precio final.
      </p>
    </fieldset>

    <!-- Fotos -->
    <fieldset class="block">
      <legend class="block__legend">Fotos</legend>

      <div v-if="gallery.length" class="shots">
        <div
          v-for="(img, i) in gallery"
          :key="img.preview"
          class="shot"
          :class="{ 'shot--main': i === 0 }"
        >
          <img :src="img.preview" :alt="`Foto ${i + 1}`" class="shot__img" />
          <span v-if="i === 0" class="shot__tag">Principal</span>

          <div class="shot__tools">
            <button
              type="button"
              class="shot__btn"
              title="Mover antes"
              aria-label="Mover antes"
              :disabled="i === 0"
              @click="moveImage(i, -1)"
            >
              ‹
            </button>
            <button
              type="button"
              class="shot__btn"
              title="Hacer principal"
              aria-label="Hacer principal"
              :disabled="i === 0"
              @click="makeMain(i)"
            >
              ★
            </button>
            <button
              type="button"
              class="shot__btn"
              title="Mover después"
              aria-label="Mover después"
              :disabled="i === gallery.length - 1"
              @click="moveImage(i, 1)"
            >
              ›
            </button>
            <button
              type="button"
              class="shot__btn shot__btn--del"
              title="Quitar foto"
              aria-label="Quitar foto"
              @click="removeImage(i)"
            >
              ×
            </button>
          </div>
        </div>
      </div>

      <div class="shots__actions">
        <label class="btn btn--ghost">
          {{ gallery.length ? 'Agregar fotos' : 'Subir fotos' }}
          <input
            type="file"
            accept="image/*"
            multiple
            class="photo__file"
            @change="onFilesChange"
          />
        </label>
        <p class="photo__hint">
          La primera es la <b>principal</b>: es la que se ve en el catálogo y la que
          abre la ficha. Ordénalas con ‹ › o marca otra con ★. Se suben al bucket
          <code>part-images</code> al guardar.
        </p>
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
          <select
            v-model="c.vehicle_brand_id"
            class="field__input"
            @change="onBrandChange(c)"
          >
            <option :value="null" disabled>— Marca del auto —</option>
            <option v-for="vb in vehicleBrands" :key="vb.id" :value="vb.id">
              {{ vb.name }}
            </option>
          </select>
          <select
            v-model="c.vehicle_model_id"
            class="field__input"
            :disabled="!c.vehicle_brand_id"
            @change="onModelChange(c)"
          >
            <option :value="null">
              {{ c.vehicle_brand_id ? 'Modelo (opc.) — todos' : '— Elige marca primero —' }}
            </option>
            <option v-for="m in modelsFor(c.vehicle_brand_id)" :key="m.id" :value="m.id">
              {{ m.name }}
            </option>
          </select>
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
          <!-- Motor opcional: habilitado en cuanto se elige la marca (0019) -->
          <select
            v-model="c.motor_id"
            class="field__input"
            :disabled="!c.vehicle_brand_id"
          >
            <option :value="null">Motor (opc.) — cualquiera</option>
            <option v-for="mo in motorsFor(c.vehicle_brand_id, c.vehicle_model_id)" :key="mo.id" :value="mo.id">
              {{ mo.name }}
            </option>
          </select>
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
      <p v-else class="block__empty">Sin compatibilidad. Agrega marca, modelo, años y motor (opcional).</p>
      <p v-if="!vehicleBrands.length" class="block__empty">
        El nomenclador de marcas de auto está vacío. Créalas en la pestaña
        “Marcas de auto” para poder declarar compatibilidad.
      </p>
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

/* Checkbox de "mejor oferta": etiqueta a la derecha, alineada con la casilla. */
.field--check {
  flex-direction: row;
  align-items: center;
  gap: var(--space-2);
  align-self: end;
  padding-bottom: 10px;
}

.field__check {
  width: 18px;
  height: 18px;
  accent-color: var(--blue);
  cursor: pointer;
  flex-shrink: 0;
}

.offer-hint {
  font-family: var(--font-mono);
  font-size: 0.82rem;
  color: var(--charcoal);
}
.offer-hint b { color: var(--blue-2); }
.offer-hint s { opacity: 0.7; }
.offer-hint__save { color: var(--orange-2); }

.field__label {
  font-size: 0.8rem;
  color: var(--charcoal);
  font-weight: 500;
}

/* Aclaración bajo un campo (p. ej. que la existencia se captura a mano). */
.field__hint {
  font-size: 0.72rem;
  color: var(--charcoal);
  opacity: 0.75;
  line-height: 1.35;
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

/* Fotos: rejilla de miniaturas, la primera marcada como principal */
.shots {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(112px, 1fr));
  gap: var(--space-3);
  margin-bottom: var(--space-4);
}

.shot {
  position: relative;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  background: var(--surface-2);
  padding: 6px;
  overflow: hidden;
}
/* La principal se distingue con el azul de marca, no con otro tamaño: así la
   rejilla no se descuadra al reordenar. */
.shot--main { border-color: var(--blue-2); }

.shot__img {
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: contain;
  display: block;
}

.shot__tag {
  position: absolute;
  top: 6px;
  left: 6px;
  padding: 2px 7px;
  border-radius: 999px;
  background: var(--blue);
  color: #eceef2;
  font-size: 0.62rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

/* La barra de herramientas aparece al pasar el mouse o al enfocar con teclado. */
.shot__tools {
  position: absolute;
  inset-inline: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  gap: 2px;
  padding: 4px;
  background: var(--surface-glass);
  opacity: 0;
  transition: opacity 0.15s ease;
}
.shot:hover .shot__tools,
.shot:focus-within .shot__tools {
  opacity: 1;
}

.shot__btn {
  width: 24px;
  height: 24px;
  display: grid;
  place-items: center;
  border: none;
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--silver);
  font-size: 0.9rem;
  line-height: 1;
  cursor: pointer;
}
.shot__btn:hover:not(:disabled) { background: var(--surface-2); color: var(--cream); }
.shot__btn:disabled { opacity: 0.3; cursor: default; }
.shot__btn--del:hover { color: var(--danger); }

.shots__actions {
  display: flex;
  gap: var(--space-4);
  align-items: center;
  flex-wrap: wrap;
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
  grid-template-columns: 1.2fr 1.2fr 0.8fr 0.8fr 1fr auto;
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
