-- supabase/migrations/0002_rls_policies.sql
-- Fase 1: catálogo público de solo lectura.
-- Se activa RLS y se agrega una policy de SELECT abierta en cada tabla.
-- No hay policies de INSERT/UPDATE/DELETE públicas: los datos se cargan por seed.sql.

alter table parts enable row level security;
alter table part_specs enable row level security;
alter table part_compatibility enable row level security;

create policy "Lectura publica de piezas" on parts for select using (true);
create policy "Lectura publica de specs" on part_specs for select using (true);
create policy "Lectura publica de compatibilidad" on part_compatibility for select
  using (true);
