import { ref } from 'vue'

export type Theme = 'dark' | 'light'

const STORAGE_KEY = 'calrod-theme'

// Estado compartido entre todos los componentes que usen el composable.
// Default: 'dark' (la web arranca oscura siempre que no haya preferencia guardada).
const theme = ref<Theme>('dark')

function apply(t: Theme) {
  // El oscuro no necesita atributo (es el :root por defecto); el claro sí.
  const el = document.documentElement
  if (t === 'light') el.setAttribute('data-theme', 'light')
  else el.removeAttribute('data-theme')
}

/**
 * useTheme — modo claro/oscuro con persistencia en localStorage.
 * Se inicializa una sola vez (initTheme) al arrancar la app.
 */
export function useTheme() {
  function setTheme(t: Theme) {
    theme.value = t
    apply(t)
    try {
      localStorage.setItem(STORAGE_KEY, t)
    } catch {
      // localStorage puede fallar (modo privado); el tema igual aplica en memoria.
    }
  }

  function toggleTheme() {
    setTheme(theme.value === 'dark' ? 'light' : 'dark')
  }

  function initTheme() {
    let saved: string | null = null
    try {
      saved = localStorage.getItem(STORAGE_KEY)
    } catch {
      saved = null
    }
    // Solo respetamos una elección explícita previa. Sin ella → oscuro (default),
    // ignorando prefers-color-scheme para cumplir "por defecto oscuro".
    setTheme(saved === 'light' ? 'light' : 'dark')
  }

  return { theme, setTheme, toggleTheme, initTheme }
}
