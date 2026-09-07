<script setup lang="ts">
/**
 * AuthPanel — panel de acceso deslizante (estilo Platzi).
 *
 * Se abre desde el header ("Acceder") y flota sobre la vista actual como un
 * cajón lateral a la derecha, con un backdrop translúcido detrás. Login y
 * registro en un solo paso; el registro añade "Confirmar contraseña".
 * Al autenticarse con éxito se cierra solo (watch sobre isAuthenticated).
 */
import { ref, computed, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { useAuthPanel } from '@/composables/useAuthPanel'

const auth = useAuthStore()
const { loading, error, isAuthenticated } = storeToRefs(auth)
const { open, mode, closePanel } = useAuthPanel()

const email = ref('')
const password = ref('')
const confirm = ref('')

// Mostrar/ocultar contraseña (el "ojito"). Un toggle por campo.
const showPassword = ref(false)
const showConfirm = ref(false)

// Error de validación local (no viene del store): p. ej. contraseñas distintas.
const localError = ref<string | null>(null)
const shownError = computed(() => localError.value ?? error.value)

const title = computed(() =>
  mode.value === 'login' ? 'Ingresa a tu cuenta' : 'Crea tu cuenta',
)

function switchMode() {
  mode.value = mode.value === 'login' ? 'register' : 'login'
  auth.error = null
  localError.value = null
  confirm.value = ''
}

async function onSubmit() {
  localError.value = null
  if (mode.value === 'register' && password.value !== confirm.value) {
    localError.value = 'Las contraseñas no coinciden.'
    return
  }
  const ok =
    mode.value === 'login'
      ? await auth.signIn(email.value.trim(), password.value)
      : await auth.signUp(email.value.trim(), password.value)
  password.value = ''
  confirm.value = ''
  // El cierre real lo dispara el watch de isAuthenticated; esto solo cubre el
  // caso de que ya estuviera autenticado (defensa extra, sin efecto normal).
  if (ok && isAuthenticated.value) closePanel()
}

// Al lograr sesión, cerramos el panel y reseteamos el formulario.
watch(isAuthenticated, (authed) => {
  if (authed && open.value) {
    closePanel()
    email.value = ''
    password.value = ''
    confirm.value = ''
    localError.value = null
  }
})

// Cerrar con Escape mientras el panel está abierto.
function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') closePanel()
}
watch(open, (isOpen) => {
  document.body.style.overflow = isOpen ? 'hidden' : ''
  if (isOpen) {
    auth.error = null
    localError.value = null
    window.addEventListener('keydown', onKeydown)
  } else {
    window.removeEventListener('keydown', onKeydown)
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="auth-backdrop">
      <div
        v-if="open"
        class="auth-backdrop"
        @click.self="closePanel"
      >
        <Transition name="auth-drawer">
          <aside
            v-if="open"
            class="auth-drawer"
            role="dialog"
            aria-modal="true"
            :aria-label="title"
          >
            <button
              type="button"
              class="auth-drawer__close"
              aria-label="Cerrar"
              @click="closePanel"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>

            <div class="auth-drawer__head">
              <img class="auth-drawer__logo" src="/logo-new.png" alt="Repuestos CalRod" />
            </div>

            <h2 class="auth-drawer__title">{{ title }}</h2>

            <p class="auth-drawer__switch">
              <template v-if="mode === 'login'">
                ¿Primera vez en CalRod?
                <button type="button" class="auth-drawer__link" @click="switchMode">Regístrate</button>
              </template>
              <template v-else>
                ¿Ya tienes cuenta?
                <button type="button" class="auth-drawer__link" @click="switchMode">Inicia sesión</button>
              </template>
            </p>

            <form class="auth-drawer__form" @submit.prevent="onSubmit">
              <label class="auth-field">
                <span class="auth-field__icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="5" width="18" height="14" rx="2" />
                    <path d="m3 7 9 6 9-6" />
                  </svg>
                </span>
                <input
                  v-model="email"
                  type="email"
                  class="auth-input"
                  autocomplete="email"
                  required
                  placeholder="Correo electrónico"
                />
              </label>

              <label class="auth-field">
                <span class="auth-field__icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="4" y="10" width="16" height="11" rx="2" />
                    <path d="M8 10V7a4 4 0 0 1 8 0v3" />
                  </svg>
                </span>
                <input
                  v-model="password"
                  :type="showPassword ? 'text' : 'password'"
                  class="auth-input auth-input--with-toggle"
                  :autocomplete="mode === 'login' ? 'current-password' : 'new-password'"
                  required
                  minlength="6"
                  placeholder="Contraseña"
                />
                <button
                  type="button"
                  class="auth-field__toggle"
                  :aria-label="showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'"
                  :aria-pressed="showPassword"
                  @click="showPassword = !showPassword"
                >
                  <svg v-if="showPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7Z" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M2 12s3.6-7 10-7c1.5 0 2.9.4 4.1 1M22 12s-3.6 7-10 7c-1.5 0-2.9-.4-4.1-1" />
                    <path d="M9.5 9.5a3 3 0 0 0 4.2 4.2" />
                    <path d="M3 3l18 18" />
                  </svg>
                </button>
              </label>

              <label v-if="mode === 'register'" class="auth-field">
                <span class="auth-field__icon" aria-hidden="true">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="4" y="10" width="16" height="11" rx="2" />
                    <path d="M8 10V7a4 4 0 0 1 8 0v3" />
                    <path d="m9 15 2 2 4-4" />
                  </svg>
                </span>
                <input
                  v-model="confirm"
                  :type="showConfirm ? 'text' : 'password'"
                  class="auth-input auth-input--with-toggle"
                  autocomplete="new-password"
                  required
                  minlength="6"
                  placeholder="Confirmar contraseña"
                />
                <button
                  type="button"
                  class="auth-field__toggle"
                  :aria-label="showConfirm ? 'Ocultar contraseña' : 'Mostrar contraseña'"
                  :aria-pressed="showConfirm"
                  @click="showConfirm = !showConfirm"
                >
                  <svg v-if="showConfirm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7Z" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M2 12s3.6-7 10-7c1.5 0 2.9.4 4.1 1M22 12s-3.6 7-10 7c-1.5 0-2.9-.4-4.1-1" />
                    <path d="M9.5 9.5a3 3 0 0 0 4.2 4.2" />
                    <path d="M3 3l18 18" />
                  </svg>
                </button>
              </label>

              <p v-if="shownError" class="auth-drawer__error" role="alert">{{ shownError }}</p>

              <button type="submit" class="auth-btn auth-btn--primary" :disabled="loading">
                {{ loading ? 'Un momento…' : mode === 'login' ? 'Continuar' : 'Crear cuenta' }}
              </button>
            </form>

            <div class="auth-drawer__divider"><span>O bien</span></div>

            <button
              type="button"
              class="auth-btn auth-btn--google"
              :disabled="loading"
              @click="auth.signInWithGoogle()"
            >
              <svg class="auth-btn__gicon" viewBox="0 0 24 24" aria-hidden="true">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1Z" />
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.99.66-2.26 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0 0 12 23Z" />
                <path fill="#FBBC05" d="M5.84 14.1a6.6 6.6 0 0 1 0-4.2V7.06H2.18a11 11 0 0 0 0 9.88l3.66-2.84Z" />
                <path fill="#EA4335" d="M12 4.75c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 1.46 14.97.5 12 .5A11 11 0 0 0 2.18 7.06L5.84 9.9C6.71 7.3 9.14 4.75 12 4.75Z" />
              </svg>
              Continuar con Google
            </button>

            <p class="auth-drawer__legal">
              Al continuar, aceptas los
              <RouterLink to="/terminos" class="auth-drawer__legal-link" @click="closePanel">Términos</RouterLink>
              y las
              <RouterLink to="/privacidad" class="auth-drawer__legal-link" @click="closePanel">Políticas de privacidad</RouterLink>.
            </p>
          </aside>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.auth-backdrop {
  position: fixed;
  inset: 0;
  z-index: 100010;
  display: flex;
  justify-content: flex-end;
  background: var(--overlay);
  backdrop-filter: blur(4px);
}

.auth-drawer {
  position: relative;
  width: min(420px, 100%);
  height: 100%;
  overflow-y: auto;
  background:
    radial-gradient(ellipse 520px 360px at 100% 0%, rgba(74, 123, 184, 0.12), transparent 65%),
    radial-gradient(ellipse 460px 320px at 0% 100%, rgba(226, 112, 58, 0.06), transparent 60%),
    var(--surface);
  border-left: 1px solid var(--border);
  box-shadow: -8px 0 40px rgba(0, 0, 0, 0.5);
  padding: var(--space-6) var(--space-6) var(--space-7);
  display: flex;
  flex-direction: column;
}

.auth-drawer__close {
  position: absolute;
  top: var(--space-4);
  right: var(--space-4);
  width: 40px;
  height: 40px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  color: var(--charcoal);
  transition: background 0.15s ease, color 0.15s ease;
}

.auth-drawer__close:hover {
  background: var(--surface-2);
  color: var(--cream);
}

.auth-drawer__close svg {
  width: 20px;
  height: 20px;
}

/* Logo: contenido en su propia caja centrada. Crece visualmente (height alto)
   pero los márgenes negativos verticales colapsan su huella de layout, así el
   logo se ve grande sin empujar el título ni el resto del formulario. */
.auth-drawer__head {
  display: flex;
  justify-content: center;
  margin-top: var(--space-4);
  margin-bottom: var(--space-2);
  overflow: visible;
}

.auth-drawer__logo {
  height: 300px;
  width: auto;
  object-fit: contain;
  margin-block: -66px;
}

.auth-drawer__title {
  font-size: 1.6rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--cream);
  text-align: center;
}

.auth-drawer__switch {
  font-size: 0.9rem;
  color: var(--charcoal);
  text-align: center;
  margin-top: var(--space-2);
  margin-bottom: var(--space-5);
}

.auth-drawer__link {
  color: var(--blue-2);
  font-weight: 600;
  text-decoration: underline;
  text-underline-offset: 3px;
}

.auth-drawer__form {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

/* Campo con icono a la izquierda. El input rellena la caja y deja hueco
   para el icono con padding-left. */
.auth-field {
  position: relative;
  display: block;
}

.auth-field__icon {
  position: absolute;
  left: var(--space-4);
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: var(--charcoal);
  pointer-events: none;
}

.auth-field__icon svg {
  width: 100%;
  height: 100%;
}

.auth-input {
  width: 100%;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--cream);
  font-size: 0.95rem;
  padding: 0 var(--space-4) 0 calc(var(--space-4) + 26px);
  height: 52px;
  outline: none;
  transition: border-color 0.15s ease, box-shadow 0.15s ease;
}

.auth-input:focus {
  border-color: var(--blue-2);
  box-shadow: 0 0 0 3px rgba(74, 123, 184, 0.18);
}

.auth-field:focus-within .auth-field__icon {
  color: var(--blue-2);
}

.auth-input::placeholder {
  color: var(--charcoal);
}

/* Autofill del navegador: Chrome/Safari pintan el campo autocompletado de
   amarillo. Forzamos el fondo y el color de la marca. El truco del box-shadow
   interior tapa el amarillo (no se puede sobreescribir background directo), y
   la transición larga evita que el amarillo asome un instante al enfocar. */
.auth-input:-webkit-autofill,
.auth-input:-webkit-autofill:hover,
.auth-input:-webkit-autofill:focus,
.auth-input:-webkit-autofill:active {
  -webkit-text-fill-color: var(--cream);
  -webkit-box-shadow: 0 0 0 1000px var(--surface-2) inset;
  box-shadow: 0 0 0 1000px var(--surface-2) inset;
  caret-color: var(--cream);
  transition: background-color 9999s ease-in-out 0s;
}

/* Cuando hay ojito, deja hueco a la derecha para que el texto no lo pise. */
.auth-input--with-toggle {
  padding-right: calc(var(--space-4) + 30px);
}

/* Botón "ojito": muestra/oculta la contraseña. */
.auth-field__toggle {
  position: absolute;
  right: calc(var(--space-4) - 6px);
  top: 50%;
  transform: translateY(-50%);
  width: 34px;
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  color: var(--charcoal);
  transition: color 0.15s ease, background 0.15s ease;
}

.auth-field__toggle:hover {
  color: var(--cream);
  background: var(--surface);
}

.auth-field__toggle svg {
  width: 19px;
  height: 19px;
}

.auth-drawer__error {
  color: var(--danger);
  font-size: 0.85rem;
}

.auth-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  height: 50px;
  border-radius: var(--radius);
  font-weight: 600;
  font-size: 0.95rem;
  transition: background 0.15s ease, border-color 0.15s ease;
}

.auth-btn:disabled {
  opacity: 0.6;
  cursor: default;
}

.auth-btn--primary {
  background: linear-gradient(135deg, var(--blue) 0%, var(--blue-2) 100%);
  color: #eceef2;
  margin-top: var(--space-2);
  box-shadow: 0 6px 18px rgba(26, 61, 110, 0.4);
}

.auth-btn--primary:hover:not(:disabled) {
  filter: brightness(1.08);
}

.auth-drawer__divider {
  display: flex;
  align-items: center;
  text-align: center;
  color: var(--charcoal);
  font-size: 0.82rem;
  margin-block: var(--space-5);
}

.auth-drawer__divider::before,
.auth-drawer__divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--border);
}

.auth-drawer__divider span {
  padding-inline: var(--space-3);
}

.auth-btn--google {
  width: 100%;
  background: var(--surface-2);
  border: 1px solid var(--border-strong);
  color: var(--cream);
}

.auth-btn--google:hover:not(:disabled) {
  border-color: var(--blue-2);
}

.auth-btn__gicon {
  width: 18px;
  height: 18px;
}

.auth-drawer__legal {
  margin-top: var(--space-6);
  text-align: center;
  font-size: 0.78rem;
  color: var(--text-faint);
  line-height: 1.5;
}

.auth-drawer__legal-link {
  color: var(--blue-2);
  text-decoration: underline;
  text-underline-offset: 2px;
}

.auth-drawer__legal-link:hover {
  filter: brightness(1.15);
}

/* ── Transiciones ────────────────────────────────────────────────────────── */
.auth-backdrop-enter-active,
.auth-backdrop-leave-active {
  transition: opacity 0.25s ease;
}
.auth-backdrop-enter-from,
.auth-backdrop-leave-to {
  opacity: 0;
}

.auth-drawer-enter-active,
.auth-drawer-leave-active {
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1);
}
.auth-drawer-enter-from,
.auth-drawer-leave-to {
  transform: translateX(100%);
}

@media (max-width: 520px) {
  .auth-drawer {
    width: 100%;
    border-left: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .auth-drawer-enter-active,
  .auth-drawer-leave-active,
  .auth-backdrop-enter-active,
  .auth-backdrop-leave-active {
    transition: none;
  }
}
</style>
