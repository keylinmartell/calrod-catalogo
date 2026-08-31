-- supabase/migrations/0011_compat_motor.sql
-- Compatibilidad: se agrega el campo OPCIONAL `motor`.
--
-- No todas las piezas dependen del motor (una balata sirve por marca/modelo/año),
-- así que `motor` es nullable: vacío = "aplica sin importar el motor". Ejemplos de
-- valor: "1.6L", "2.0 TDI", "V6 3.5". Se indexa para filtrar/buscar por motor.

alter table part_compatibility add column motor text; -- opcional; null = cualquier motor

create index idx_compat_motor on part_compatibility(motor);
