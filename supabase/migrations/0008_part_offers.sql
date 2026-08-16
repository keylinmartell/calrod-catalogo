-- supabase/migrations/0008_part_offers.sql
-- Oferta por pieza (estilo "volante de tienda"): permite marcar descuentos y
-- destacar "mejor oferta" en la tarjeta del catálogo (PartCard).
--
-- Ambas columnas son OPCIONALES: las piezas existentes quedan con discount_pct
-- = null (sin descuento) e is_best_deal = false, así el catálogo se ve igual que
-- antes hasta que un admin active una oferta desde el panel.

alter table parts
  add column discount_pct numeric,                       -- 0–100; null = sin descuento
  add column is_best_deal boolean not null default false; -- cinta "MEJOR OFERTA"

-- Rango válido del descuento (si viene). Evita porcentajes absurdos que romperían
-- el cálculo del precio original en la UI.
alter table parts
  add constraint parts_discount_pct_range
  check (discount_pct is null or (discount_pct > 0 and discount_pct < 100));

-- Las policies de escritura de 0004 ("Admin edita piezas", etc.) ya cubren estas
-- columnas: aplican a la fila completa, no por columna. No hace falta nada más.
