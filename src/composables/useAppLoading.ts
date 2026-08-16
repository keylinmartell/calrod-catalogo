import { ref } from 'vue'

/**
 * useAppLoading — pantalla de carga global de arranque.
 *
 * `booting` arranca en `true`: al abrir el enlace se muestra el overlay de carga
 * (llanta girando + "Cargando…") tapando toda la vista, en cualquier dispositivo.
 * La PRIMERA vista que se monta (sea catálogo, ficha, admin o 404) llama a
 * `finishBoot()` cuando TODOS sus endpoints críticos han respondido; ahí el
 * overlay se desvanece y aparece la vista.
 *
 * Es un flag de un solo sentido (se apaga una vez y no vuelve a encenderse), así
 * que las navegaciones posteriores del lado cliente NO vuelven a mostrarlo —
 * esas ya tienen sus propios estados de carga dentro de la vista.
 */
const booting = ref(true)

export function useAppLoading() {
  function finishBoot() {
    booting.value = false
  }

  return { booting, finishBoot }
}
