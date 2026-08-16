export type OriginType = 'original' | 'alternativa' | 'remanufacturada'

export type Availability = 'disponible' | 'stock_bajo' | 'agotado'

export interface Category {
  id: string
  name: string
  slug: string
  created_at?: string
}

export interface PartSpec {
  id: number
  part_id: string
  label: string
  value: string
}

export interface PartCompatibility {
  id: number
  part_id: string
  vehicle_brand: string
  vehicle_model: string
  year_from: number | null
  year_to: number | null
}

export interface Part {
  id: string
  code: string
  name: string
  category_id: string | null
  brand: string
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
  created_at: string
  categories?: Category | null
  part_specs?: PartSpec[]
  part_compatibility?: PartCompatibility[]
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

// ── Panel admin (cierre Fase 1) ─────────────────────────────────────────────

export interface Profile {
  id: string
  email: string | null
  role: 'user' | 'admin'
  created_at: string
}

/** Campos escribibles de `parts` (sin id ni created_at, que los pone la BD). */
export interface PartInput {
  code: string
  name: string
  category_id: string | null
  brand: string
  origin_type: OriginType
  price: number
  availability: Availability
  description: string | null
  material: string | null
  image_url: string | null
  discount_amount: number | null
  is_best_deal: boolean
}

/** Campos escribibles de `categories` (sin id/created_at). */
export interface CategoryInput {
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

/** Fila de compatibilidad en el formulario (sin id/part_id). */
export interface CompatInput {
  vehicle_brand: string
  vehicle_model: string
  year_from: number | null
  year_to: number | null
}
