import { defineStore } from 'pinia'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/services/supabase'
import type { Profile } from '@/types/part'

interface AuthState {
  session: Session | null
  profile: Profile | null
  loading: boolean
  error: string | null
  ready: boolean
}

// Traduce los errores de Supabase Auth a mensajes que el cliente entienda.
function humanError(message: string): string {
  const m = message.toLowerCase()
  if (m.includes('invalid login credentials')) return 'Correo o contraseña incorrectos.'
  if (m.includes('already registered')) return 'Ese correo ya está registrado. Inicia sesión.'
  if (m.includes('password')) return 'La contraseña debe tener al menos 6 caracteres.'
  if (m.includes('email')) return 'Revisa el correo: no parece válido.'
  return 'No pudimos completar la operación. Intenta de nuevo.'
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    session: null,
    profile: null,
    loading: false,
    error: null,
    ready: false,
  }),

  getters: {
    isAuthenticated: (state) => state.session !== null,
    isAdmin: (state) => state.profile?.role === 'admin',
  },

  actions: {
    /**
     * init — se llama una vez al arrancar el panel. Lee la sesión guardada y se
     * suscribe a los cambios de auth para mantener session/profile al día.
     */
    async init() {
      if (this.ready) return
      const { data } = await supabase.auth.getSession()
      this.session = data.session
      if (this.session) await this.loadProfile()

      supabase.auth.onAuthStateChange((_event, session) => {
        this.session = session
        if (session) this.loadProfile()
        else this.profile = null
      })

      this.ready = true
    },

    async loadProfile() {
      const uid = this.session?.user.id
      if (!uid) {
        this.profile = null
        return
      }
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', uid)
        .maybeSingle()

      if (error) {
        console.error('[CalRod] loadProfile:', error)
        this.profile = null
        return
      }
      this.profile = (data as Profile) ?? null
    },

    async signIn(email: string, password: string): Promise<boolean> {
      this.loading = true
      this.error = null
      try {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
        await this.loadProfile()
        return true
      } catch (e) {
        this.error = humanError((e as Error).message)
        console.error('[CalRod] signIn:', e)
        return false
      } finally {
        this.loading = false
      }
    },

    async signUp(email: string, password: string): Promise<boolean> {
      this.loading = true
      this.error = null
      try {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        // Con la confirmación de correo desactivada, signUp deja sesión activa.
        // El trigger on_auth_user_created ya creó el profile con rol 'user'.
        await this.loadProfile()
        return true
      } catch (e) {
        this.error = humanError((e as Error).message)
        console.error('[CalRod] signUp:', e)
        return false
      } finally {
        this.loading = false
      }
    },

    async signOut() {
      await supabase.auth.signOut()
      this.session = null
      this.profile = null
    },
  },
})
