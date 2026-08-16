<script setup lang="ts">
defineProps<{
  items: {
    vehicle_brand: string
    vehicle_model: string
    year_from: number | null
    year_to: number | null
  }[]
}>()

// Rango de años legible aunque falte alguno (o los dos): "2015–2020", "2015+",
// "hasta 2020" o vacío. Los años son opcionales en la BD.
function yearRange(from: number | null, to: number | null): string {
  if (from && to) return from === to ? `${from}` : `${from}–${to}`
  if (from) return `${from}+`
  if (to) return `hasta ${to}`
  return ''
}
</script>

<template>
  <section class="panel-card">
    <h2 class="panel-title">
      <span class="panel-icon">
        <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--blue-2)" stroke-width="1.7">
          <path d="M3 12h4l2-4 4 8 2-4h6"/>
        </svg>
      </span>
      Compatibilidad
    </h2>

    <div v-if="items.length" class="compat-list">
      <div v-for="(item, i) in items" :key="i" class="compat-row">
        <div class="compat-vehicle">
          <span class="compat-brand">{{ item.vehicle_brand }}</span>
          <span class="compat-model">{{ item.vehicle_model }}</span>
        </div>
        <span
          v-if="yearRange(item.year_from, item.year_to)"
          class="compat-years mono"
        >{{ yearRange(item.year_from, item.year_to) }}</span>
      </div>
    </div>
    <p v-else class="empty-note">Sin compatibilidad registrada todavía.</p>
  </section>
</template>

<style scoped>
.panel-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-5) var(--space-6);
}
.panel-title {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 1.05rem;
  font-weight: 700;
  margin-bottom: var(--space-4);
}
.panel-icon {
  width: 26px;
  height: 26px;
  border-radius: 7px;
  background: rgba(46,111,224,0.14);
  border: 1px solid rgba(46,111,224,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.compat-list { display: flex; flex-direction: column; gap: 8px; }
.compat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: 9px;
  padding: 11px 14px;
}
.compat-vehicle { display: flex; flex-direction: column; }
.compat-brand { font-size: 0.86rem; font-weight: 600; color: var(--cream); }
.compat-model { font-size: 0.76rem; color: var(--charcoal); }
.compat-years { font-size: 0.78rem; color: var(--blue-2); }
.empty-note { color: var(--charcoal); font-size: 0.82rem; font-style: italic; margin: 0; }
</style>