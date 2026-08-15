<script setup lang="ts">
defineProps<{
  specs: { label: string; value: string }[]
  material?: string | null
}>()
</script>

<template>
  <section class="panel-card">
    <h2 class="panel-title">
      <span class="panel-icon">
        <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="var(--blue-2)" stroke-width="1.7">
          <path d="M14.7 6.3a4 4 0 0 1-5.4 5.4L4 17v3h3l5.3-5.3a4 4 0 0 1 5.4-5.4l-2.5 2.5-2-2z"/>
        </svg>
      </span>
      Especificaciones
    </h2>

    <dl class="spec-list">
      <div v-if="material" class="spec-row">
        <dt>Material</dt>
        <dd class="mono">{{ material }}</dd>
      </div>
      <div v-for="s in specs" :key="s.label" class="spec-row">
        <dt>{{ s.label }}</dt>
        <dd class="mono">{{ s.value }}</dd>
      </div>
      <p v-if="!material && !specs.length" class="empty-note">
        Sin especificaciones registradas todavía.
      </p>
    </dl>
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
.spec-list { display: flex; flex-direction: column; }
.spec-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  padding: 11px 0;
  border-bottom: 1px solid var(--border);
  font-size: 0.85rem;
}
.spec-row:last-child { border-bottom: none; }
.spec-row dt { color: var(--charcoal); margin: 0; }
.spec-row dd { color: var(--cream); margin: 0; }
.empty-note { color: var(--charcoal); font-size: 0.82rem; font-style: italic; margin: 0; }
</style>