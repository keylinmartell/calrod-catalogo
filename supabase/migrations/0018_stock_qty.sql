-- supabase/migrations/0018_stock_qty.sql
-- EXISTENCIA: cuántas unidades de la pieza hay en el mostrador.
--
-- Hasta ahora `availability` (0001) era el único dato de inventario, y es una
-- etiqueta ('disponible' | 'stock_bajo' | 'agotado'): sirve para pintar el
-- catálogo pero no responde "¿me alcanzan 12?". Esta columna guarda el número.
--
-- Las dos conviven a propósito y por ahora se editan A MANO, cada una por su
-- lado: no hay trigger que derive la etiqueta de la cantidad. El umbral de
-- "stock bajo" es una decisión del negocio que cambia por tipo de pieza, así que
-- forzarlo en la BD ahora sería adivinar. Si más adelante se quiere automatizar,
-- este es el dato que lo permite.
--
-- Arranca en 0 y no en null: "no sé cuántas hay" y "no hay" se ven igual en la
-- vitrina, y un default numérico evita que cada consumidor tenga que decidir qué
-- hacer con el null. El CHECK impide existencias negativas.
--
-- Idempotente, igual que 0015 y 0016: se puede correr sobre una base que ya la
-- tenga sin que falle.

alter table parts
  add column if not exists stock_qty integer not null default 0;

alter table parts drop constraint if exists parts_stock_qty_no_negative;
alter table parts
  add constraint parts_stock_qty_no_negative check (stock_qty >= 0);
