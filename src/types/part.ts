export type PartCategory =
  | 'frenos'
  | 'motor'
  | 'suspension'
  | 'electrico'
  | 'carroceria'
  | 'filtros'

export type OriginType = 'original' | 'alternativa' | 'remanufacturada'

export type Availability = 'disponible' | 'stock_bajo' | 'agotado'

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
  year_from: number
  year_to: number
}

export interface Part {
  id: string
  code: string
  name: string
  category: PartCategory
  brand: string
  origin_type: OriginType
  price: number
  availability: Availability
  description: string | null
  material: string | null
  image_url: string | null
  created_at: string
  part_specs?: PartSpec[]
  part_compatibility?: PartCompatibility[]
}

export const CATEGORIES: { value: PartCategory; label: string }[] = [
  { value: 'frenos', label: 'Frenos' },
  { value: 'motor', label: 'Motor' },
  { value: 'suspension', label: 'Suspensión' },
  { value: 'electrico', label: 'Eléctrico' },
  { value: 'carroceria', label: 'Carrocería' },
  { value: 'filtros', label: 'Filtros' },
]

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
  category: PartCategory
  brand: string
  origin_type: OriginType
  price: number
  availability: Availability
  description: string | null
  material: string | null
  image_url: string | null
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
  year_from: number
  year_to: number
}
