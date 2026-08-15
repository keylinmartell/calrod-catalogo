<script setup lang="ts">
import { ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/authStore'

const auth = useAuthStore()
const { loading, error } = storeToRefs(auth)

const mode = ref<'login' | 'register'>('login')
const email = ref('')
const password = ref('')

function toggleMode() {
  mode.value = mode.value === 'login' ? 'register' : 'login'
  auth.error = null
}

async function onSubmit() {
  if (mode.value === 'login') {
    await auth.signIn(email.value.trim(), password.value)
  } else {
    await auth.signUp(email.value.trim(), password.value)
  }
  // El cambio de vista (a panel o a "cuenta creada") lo maneja AdminView según
  // isAdmin / isAuthenticated. Aquí solo limpiamos la contraseña.
  password.value = ''
}
</script>

<template>
  <div class="auth">
    <div class="auth__card">
      <p class="auth__eyebrow mono">Acceso interno</p>
      <h1 class="auth__title">
        {{ mode === 'login' ? 'Iniciar sesión' : 'Crear cuenta' }}
      </h1>
      <p class="auth__lead">
        Panel de administración del catálogo CalRod.
      </p>

      <form class="auth__form" @submit.prevent="onSubmit">
        <label class="field">
          <span class="field__label">Correo</span>
          <input
            v-model="email"
            type="email"
            class="field__input"
            autocomplete="email"
            required
            placeholder="tu@correo.com"
          />
        </label>

        <label class="field">
          <span class="field__label">Contraseña</span>
          <input
            v-model="password"
            type="password"
            class="field__input"
            :autocomplete="mode === 'login' ? 'current-password' : 'new-password'"
            required
            minlength="6"
            placeholder="Mínimo 6 caracteres"
          />
        </label>

        <p v-if="error" class="auth__error" role="alert">{{ error }}</p>

        <button type="submit" class="btn btn--primary" :disabled="loading">
          {{ loading ? 'Un momento…' : mode === 'login' ? 'Entrar' : 'Registrarme' }}
        </button>
      </form>

      <p class="auth__switch">
        {{ mode === 'login' ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?' }}
        <button type="button" class="auth__link" @click="toggleMode">
          {{ mode === 'login' ? 'Crear una' : 'Iniciar sesión' }}
        </button>
      </p>
    </div>
  </div>
</template>

<style scoped>
.auth {
  display: grid;
  place-items: center;
  padding-block: var(--space-6);
}

.auth__card {
  width: 100%;
  max-width: 420px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  padding: var(--space-6);
}

.auth__eyebrow {
  color: var(--blue-2);
  font-size: 0.75rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: var(--space-2);
}

.auth__title {
  font-size: 1.6rem;
  font-weight: 800;
  letter-spacing: -0.02em;
}

.auth__lead {
  color: var(--charcoal);
  font-size: 0.92rem;
  margin-block: var(--space-2) var(--space-5);
}

.auth__form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.field__label {
  font-size: 0.82rem;
  color: var(--charcoal);
  font-weight: 500;
}

.field__input {
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--cream);
  font-size: 0.95rem;
  padding: 0 var(--space-4);
  height: 44px;
  outline: none;
  transition: border-color 0.15s ease;
}

.field__input:focus {
  border-color: var(--blue);
}

.field__input::placeholder {
  color: var(--charcoal);
}

.auth__error {
  color: var(--danger);
  font-size: 0.85rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  height: 46px;
  transition: background 0.15s ease;
}

.btn--primary {
  background: var(--blue);
  color: #eceef2;
}

.btn--primary:hover:not(:disabled) {
  background: var(--blue-2);
}

.btn:disabled {
  opacity: 0.6;
  cursor: default;
}

.auth__switch {
  margin-top: var(--space-5);
  font-size: 0.88rem;
  color: var(--charcoal);
  text-align: center;
}

.auth__link {
  color: var(--blue-2);
  font-weight: 600;
  text-decoration: underline;
  text-underline-offset: 3px;
}
</style>
