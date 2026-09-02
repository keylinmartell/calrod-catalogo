<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import type { Part } from '@/types/part'
import { AVAILABILITY_LABELS, ORIGIN_LABELS } from '@/types/part'
import { partWholesale } from '@/composables/usePartPricing'

const props = defineProps<{ part: Part }>()

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

// Línea única de metadatos al pie: "Disponible · Original" en vez de badges.
const footLine = computed(() => {
  const bits = [AVAILABILITY_LABELS[props.part.availability]]
  if (props.part.origin_type === 'original' || props.part.origin_type === 'alternativa') {
    bits.push(ORIGIN_LABELS[props.part.origin_type])
  }
  return bits.join(' · ')
})

const ribbon = computed(() => {
  if (props.part.is_best_deal) return 'MEJOR OFERTA'
  if (props.part.availability === 'stock_bajo') return 'ÚLTIMAS PIEZAS'
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
      <p class="card__sub mono">{{ part.brands?.name ?? '—' }} · {{ part.code }}</p>

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
      <p class="card__foot mono">{{ footLine }}</p>
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

/* ── Pie ─────────────────────────────────────────────────────────────────── */
.card__foot {
  margin-top: 6px;
  font-size: 0.65rem;
  color: var(--charcoal);
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
}
</style>