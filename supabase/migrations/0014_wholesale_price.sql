-- supabase/migrations/0014_wholesale_price.sql
-- Precio MAYORISTA por pieza. La misma pieza vale distinto cuando el cliente
-- lleva varias unidades, y ese umbral no es igual para todo el catálogo (un
-- amortiguador se vende por par, un filtro por caja), así que la cantidad
-- mínima vive en la pieza con 5 por defecto y el admin la edita cuando aplica.
--
--   price            → precio al DETALLE (menos discount_amount si hay oferta)
--   wholesale_price  → precio por unidad al llevar wholesale_min_qty o más
--   wholesale_min_qty→ desde cuántas unidades aplica (default 5)
--
-- null en wholesale_price = la pieza no tiene precio mayorista y se muestra
-- igual que hoy. Que el mayorista sea MENOR que el precio final al detalle se
-- valida en el panel (ahí se ve el precio de la pieza completo); en la BD solo
-- garantizamos que sea positivo.

alter table parts add column if not exists wholesale_price numeric;
alter table parts add column if not exists wholesale_min_qty int not null default 5;

-- Guardas drop/add: la migración se puede volver a correr sin chocar con la
-- constraint ya creada (mismo estilo que 0010).
alter table parts drop constraint if exists parts_wholesale_price_positive;
alter table parts
  add constraint parts_wholesale_price_positive
  check (wholesale_price is null or wholesale_price > 0);

-- "Mayorista desde 1 unidad" no es un mayorista: el mínimo real empieza en 2.
alter table parts drop constraint if exists parts_wholesale_min_qty_valid;
alter table parts
  add constraint parts_wholesale_min_qty_valid
  check (wholesale_min_qty >= 2);
