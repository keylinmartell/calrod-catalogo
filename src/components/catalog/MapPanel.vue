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
  html: `
    <div class="store-pin">
      <div class="store-pin__pulse"></div>
      <div class="store-pin__pulse store-pin__pulse--delay"></div>
      <div class="store-pin__halo"></div>
      <div class="store-pin__core">
        <span class="store-pin__dot"></span>
      </div>
    </div>
  `,
  iconSize: [44, 44],
  iconAnchor: [22, 22],
})

onMounted(() => {
  map = L.map(mapEl.value!, {
    center: [props.lat, props.lng],
    zoom: props.zoom,
    zoomControl: false,
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

function recenter() {
  if (!map) return
  map.flyTo([props.lat, props.lng], props.zoom, { duration: 0.6 })
}

const directionsUrl = () =>
  `https://www.google.com/maps/dir/?api=1&destination=${props.lat},${props.lng}`
</script>

<template>
  <aside class="map-card" aria-label="Ubicación de la tienda física CalRod">
    <!-- Marco metálico con reflejo superior -->
    <div class="map-card__bezel">
      <!-- Lienzo Leaflet -->
      <div ref="mapEl" class="map-canvas"></div>

      <!-- Vignette cinemático para integrar el mapa con el UI oscuro -->
      <div class="map-vignette" aria-hidden="true"></div>
      <div class="map-grid-overlay" aria-hidden="true"></div>

      <!-- HUD Superior: Estado de Tienda + Botón Recentrar -->
      <div class="map-hud-top">
        <div class="map-status-pill">
          <span class="map-status-pill__dot"></span>
          <span class="map-status-pill__label">TIENDA FÍSICA</span>
          <span class="map-status-pill__sep" aria-hidden="true">·</span>
          <span class="map-status-pill__sub">SANTA CLARA</span>
        </div>

        <button
          type="button"
          class="map-recenter-btn"
          title="Centrar en la tienda"
          aria-label="Centrar mapa en la ubicación de la tienda"
          @click="recenter"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M12 2v3M12 19v3M2 12h3M19 12h3" />
          </svg>
        </button>
      </div>

      <!-- Dock Inferior Glassmorphic de Alta Precisión -->
      <div class="map-dock">
        <div class="map-dock__info">
          <div class="map-dock__pin" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
              <circle cx="12" cy="10" r="3" />
            </svg>
          </div>
          <div class="map-dock__text">
            <span class="map-dock__eyebrow">PUNTO DE ENTREGA Y MOSTRADOR</span>
            <p class="map-dock__address" :title="address">{{ address }}</p>
          </div>
        </div>

        <a
          :href="directionsUrl()"
          target="_blank"
          rel="noopener noreferrer"
          class="map-dock__cta"
          title="Abrir ruta en Google Maps"
        >
          <span>Cómo llegar</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" class="map-dock__cta-icon">
            <path d="M7 17L17 7" />
            <path d="M7 7h10v10" />
          </svg>
        </a>
      </div>

      <span class="map-attr" aria-hidden="true">© OSM</span>
    </div>
  </aside>
</template>

<style scoped>
.map-card {
  position: relative;
  width: 100%;
  height: 224px;
  border-radius: 18px;
  padding: 1px;
  background: linear-gradient(
    145deg,
    rgba(255, 255, 255, 0.16) 0%,
    rgba(74, 123, 184, 0.22) 38%,
    rgba(255, 255, 255, 0.05) 100%
  );
  box-shadow:
    0 20px 44px -12px rgba(0, 0, 0, 0.65),
    0 0 0 1px rgba(8, 9, 12, 0.8),
    inset 0 1px 0 rgba(255, 255, 255, 0.15);
  z-index: 1;
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.25s ease;
}

.map-card:hover {
  box-shadow:
    0 24px 52px -12px rgba(0, 0, 0, 0.75),
    0 0 28px -6px rgba(74, 123, 184, 0.22),
    inset 0 1px 0 rgba(255, 255, 255, 0.22);
}

.map-card__bezel {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 17px;
  background: #0b0f17;
  overflow: hidden;
}

.map-canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

/* Color-grading oscuro OEM estilo navegación automotriz premium */
:deep(.leaflet-tile-pane) {
  filter: grayscale(0.75) invert(0.92) contrast(1.18) hue-rotate(188deg) brightness(0.82) saturate(1.35);
  transition: filter 0.35s ease;
}

.map-card:hover :deep(.leaflet-tile-pane) {
  filter: grayscale(0.65) invert(0.92) contrast(1.2) hue-rotate(188deg) brightness(0.88) saturate(1.45);
}

:root[data-theme='light'] :deep(.leaflet-tile-pane) {
  filter: saturate(1.08) contrast(1.04) brightness(0.98);
}

/* Vignette sutil en bordes para fundir los tiles y dar contraste al HUD */
.map-vignette {
  position: absolute;
  inset: 0;
  z-index: 2;
  pointer-events: none;
  background:
    radial-gradient(circle at 50% 42%, transparent 35%, rgba(8, 11, 18, 0.55) 100%),
    linear-gradient(180deg, rgba(8, 11, 18, 0.5) 0%, transparent 28%, transparent 58%, rgba(8, 11, 18, 0.82) 100%);
}

:root[data-theme='light'] .map-vignette {
  background:
    linear-gradient(180deg, rgba(15, 23, 42, 0.18) 0%, transparent 24%, transparent 62%, rgba(15, 23, 42, 0.35) 100%);
}

.map-grid-overlay {
  position: absolute;
  inset: 0;
  z-index: 2;
  pointer-events: none;
  opacity: 0.12;
  background-image:
    linear-gradient(to right, rgba(148, 163, 184, 0.15) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(148, 163, 184, 0.15) 1px, transparent 1px);
  background-size: 28px 28px;
  mask-image: radial-gradient(circle at 50% 50%, transparent 40%, #000 100%);
}

/* ── HUD Superior ─────────────────────────────────────────────────────────── */
.map-hud-top {
  position: absolute;
  top: 12px;
  left: 12px;
  right: 48px;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  pointer-events: none;
}

.map-status-pill {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 5px 11px;
  border-radius: 999px;
  background: rgba(9, 13, 22, 0.82);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  box-shadow:
    0 8px 20px rgba(0, 0, 0, 0.4),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

.map-status-pill__dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #22c55e;
  box-shadow: 0 0 10px #22c55e;
  animation: status-pulse 2.2s infinite ease-in-out;
}

@keyframes status-pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.22); opacity: 0.75; }
}

.map-status-pill__label {
  font-family: var(--font-mono, monospace);
  font-size: 0.62rem;
  font-weight: 700;
  letter-spacing: 0.09em;
  color: #f8fafc;
}

.map-status-pill__sep {
  color: rgba(148, 163, 184, 0.5);
  font-size: 0.7rem;
}

.map-status-pill__sub {
  font-family: var(--font-mono, monospace);
  font-size: 0.6rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  color: #93c5fd;
}

.map-recenter-btn {
  pointer-events: auto;
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: grid;
  place-items: center;
  background: rgba(9, 13, 22, 0.82);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #cbd5e1;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.35);
  transition: all 0.18s ease;
}

.map-recenter-btn:hover {
  background: rgba(30, 58, 138, 0.75);
  border-color: rgba(96, 165, 250, 0.45);
  color: #ffffff;
  transform: scale(1.05);
}

.map-recenter-btn svg {
  width: 14px;
  height: 14px;
}

/* ── Dock Inferior ────────────────────────────────────────────────────────── */
.map-dock {
  position: absolute;
  bottom: 10px;
  left: 10px;
  right: 10px;
  z-index: 400;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 8px 10px 8px 10px;
  border-radius: 13px;
  background: linear-gradient(135deg, rgba(13, 18, 29, 0.88), rgba(9, 12, 20, 0.94));
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.11);
  box-shadow:
    0 10px 28px rgba(0, 0, 0, 0.55),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

.map-dock__info {
  display: flex;
  align-items: center;
  gap: 9px;
  min-width: 0;
  flex: 1;
}

.map-dock__pin {
  width: 32px;
  height: 32px;
  border-radius: 9px;
  background: linear-gradient(145deg, rgba(59, 130, 246, 0.22), rgba(29, 78, 216, 0.12));
  border: 1px solid rgba(96, 165, 250, 0.28);
  color: #60a5fa;
  display: grid;
  place-items: center;
  flex-shrink: 0;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.12);
}

.map-dock__pin svg {
  width: 15px;
  height: 15px;
}

.map-dock__text {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.map-dock__eyebrow {
  font-family: var(--font-mono, monospace);
  font-size: 0.54rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  color: #94a3b8;
  line-height: 1.1;
}

.map-dock__address {
  font-size: 0.74rem;
  font-weight: 600;
  color: #f8fafc;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.25;
}

.map-dock__cta {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 7px 12px;
  border-radius: 9px;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  border: 1px solid rgba(147, 197, 253, 0.35);
  color: #ffffff;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.01em;
  text-decoration: none;
  white-space: nowrap;
  flex-shrink: 0;
  box-shadow:
    0 4px 12px rgba(37, 99, 235, 0.35),
    inset 0 1px 0 rgba(255, 255, 255, 0.25);
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}

.map-dock__cta:hover {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  transform: translateY(-1px);
  box-shadow:
    0 6px 16px rgba(59, 130, 246, 0.5),
    inset 0 1px 0 rgba(255, 255, 255, 0.35);
}

.map-dock__cta-icon {
  width: 13px;
  height: 13px;
  transition: transform 0.2s ease;
}

.map-dock__cta:hover .map-dock__cta-icon {
  transform: translate(1.5px, -1.5px);
}

.map-attr {
  position: absolute;
  bottom: 66px;
  right: 12px;
  z-index: 400;
  font-family: var(--font-mono, monospace);
  font-size: 0.5rem;
  letter-spacing: 0.05em;
  color: rgba(255, 255, 255, 0.32);
  pointer-events: none;
}

/* ── Controles de Zoom de Leaflet ─────────────────────────────────────────── */
:deep(.leaflet-control-zoom) {
  border: 1px solid rgba(255, 255, 255, 0.12) !important;
  border-radius: 9px !important;
  overflow: hidden;
  background: rgba(9, 13, 22, 0.82) !important;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4) !important;
  margin-top: 12px !important;
  margin-right: 12px !important;
}

:deep(.leaflet-control-zoom a) {
  background: transparent !important;
  color: #cbd5e1 !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
  width: 28px !important;
  height: 28px !important;
  line-height: 28px !important;
  font-size: 14px !important;
  font-weight: 600 !important;
  transition: all 0.15s ease;
}

:deep(.leaflet-control-zoom a:last-child) {
  border-bottom: none !important;
}

:deep(.leaflet-control-zoom a:hover) {
  background: rgba(59, 130, 246, 0.28) !important;
  color: #ffffff !important;
}
</style>

<style>
/* Pin radar de alta precisión — global para el contenedor de Leaflet */
.store-pin-wrap {
  display: grid !important;
  place-items: center;
}

.store-pin {
  position: relative;
  width: 44px;
  height: 44px;
  display: grid;
  place-items: center;
}

.store-pin__pulse {
  position: absolute;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(59, 130, 246, 0.38) 0%, rgba(59, 130, 246, 0) 70%);
  border: 1.5px solid rgba(96, 165, 250, 0.65);
  animation: store-pin-radar 2.6s cubic-bezier(0.16, 1, 0.3, 1) infinite;
}

.store-pin__pulse--delay {
  animation-delay: 1.3s;
}

.store-pin__halo {
  position: absolute;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: rgba(37, 99, 235, 0.28);
  backdrop-filter: blur(2px);
}

.store-pin__core {
  position: relative;
  z-index: 2;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: linear-gradient(135deg, #60a5fa 0%, #2563eb 55%, #1e40af 100%);
  border: 2.5px solid #ffffff;
  box-shadow:
    0 4px 12px rgba(0, 0, 0, 0.65),
    0 0 14px rgba(59, 130, 246, 0.85);
  display: grid;
  place-items: center;
}

.store-pin__dot {
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: #ffffff;
}

@keyframes store-pin-radar {
  0% {
    transform: scale(0.45);
    opacity: 0.95;
  }
  100% {
    transform: scale(1.55);
    opacity: 0;
  }
}
</style>
