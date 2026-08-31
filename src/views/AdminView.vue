<script setup lang="ts">
import { onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/authStore'
import AdminDashboard from '@/components/admin/AdminDashboard.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'
import { useAppLoading } from '@/composables/useAppLoading'

// El acceso ya lo controla el guard del router (requiresAdmin): aquí solo
// llegan admins autenticados. Mantenemos un estado de carga por si init aún
// no terminó al montar (defensa; el guard normalmente ya lo resolvió).
const auth = useAuthStore()
const router = useRouter()
const { ready, isAdmin } = storeToRefs(auth)
const { finishBoot } = useAppLoading()

onMounted(async () => {
  await auth.init()
  finishBoot()
})

// Si el admin cierra sesión (o pierde el rol) estando en el panel, lo devolvemos
// al catálogo en vez de dejar la vista en blanco.
watch(isAdmin, (admin) => {
  if (ready.value && !admin) router.push('/')
})
</script>

<template>
  <div class="admin container">
    <AdminDashboard v-if="isAdmin" />

    <div v-else-if="!ready" class="admin__state">
      <GearSpinner :size="44" />
      <p>Cargando…</p>
    </div>
  </div>
</template>

<style scoped>
.admin {
  padding-block: var(--space-7) var(--space-8);
  min-height: 60vh;
}

.admin__state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding-block: var(--space-8);
  color: var(--charcoal);
  text-align: center;
}
</style>
