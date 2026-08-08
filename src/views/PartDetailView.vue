<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useParts } from '@/composables/useParts'
import type { Part } from '@/types/part'
import { AVAILABILITY_LABELS, ORIGIN_LABELS } from '@/types/part'
import PartSpecSheet from '@/components/part-detail/PartSpecSheet.vue'
import CompatibilityList from '@/components/part-detail/CompatibilityList.vue'

const route = useRoute()
const router = useRouter()
const { fetchPartById } = useParts()

const part = ref<Part | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

const priceFmt = computed(() =>
  part.value
    ? new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'USD',
      }).format(part.value.price)
    : '',
)

async function load(id: string) {
  loading.value = true
  error.value = null
  try {
    const found = await fetchPartById(id)
    if (!found) {
      // 404: la pieza no existe en Supabase.
      router.replace({ name: 'not-found' })
      return
    }
    part.value = found
    document.title = `${found.name} — Respuestos CalRod`
  } catch (e) {
    error.value =
      'No pudimos cargar esta pieza. Revisa tu conexión e intenta de nuevo.'
    console.error('[CalRod] PartDetail:', e)
  } finally {
    loading.value = false
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
    <RouterLink to="/" class="detail__back">← Volver al catálogo</RouterLink>

    <div v-if="loading" class="detail__state">
      <div class="spinner" aria-hidden="true"></div>
      <p>Cargando pieza…</p>
    </div>

    <div v-else-if="error" class="detail__state detail__state--error" role="alert">
      <p>{{ error }}</p>
      <button class="btn btn--ghost" @click="load(route.params.id as string)">
        Reintentar
      </button>
    </div>

    <article v-else-if="part" class="sheet">
      <div class="sheet__media">
        <img
          v-if="part.image_url"
          :src="part.image_url"
          :alt="part.name"
          class="sheet__img"
        />
        <div v-else class="sheet__img sheet__img--empty" aria-hidden="true">
          <span class="mono">Sin imagen</span>
        </div>
      </div>

      <div class="sheet__info">
        <div class="sheet__badges">
          <span class="pill pill--origin">{{ ORIGIN_LABELS[part.origin_type] }}</span>
          <span class="pill" :class="`pill--${part.availability}`">
            {{ AVAILABILITY_LABELS[part.availability] }}
          </span>
        </div>

        <h1 class="sheet__name">{{ part.name }}</h1>
        <p class="sheet__sku mono">SKU {{ part.code }} · {{ part.brand }}</p>
        <p class="sheet__price mono">{{ priceFmt }}</p>

        <p v-if="part.description" class="sheet__desc">{{ part.description }}</p>

        <!-- Fase 2: aquí entra el botón "Agregar al carrito" (slot reservado). -->

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
  padding-block: var(--space-6) var(--space-8);
}

.detail__back {
  display: inline-block;
  color: var(--orange-2);
  font-weight: 500;
  margin-bottom: var(--space-5);
}

.detail__back:hover {
  text-decoration: underline;
  text-underline-offset: 3px;
}

.sheet {
  display: grid;
  grid-template-columns: 1fr 1.1fr;
  gap: var(--space-7);
  align-items: start;
}

.sheet__media {
  position: sticky;
  top: calc(var(--header-h) + var(--space-4));
}

.sheet__img {
  width: 100%;
  aspect-ratio: 4 / 3;
  object-fit: cover;
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  background: var(--surface-2);
}

.sheet__img--empty {
  display: grid;
  place-items: center;
  color: var(--charcoal);
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

.pill--origin {
  background: var(--orange);
  color: #1a1206;
}

.pill--disponible {
  background: rgba(107, 191, 123, 0.16);
  color: var(--ok);
}
.pill--stock_bajo {
  background: rgba(240, 183, 63, 0.16);
  color: var(--warn);
}
.pill--agotado {
  background: rgba(217, 92, 74, 0.16);
  color: var(--danger);
}

.sheet__name {
  font-size: clamp(1.5rem, 3vw, 2.1rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}

.sheet__sku {
  color: var(--charcoal);
  font-size: 0.85rem;
  margin-top: var(--space-2);
}

.sheet__price {
  font-size: 1.6rem;
  font-weight: 600;
  color: var(--orange-2);
  margin-block: var(--space-3);
}

.sheet__desc {
  color: var(--cream);
  opacity: 0.85;
  margin-bottom: var(--space-5);
  max-width: 60ch;
}

.sheet__sections {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
  margin-top: var(--space-5);
  padding-top: var(--space-5);
  border-top: 1px solid var(--border);
}

.detail__state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding-block: var(--space-8);
  color: var(--charcoal);
}

.detail__state--error {
  color: var(--danger);
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--surface-2);
  border-top-color: var(--orange);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

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

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 860px) {
  .sheet {
    grid-template-columns: 1fr;
    gap: var(--space-5);
  }
  .sheet__media {
    position: static;
  }
}
</style>
