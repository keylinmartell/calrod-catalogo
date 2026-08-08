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

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
