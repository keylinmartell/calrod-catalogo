<script setup lang="ts">
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/authStore'
import AdminAuth from '@/components/admin/AdminAuth.vue'
import AdminDashboard from '@/components/admin/AdminDashboard.vue'
import GearSpinner from '@/components/brand/GearSpinner.vue'
import { useAppLoading } from '@/composables/useAppLoading'

const auth = useAuthStore()
const { ready, isAdmin, isAuthenticated } = storeToRefs(auth)
const { finishBoot } = useAppLoading()

onMounted(async () => {
  // init lee la sesión guardada y se suscribe a los cambios de auth.
  await auth.init()
  finishBoot()
})
</script>

<template>
  <div class="admin container">
    <!-- Mientras init resuelve la sesión, evitamos el parpadeo login → panel. -->
    <div v-if="!ready" class="admin__state">
      <GearSpinner :size="44" />
      <p>Cargando…</p>
    </div>

    <!-- Admin: panel completo. -->
    <AdminDashboard v-else-if="isAdmin" />

    <!-- Sesión sin rol admin: registrado pero aún no promovido. -->
    <div v-else-if="isAuthenticated" class="admin__state admin__gate">
      <h1 class="admin__gate-title">Cuenta creada</h1>
      <p>
        Tu cuenta existe pero todavía no tiene permisos de administrador. Pide que
        te promuevan a <strong>admin</strong> en Supabase y vuelve a entrar.
      </p>
      <button class="btn btn--ghost" @click="auth.signOut()">Cerrar sesión</button>
    </div>

    <!-- Sin sesión: login / registro. -->
    <AdminAuth v-else />
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

.admin__gate {
  max-width: 46ch;
  margin-inline: auto;
}

.admin__gate-title {
  font-size: 1.4rem;
  color: var(--cream);
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
}

.btn--ghost {
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

.btn--ghost:hover {
  border-color: var(--blue);
}
</style>
