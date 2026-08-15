<script setup lang="ts">
import { RouterLink } from 'vue-router'
</script>

<template>
  <div class="container notfound">
    <p class="notfound__code mono">404</p>
    <h1 class="notfound__title">No encontramos esta página</h1>
    <p class="notfound__lead">
      La pieza o la ruta que buscas no existe o fue movida.
    </p>
    <RouterLink to="/" class="btn btn--primary">Volver al catálogo</RouterLink>
  </div>
</template>

<style scoped>
.notfound {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: var(--space-3);
  padding-block: var(--space-8);
}

.notfound__code {
  color: var(--blue);
  font-size: 3rem;
  font-weight: 600;
}

.notfound__title {
  font-size: 1.6rem;
}

.notfound__lead {
  color: var(--charcoal);
  max-width: 44ch;
}

.btn--primary {
  margin-top: var(--space-4);
  display: inline-flex;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover {
  background: var(--blue-2);
}
</style>
