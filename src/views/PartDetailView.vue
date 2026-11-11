<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useParts } from '@/composables/useParts'
import { useAppLoading } from '@/composables/useAppLoading'
import { useAuthStore } from '@/stores/authStore'
import { money, partWholesale, retailPrice } from '@/composables/usePartPricing'
import { getStockStatus, openWhatsAppOrder } from '@/composables/useWhatsApp'
import type { Part } from '@/types/part'
import {
  AVAILABILITY_LABELS,
  ORIGIN_LABELS,
  motorName,
  partGallery,
  vehicleBrandName,
  vehicleModelName,
} from '@/types/part'
import PartGallery from '@/components/part-detail/PartGallery.vue'
import PartSpecSheet from '@/components/part-detail/PartSpecSheet.vue'
import CompatibilityList from '@/components/part-detail/CompatibilityList.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const route = useRoute()
const router = useRouter()
const { fetchPartById } = useParts()
const { finishBoot } = useAppLoading()
const auth = useAuthStore()

function goAdmin(action: 'edit' | 'duplicate') {
  if (!part.value) return
  router.push({ path: '/admin', query: { [action]: part.value.id } })
}

const part = ref<Part | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

/** Fotos ordenadas para la galería; [] si la pieza no tiene ninguna. */
const images = computed(() => (part.value ? partGallery(part.value) : []))

// Precio: las reglas viven en usePartPricing, aquí solo se formatean. `price` es
// el NORMAL y el descuento un monto fijo (0010), así que el tachado solo aparece
// cuando de verdad hay ahorro.
const price = computed(() => {
  const p = part.value
  if (!p) return null
  const final = retailPrice(p)
  return {
    finalFmt: money.format(final),
    originalFmt: money.format(p.price),
    saveFmt: money.format(p.price - final),
    hasOffer: final < p.price,
  }
})

const wholesale = computed(() => (part.value ? partWholesale(part.value) : null))

const stockInfo = computed(() => (part.value ? getStockStatus(part.value) : null))
const isStockAvailable = computed(() => stockInfo.value?.hasStock ?? false)
const orderBtnLabel = computed(() => (isStockAvailable.value ? 'Encargar más' : 'Encargar'))

function onOrderClick() {
  if (!part.value) return
  openWhatsAppOrder({
    partName: part.value.name,
    partCode: part.value.code,
    hasStock: isStockAvailable.value,
  })
}

/** Primera compatibilidad en una línea: "Toyota Corolla · 1.8L (2015–2020)". */
const compatSummary = computed(() => {
  const rows = part.value?.part_compatibility ?? []
  const first = rows[0]
  if (!first) return null

  const name = [vehicleBrandName(first), vehicleModelName(first)]
    .filter(Boolean)
    .join(' ')
  const motor = motorName(first)
  const from = first.year_from
  const to = first.year_to
  const years = from && to ? `${from}–${to}` : from ? `${from}+` : to ? `hasta ${to}` : ''

  return {
    label: [name, motor, years ? `(${years})` : '']
      .filter(Boolean)
      .join(' · ')
      .replace(' · (', ' ('),
    rest: rows.length - 1,
  }
})

function goToCompat() {
  document
    .getElementById('compatibilidad')
    ?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

async function load(id: string) {
  loading.value = true
  error.value = null
  try {
    const found = await fetchPartById(id)
    if (!found) {
      router.replace({ name: 'not-found' })
      return
    }
    part.value = found
    document.title = `${found.name} — Repuestos CalRod`
  } catch (e) {
    error.value =
      'No pudimos cargar esta pieza. Revisa tu conexión e intenta de nuevo.'
    console.error('[CalRod] PartDetail:', e)
  } finally {
    loading.value = false
    // Quita el overlay de arranque global cuando la ficha resuelve su endpoint
    // (éxito, error o redirección a 404). Es idempotente tras el primer arranque.
    finishBoot()
  }
}

onMounted(() => load(route.params.id as string))
watch(
  () => route.params.id,
  (id) => id && load(id as string),
)
</script>

<template>
  <div class="container detail">
    <nav class="breadcrumb mono" aria-label="Ruta de navegación">
      <RouterLink to="/">Catálogo</RouterLink>
      <span aria-hidden="true">/</span>
      <span v-if="part">{{ part.categories?.name ?? 'Pieza' }}</span>
    </nav>

    <div v-if="loading" class="detail__state">
      <GearSpinner :size="44" />
      <p>Cargando pieza…</p>
    </div>

    <div v-else-if="error" class="detail__state detail__state--error" role="alert">
      <p>{{ error }}</p>
      <button class="btn btn--ghost" @click="load(route.params.id as string)">
        Reintentar
      </button>
    </div>

    <article v-else-if="part" class="sheet">
      <!-- ---------- FOTOS ---------- -->
      <div class="sheet__media">
        <PartGallery :images="images" :name="part.name" />
      </div>

      <!-- ---------- INFO ---------- -->
      <div class="sheet__info">
        <div class="info__top">
          <span class="stock-chip" :class="`stock-chip--${part.availability}`">
            <span class="stock-chip__dot"></span>
            {{ AVAILABILITY_LABELS[part.availability] }}
            <span v-if="stockInfo" class="stock-chip__qty mono">· {{ stockInfo.qty }} en existencia</span>
          </span>
          <span v-if="part.code" class="code mono">{{ part.code }}</span>
        </div>

        <h1 class="name">{{ part.name }}</h1>
        <div v-if="auth.isAdmin" class="admin-bar">
          <button type="button" class="admin-bar__btn" @click="goAdmin('edit')">
            Editar
          </button>
          <button type="button" class="admin-bar__btn" @click="goAdmin('duplicate')">
            Duplicar
          </button>
        </div>
        <p v-if="part.description" class="tagline">{{ part.description }}</p>

        <!-- Datos de la pieza: filas etiqueta/valor, sin caja alrededor. -->
        <dl class="facts">
          <div v-if="part.brands" class="fact">
            <dt>Marca</dt>
            <dd>{{ part.brands.name }}</dd>
          </div>
          <div class="fact">
            <dt>Tipo</dt>
            <dd>{{ ORIGIN_LABELS[part.origin_type] }}</dd>
          </div>
          <div v-if="part.categories" class="fact">
            <dt>Categoría</dt>
            <dd>{{ part.categories.name }}</dd>
          </div>
          <div v-if="part.material" class="fact">
            <dt>Material</dt>
            <dd>{{ part.material }}</dd>
          </div>
        </dl>

        <!-- Compatibilidad resumida; el resto se lee en la sección de abajo. -->
        <p v-if="compatSummary" class="compat-teaser">
          <span class="compat-teaser__label">Compatible con</span>
          <span class="compat-teaser__value">{{ compatSummary.label }}</span>
          <button
            v-if="compatSummary.rest > 0"
            type="button"
            class="compat-teaser__more"
            @click="goToCompat"
          >
            y {{ compatSummary.rest }} más
            <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M5 12h14M13 6l6 6-6 6" />
            </svg>
          </button>
        </p>

        <!-- Precio: la única zona con líneas, que es donde de verdad ayudan. -->
        <div v-if="price" class="price">
          <div class="price__main">
            <span class="price__now mono">{{ price.finalFmt }}</span>
            <template v-if="price.hasOffer">
              <span class="price__was mono">{{ price.originalFmt }}</span>
              <span class="price__save">Ahorras {{ price.saveFmt }}</span>
            </template>
          </div>
          <p v-if="wholesale" class="price__wholesale">
            <b class="mono">{{ wholesale.priceFmt }}</b> por unidad desde
            {{ wholesale.minQty }} u.
            <span class="price__wholesale-save">(−{{ wholesale.saveFmt }} c/u)</span>
          </p>
        </div>

        <!-- Encargo directo por WhatsApp -->
        <div class="order-box">
          <div v-if="stockInfo" class="stock-banner" :class="`stock-banner--${stockInfo.tone}`">
            <span class="stock-banner__dot" aria-hidden="true"></span>
            <div class="stock-banner__text">
              <strong class="stock-banner__title">
                {{ stockInfo.hasStock ? 'Stock disponible' : 'Sin existencia inmediata' }}
              </strong>
              <span class="stock-banner__qty mono">
                ({{ stockInfo.qty }} {{ stockInfo.qty === 1 ? 'unidad disponible' : 'unidades disponibles' }})
              </span>
            </div>
          </div>

          <button
            type="button"
            class="order-cta-btn"
            :class="{ 'order-cta-btn--more': isStockAvailable }"
            @click="onOrderClick"
          >
            <svg class="order-cta-btn__icon" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
              <path
                d="M16.004 3.2c-7.06 0-12.8 5.74-12.8 12.8 0 2.258.594 4.462 1.72 6.4L3.2 28.8l6.56-1.72a12.74 12.74 0 0 0 6.244 1.62h.006c7.06 0 12.8-5.74 12.8-12.8 0-3.42-1.332-6.634-3.75-9.052A12.72 12.72 0 0 0 16.004 3.2Zm0 23.36h-.004a10.56 10.56 0 0 1-5.384-1.474l-.386-.23-3.894 1.02 1.04-3.796-.252-.39a10.55 10.55 0 0 1-1.616-5.62c0-5.868 4.776-10.64 10.648-10.64a10.57 10.57 0 0 1 7.524 3.12 10.56 10.56 0 0 1 3.116 7.526c0 5.868-4.776 10.64-10.642 10.64Zm5.834-7.964c-.32-.16-1.892-.934-2.184-1.04-.293-.107-.507-.16-.72.16-.213.32-.826 1.04-1.013 1.253-.187.213-.373.24-.693.08-.32-.16-1.35-.498-2.57-1.586-.95-.847-1.592-1.894-1.778-2.214-.187-.32-.02-.493.14-.652.144-.143.32-.373.48-.56.16-.187.213-.32.32-.533.107-.213.053-.4-.027-.56-.08-.16-.72-1.734-.986-2.374-.26-.624-.523-.54-.72-.55l-.613-.01c-.213 0-.56.08-.853.4-.293.32-1.12 1.094-1.12 2.667 0 1.574 1.146 3.094 1.306 3.307.16.213 2.253 3.44 5.46 4.826.763.33 1.358.527 1.822.674.766.244 1.463.21 2.014.127.615-.092 1.892-.774 2.158-1.52.267-.747.267-1.387.187-1.52-.08-.134-.293-.214-.613-.374Z"
              />
            </svg>
            <span>{{ orderBtnLabel }}</span>
          </button>
          <div class="order-notice">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
            <span>Los encargos están disponibles en aproximadamente <strong>15 días</strong>.</span>
          </div>
        </div>
      </div>

      <!-- ---------- DETALLE TÉCNICO ---------- -->
      <div class="sheet__tech">
        <PartSpecSheet :specs="part.part_specs ?? []" :material="part.material" />
        <CompatibilityList
          id="compatibilidad"
          :items="part.part_compatibility ?? []"
        />
      </div>
    </article>
  </div>
</template>

<style scoped>
.admin-bar {
  display: flex;
  gap: var(--space-2);
  margin-top: var(--space-3);
}

.admin-bar__btn {
  padding: var(--space-2) var(--space-4);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--cream);
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  border-radius: var(--radius);
  cursor: pointer;
}

.admin-bar__btn:hover {
  border-color: var(--blue);
  color: var(--blue-2);
}

/*
 * Ficha sin cajas anidadas. Antes cada zona era un rectángulo con borde (foto,
 * compra, especificaciones, compatibilidad) y encima cada compatibilidad traía
 * su propia cajita: la página se leía como un formulario. Ahora la jerarquía la
 * dan el espacio, el tamaño del texto y unas pocas líneas finas donde separar de
 * verdad aporta — el precio y el arranque del bloque técnico.
 */
.detail {
  padding-block: var(--space-5) var(--space-8);
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: 0.78rem;
  color: var(--charcoal);
  margin-bottom: var(--space-6);
}
.breadcrumb a { color: var(--blue-2); }
.breadcrumb a:hover { text-decoration: underline; text-underline-offset: 3px; }

/* Dos columnas arriba (fotos | compra) y el bloque técnico cruzando ambas. */
.sheet {
  display: grid;
  grid-template-columns: minmax(0, 1.02fr) minmax(0, 0.98fr);
  column-gap: var(--space-7);
  row-gap: var(--space-8);
  align-items: start;
}

.sheet__media {
  position: sticky;
  top: calc(var(--header-h) + var(--space-4));
}

.sheet__info {
  padding-top: var(--space-2);
}

/* ---------- cabecera de la info ---------- */
.info__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  margin-bottom: var(--space-4);
}

.stock-chip {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 5px 11px;
  border-radius: 999px;
  font-size: 0.74rem;
  font-weight: 600;
  /* currentColor tiñe fondo y punto: un solo color por estado, sin repetirlo. */
  background: color-mix(in srgb, currentColor 12%, transparent);
}
.stock-chip__dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}
.stock-chip__qty { font-weight: 500; opacity: 0.85; }
.stock-chip--disponible { color: var(--ok); }
.stock-chip--stock_bajo { color: var(--warn); }
.stock-chip--agotado    { color: var(--danger); }

.code {
  font-size: 0.76rem;
  color: var(--charcoal);
  letter-spacing: 0.06em;
}

.name {
  font-size: clamp(1.55rem, 2.7vw, 2.15rem);
  font-weight: 800;
  letter-spacing: -0.022em;
  line-height: 1.12;
}

.tagline {
  margin-top: var(--space-3);
  color: var(--text-dim);
  font-size: 0.95rem;
  line-height: 1.55;
  max-width: 54ch;
}

/* ---------- datos ---------- */
.facts {
  display: grid;
  gap: 9px;
  margin-top: var(--space-5);
}
.fact {
  display: flex;
  gap: var(--space-2);
  align-items: baseline;
  font-size: 0.86rem;
}
.fact dt {
  color: var(--charcoal);
  margin: 0;
  min-width: 82px;
}
.fact dd {
  color: var(--cream);
  margin: 0;
  font-weight: 500;
}

/* ---------- compatibilidad resumida ---------- */
.compat-teaser {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: var(--space-2);
  margin-top: var(--space-4);
  font-size: 0.86rem;
}
.compat-teaser__label { color: var(--charcoal); }
.compat-teaser__value { color: var(--blue-2); font-weight: 600; }
.compat-teaser__more {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 0;
  border: none;
  background: none;
  color: var(--charcoal);
  font-size: 0.8rem;
  cursor: pointer;
  text-decoration: underline;
  text-underline-offset: 3px;
}
.compat-teaser__more:hover { color: var(--cream); }

/* ---------- precio ---------- */
.price {
  margin-top: var(--space-5);
  padding-block: var(--space-4);
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}
.price__main {
  display: flex;
  align-items: baseline;
  flex-wrap: wrap;
  gap: var(--space-3);
}
.price__now {
  font-size: 2rem;
  font-weight: 700;
  color: var(--cream);
  line-height: 1;
  letter-spacing: -0.02em;
}
.price__was {
  font-size: 0.95rem;
  color: var(--charcoal);
  text-decoration: line-through;
}
.price__save {
  padding: 3px 9px;
  border-radius: 999px;
  background: color-mix(in srgb, var(--orange) 16%, transparent);
  color: var(--orange-2);
  font-size: 0.74rem;
  font-weight: 700;
}
.price__wholesale {
  margin-top: var(--space-3);
  font-size: 0.82rem;
  color: var(--text-dim);
}
.price__wholesale b { color: var(--cream); }
.price__wholesale-save { color: var(--ok); }

/* ---------- Bloque de encargo ---------- */
.order-box {
  margin-top: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.stock-banner {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 0.88rem;
  line-height: 1.3;
}

.stock-banner__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
  background: currentColor;
}

.stock-banner--ok {
  color: var(--ok);
}

.stock-banner--warn {
  color: var(--warn);
}

.stock-banner--out {
  color: var(--danger);
}

.stock-banner__text {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 6px;
}

.stock-banner__title {
  color: var(--cream);
  font-weight: 700;
}

.stock-banner__qty {
  font-size: 0.82rem;
  color: var(--text-dim);
}

.order-cta-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  width: 100%;
  max-width: 320px;
  padding: 12px 20px;
  font-family: var(--font-display);
  font-size: 0.95rem;
  font-weight: 700;
  border-radius: var(--radius);
  border: 1px solid rgba(37, 211, 102, 0.45);
  background: #25d366;
  color: #fff;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(37, 211, 102, 0.3);
  transition: transform 0.15s ease, background-color 0.15s ease, box-shadow 0.15s ease;
}

.order-cta-btn:hover {
  background: #20ba59;
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(37, 211, 102, 0.4);
}

.order-cta-btn:active {
  transform: translateY(0);
}

.order-cta-btn__icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.order-notice {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  color: var(--charcoal);
  line-height: 1.4;
}

.order-notice svg {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
  color: var(--blue-2);
}

.order-notice strong {
  color: var(--cream);
  font-weight: 600;
}

/* ---------- bloque técnico ---------- */
/* Cruza las dos columnas y se divide en dos: la línea del centro es el único
   separador, en vez de dos tarjetas con borde completo. */
.sheet__tech {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: var(--space-7);
  padding-top: var(--space-6);
  border-top: 1px solid var(--border);
}
.sheet__tech > :last-child {
  padding-left: var(--space-7);
  border-left: 1px solid var(--border);
}

/* ---------- estados ---------- */
.detail__state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding-block: var(--space-8);
  color: var(--charcoal);
}
.detail__state--error { color: var(--danger); }

.btn {
  display: inline-flex;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
}
.btn--ghost {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

@media (max-width: 980px) {
  .sheet {
    grid-template-columns: minmax(0, 1fr);
    row-gap: var(--space-6);
  }
  .sheet__media { position: static; }
  .sheet__tech {
    grid-template-columns: minmax(0, 1fr);
    gap: var(--space-6);
  }
  /* En una columna la línea vertical no separa nada: pasa a horizontal. */
  .sheet__tech > :last-child {
    padding-left: 0;
    border-left: none;
    padding-top: var(--space-6);
    border-top: 1px solid var(--border);
  }
}
</style>
