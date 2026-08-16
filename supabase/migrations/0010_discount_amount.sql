-- supabase/migrations/0010_discount_amount.sql
-- Cambia la oferta de "porcentaje" a "monto fijo en USD".
--
-- El modelo anterior (0008, discount_pct) confundía: poner 3 quitaba 3 %, no 3 USD.
-- Ahora el admin captura directamente cuánto se descuenta en dólares:
--   price = precio NORMAL ; discount_amount = USD de descuento
--   precio final mostrado = price - discount_amount
--
-- Guardas IF EXISTS: funciona tanto si 0008 ya se aplicó (convierte la columna)
-- como en un reset limpio (0008 crea discount_pct y aquí se reemplaza).

alter table parts drop constraint if exists parts_discount_pct_range;

alter table parts add column if not exists discount_amount numeric; -- >0; null = sin oferta
alter table parts drop column if exists discount_pct;

-- El descuento, si viene, debe ser positivo. Que sea menor que el precio se valida
-- en la UI (evita un precio final negativo o cero); aquí solo garantizamos > 0.
alter table parts
  add constraint parts_discount_amount_positive
  check (discount_amount is null or discount_amount > 0);
