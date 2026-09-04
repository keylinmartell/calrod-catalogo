import { computed, effectScope, ref, watch } from 'vue'
import { supabase } from '@/services/supabase'
import { useAuthStore } from '@/stores/authStore'
import {
  favoriteVehicleKey,
  toFavoriteVehicle,
  type FavoriteVehicle,
  type UserVehicle,
} from '@/types/part'

/**
 * useFavoriteVehicles — los autos favoritos del cliente ("Mis autos").
 *
 * Un favorito es marca + (modelo | motor) opcionales, lo mismo que la
 * compatibilidad sabe expresar desde 0019: guardarlo una vez ahorra rearmar el
 * filtro marca → modelo → motor en cada visita.
 *
 * DÓNDE SE GUARDA. Con sesión, en `user_vehicles` (0017/0021), que lleva RLS por
 * usuario y por tanto lo sigue entre dispositivos. Sin sesión, en localStorage:
 * la mayoría de quien entra a un catálogo de repuestos no se registra, y obligar
 * a crear cuenta para marcar un auto rompería el flujo. Al iniciar sesión los
 * favoritos locales se suben a la cuenta y el navegador deja de guardarlos.
 *
 * QUIÉN MANDA EN LA UI. La única prueba de que un auto llegó a la BD es que su
 * fila exista, o sea `id !== null`. Tener sesión NO alcanza: el insert puede
 * fallar (RLS, migración a medias, red caída) y el auto acaba en el navegador.
 * Por eso la vista lee `storage`, derivado de los datos, y no `isAuthenticated`.
 *
 * Estado a nivel de módulo (singleton): el sidebar se monta dos veces — columna
 * de escritorio y drawer de móvil — y las dos copias tienen que ver la misma lista.
 */

const STORAGE_KEY = 'calrod:autos-favoritos'

// Trae la marca (para el nombre) y, cuando existen, modelo y motor.
const FAVORITE_SELECT =
  '*, vehicle_brands(*), vehicle_models(*, vehicle_brands(*)), vehicle_motors(*)'

/**
 * Lo que se pide de vuelta al insertar: solo columnas propias, sin embeds. Los
 * nombres ya vienen del nomenclador que está en pantalla, así que el embed no
 * aporta nada aquí y sí añade una forma de que el POST falle (caché de esquema
 * de PostgREST). Antes se reintentaba el INSERT cuando el select con embeds
 * fallaba, y ese reintento chocaba contra `idx_user_vehicles_unique_v2`: la fila
 * quedaba en la BD pero la app la daba por perdida y la escribía en localStorage.
 */
const INSERT_RETURNING = 'id, vehicle_brand_id, vehicle_model_id, motor_id'

const favorites = ref<FavoriteVehicle[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
/** La última carga con sesión llegó a leer `user_vehicles` sin error. */
const dbReady = ref(false)

/** Evita que cada componente que monta el sidebar dispare su propia carga. */
let loadStarted = false
/**
 * Ámbito propio para el watcher de la sesión. Detached a propósito: si se creara
 * dentro del setup del primer componente que lo pide, al desmontarse ese
 * componente (el sidebar se monta y desmonta con el drawer de móvil) el watcher
 * moriría con él y los cambios de sesión dejarían de recargar la lista.
 */
let sessionScope: ReturnType<typeof effectScope> | null = null

/**
 * De dónde salen los autos que se están viendo, para que la UI diga la verdad:
 * 'db' todos en la cuenta, 'local' ninguno, 'mixed' unos sí y otros no (lo típico
 * cuando la subida al iniciar sesión falló a medias).
 */
const storage = computed<'db' | 'local' | 'mixed'>(() => {
  if (!favorites.value.length) return dbReady.value ? 'db' : 'local'
  const inDb = favorites.value.filter((f) => f.id).length
  if (inDb === favorites.value.length) return 'db'
  return inDb ? 'mixed' : 'local'
})

/** 23505: choca con `idx_user_vehicles_unique_v2`, o sea ya estaba en la cuenta. */
function isDuplicate(e: unknown): boolean {
  return (e as { code?: string } | null)?.code === '23505'
}

// ── localStorage ────────────────────────────────────────────────────────────

function readLocal(): FavoriteVehicle[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return []
    const parsed = JSON.parse(raw) as unknown
    if (!Array.isArray(parsed)) return []
    // Filtramos lo que no tenga marca: sin ella el favorito no describe nada y
    // no se podría ni pintar ni convertir en filtro.
    return parsed
      .filter((f): f is FavoriteVehicle => !!f && typeof f === 'object' && !!(f as FavoriteVehicle).brandId)
      .map((f) => ({
        id: null,
        brandId: f.brandId,
        brandName: f.brandName ?? '',
        modelId: f.modelId ?? null,
        modelName: f.modelName ?? '',
        motorId: f.motorId ?? null,
        motorName: f.motorName ?? '',
      }))
  } catch {
    // localStorage bloqueado o JSON corrupto: se sigue sin favoritos locales.
    return []
  }
}

function writeLocal(list: FavoriteVehicle[]) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list))
  } catch {
    /* modo privado o cuota llena: el favorito vive solo en esta sesión */
  }
}

/** Los autos sin fila propia son los únicos que el navegador tiene que guardar. */
function persistLocalPart(list: FavoriteVehicle[]) {
  writeLocal(list.filter((f) => !f.id))
}

// ── Supabase ────────────────────────────────────────────────────────────────

async function resolveUserId(): Promise<string | null> {
  const auth = useAuthStore()
  if (auth.session?.user?.id) return auth.session.user.id

  try {
    const { data } = await supabase.auth.getSession()
    if (data.session?.user?.id) {
      if (!auth.session) {
        auth.session = data.session
        void auth.loadProfile()
      }
      return data.session.user.id
    }
  } catch (e) {
    console.warn('[CalRod] resolveUserId error:', e)
  }
  return null
}

async function fetchFromDb(): Promise<FavoriteVehicle[]> {
  const { data, error: err } = await supabase
    .from('user_vehicles')
    .select(FAVORITE_SELECT)
    .order('created_at', { ascending: true })
  if (err) throw err
  // Mismo caso que PART_SELECT en useParts: con embeds anidados supabase-js no
  // infiere la forma, así que el contrato lo fija FAVORITE_SELECT + UserVehicle.
  return ((data ?? []) as unknown as UserVehicle[]).map(toFavoriteVehicle)
}

/**
 * Un único INSERT, sin embeds. Empareja cada fila devuelta con su candidato por
 * clave y no por posición, para no depender del orden en que responda PostgREST.
 */
async function insertInDb(
  userId: string,
  items: FavoriteVehicle[],
): Promise<FavoriteVehicle[]> {
  const payload = items.map((f) => ({
    user_id: userId,
    vehicle_brand_id: f.brandId,
    vehicle_model_id: f.modelId,
    motor_id: f.motorId,
  }))

  const { data, error: err } = await supabase
    .from('user_vehicles')
    .insert(payload)
    .select(INSERT_RETURNING)

  if (err) throw err

  const byKey = new Map(items.map((f) => [favoriteVehicleKey(f), f]))
  return (data ?? []).map((row) => {
    const src = byKey.get(
      favoriteVehicleKey({
        brandId: row.vehicle_brand_id,
        modelId: row.vehicle_model_id ?? null,
        motorId: row.motor_id ?? null,
      }),
    )
    return {
      id: row.id,
      brandId: row.vehicle_brand_id,
      brandName: src?.brandName ?? '',
      modelId: row.vehicle_model_id ?? null,
      modelName: src?.modelName ?? '',
      motorId: row.motor_id ?? null,
      motorName: src?.motorName ?? '',
    }
  })
}

export function useFavoriteVehicles() {
  const auth = useAuthStore()

  /**
   * Carga la lista según haya sesión o no. Con sesión, además sube a la cuenta
   * los favoritos que se hubieran marcado antes de entrar (sin duplicar los que
   * ya estaban). El navegador solo se limpia de lo que sí llegó a la cuenta: si
   * la subida falla, esos autos siguen en localStorage y a la vista, en lugar de
   * desaparecer sin que nadie se entere.
   */
  async function load() {
    loading.value = true
    error.value = null
    try {
      const userId = await resolveUserId()
      if (!userId) {
        dbReady.value = false
        favorites.value = readLocal()
        return
      }

      try {
        const list = await fetchFromDb()
        dbReady.value = true

        const known = new Set(list.map(favoriteVehicleKey))
        const pending = readLocal().filter((f) => !known.has(favoriteVehicleKey(f)))

        let uploaded: FavoriteVehicle[] = []
        let stuck: FavoriteVehicle[] = []
        if (pending.length) {
          try {
            uploaded = await insertInDb(userId, pending)
          } catch (insertErr) {
            stuck = pending
            error.value =
              'No pudimos subir a tu cuenta los autos guardados en este navegador. Siguen aquí; inténtalo de nuevo más tarde.'
            console.warn('[CalRod] No se pudieron sincronizar pendientes a BD:', insertErr)
          }
        }

        favorites.value = [...list, ...uploaded, ...stuck]
        writeLocal(stuck)
      } catch (dbErr) {
        dbReady.value = false
        console.warn('[CalRod] BD user_vehicles no disponible o requiere migración 0021:', dbErr)
        error.value =
          'No pudimos leer los autos de tu cuenta. Se están mostrando los de este navegador.'
        favorites.value = readLocal()
      }
    } catch (e) {
      dbReady.value = false
      favorites.value = readLocal()
      console.error('[CalRod] favoritos load:', e)
    } finally {
      loading.value = false
    }
  }

  /** Primera carga (una sola por sesión de app) + reacción a login/logout. */
  function ensureLoaded() {
    if (!loadStarted) {
      loadStarted = true
      void load()
    }
    if (!sessionScope) {
      sessionScope = effectScope(true)
      sessionScope.run(() => {
        // Al entrar, los favoritos locales pasan a la cuenta; al salir, la lista
        // vuelve a ser la del navegador (los de la cuenta no se quedan a la vista).
        watch(
          () => auth.session?.user.id ?? null,
          () => void load(),
        )
      })
    }
  }

  function isFavorite(f: {
    brandId: string
    modelId: string | null
    motorId: string | null
  }): boolean {
    const key = favoriteVehicleKey(f)
    return favorites.value.some((x) => favoriteVehicleKey(x) === key)
  }

  /** Marca un auto. Si ya estaba, no hace nada (el UNIQUE de 0021 lo respalda). */
  async function add(f: Omit<FavoriteVehicle, 'id'>): Promise<void> {
    if (!f.brandId || isFavorite(f)) return
    error.value = null
    const userId = await resolveUserId()

    if (!userId) {
      console.info(
        '[CalRod] Modo invitado: guardando favorito en localStorage del navegador. Inicia sesión para guardarlo en tu cuenta de BD.',
      )
      const list = [...favorites.value, { ...f, id: null }]
      favorites.value = list
      persistLocalPart(list)
      return
    }

    try {
      const [row] = await insertInDb(userId, [{ ...f, id: null }])
      if (!row) {
        // Sin fila de vuelta: la cuenta es la fuente, así que se relee en lugar
        // de inventar un favorito local que en realidad ya quedó guardado.
        await load()
        return
      }
      favorites.value = [...favorites.value, row]
      dbReady.value = true
    } catch (e) {
      if (isDuplicate(e)) {
        // Ya estaba en la cuenta (otro dispositivo, u otra pestaña en paralelo).
        await load()
        return
      }
      console.warn('[CalRod] favoritos add en BD falló (guardando en local):', e)
      error.value =
        'No pudimos guardar el auto en tu cuenta. Quedó guardado solo en este navegador.'
      const list = [...favorites.value, { ...f, id: null }]
      favorites.value = list
      persistLocalPart(list)
    }
  }

  /** Quita un auto de favoritos (de la cuenta si vive ahí, del navegador si no). */
  async function remove(f: FavoriteVehicle): Promise<void> {
    error.value = null
    const key = favoriteVehicleKey(f)
    const userId = await resolveUserId()

    if (f.id && userId) {
      const { error: err } = await supabase
        .from('user_vehicles')
        .delete()
        .eq('id', f.id)
      if (err) {
        // Si la fila sigue en la BD, sacarla de la vista solo la haría reaparecer
        // al recargar: mejor decirlo y dejar el auto donde está.
        console.warn('[CalRod] favoritos remove en BD falló:', err)
        error.value = 'No pudimos quitar el auto de tu cuenta. Inténtalo de nuevo.'
        return
      }
    }

    const list = favorites.value.filter((x) => favoriteVehicleKey(x) !== key)
    favorites.value = list
    persistLocalPart(list)
  }

  /** Alterna: marca el auto si no estaba, lo quita si ya era favorito. */
  async function toggle(f: Omit<FavoriteVehicle, 'id'>): Promise<void> {
    const key = favoriteVehicleKey(f)
    const existing = favorites.value.find((x) => favoriteVehicleKey(x) === key)
    if (existing) await remove(existing)
    else await add(f)
  }

  return {
    favorites,
    loading,
    error,
    storage,
    ensureLoaded,
    load,
    isFavorite,
    add,
    remove,
    toggle,
  }
}
