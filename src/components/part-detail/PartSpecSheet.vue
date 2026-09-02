<script setup lang="ts">
defineProps<{
  specs: { label: string; value: string }[]
  material?: string | null
}>()
</script>

<template>
  <section class="tech-block">
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
/*
 * Bloque plano: sin fondo, sin borde, sin radio. La separación respecto al resto
 * la pone la ficha (PartDetailView dibuja la línea del bloque técnico), así la
 * página deja de ser una pila de tarjetas dentro de tarjetas.
 */
.tech-block { min-width: 0; }

.panel-title {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  font-family: var(--font-display);
  color: var(--charcoal);
  margin-bottom: var(--space-4);
}
.panel-icon {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}
.spec-list { display: flex; flex-direction: column; }
/* Punteada y solo entre filas: marca el renglón sin encajonarlo. */
.spec-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: var(--space-4);
  padding: 10px 0;
  border-bottom: 1px dotted var(--border);
  font-size: 0.86rem;
}
.spec-row:last-child { border-bottom: none; }
.spec-row dt { color: var(--charcoal); margin: 0; }
.spec-row dd { color: var(--cream); margin: 0; text-align: right; }
.empty-note { color: var(--charcoal); font-size: 0.82rem; font-style: italic; margin: 0; }
</style>
