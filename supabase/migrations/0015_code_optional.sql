-- supabase/migrations/0015_code_optional.sql
-- El CÓDIGO / SKU de la pieza pasa a ser OPCIONAL.
--
-- Venía `not null` desde 0001, pero no todo lo que entra al mostrador trae número
-- de parte legible (piezas sueltas, genéricos, lotes sin caja). Obligar el campo
-- forzaba a inventar códigos, que es peor que no tenerlo: contamina la búsqueda
-- por código con valores falsos.
--
-- El UNIQUE se mantiene. En Postgres un índice único considera cada NULL
-- distinto, así que muchas piezas pueden quedarse sin código a la vez y las que
-- SÍ tienen código siguen sin poder repetirlo.
--
-- La cadena vacía es el caso peligroso: '' no es NULL, así que dos piezas con
-- código vacío chocarían contra el UNIQUE. Se normaliza lo que ya exista y un
-- CHECK impide que vuelva a entrar.

alter table parts alter column code drop not null;

-- Códigos vacíos o de solo espacios que ya estén guardados: pasan a null.
update parts set code = null where code is not null and btrim(code) = '';

alter table parts drop constraint if exists parts_code_not_blank;
alter table parts
  add constraint parts_code_not_blank
  check (code is null or btrim(code) <> '');
