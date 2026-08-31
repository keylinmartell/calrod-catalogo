import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  // Falla temprano y claro: sin credenciales el catálogo no puede leer datos.
  console.error(
    '[CalRod] Faltan VITE_SUPABASE_URL o VITE_SUPABASE_ANON_KEY. ' +
      'Revisa tu .env.local (local) o las Environment Variables en Vercel.',
  )
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    // Guarda la sesión en localStorage y la refresca sola mientras el
    // refresh token siga vivo, así el usuario no pierde la sesión al recargar.
    persistSession: true,
    autoRefreshToken: true,
    // Necesario para recoger la sesión al volver del OAuth de Google (viene en la URL).
    detectSessionInUrl: true,
  },
})

// NOTA sobre "el token expira a las 24 horas":
// La duración del access token (JWT) NO se fija desde el cliente, sino en el
// dashboard de Supabase → Authentication → Settings → "Access token (JWT)
// expiry limit". Ponlo en 86400 (24 h). Con autoRefreshToken activado, el SDK
// renueva el token en segundo plano usando el refresh token, de modo que la
// sesión efectiva dura hasta que caduque el refresh token o se cierre sesión.
