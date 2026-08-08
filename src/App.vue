<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
</script>

<template>
  <a href="#main" class="skip-link">Saltar al contenido</a>
  <AppHeader />
  <main id="main" class="app-main">
    <RouterView />
  </main>
  <AppFooter />
</template>

<style scoped>
.app-main {
  min-height: 60vh;
}

.skip-link {
  position: absolute;
  left: var(--space-4);
  top: -48px;
  background: var(--orange);
  color: #1a1206;
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-sm);
  font-weight: 600;
  z-index: 100;
  transition: top 0.15s ease;
}

.skip-link:focus {
  top: var(--space-3);
}
</style>
