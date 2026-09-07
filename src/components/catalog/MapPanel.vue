<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

const props = withDefaults(
  defineProps<{
    lat: number
    lng: number
    address: string
    /** true = mapa navegable (arrastrar/zoom); false = preview estático. */
    interactive?: boolean
    zoom?: number
  }>(),
  { interactive: true, zoom: 15 },
)

const mapEl = ref<HTMLElement | null>(null)
let map: L.Map | null = null
let marker: L.Marker | null = null

const pinIcon = L.divIcon({
  className: 'store-pin-wrap',
  html: '<div class="store-pin"><div class="store-pin__ring"></div><div class="store-pin__core"></div></div>',
  iconSize: [32, 32],
  iconAnchor: [16, 16],
})

onMounted(() => {
  map = L.map(mapEl.value!, {
    center: [props.lat, props.lng],
    zoom: props.zoom,
    zoomControl: false, // We add it manually for positioning
    attributionControl: false,
    dragging: props.interactive,
    scrollWheelZoom: false,
    doubleClickZoom: props.interactive,
    touchZoom: props.interactive,
    tap: props.interactive,
  })

  if (props.interactive) {
    L.control.zoom({ position: 'topright' }).addTo(map)
  }

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
  }).addTo(map)

  marker = L.marker([props.lat, props.lng], {
    icon: pinIcon,
    title: props.address,
  }).addTo(map)
})

watch(
  () => [props.lat, props.lng] as const,
  ([lat, lng]) => {
    if (!map) return
    map.setView([lat, lng], props.zoom)
    marker?.setLatLng([lat, lng])
  },
)

onBeforeUnmount(() => {
  map?.remove()
  map = null
  marker = null
})

const directionsUrl = () =>
  `https://www.google.com/maps/dir/?api=1&destination=${props.lat},${props.lng}`
</script>

<template>
  <aside class="map-panel" aria-label="Ubicación de la tienda">
    <div ref="mapEl" class="map-canvas"></div>

    <!-- Badge flotante superior -->
    <div class="map-badge">
      <span class="pulse"></span>
      <span class="map-badge__text">CALROD · TIENDA FÍSICA</span>
    </div>

    <!-- Barra inferior flotante Pro con efecto vidrio -->
    <div class="map-overlay-card">
      <div class="map-info">
        <div class="map-info__icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 21s-6-5.3-6-10a6 6 0 0 1 12 0c0 4.7-6 10-6 10Z"/>
            <circle cx="12" cy="11" r="2.5"/>
          </svg>
        </div>
        <span class="address" :title="address">{{ address }}</span>
      </div>

      <a
        :href="directionsUrl()"
        target="_blank"
        rel="noopener"
        class="directions-btn"
        title="Obtener indicaciones en Google Maps"
      >
        <span>Cómo llegar</span>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="directions-btn__arrow">
          <line x1="5" y1="12" x2="19" y2="12"></line>
          <polyline points="12 5 19 12 12 19"></polyline>
        </svg>
      </a>
    </div>

    <span class="map-attribution">© OpenStreetMap</span>
  </aside>
</template>

<style scoped>
.map-panel {
  position: relative;
  width: 100%;
  height: 190px;
  background: #0d121c;
  border-radius: var(--radius-lg, 16px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow:
    0 14px 34px rgba(0, 0, 0, 0.45),
    0 0 0 1px rgba(74, 123, 184, 0.15);
  overflow: hidden;
  z-index: 1;
}

.map-canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

/* Aplicar el filtro SOLO a los tiles (imágenes del mapa), no a los pines ni controles */
:deep(.leaflet-tile-pane) {
  filter: grayscale(0.5) brightness(0.65) contrast(1.1) invert(0.05) sepia(0.2) hue-rotate(180deg);
  transition: filter 0.3s ease;
}

:root[data-theme='light'] :deep(.leaflet-tile-pane) {
  filter: saturate(1.1) contrast(1.05);
}

/* ── Badge Superior ───────────────────────────────────────────────────────── */
.map-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 400;
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 4px 10px;
  border-radius: 999px;
  background: rgba(11, 16, 25, 0.8);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.35);
  pointer-events: none;
}

.map-badge__text {
  font-family: var(--font-mono, monospace);
  font-size: 0.64rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: #f1f5f9;
}

.pulse {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 8px #22c55e;
  animation: pulse-ring 2s infinite;
}

@keyframes pulse-ring {
  0%   { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.6); }
  70%  { box-shadow: 0 0 0 6px rgba(34, 197, 94, 0); }
  100% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0); }
}

/* ── Tarjeta Inferior Flotante ────────────────────────────────────────────── */
.map-overlay-card {
  position: absolute;
  bottom: 8px;
  left: 8px;
  right: 8px;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 6px 10px;
  border-radius: 10px;
  background: rgba(11, 16, 25, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

.map-info {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 0;
  flex: 1;
}

.map-info__icon {
  width: 20px;
  height: 20px;
  border-radius: 5px;
  background: rgba(74, 123, 184, 0.15);
  color: var(--blue-2, #60a5fa);
  display: grid;
  place-items: center;
  flex-shrink: 0;
}

.map-info__icon svg {
  width: 12px;
  height: 12px;
}

.address {
  font-size: 0.7rem;
  font-weight: 500;
  color: #f1f5f9;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.2;
}

.directions-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #ffffff;
  font-size: 0.68rem;
  font-weight: 600;
  text-decoration: none;
  white-space: nowrap;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.directions-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-1px);
}

.directions-btn__arrow {
  width: 12px;
  height: 12px;
  transition: transform 0.15s ease;
}

.directions-btn:hover .directions-btn__arrow {
  transform: translateX(2px);
}

.map-attribution {
  position: absolute;
  top: 6px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 400;
  font-family: var(--font-mono, monospace);
  font-size: 0.5rem;
  color: rgba(255, 255, 255, 0.3);
  pointer-events: none;
}

/* ── Estilos personalizados para controles de Leaflet ─────────────────────── */
:deep(.leaflet-control-zoom) {
  border: 1px solid rgba(255, 255, 255, 0.12) !important;
  border-radius: 8px !important;
  overflow: hidden;
  background: rgba(11, 16, 25, 0.78) !important;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.35) !important;
  margin-top: 10px !important;
  margin-right: 10px !important;
}

:deep(.leaflet-control-zoom a) {
  background: transparent !important;
  color: #e2e8f0 !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
  width: 26px !important;
  height: 26px !important;
  line-height: 26px !important;
  font-size: 14px !important;
  transition: all 0.15s ease;
}

:deep(.leaflet-control-zoom a:hover) {
  background: rgba(74, 123, 184, 0.3) !important;
  color: #ffffff !important;
}
</style>

<style>
/* Pin del mapa — global porque Leaflet renderiza fuera del scope */
.store-pin-wrap {
  display: grid !important;
  place-items: center;
}

.store-pin {
  position: relative;
  width: 18px;
  height: 18px;
  display: grid;
  place-items: center;
}

.store-pin__ring {
  position: absolute;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(74, 123, 184, 0.3);
  border: 1px solid rgba(74, 123, 184, 0.5);
  animation: pin-radar 2.2s infinite ease-out;
}

.store-pin__core {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  border: 2px solid #ffffff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
  position: relative;
  z-index: 2;
}

@keyframes pin-radar {
  0% { transform: scale(0.6); opacity: 1; }
  100% { transform: scale(1.6); opacity: 0; }
}
</style>
