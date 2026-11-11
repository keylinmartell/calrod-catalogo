<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import type { Part } from '@/types/part'
import { ORIGIN_LABELS } from '@/types/part'
import { partWholesale } from '@/composables/usePartPricing'
import { getStockStatus, openWhatsAppOrder } from '@/composables/useWhatsApp'

const props = defineProps<{ part: Part }>()

const stockInfo = computed(() => getStockStatus(props.part))
const isStockAvailable = computed(() => stockInfo.value.hasStock)
const orderBtnLabel = computed(() => (isStockAvailable.value ? 'Encargar más' : 'Encargar'))

function onOrderClick(e: Event) {
  e.preventDefault()
  e.stopPropagation()
  openWhatsAppOrder({
    partName: props.part.name,
    partCode: props.part.code,
    hasStock: isStockAvailable.value,
  })
}


// Precio mayorista (0014): segundo precio por unidad al llevar varias piezas.
// null cuando la pieza no tiene mayorista o no conviene contra el detalle.
const wholesale = computed(() => partWholesale(props.part))

// `price` es el precio NORMAL. Si hay discount_amount válido (>0 y < price),
// el precio final es `price - discount_amount` y el original tachado es `price`.
const offer = computed(() => {
  const save = props.part.discount_amount
  if (!save || save <= 0) return null
  const original = props.part.price
  const final = original - save
  if (final <= 0) return null
  return {
    final,
    original,
    save,
  }
})

// Partimos el precio en entero + centavos para el formato tipo anuncio
// ($ chico arriba — dólares grandes — centavos chicos arriba).
function splitPrice(value: number) {
  const [int, cents = '00'] = value.toFixed(2).split('.')
  return { int, cents }
}

// Precio grande: si hay oferta, mostramos el FINAL; si no, el precio normal.
const priceParts = computed(() =>
  splitPrice(offer.value ? offer.value.final : props.part.price),
)
const originalPriceFmt = computed(() =>
  offer.value
    ? new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'USD' }).format(
        offer.value.original,
      )
    : '',
)
const saveFmt = computed(() =>
  offer.value
    ? new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'USD' }).format(
        offer.value.save,
      )
    : '',
)

const originLabel = computed(() => ORIGIN_LABELS[props.part.origin_type] ?? '')

const ribbon = computed(() => {
  if (props.part.is_best_deal) return 'MEJOR OFERTA'
  if (stockInfo.value.tone === 'warn') return 'ÚLTIMAS PIEZAS'
  return null
})
</script>

<template>
  <RouterLink :to="`/pieza/${part.id}`" class="card">
    <!-- Franja de foto: estudio propio, con aire y sombra de producto flotando -->
    <div class="card__photo">
      <img
        v-if="part.image_url"
        :src="part.image_url"
        :alt="part.name"
        loading="lazy"
        class="card__img"
      />
      <div v-else class="card__img card__img--empty" aria-hidden="true">
        <span class="mono">Sin imagen</span>
      </div>

      <span v-if="offer" class="save-sticker">
        <span>AHORRA<br />{{ saveFmt }}</span>
      </span>

      <span v-if="ribbon" class="ribbon" :class="{ 'ribbon--deal': part.is_best_deal }">
        <span class="ribbon__text">{{ ribbon }}</span>
      </span>
    </div>

    <!-- Cuerpo tipo volante -->
    <div class="card__body">
      <h3 class="card__name">{{ part.name }}</h3>
      <p class="card__sub mono">
        {{ part.brands?.name ?? '—' }}<template v-if="part.code"> · {{ part.code }}</template><template v-if="originLabel"> · {{ originLabel }}</template>
      </p>

      <!-- Precio estilo anuncio: $ chico, entero grande, centavos chicos -->
      <div class="price">
        <span v-if="offer" class="price__was mono">{{ originalPriceFmt }}</span>
        <div class="price__now">
          <span class="price__symbol">$</span>
          <span class="price__int">{{ priceParts.int }}</span>
          <span class="price__cents">{{ priceParts.cents }}</span>
        </div>
      </div>
      <p v-if="wholesale" class="card__wholesale mono">
        Mayorista <b>{{ wholesale.priceFmt }}</b> · {{ wholesale.qtyLabel }}
      </p>

      <!-- Indicador de existencia estilo tienda / catálogo -->
      <div class="card__stock mono" :class="`card__stock--${stockInfo.tone}`">
        <span class="card__stock-dot" aria-hidden="true"></span>
        <span>{{ stockInfo.cardLabel }}</span>
      </div>

      <div class="card__order">
        <button
          type="button"
          class="order-btn"
          :class="{ 'order-btn--more': isStockAvailable }"
          :title="`${orderBtnLabel} vía WhatsApp`"
          @click="onOrderClick"
        >
          <svg class="order-btn__icon" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
            <path
              d="M16.004 3.2c-7.06 0-12.8 5.74-12.8 12.8 0 2.258.594 4.462 1.72 6.4L3.2 28.8l6.56-1.72a12.74 12.74 0 0 0 6.244 1.62h.006c7.06 0 12.8-5.74 12.8-12.8 0-3.42-1.332-6.634-3.75-9.052A12.72 12.72 0 0 0 16.004 3.2Zm0 23.36h-.004a10.56 10.56 0 0 1-5.384-1.474l-.386-.23-3.894 1.02 1.04-3.796-.252-.39a10.55 10.55 0 0 1-1.616-5.62c0-5.868 4.776-10.64 10.648-10.64a10.57 10.57 0 0 1 7.524 3.12 10.56 10.56 0 0 1 3.116 7.526c0 5.868-4.776 10.64-10.642 10.64Zm5.834-7.964c-.32-.16-1.892-.934-2.184-1.04-.293-.107-.507-.16-.72.16-.213.32-.826 1.04-1.013 1.253-.187.213-.373.24-.693.08-.32-.16-1.35-.498-2.57-1.586-.95-.847-1.592-1.894-1.778-2.214-.187-.32-.02-.493.14-.652.144-.143.32-.373.48-.56.16-.187.213-.32.32-.533.107-.213.053-.4-.027-.56-.08-.16-.72-1.734-.986-2.374-.26-.624-.523-.54-.72-.55l-.613-.01c-.213 0-.56.08-.853.4-.293.32-1.12 1.094-1.12 2.667 0 1.574 1.146 3.094 1.306 3.307.16.213 2.253 3.44 5.46 4.826.763.33 1.358.527 1.822.674.766.244 1.463.21 2.014.127.615-.092 1.892-.774 2.158-1.52.267-.747.267-1.387.187-1.52-.08-.134-.293-.214-.613-.374Z"
            />
          </svg>
          <span>{{ orderBtnLabel }}</span>
        </button>
        <p class="order-info">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <circle cx="12" cy="12" r="10" />
            <polyline points="12 6 12 12 16 14" />
          </svg>
          <span>Encargos disponibles en ~15 días aprox.</span>
        </p>
      </div>
    </div>
  </RouterLink>
</template>

<style scoped>
.card {
  display: flex;
  flex-direction: column;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  transition: border-color 0.15s ease, transform 0.12s ease;
}

.card:hover {
  border-color: var(--blue-2);
  transform: translateY(-2px);
}

/* ── Franja de foto: cuadrada y compacta ────── */
.card__photo {
  position: relative;
  aspect-ratio: 1 / 1;
  background: var(--surface-2);
  display: grid;
  place-items: center;
  overflow: hidden;
  padding: var(--space-3);
}

.card__img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  display: block;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.25));
}

.card__img--empty {
  color: var(--charcoal);
  font-size: 0.72rem;
}

/* ── Sticker de ahorro ──────────────────────────────────────── */
.save-sticker {
  position: absolute;
  top: 6px;
  left: 6px;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  background: var(--blue);
  color: #fff;
  font-family: var(--font-display);
  font-size: 0.52rem;
  font-weight: 800;
  line-height: 1.05;
  transform: rotate(-6deg);
  clip-path: polygon(
    50% 0%, 61% 15%, 79% 9%, 82% 28%, 100% 35%, 91% 52%,
    100% 69%, 82% 74%, 79% 93%, 61% 87%, 50% 100%, 39% 87%,
    21% 93%, 18% 74%, 0% 69%, 9% 52%, 0% 35%, 18% 28%,
    21% 9%, 39% 15%
  );
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
  z-index: 2;
}

/* ── Cinta diagonal ──────────────────────────────────────────── */
.ribbon {
  position: absolute;
  top: 14px;
  right: -42px;
  width: 140px;
  transform: rotate(45deg);
  background: var(--blue);
  text-align: center;
  padding: 3px 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.25);
  z-index: 2;
}
.ribbon--deal { background: var(--blue-2); }
.ribbon__text {
  display: block;
  color: #fff;
  font-family: var(--font-display);
  font-size: 0.45rem;
  font-weight: 800;
  letter-spacing: 0.04em;
  white-space: nowrap;
}

/* ── Cuerpo: compacto ─────────────────────────────────────────── */
.card__body {
  display: flex;
  flex-direction: column;
  padding: var(--space-3);
}

.card__name {
  font-family: var(--font-display);
  font-size: 0.92rem;
  font-weight: 700;
  line-height: 1.25;
  color: var(--cream);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card__sub {
  margin-top: 2px;
  font-size: 0.68rem;
  color: var(--charcoal);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ── Precio estilo anuncio ─────────────────────────────────────────────────── */
.price {
  margin-top: var(--space-2);
}

.price__was {
  display: block;
  font-size: 0.72rem;
  color: var(--charcoal);
  text-decoration: line-through;
  margin-bottom: 1px;
}

.price__now {
  display: flex;
  align-items: flex-start;
  color: var(--blue-2);
  font-family: var(--font-display);
  font-weight: 800;
  line-height: 1;
}

.price__symbol {
  font-size: 0.88rem;
  margin-top: 2px;
}

.price__int {
  font-size: 1.85rem;
  letter-spacing: -0.02em;
}

.price__cents {
  font-size: 0.88rem;
  margin-top: 2px;
}

/* ── Mayorista: segundo precio, discreto pero legible ────────────────────── */
.card__wholesale {
  margin-top: 4px;
  font-size: 0.66rem;
  color: var(--charcoal);
}

.card__wholesale b {
  color: var(--blue-2);
  font-weight: 700;
}

/* ── Indicador de existencia ─────────────────────────────────────────────── */
.card__stock {
  margin-top: 6px;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.68rem;
  font-weight: 600;
  line-height: 1.2;
}

.card__stock-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
  background: currentColor;
}

.card__stock--ok {
  color: var(--ok);
}

.card__stock--warn {
  color: var(--warn);
}

.card__stock--out {
  color: var(--danger);
}

/* ── Encargo por WhatsApp ────────────────────────────────────────────────── */
.card__order {
  margin-top: var(--space-2);
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.order-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  padding: 6px 10px;
  font-family: var(--font-display);
  font-size: 0.74rem;
  font-weight: 700;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(37, 211, 102, 0.4);
  background: #25d366;
  color: #fff;
  cursor: pointer;
  transition: transform 0.12s ease, background-color 0.15s ease, box-shadow 0.15s ease;
  box-shadow: 0 2px 6px rgba(37, 211, 102, 0.25);
}

.order-btn:hover {
  background: #20ba59;
  transform: translateY(-1px);
  box-shadow: 0 4px 10px rgba(37, 211, 102, 0.35);
}

.order-btn:active {
  transform: translateY(0);
}

.order-btn__icon {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
}

.order-info {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.6rem;
  color: var(--charcoal);
  line-height: 1.2;
}

.order-info svg {
  width: 11px;
  height: 11px;
  flex-shrink: 0;
  color: var(--blue-2);
}

/* ── Móvil: tarjeta cuadrícula compacta ─────────────────────────────────── */
@media (max-width: 520px) {
  .card__body { padding: var(--space-2); }
  .card__name { font-size: 0.82rem; }
  .card__sub { font-size: 0.62rem; }
  .price__int { font-size: 1.45rem; }
  .price__symbol, .price__cents { font-size: 0.75rem; }
  .card__wholesale { font-size: 0.58rem; }
  .card__foot { font-size: 0.58rem; }
  .order-btn {
    font-size: 0.68rem;
    padding: 5px 8px;
    gap: 4px;
  }
  .order-btn__icon {
    width: 12px;
    height: 12px;
  }
  .order-info {
    font-size: 0.56rem;
  }
}
</style>