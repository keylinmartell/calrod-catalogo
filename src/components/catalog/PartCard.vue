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
    </div>

    <div class="card__body">
      <h3 class="card__name">{{ part.name }}</h3>

      <div class="card__stock">
        <span class="dot" :class="stockClass" aria-hidden="true"></span>
        <span class="card__stock-label">{{ AVAILABILITY_LABELS[part.availability] }}</span>
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
  background: var(--orange);
  color: #1a1206;
}

.badge--alt {
  background: var(--surface);
  color: var(--cream);
  border: 1px solid var(--border-strong);
}

.card__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-4);
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

.card__stock {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: 0.8rem;
  color: var(--charcoal);
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot--disponible {
  background: var(--ok);
}
.dot--stock_bajo {
  background: var(--warn);
}
.dot--agotado {
  background: var(--danger);
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
  color: var(--orange-2);
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

  .card__body {
    flex: 1;
    padding: var(--space-2) var(--space-2) var(--space-2) 0;
    gap: var(--space-1);
  }

  .card__name {
    font-size: 0.8rem;
    min-height: 2em;
  }

  .card__stock {
    font-size: 0.68rem;
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
