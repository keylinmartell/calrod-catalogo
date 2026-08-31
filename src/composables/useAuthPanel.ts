import { ref } from 'vue'

/**
 * useAuthPanel — estado global del panel de acceso (login/registro).
 *
 * El botón "Acceder" del header, un guard de router o cualquier vista pueden
 * abrir el mismo panel deslizante. Estado compartido (módulo singleton), así
 * que todos los componentes ven el mismo `open`.
 */
export type AuthPanelMode = 'login' | 'register'

const open = ref(false)
const mode = ref<AuthPanelMode>('login')

export function useAuthPanel() {
  function openPanel(startMode: AuthPanelMode = 'login') {
    mode.value = startMode
    open.value = true
  }

  function closePanel() {
    open.value = false
  }

  return { open, mode, openPanel, closePanel }
}
