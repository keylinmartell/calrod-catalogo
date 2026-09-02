<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import type { Part } from '@/types/part'
import { ORIGIN_LABELS } from '@/types/part'
import { partWholesale } from '@/composables/usePartPricing'

const props = defineProps<{
  part: Part
  highlightCompat?: string
}>()

const quantity = ref(1)

function dec() {
  if (quantity.value > 1) quantity.value--
}

function inc() {
  quantity.value++
}

const money = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 2,
})

// Cálculo de oferta / descuento
const offer = computed(() => {
  const save = props.part.discount_amount
  if (!save || save <= 0) return null
  const original = props.part.price
  const final = original - save
  if (final <= 0) return null
  const pct = Math.round((save / original) * 100)
  return {
    finalFmt: money.format(final),
    originalFmt: money.format(original),
    pct: `-${pct}%`,
  }
})

const priceFmt = computed(() => money.format(props.part.price))

// Mayorista (0014). Como esta fila ya trae selector de cantidad, el precio
// grande sigue a la cantidad elegida: al llegar al mínimo mayorista se muestra
// ese precio por unidad, no el del detalle.
const wholesale = computed(() => partWholesale(props.part))

const appliesWholesale = computed(
  () => !!wholesale.value && quantity.value >= wholesale.value.minQty,
)

const unitPriceFmt = computed(() => {
  if (appliesWholesale.value && wholesale.value) return wholesale.value.priceFmt
  return offer.value ? offer.value.finalFmt : priceFmt.value
})

// Rango de años de compatibilidad para el display
const compatYears = computed(() => {
  const compats = props.part.part_compatibility ?? []
  if (!compats.length) return ''
  const first = compats[0]
  if (first.year_from && first.year_to) {
    return `${first.year_from} - ${first.year_to}`
  } else if (first.year_from) {
    return `Desde ${first.year_from}`
  } else if (first.year_to) {
    return `Hasta ${first.year_to}`
  }
  return ''
})

const originName = computed(() => {
  return ORIGIN_LABELS[props.part.origin_type] ?? 'Alternativa'
})
</script>

<template>
  <div class="list-item">
    <!-- Miniatura de foto -->
    <RouterLink :to="`/pieza/${part.id}`" class="list-item__photo">
      <img
        v-if="part.image_url"
        :src="part.image_url"
        :alt="part.name"
        loading="lazy"
        class="list-item__img"
      />
      <div v-else class="list-item__img list-item__img--empty">
        <span>Sin foto</span>
      </div>
    </RouterLink>

    <!-- Información central de la pieza -->
    <div class="list-item__info">
      <span class="list-item__code mono">{{ part.code }}</span>
      <RouterLink :to="`/pieza/${part.id}`" class="list-item__name">
        {{ part.name }}
      </RouterLink>
      <p v-if="part.description" class="list-item__desc">
        {{ part.description }}
      </p>
      <p v-if="compatYears" class="list-item__years mono">
        {{ compatYears }}
      </p>
      <div class="list-item__meta">
        <span class="meta-label">Marca:</span>
        <span class="meta-val">{{ part.brands?.name ?? 'CalRod' }}</span>
        <span class="meta-sep">·</span>
        <span class="meta-label">Tipo:</span>
        <span class="meta-val">{{ originName }}</span>
      </div>
    </div>

    <!-- Precios y descuento -->
    <div class="list-item__pricing">
      <div class="price-row">
        <span class="price-main">{{ unitPriceFmt }}</span>
        <span class="price-tax">Al cambio CUP</span>
        <span v-if="offer && !appliesWholesale" class="price-badge">
          {{ offer.pct }}
        </span>
        <span v-if="appliesWholesale" class="price-badge price-badge--wholesale">
          MAYORISTA
        </span>
      </div>
      <div v-if="offer && !appliesWholesale" class="price-original mono">
        {{ offer.originalFmt }} IVA Incl.
      </div>
      <div v-if="wholesale" class="price-wholesale mono">
        <template v-if="appliesWholesale">
          Precio mayorista por {{ quantity }} u.
        </template>
        <template v-else>
          Mayorista <b>{{ wholesale.priceFmt }}</b> · {{ wholesale.qtyLabel }}
        </template>
      </div>
    </div>

    <!-- Acciones: selector de cantidad y botón carrito -->
    <div class="list-item__actions">
      <div class="qty-stepper">
        <button
          type="button"
          class="qty-btn"
          aria-label="Disminuir cantidad"
          @click="dec"
        >
          −
        </button>
        <span class="qty-val mono">{{ quantity }}</span>
        <button
          type="button"
          class="qty-btn"
          aria-label="Aumentar cantidad"
          @click="inc"
        >
          +
        </button>
      </div>

      <RouterLink
        :to="`/pieza/${part.id}`"
        class="cart-btn"
        aria-label="Ver detalles y comprar"
        title="Ver detalles"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="9" cy="21" r="1" />
          <circle cx="20" cy="21" r="1" />
          <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
        </svg>
      </RouterLink>
    </div>
  </div>
</template>

<style scoped>
.list-item {
  display: grid;
  grid-template-columns: 90px 1fr auto auto;
  gap: var(--space-4);
  align-items: center;
  padding: var(--space-4);
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  transition: background 0.15s ease;
}

.list-item:last-child {
  border-bottom: none;
}

.list-item:hover {
  background: var(--surface-2);
}

/* Foto miniatura */
.list-item__photo {
  width: 90px;
  height: 90px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  display: grid;
  place-content: center;
  overflow: hidden;
  padding: 6px;
  flex-shrink: 0;
}

.list-item__img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.list-item__img--empty {
  font-size: 0.72rem;
  color: var(--charcoal);
}

/* Info central */
.list-item__info {
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
}

.list-item__code {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--blue-2);
  letter-spacing: 0.05em;
}

.list-item__name {
  font-family: var(--font-display);
  font-size: 1.02rem;
  font-weight: 700;
  color: var(--cream);
  text-transform: uppercase;
  text-decoration: none;
  line-height: 1.25;
}

.list-item__name:hover {
  color: var(--blue-2);
}

.list-item__desc {
  font-size: 0.8rem;
  color: var(--charcoal);
  text-transform: uppercase;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.list-item__years {
  font-size: 0.76rem;
  color: var(--cream);
  font-weight: 600;
}

.list-item__meta {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.75rem;
  color: var(--charcoal);
  margin-top: 2px;
}

.meta-label {
  color: var(--charcoal);
}

.meta-val {
  color: var(--cream);
  font-weight: 600;
}

.meta-sep {
  color: var(--border-strong);
}

/* Pricing */
.list-item__pricing {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
  padding-inline: var(--space-2);
}

.price-row {
  display: flex;
  align-items: baseline;
  gap: 5px;
}

.price-main {
  font-family: var(--font-display);
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--cream);
}

.price-tax {
  font-size: 0.72rem;
  color: var(--charcoal);
}

.price-badge {
  background: rgba(26, 61, 110, 0.15);
  color: var(--blue-2);
  font-size: 0.72rem;
  font-weight: 700;
  padding: 2px 6px;
  border-radius: 4px;
}

.price-original {
  font-size: 0.78rem;
  color: var(--charcoal);
  text-decoration: line-through;
}

/* Mayorista: mismo tono que el badge de oferta, sin tachado (no es un "antes"). */
.price-badge--wholesale {
  background: rgba(46, 111, 224, 0.18);
  letter-spacing: 0.04em;
}

.price-wholesale {
  font-size: 0.76rem;
  color: var(--charcoal);
  margin-top: 2px;
}

.price-wholesale b {
  color: var(--blue-2);
  font-weight: 700;
}

/* Acciones */
.list-item__actions {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.qty-stepper {
  display: flex;
  align-items: center;
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  border-radius: var(--radius-sm);
  overflow: hidden;
  height: 36px;
}

.qty-btn {
  width: 30px;
  height: 100%;
  background: none;
  border: none;
  color: var(--cream);
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: grid;
  place-content: center;
  transition: background 0.12s ease;
}

.qty-btn:hover {
  background: rgba(255, 255, 255, 0.08);
}

.qty-val {
  width: 32px;
  text-align: center;
  font-size: 0.9rem;
  color: var(--cream);
  font-weight: 600;
}

.cart-btn {
  display: grid;
  place-content: center;
  width: 38px;
  height: 38px;
  background: var(--blue);
  color: #fff;
  border-radius: var(--radius-sm);
  text-decoration: none;
  transition: background 0.15s ease, transform 0.1s ease;
}

.cart-btn:hover {
  background: var(--blue-2);
  transform: translateY(-1px);
}

.cart-btn svg {
  width: 18px;
  height: 18px;
}

/* Responsivo */
@media (max-width: 860px) {
  .list-item {
    grid-template-columns: 80px 1fr;
    gap: var(--space-3);
  }

  .list-item__pricing {
    grid-column: 1 / -1;
    align-items: flex-start;
  }

  .list-item__actions {
    grid-column: 1 / -1;
    justify-content: flex-end;
  }
}
</style>
