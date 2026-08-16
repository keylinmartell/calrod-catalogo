<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useParts } from '@/composables/useParts'
import { useAppLoading } from '@/composables/useAppLoading'
import type { Part } from '@/types/part'
import { AVAILABILITY_LABELS, ORIGIN_LABELS } from '@/types/part'
import PartSpecSheet from '@/components/part-detail/PartSpecSheet.vue'
import CompatibilityList from '@/components/part-detail/CompatibilityList.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'

const route = useRoute()
const router = useRouter()
const { fetchPartById } = useParts()
const { finishBoot } = useAppLoading()

const part = ref<Part | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

const money = new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'USD' })

// Oferta: mismo modelo que PartCard. `price` es el precio NORMAL; si hay
// discount_amount válido (>0 y < price), el final es `price - descuento`.
const offer = computed(() => {
  const p = part.value
  if (!p) return null
  const save = p.discount_amount
  if (!save || save <= 0) return null
  const final = p.price - save
  if (final <= 0) return null
  return {
    finalFmt: money.format(final),
    originalFmt: money.format(p.price),
    saveFmt: money.format(save),
  }
})

const priceFmt = computed(() =>
  part.value ? money.format(part.value.price) : '',
)

const availabilityDotClass = computed(() =>
  part.value ? `dot--${part.value.availability}` : '',
)

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
      <!-- ---------- MEDIA ---------- -->
      <div class="sheet__media">
        <div class="media-frame">
          <span class="corner tl"></span><span class="corner tr"></span>
          <span class="corner bl"></span><span class="corner br"></span>
          <img
            v-if="part.image_url"
            :src="part.image_url"
            :alt="part.name"
            class="sheet__img"
          />
          <div v-else class="sheet__img sheet__img--empty" aria-hidden="true">
            <svg viewBox="0 0 24 24" width="34" height="34" fill="none" stroke="var(--charcoal)" stroke-width="1.4">
              <rect x="3" y="5" width="18" height="14" rx="2"/>
              <circle cx="8.5" cy="10" r="1.6"/>
              <path d="M21 15l-5-4-4.5 4L8 12l-5 5"/>
            </svg>
            <span class="mono">Foto próximamente</span>
          </div>
        </div>
      </div>

      <!-- ---------- FICHA (tarjeta de compra) ---------- -->
      <div class="sheet__info">
        <div class="info-card">
          <div class="sheet__badges">
            <span v-if="part.categories" class="pill pill--category">
              {{ part.categories.name }}
            </span>
            <span class="pill pill--origin">{{ ORIGIN_LABELS[part.origin_type] }}</span>
          </div>

          <h1 class="sheet__name">{{ part.name }}</h1>

          <div class="sheet__meta mono">
            <span>Núm. de parte <b>{{ part.code }}</b></span>
            <span class="meta-sep">·</span>
            <span>{{ part.brand }}</span>
          </div>

          <div class="price-row">
            <div class="price-box">
              <span v-if="offer" class="price-was mono">{{ offer.originalFmt }}</span>
              <span class="sheet__price mono">{{ offer ? offer.finalFmt : priceFmt }}</span>
              <span v-if="offer" class="price-save">Ahorras {{ offer.saveFmt }}</span>
            </div>
            <span class="availability" :class="availabilityDotClass">
              <span class="dot"></span>
              {{ AVAILABILITY_LABELS[part.availability] }}
            </span>
          </div>

          <p v-if="part.description" class="sheet__desc">{{ part.description }}</p>

          <!-- Fase 2: aquí entra "Agregar al carrito" (slot reservado, deshabilitado por ahora). -->
          <button class="btn btn--cta" disabled>
            Compra en línea próximamente
          </button>
        </div>

        <div class="sheet__sections">
          <PartSpecSheet
            :specs="part.part_specs ?? []"
            :material="part.material"
          />
          <CompatibilityList :items="part.part_compatibility ?? []" />
        </div>
      </div>
    </article>
  </div>
</template>

<style scoped>
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

.sheet {
  display: grid;
  grid-template-columns: 1fr 1.05fr;
  gap: var(--space-7);
  align-items: start;
}

/* ---------- MEDIA con esquinas HUD ---------- */
.sheet__media { position: sticky; top: calc(var(--header-h) + var(--space-4)); }

.media-frame {
  position: relative;
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--border);
  background: var(--surface-2);
  padding: var(--space-6);
}
.corner { position: absolute; width: 16px; height: 16px; border: 1.5px solid rgba(46,111,224,0.55); z-index: 2; }
.corner.tl { top: 10px; left: 10px; border-right: none; border-bottom: none; }
.corner.tr { top: 10px; right: 10px; border-left: none; border-bottom: none; }
.corner.bl { bottom: 10px; left: 10px; border-right: none; border-top: none; }
.corner.br { bottom: 10px; right: 10px; border-left: none; border-top: none; }

/* Igual que PartCard: caja cuadrada + object-fit contain para que la pieza se
   vea completa (nunca recortada), "flotando" con una sombra suave. */
.sheet__img {
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: contain;
  object-position: center;
  display: block;
  filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.35));
}
.sheet__img--empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: var(--charcoal);
  font-size: 0.8rem;
}

/* ---------- FICHA / tarjeta de compra ---------- */
.info-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
}

.sheet__badges {
  display: flex;
  gap: var(--space-2);
  margin-bottom: var(--space-4);
}
.pill {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  font-family: var(--font-display);
}
.pill--origin { background: var(--blue); color: #eceef2; }
.pill--category {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--blue-2);
}

.sheet__name {
  font-size: clamp(1.5rem, 2.6vw, 2rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  line-height: 1.15;
}

.sheet__meta {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  color: var(--charcoal);
  font-size: 0.8rem;
  margin-top: var(--space-3);
}
.sheet__meta b { color: var(--cream); font-weight: 500; }
.meta-sep { opacity: 0.5; }

.price-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: var(--space-5);
  padding-top: var(--space-4);
  border-top: 1px dashed var(--border);
}
.price-box {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.price-was {
  font-size: 0.9rem;
  color: var(--charcoal);
  text-decoration: line-through;
}
.sheet__price {
  font-size: 1.7rem;
  font-weight: 700;
  color: var(--blue-2);
  line-height: 1.1;
}
.price-save {
  font-size: 0.78rem;
  font-weight: 600;
  color: var(--orange-2);
}

.availability {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.78rem;
  font-family: var(--font-mono, monospace);
}
.availability .dot { width: 7px; height: 7px; border-radius: 50%; }
.dot--disponible .dot { background: var(--ok); box-shadow: 0 0 0 3px rgba(107,191,123,0.18); }
.dot--stock_bajo .dot { background: var(--warn); box-shadow: 0 0 0 3px rgba(240,183,63,0.18); }
.dot--agotado    .dot { background: var(--danger); box-shadow: 0 0 0 3px rgba(217,92,74,0.18); }
.dot--disponible { color: var(--ok); }
.dot--stock_bajo { color: var(--warn); }
.dot--agotado    { color: var(--danger); }

.sheet__desc {
  color: var(--cream);
  opacity: 0.82;
  margin-top: var(--space-4);
  line-height: 1.55;
  max-width: 56ch;
}

.btn--cta {
  width: 100%;
  margin-top: var(--space-5);
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  background: var(--surface-2);
  border: 1px dashed var(--border-strong);
  color: var(--charcoal);
  font-weight: 600;
  cursor: not-allowed;
}

.sheet__sections {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
  margin-top: var(--space-5);
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

@media (max-width: 860px) {
  .sheet { grid-template-columns: 1fr; gap: var(--space-5); }
  .sheet__media { position: static; }
}
</style>