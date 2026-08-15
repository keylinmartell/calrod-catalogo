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
  className: 'store-pin',
  html: '<span></span>',
  iconSize: [18, 18],
  iconAnchor: [9, 9],
})

onMounted(() => {
  map = L.map(mapEl.value!, {
    center: [props.lat, props.lng],
    zoom: props.zoom,
    zoomControl: props.interactive,
    attributionControl: false,
    dragging: props.interactive,
    scrollWheelZoom: props.interactive,
    doubleClickZoom: props.interactive,
    touchZoom: props.interactive,
    // Sin scroll-zoom accidental al hacer scroll de la página en móvil.
    tap: props.interactive,
  })

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    // Atribución obligatoria por licencia de OSM (visible en el footer del panel).
  }).addTo(map)

  marker = L.marker([props.lat, props.lng], {
    icon: pinIcon,
    title: props.address,
  }).addTo(map)
})

// Si la ubicación llega/cambia después de montar (viene de Supabase async),
// reposicionamos el mapa y el pin sin recrear la instancia.
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

// Deep-link universal: geo: en móvil lo captura la app de mapas nativa;
// en escritorio abre Google Maps. Sin SDK ni API key.
const directionsUrl = () =>
  `https://www.google.com/maps/dir/?api=1&destination=${props.lat},${props.lng}`
</script>

<template>
  <aside class="map-panel" aria-label="Ubicación de la tienda">
    <span class="corner tl"></span>
    <span class="corner tr"></span>
    <span class="corner bl"></span>
    <span class="corner br"></span>

    <div class="map-header">
      <span class="pulse"></span>
      <span>CALROD · UBICACIÓN</span>
    </div>

    <div ref="mapEl" class="map-canvas"></div>

    <div class="map-footer">
      <span class="address">{{ address }}</span>
      <a
        :href="directionsUrl()"
        target="_blank"
        rel="noopener"
        class="directions-btn"
      >
        Cómo llegar →
      </a>
    </div>

    <p class="map-attribution">© OpenStreetMap</p>
  </aside>
</template>

<style scoped>
.map-panel {
  position: relative;
  background: linear-gradient(
    165deg,
    var(--surface),
    color-mix(in srgb, var(--surface) 85%, black)
  );
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-5) var(--space-5) var(--space-4);
  overflow: hidden;
  z-index: 1;
}

/* HUD corner marks — mismo lenguaje visual que HeroPanel. */
.corner {
  position: absolute;
  width: 14px;
  height: 14px;
  border: 1.5px solid rgba(74, 123, 184, 0.35);
}
.corner.tl { top: 10px; left: 10px; border-right: none; border-bottom: none; }
.corner.tr { top: 10px; right: 10px; border-left: none; border-bottom: none; }
.corner.bl { bottom: 10px; left: 10px; border-right: none; border-top: none; }
.corner.br { bottom: 10px; right: 10px; border-left: none; border-top: none; }

.map-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.09em;
  color: var(--charcoal);
  margin-bottom: var(--space-4);
  padding-left: 2px;
}

.pulse {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ok);
  animation: pulse-ring 2s infinite;
}
@keyframes pulse-ring {
  0%   { box-shadow: 0 0 0 0 rgba(92, 158, 115, 0.55); }
  70%  { box-shadow: 0 0 0 6px rgba(92, 158, 115, 0); }
  100% { box-shadow: 0 0 0 0 rgba(92, 158, 115, 0); }
}

.map-canvas {
  height: 200px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  /* Integra las teselas claras de OSM al tema oscuro. */
  filter: grayscale(0.35) brightness(0.82) contrast(1.05);
}

/* En modo claro las teselas ya combinan: sin oscurecer, solo un leve desaturado. */
:root[data-theme='light'] .map-canvas {
  filter: grayscale(0.15);
}

.map-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--space-3);
  margin-top: var(--space-4);
  padding-top: var(--space-3);
  border-top: 1px dashed var(--border);
}
.address {
  font-size: 0.78rem;
  color: var(--charcoal);
  max-width: 60%;
  line-height: 1.35;
}
.directions-btn {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--blue-2);
  text-decoration: none;
  white-space: nowrap;
}
.directions-btn:hover {
  text-decoration: underline;
}

.map-attribution {
  margin-top: var(--space-2);
  font-family: var(--font-mono);
  font-size: 0.58rem;
  color: var(--text-faint);
  text-align: right;
}
</style>

<style>
/* Pin del mapa — global porque Leaflet renderiza fuera del scope del componente. */
.store-pin span {
  display: block;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: var(--blue-2);
  border: 2.5px solid var(--cream);
  box-shadow: 0 0 0 4px rgba(74, 123, 184, 0.25);
}
</style>
