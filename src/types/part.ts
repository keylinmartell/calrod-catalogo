export type OriginType = 'original' | 'alternativa' | 'remanufacturada'

export type Availability = 'disponible' | 'stock_bajo' | 'agotado'

export interface Category {
  id: string
  name: string
  slug: string
  created_at?: string
}

/** Marca de la pieza (STP, Wurtex, …). Tabla propia, FK parts.brand_id (0012). */
export interface Brand {
  id: string
  name: string
  slug: string
  created_at?: string
}

/**
 * Marca de AUTO (Toyota, Geely, …) — el nomenclador que administra el panel
 * (0013). No confundir con Brand: esa es la marca de la refacción. Es la raíz de
 * la jerarquía del vehículo: marca → modelo → motor (0016).
 */
export interface VehicleBrand {
  id: string
  name: string
  slug: string
  created_at?: string
}

/**
 * Modelo de auto (Corolla, Sentra, …) — pertenece a una marca (0016). El slug es
 * único DENTRO de la marca, no globalmente.
 */
export interface VehicleModel {
  id: string
  vehicle_brand_id: string
  name: string
  slug: string
  created_at?: string
  /** Marca embebida por la FK cuando el select la pide. */
  vehicle_brands?: VehicleBrand | null
}

/**
 * Motor de un modelo ("1.8L", "2.0 TDI") — pertenece a un modelo (0016). No toda
 * pieza depende del motor, así que la compatibilidad lo referencia opcionalmente.
 */
export interface VehicleMotor {
  id: string
  vehicle_brand_id?: string | null
  vehicle_model_id?: string | null
  name: string
  slug: string
  created_at?: string
  vehicle_brands?: VehicleBrand | null
  vehicle_models?: VehicleModel | null
}


export interface PartSpec {
  id: number
  part_id: string
  label: string
  value: string
}

/**
 * Una fila de compatibilidad: "esta pieza sirve para este vehículo (marca, modelo
 * opcional, motor opcional), entre estos años".
 */
export interface PartCompatibility {
  id: number
  part_id: string
  /** FK a marcas de auto (0019). */
  vehicle_brand_id?: string | null
  /** FK al nomenclador de modelos (0016/0019 opcional). */
  vehicle_model_id: string | null
  /** Motor OPCIONAL (0016/0019). null = aplica sin importar el motor. */
  motor_id: string | null
  year_from: number | null
  year_to: number | null
  /** Marca embebida por la FK directa o a través del modelo. */
  vehicle_brands?: VehicleBrand | null
  /** Modelo embebido por la FK (cuando se especificó modelo). */
  vehicle_models?: VehicleModel | null
  /** Motor embebido por la FK. */
  vehicle_motors?: VehicleMotor | null
}

/**
 * Los tres nombres de una fila de compatibilidad. Un solo lugar sabe cómo vienen
 * anidados por las FK, para que la UI no repita el `?.name ?? ''` en cada
 * plantilla.
 */
export function vehicleBrandName(compat: {
  vehicle_brands?: VehicleBrand | null
  vehicle_models?: VehicleModel | null
  vehicle_motors?: VehicleMotor | null
}): string {
  return (
    compat.vehicle_brands?.name ??
    compat.vehicle_models?.vehicle_brands?.name ??
    compat.vehicle_motors?.vehicle_brands?.name ??
    ''
  )
}

export function vehicleModelName(compat: {
  vehicle_models?: VehicleModel | null
}): string {
  return compat.vehicle_models?.name ?? ''
}

export function motorName(compat: {
  vehicle_motors?: VehicleMotor | null
}): string {
  return compat.vehicle_motors?.name ?? ''
}


export interface Part {
  id: string
  /**
   * Código / SKU OPCIONAL (0015). null = la pieza no tiene número de parte. El
   * UNIQUE sigue vigente para las que sí lo tienen (en Postgres cada NULL cuenta
   * como distinto, así que varias piezas pueden quedarse sin código).
   */
  code: string | null
  name: string

  category_id: string | null
  brand_id: string | null
  origin_type: OriginType
  price: number
  availability: Availability
  description: string | null
  material: string | null
  image_url: string | null
  /**
   * Oferta (opcionales, columnas 0008 → 0010). Si vienen null/undefined la pieza
   * se muestra sin sticker de ahorro ni cinta de "mejor oferta".
   *  - discount_amount: monto FIJO de descuento en USD (>0). `price` es el precio
   *    NORMAL; el precio final mostrado es `price - discount_amount`.
   *  - is_best_deal: marca manual para la cinta "MEJOR OFERTA".
   */
  discount_amount?: number | null
  is_best_deal?: boolean | null
  /**
   * Precio MAYORISTA (0014). `wholesale_price` es el precio POR UNIDAD al llevar
   * `wholesale_min_qty` piezas o más; null = la pieza no tiene precio mayorista.
   * `wholesale_min_qty` trae 5 por defecto desde la BD y se edita por pieza.
   */
  wholesale_price?: number | null
  wholesale_min_qty?: number | null
  /**
   * Unidades EN EXISTENCIA (0018). Es el número; `availability` sigue siendo la
   * etiqueta que pinta el catálogo. Las dos se editan a mano por separado: no hay
   * regla que derive una de la otra (el umbral de "stock bajo" depende del tipo
   * de pieza). La columna es NOT NULL con default 0 en la BD.
   */
  stock_qty?: number | null
  created_at: string
  categories?: Category | null
  brands?: Brand | null
  part_specs?: PartSpec[]
  part_compatibility?: PartCompatibility[]
  /**
   * Galería de fotos (0020), ordenada por `sort_order`. No la piden el catálogo
   * ni el panel: solo la ficha de detalle, que es la única que muestra más de
   * una. Usa `partGallery()` en vez de leerla directo — sabe combinarla con
   * `image_url` para las piezas que todavía no se han vuelto a guardar.
   */
  part_images?: PartImage[]
}

export const AVAILABILITY_LABELS: Record<Availability, string> = {
  disponible: 'Disponible',
  stock_bajo: 'Stock bajo',
  agotado: 'Agotado',
}

export const ORIGIN_LABELS: Record<OriginType, string> = {
  original: 'Original',
  alternativa: 'Alternativa',
  remanufacturada: 'Remanufacturada',
}

/**
 * Una foto de la galería de una pieza (0020). `sort_order` 0 es la PRINCIPAL: la
 * que abre la ficha y la que se copia a `parts.image_url` para que el catálogo
 * pinte su tarjeta sin join.
 */
export interface PartImage {
  id: string
  part_id: string
  url: string
  sort_order: number
  created_at?: string
}

/**
 * Las fotos de una pieza, ordenadas y listas para la galería.
 *
 * Un solo lugar sabe que hay dos orígenes posibles: la tabla `part_images`
 * (0020) y, para las piezas que nadie volvió a guardar desde entonces, la
 * `image_url` suelta de la fila. Si la tabla trae filas manda ella; si no, la
 * principal sola. Devuelve [] cuando no hay ninguna foto, así la UI resuelve el
 * placeholder con un único `v-if`.
 */
export function partGallery(part: {
  image_url?: string | null
  part_images?: PartImage[]
}): string[] {
  const rows = part.part_images ?? []
  if (rows.length) {
    return [...rows]
      .sort((a, b) => a.sort_order - b.sort_order)
      .map((r) => r.url)
      .filter((url) => Boolean(url && url.trim()))
  }
  return part.image_url && part.image_url.trim() ? [part.image_url] : []
}

// ── Panel admin (cierre Fase 1) ─────────────────────────────────────────────

export interface Profile {
  id: string
  email: string | null
  role: 'user' | 'admin'
  created_at: string
}

/** Campos escribibles de `parts` (sin id ni created_at, que los pone la BD). */
export interface PartInput {
  /** Opcional (0015): vacío → null, nunca cadena vacía (choca con el UNIQUE). */
  code: string | null
  name: string
  category_id: string | null
  brand_id: string | null
  origin_type: OriginType
  price: number
  availability: Availability
  description: string | null
  material: string | null
  image_url: string | null
  discount_amount: number | null
  is_best_deal: boolean
  /** Precio mayorista por unidad; null = la pieza no tiene mayorista (0014). */
  wholesale_price: number | null
  /** Desde cuántas unidades aplica el mayorista (5 por defecto). */
  wholesale_min_qty: number
  /** Unidades en existencia (0018). Se captura a mano; 0 = agotado. */
  stock_qty: number
}

/**
 * Una foto en el formulario del panel: o ya vive en el bucket (`url`), o es un
 * archivo recién elegido que todavía no se ha subido (`file`). El ORDEN del array
 * es el orden de la galería y el primero es la principal, así que reordenar en la
 * UI es mover elementos de sitio y nada más.
 */
export interface PartImageDraft {
  /** URL pública si la foto ya está subida; null si es un archivo nuevo. */
  url: string | null
  /** Archivo elegido en el input; null si la foto ya estaba subida. */
  file: File | null
  /** Lo que pinta el <img> del formulario: la URL pública o un object URL local. */
  preview: string
}

/** Campos escribibles de `categories` (sin id/created_at). */
export interface CategoryInput {
  name: string
  slug: string
}

/** Campos escribibles de `brands` (sin id/created_at). */
export interface BrandInput {
  name: string
  slug: string
}

/** Campos escribibles de `vehicle_brands` — el nomenclador de marcas de auto. */
export interface VehicleBrandInput {
  name: string
  slug: string
}

/** Campos escribibles de `vehicle_models` (0016). La marca es obligatoria. */
export interface VehicleModelInput {
  vehicle_brand_id: string
  name: string
  slug: string
}

/** Campos escribibles de `vehicle_motors` (0016/0019). La marca es obligatoria, el modelo opcional. */
export interface VehicleMotorInput {
  vehicle_brand_id: string
  vehicle_model_id?: string | null
  name: string
  slug: string
}

// ── Ubicación de la tienda (fila única en store_settings, 0007) ──────────────

export interface StoreSettings {
  id: number
  address: string
  lat: number
  lng: number
  updated_at?: string
}

/** Campos editables de la ubicación desde el panel admin. */
export interface StoreSettingsInput {
  address: string
  lat: number
  lng: number
}

/** Fila de spec en el formulario (sin id/part_id: se generan al guardar). */
export interface SpecInput {
  label: string
  value: string
}

/**
 * Fila de compatibilidad en el formulario (sin id/part_id).
 */
export interface CompatInput {
  /** Marca del auto (obligatoria en compatibilidad). */
  vehicle_brand_id: string | null
  /** Modelo opcional; null = aplica a todos los modelos o no depende del modelo. */
  vehicle_model_id: string | null
  /** Motor opcional; null = aplica sin importar el motor. */
  motor_id: string | null
  year_from: number | null
  year_to: number | null
}

// ── "Mis autos": vehículos favoritos del cliente (0017) ──────────────────────

/**
 * Un auto guardado por el cliente. Apunta al nomenclador, así que si el admin
 * corrige el nombre del modelo el auto guardado se corrige con él.
 */
export interface UserVehicle {
  id: string
  user_id: string
  vehicle_model_id: string
  motor_id: string | null
  created_at?: string
  /** Modelo embebido por la FK, con su marca dentro. */
  vehicle_models?: VehicleModel | null
  vehicle_motors?: VehicleMotor | null
}

/** Campos que el cliente envía al guardar un auto (user_id lo pone la sesión). */
export interface UserVehicleInput {
  vehicle_model_id: string
  motor_id: string | null
}

/** "Toyota Corolla · 1.8L", o "Toyota Corolla" si no se guardó el motor. */
export function userVehicleLabel(v: UserVehicle): string {
  const brand = v.vehicle_models?.vehicle_brands?.name ?? ''
  const model = v.vehicle_models?.name ?? ''
  const motor = v.vehicle_motors?.name ?? ''
  const head = [brand, model].filter(Boolean).join(' ')
  return motor ? `${head} · ${motor}` : head
}

