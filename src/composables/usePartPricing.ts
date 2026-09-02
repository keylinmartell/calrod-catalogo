import type { Part } from '@/types/part'

/**
 * usePartPricing — una sola fuente para las reglas de precio que la tarjeta, la
 * lista, la ficha y el panel tienen que contar igual:
 *
 *   detalle   = price − discount_amount   (0010; el descuento es monto fijo USD)
 *   mayorista = wholesale_price por unidad al llevar wholesale_min_qty o más (0014)
 *
 * El mayorista solo se muestra si de verdad conviene (menor que el precio final
 * al detalle). Un "mayorista" igual o más caro no se anuncia: sería ruido, y el
 * panel además lo rechaza al guardar.
 */
export const money = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'USD',
})

/** Precio final al detalle: el normal menos la oferta si hay una válida. */
export function retailPrice(part: Pick<Part, 'price' | 'discount_amount'>): number {
  const save = part.discount_amount
  if (!save || save <= 0) return part.price
  const final = part.price - save
  return final > 0 ? final : part.price
}

export interface WholesaleInfo {
  /** Precio por unidad en mayorista. */
  price: number
  /** Cantidad mínima para que aplique. */
  minQty: number
  priceFmt: string
  /** Etiqueta corta para la UI: "Desde 5 u." */
  qtyLabel: string
  /** Cuánto se ahorra por unidad contra el precio al detalle. */
  save: number
  saveFmt: string
}

/** Datos del precio mayorista listos para pintar, o null si la pieza no tiene. */
export function partWholesale(
  part: Pick<
    Part,
    'price' | 'discount_amount' | 'wholesale_price' | 'wholesale_min_qty'
  >,
): WholesaleInfo | null {
  const price = part.wholesale_price
  if (price === null || price === undefined || price <= 0) return null

  const retail = retailPrice(part)
  if (price >= retail) return null

  // La BD garantiza min_qty >= 2 con default 5; si llegara vacío por una fila
  // vieja, caemos al 5 acordado en vez de anunciar "desde 0 unidades".
  const minQty = part.wholesale_min_qty && part.wholesale_min_qty >= 2
    ? part.wholesale_min_qty
    : 5

  return {
    price,
    minQty,
    priceFmt: money.format(price),
    qtyLabel: `Desde ${minQty} u.`,
    save: retail - price,
    saveFmt: money.format(retail - price),
  }
}
