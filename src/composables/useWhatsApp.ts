export const WHATSAPP_PHONE = '5356269303'

export interface StockStatus {
  qty: number
  hasStock: boolean
  tone: 'ok' | 'warn' | 'out'
  /** Etiqueta compacta para tarjeta del catálogo */
  cardLabel: string
  /** Etiqueta estilo tienda para vista de lista */
  badgeLabel: string
}

export function getStockQuantity(part: { availability?: string; stock_qty?: number | null }): number {
  if (part.availability === 'agotado') return 0
  if (typeof part.stock_qty === 'number') {
    return Math.max(0, part.stock_qty)
  }
  return 0
}

export function hasStock(part: { availability?: string; stock_qty?: number | null }): boolean {
  return getStockQuantity(part) > 0
}

export function getStockStatus(part: { availability?: string; stock_qty?: number | null }): StockStatus {
  const qty = getStockQuantity(part)

  if (qty <= 0) {
    return {
      qty: 0,
      hasStock: false,
      tone: 'out',
      cardLabel: 'Agotado · 0 disponibles',
      badgeLabel: 'Sin existencia · 0 disponibles',
    }
  }

  if (qty === 1) {
    return {
      qty: 1,
      hasStock: true,
      tone: 'warn',
      cardLabel: '¡Última disponible! (1 u.)',
      badgeLabel: '¡Última unidad! · 1 disponible',
    }
  }

  if (qty <= 5 || part.availability === 'stock_bajo') {
    return {
      qty,
      hasStock: true,
      tone: 'warn',
      cardLabel: `¡Quedan ${qty} disponibles!`,
      badgeLabel: `Stock bajo · ${qty} disponibles`,
    }
  }

  return {
    qty,
    hasStock: true,
    tone: 'ok',
    cardLabel: `En stock · ${qty} disponibles`,
    badgeLabel: `En stock · ${qty} disponibles`,
  }
}

export function getWhatsAppOrderUrl(params: {
  partName: string
  partCode?: string | null
  hasStock: boolean
  quantity?: number
}): string {
  const { partName, partCode, hasStock, quantity = 1 } = params
  const action = hasStock ? 'encargar más unidades' : 'encargar'
  const qtyText = quantity > 1 ? ` (${quantity} u.)` : ''
  const codeText = partCode ? ` [Código: ${partCode}]` : ''
  const message = `Hola, me interesa ${action} de la pieza: ${partName}${qtyText}${codeText}.`

  return `https://wa.me/${WHATSAPP_PHONE}?text=${encodeURIComponent(message)}`
}

export function openWhatsAppOrder(params: {
  partName: string
  partCode?: string | null
  hasStock: boolean
  quantity?: number
}) {
  const url = getWhatsAppOrderUrl(params)
  window.open(url, '_blank', 'noopener,noreferrer')
}
