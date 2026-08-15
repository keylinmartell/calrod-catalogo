<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import type { Part } from '@/types/part'
import { AVAILABILITY_LABELS, ORIGIN_LABELS } from '@/types/part'

const props = defineProps<{ part: Part }>()

const priceFmt = computed(() =>
  new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'USD',
  }).format(props.part.price),
)

// Solo mostramos badge para original / alternativa (§5).
const badge = computed(() => {
  if (props.part.origin_type === 'original') return ORIGIN_LABELS.original
  if (props.part.origin_type === 'alternativa') return ORIGIN_LABELS.alternativa
  return null
})

const stockClass = computed(() => `dot--${props.part.availability}`)

// Resumen de compatibilidad: "Marca Modelo (años)" por cada fila registrada.
const compatItems = computed(() =>
  (props.part.part_compatibility ?? []).map((c) => {
    const years =
      c.year_from === c.year_to ? `${c.year_from}` : `${c.year_from}–${c.year_to}`
    return { id: c.id, label: `${c.vehicle_brand} ${c.vehicle_model}`, years }
  }),
)

// Mostramos hasta 3 en la card; el resto se resume en un contador.
const MAX_COMPAT = 3
const visibleCompat = computed(() => compatItems.value.slice(0, MAX_COMPAT))
const extraCompat = computed(() => Math.max(0, compatItems.value.length - MAX_COMPAT))
</script>

<template>
  <RouterLink :to="`/pieza/${part.id}`" class="card">
    <div class="card__media">
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
      <span
        v-if="badge"
        class="badge"
        :class="{ 'badge--alt': part.origin_type === 'alternativa' }"
      >
        {{ badge }}
      </span>

      <span class="stock-tag" :class="`stock-tag--${part.availability}`">
        <span class="dot" :class="stockClass" aria-hidden="true"></span>
        <span class="stock-tag__label">{{ AVAILABILITY_LABELS[part.availability] }}</span>
      </span>
    </div>

    <div class="card__body">
      <div class="card__head">
        <h3 class="card__name">{{ part.name }}</h3>
        <span class="card__details">
          <svg
            class="card__tap-icon"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M9 11V6a2 2 0 0 1 4 0v6" />
            <path d="M13 8a2 2 0 0 1 4 0v5" />
            <path d="M17 9a2 2 0 0 1 4 0v6a6 6 0 0 1-6 6h-2a6 6 0 0 1-5.2-3l-2.3-4a2 2 0 0 1 3.4-2.1L9 13" />
          </svg>
          Ver detalles
        </span>
      </div>

      <div v-if="compatItems.length" class="card__compat">
        <span class="card__compat-title">Compatibilidad</span>
        <ul class="card__compat-list">
          <li v-for="c in visibleCompat" :key="c.id" class="card__compat-item">
            <span class="card__compat-model">{{ c.label }}</span>
            <span class="card__compat-years mono">{{ c.years }}</span>
          </li>
        </ul>
        <span v-if="extraCompat" class="card__compat-more">
          +{{ extraCompat }} vehículo{{ extraCompat > 1 ? 's' : '' }} más
        </span>
      </div>

      <div class="card__meta">
        <span class="card__price mono">{{ priceFmt }}</span>
        <span class="card__sku mono">{{ part.code }}</span>
      </div>

      <!-- Fase 2: aquí entra el botón "Agregar al carrito" (slot reservado). -->
    </div>
  </RouterLink>
</template>

<style scoped>
.card {
  display: flex;
  flex-direction: column;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: transform 0.15s ease, border-color 0.15s ease;
}

.card:hover {
  transform: translateY(-3px);
  border-color: var(--border-strong);
  background: var(--surface-2);
}

.card__media {
  position: relative;
  aspect-ratio: 4 / 3;
  background: var(--surface-2);
}

.card__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card__img--empty {
  display: grid;
  place-items: center;
  color: var(--charcoal);
  font-size: 0.8rem;
}

.badge {
  position: absolute;
  top: var(--space-3);
  left: var(--space-3);
  padding: 4px 10px;
  border-radius: 999px;
  font-family: var(--font-display);
  font-size: 0.66rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  background: var(--blue);
  /* Va sobre azul oscuro en ambos temas → texto siempre claro (no usa --cream,
     que en modo claro se vuelve oscuro). */
  color: #eceef2;
}

.badge--alt {
  /* Chip sobre la foto: fondo oscuro translúcido fijo + texto claro, legible
     en ambos temas sin depender de la foto. */
  background: rgba(8, 9, 12, 0.72);
  color: #eceef2;
  border: 1px solid rgba(236, 238, 242, 0.22);
  backdrop-filter: blur(4px);
}

.card__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-4);
}

.card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-2);
}

.card__name {
  font-size: 1rem;
  font-weight: 600;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 2.6em;
}

.card__details {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
  font-family: var(--font-display);
  font-size: 0.66rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--blue-2);
  white-space: nowrap;
}

.card__tap-icon {
  width: 15px;
  height: 15px;
  flex-shrink: 0;
  transform-origin: 70% 70%;
}

/* Un toquecito animado para que se note que es tocable. */
.card:hover .card__tap-icon {
  animation: tap 0.6s ease infinite;
}

@keyframes tap {
  0%,
  100% {
    transform: translateY(0) scale(1);
  }
  50% {
    transform: translateY(2px) scale(0.9);
  }
}

@media (prefers-reduced-motion: reduce) {
  .card:hover .card__tap-icon {
    animation: none;
  }
}

/* Etiqueta de disponibilidad sobre la foto: esquina superior derecha en
   escritorio; se reubica en móvil (§ ver media query). */
.stock-tag {
  position: absolute;
  top: var(--space-3);
  right: var(--space-3);
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 600;
  /* Chip sobre foto: fondo oscuro fijo en ambos temas (la foto no cambia), así
     los colores de estado se ven siempre. */
  background: rgba(8, 9, 12, 0.72);
  backdrop-filter: blur(4px);
  border: 1px solid rgba(236, 238, 242, 0.22);
  color: #eceef2;
}

/* Colores de estado brillantes (independientes del tema) para contraste sobre
   el chip oscuro. */
.stock-tag--disponible {
  color: #6bbf7b;
}
.stock-tag--stock_bajo {
  color: #f0b73f;
}
.stock-tag--agotado {
  color: #e07a6a;
}

.stock-tag__label {
  line-height: 1;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot--disponible {
  background: #6bbf7b;
}
.dot--stock_bajo {
  background: #f0b73f;
}
.dot--agotado {
  background: #e07a6a;
}

.card__compat {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  padding: var(--space-2);
  background: var(--surface-2);
  border-radius: var(--radius-sm);
}

.card__compat-title {
  font-family: var(--font-display);
  font-size: 0.62rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--blue-2);
}

.card__compat-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.card__compat-item {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: var(--space-2);
  font-size: 0.78rem;
  color: var(--cream);
}

.card__compat-model {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card__compat-years {
  color: var(--charcoal);
  font-size: 0.72rem;
  flex-shrink: 0;
}

.card__compat-more {
  font-size: 0.7rem;
  color: var(--charcoal);
}

.card__meta {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: var(--space-2);
  padding-top: var(--space-2);
  border-top: 1px solid var(--border);
}

.card__price {
  font-size: 1.05rem;
  font-weight: 600;
  color: var(--blue-2);
}

  .card__sku {
  font-size: 0.78rem;
  color: var(--charcoal);
}

@media (max-width: 520px) {
  .card {
    flex-direction: row;
    align-items: center;
    gap: var(--space-2);
    min-height: 130px;
    border-radius: var(--radius);
  }

  .card__media {
    aspect-ratio: 1 / 1;
    width: 95px;
    min-width: 95px;
    height: 95px;
    margin: 0 0 0 var(--space-2);
    flex-shrink: 0;
  }

  .card__img,
  .card__img--empty {
    width: 100%;
    height: 100%;
  }

  .badge {
    top: 2px;
    left: 2px;
    font-size: 0.46rem;
    padding: 2px 5px;
  }

  /* En vistas pequeñas la etiqueta de disponibilidad va a la esquina
     inferior izquierda de la foto. */
  .stock-tag {
    top: auto;
    right: auto;
    bottom: 4px;
    left: 4px;
    gap: 4px;
    padding: 2px 6px;
    font-size: 0.6rem;
  }

  .card__body {
    flex: 1;
    padding: var(--space-2) var(--space-2) var(--space-2) 0;
    gap: var(--space-1);
  }

  .card__name {
    font-size: 0.8rem;
    min-height: 2em;
  }

  .card__details {
    font-size: 0.56rem;
    letter-spacing: 0.04em;
  }

  /* En móvil la card es horizontal y baja: reducimos la compatibilidad a
     una sola línea para no romper el alto. */
  .card__compat {
    padding: var(--space-1) var(--space-2);
    gap: 0;
  }

  .card__compat-title {
    font-size: 0.54rem;
  }

  .card__compat-list {
    /* Solo la primera fila visible en móvil. */
    max-height: 1.1rem;
    overflow: hidden;
  }

  .card__compat-item {
    font-size: 0.68rem;
  }

  .card__compat-years {
    font-size: 0.62rem;
  }

  .card__compat-more {
    font-size: 0.6rem;
  }

  .card__meta {
    padding-top: 0;
    gap: var(--space-1);
  }

  .card__price {
    font-size: 0.8rem;
  }

  .card__sku {
    font-size: 0.64rem;
  }
}
</style>
