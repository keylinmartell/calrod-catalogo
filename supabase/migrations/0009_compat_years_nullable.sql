-- supabase/migrations/0009_compat_years_nullable.sql
-- Los años de compatibilidad pasan a ser OPCIONALES.
--
-- Antes (0001_init.sql) year_from/year_to eran `int not null`, así que un campo
-- de año vacío en el panel provocaba:
--   • 22P02 (invalid_text_representation) al mandar "" en vez de número, o
--   • 23502 (not_null_violation) al mandar null.
-- La app ahora normaliza vacío → null; esta migración permite ese null en la BD.

alter table part_compatibility alter column year_from drop not null;
alter table part_compatibility alter column year_to drop not null;
