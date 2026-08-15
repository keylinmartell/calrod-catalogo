<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useStoreSettings } from '@/composables/useStoreSettings'
import MapPanel from '@/components/catalog/MapPanel.vue'

const { fetchStoreSettings, updateStoreSettings } = useStoreSettings()

const loading = ref(false)
const saving = ref(false)
const error = ref<string | null>(null)
const savedOk = ref(false)

// Borrador editable. lat/lng como string para no pelear con el input mientras
// se escribe (se validan y convierten a número al guardar).
const draft = reactive({ address: '', lat: '', lng: '' })

// Coordenadas ya numéricas para el preview del mapa (null mientras no sean válidas).
const preview = reactive<{ lat: number | null; lng: number | null }>({
  lat: null,
  lng: null,
})

function syncPreview() {
  const lat = Number(draft.lat)
  const lng = Number(draft.lng)
  preview.lat = Number.isFinite(lat) && draft.lat.trim() !== '' ? lat : null
  preview.lng = Number.isFinite(lng) && draft.lng.trim() !== '' ? lng : null
}

async function load() {
  loading.value = true
  error.value = null
  try {
    const s = await fetchStoreSettings()
    if (s) {
      draft.address = s.address
      draft.lat = String(s.lat)
      draft.lng = String(s.lng)
      syncPreview()
    }
  } catch (e) {
    error.value = 'No pudimos cargar la ubicación.'
    console.error('[CalRod] StoreLocationManager load:', e)
  } finally {
    loading.value = false
  }
}

async function save() {
  savedOk.value = false
  const address = draft.address.trim()
  const lat = Number(draft.lat)
  const lng = Number(draft.lng)

  if (!address) {
    error.value = 'La dirección es obligatoria.'
    return
  }
  if (!Number.isFinite(lat) || lat < -90 || lat > 90) {
    error.value = 'Latitud inválida (debe estar entre -90 y 90).'
    return
  }
  if (!Number.isFinite(lng) || lng < -180 || lng > 180) {
    error.value = 'Longitud inválida (debe estar entre -180 y 180).'
    return
  }

  saving.value = true
  error.value = null
  try {
    await updateStoreSettings({ address, lat, lng })
    savedOk.value = true
    syncPreview()
  } catch (e) {
    const msg = (e as Error).message?.toLowerCase() ?? ''
    if (msg.includes('row-level security') || msg.includes('policy')) {
      error.value = 'Sin permisos. ¿Sigue tu sesión de admin activa?'
    } else {
      error.value = 'No se pudo guardar la ubicación.'
    }
    console.error('[CalRod] StoreLocationManager save:', e)
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<template>
  <section class="loc">
    <div class="loc__grid">
      <form class="loc__form" @submit.prevent="save">
        <p class="loc__hint">
          Para sacar las coordenadas: entra a
          <a href="https://openstreetmap.org" target="_blank" rel="noopener">openstreetmap.org</a>,
          busca la dirección, clic derecho sobre el punto exacto → “Mostrar
          dirección”. Ahí aparecen la latitud y longitud para copiar.
        </p>

        <label class="field">
          <span class="field__label">Dirección</span>
          <input
            v-model="draft.address"
            class="field__input"
            placeholder="Ej. Calle 23 esq. L, Vedado, La Habana"
          />
        </label>

        <div class="loc__coords">
          <label class="field">
            <span class="field__label">Latitud</span>
            <input
              v-model="draft.lat"
              class="field__input mono"
              placeholder="23.1136"
              inputmode="decimal"
              @input="syncPreview"
            />
          </label>
          <label class="field">
            <span class="field__label">Longitud</span>
            <input
              v-model="draft.lng"
              class="field__input mono"
              placeholder="-82.3666"
              inputmode="decimal"
              @input="syncPreview"
            />
          </label>
        </div>

        <p v-if="error" class="loc__msg loc__msg--error" role="alert">{{ error }}</p>
        <p v-else-if="savedOk" class="loc__msg loc__msg--ok" role="status">
          Ubicación guardada.
        </p>

        <button type="submit" class="btn btn--primary" :disabled="saving || loading">
          {{ saving ? 'Guardando…' : 'Guardar ubicación' }}
        </button>
      </form>

      <!-- Preview en vivo: mismo componente que ve el cliente en el catálogo. -->
      <div class="loc__preview">
        <span class="loc__preview-label mono">Vista previa</span>
        <MapPanel
          v-if="preview.lat !== null && preview.lng !== null"
          :key="`${preview.lat},${preview.lng}`"
          :lat="preview.lat"
          :lng="preview.lng"
          :address="draft.address || 'Ubicación de la tienda'"
        />
        <p v-else class="loc__preview-empty">
          Ingresa latitud y longitud válidas para ver el mapa.
        </p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.loc__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-6);
  align-items: start;
}

.loc__form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  background: var(--surface);
  padding: var(--space-5);
}

.loc__hint {
  font-size: 0.82rem;
  color: var(--charcoal);
  line-height: 1.5;
  padding: var(--space-3);
  background: var(--surface-2);
  border-radius: var(--radius-sm);
}

.loc__hint a {
  color: var(--blue-2);
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
}

.field__input:focus {
  border-color: var(--blue);
}

.field__input::placeholder {
  color: var(--charcoal);
}

.loc__coords {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-3);
}

.loc__msg {
  font-size: 0.9rem;
}
.loc__msg--error {
  color: var(--danger);
}
.loc__msg--ok {
  color: var(--ok);
}

.loc__preview {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.loc__preview-label {
  font-size: 0.72rem;
  color: var(--charcoal);
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.loc__preview-empty {
  color: var(--charcoal);
  font-size: 0.9rem;
  padding: var(--space-6);
  text-align: center;
  border: 1px dashed var(--border);
  border-radius: var(--radius-lg);
}

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
  align-self: flex-start;
}

.btn--primary {
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover:not(:disabled) {
  background: var(--blue-2);
}

.btn:disabled {
  opacity: 0.6;
  cursor: default;
}

@media (max-width: 860px) {
  .loc__grid {
    grid-template-columns: 1fr;
  }
}
</style>
