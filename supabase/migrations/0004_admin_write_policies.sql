-- supabase/migrations/0004_admin_write_policies.sql
-- Fase 1 (cierre): la cerradura real del panel admin.
-- El SELECT público de 0002 se mantiene; aquí se agregan las escrituras,
-- permitidas SOLO a usuarios con rol 'admin' (via is_admin() de 0003).
-- Sin sesión de admin, Postgres rechaza todo INSERT/UPDATE/DELETE aunque el
-- panel se abra en el navegador: ocultar la ruta es comodidad, esto es seguridad.

-- ── parts ──────────────────────────────────────────────────────────────────
create policy "Admin inserta piezas" on parts for insert
  with check (is_admin());
create policy "Admin edita piezas" on parts for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra piezas" on parts for delete
  using (is_admin());

-- ── part_specs ─────────────────────────────────────────────────────────────
create policy "Admin inserta specs" on part_specs for insert
  with check (is_admin());
create policy "Admin edita specs" on part_specs for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra specs" on part_specs for delete
  using (is_admin());

-- ── part_compatibility ─────────────────────────────────────────────────────
create policy "Admin inserta compatibilidad" on part_compatibility for insert
  with check (is_admin());
create policy "Admin edita compatibilidad" on part_compatibility for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra compatibilidad" on part_compatibility for delete
  using (is_admin());

-- ── Storage: bucket part-images ────────────────────────────────────────────
-- Lectura pública (las fichas muestran la imagen vía URL pública) y escritura
-- solo admin. El bucket debe existir y ser público (lo crea el cliente).
create policy "Lectura publica de imagenes" on storage.objects for select
  using (bucket_id = 'part-images');
create policy "Admin sube imagenes" on storage.objects for insert
  with check (bucket_id = 'part-images' and is_admin());
create policy "Admin reemplaza imagenes" on storage.objects for update
  using (bucket_id = 'part-images' and is_admin())
  with check (bucket_id = 'part-images' and is_admin());
create policy "Admin borra imagenes" on storage.objects for delete
  using (bucket_id = 'part-images' and is_admin());
