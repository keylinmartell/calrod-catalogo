-- supabase/migrations/0020_part_images.sql
-- Galería de fotos por pieza. Hasta ahora `parts.image_url` guardaba UNA foto y
-- la ficha no podía mostrar más; una pieza real se fotografía desde varios
-- ángulos, así que las fotos pasan a ser una tabla hija ordenada.
--
--   parts  1 ─── N  part_images   (sort_order 0 = foto PRINCIPAL)
--
-- ── Por qué `parts.image_url` NO se elimina ──────────────────────────────────
-- Sigue siendo la foto principal DENORMALIZADA. El catálogo pinta cientos de
-- tarjetas (PartCard, PartListItem) y el panel admin su tabla: todas necesitan
-- una sola foto y ninguna la galería completa. Manteniendo la principal en la
-- fila, esas vistas siguen resolviéndose con un solo SELECT sin join.
-- La regla de sincronización vive en el frontend (useAdminParts.replaceImages):
-- al guardar, `image_url` = la foto de sort_order 0.
--
-- Idempotente (mismo criterio que 0016): corre igual sobre una base virgen, ya
-- migrada, o migrada a medias.

create table if not exists part_images (
  id uuid primary key default gen_random_uuid(),
  part_id uuid not null references parts(id) on delete cascade,
  url text not null,
  -- Posición en la galería. 0 = principal (la que se ve primero y la que se
  -- copia a parts.image_url). No es unique por pieza a propósito: al reordenar,
  -- el frontend borra e reinserta el bloque completo, y un unique obligaría a
  -- hacerlo en dos pasos para no chocar con posiciones intermedias.
  sort_order int not null default 0,
  created_at timestamptz default now(),
  constraint part_images_url_not_blank check (btrim(url) <> ''),
  constraint part_images_sort_order_non_negative check (sort_order >= 0)
);

-- La galería siempre se lee por pieza y en orden: un índice compuesto cubre la
-- consulta entera sin pasar por la tabla.
create index if not exists idx_part_images_part_order
  on part_images (part_id, sort_order);

-- ── Backfill: la foto que ya tenía cada pieza pasa a ser su principal ────────
-- Solo para piezas que aún no tienen ninguna fila en part_images, así repetir el
-- script no duplica la principal.
insert into part_images (part_id, url, sort_order)
select p.id, p.image_url, 0
from parts p
where p.image_url is not null
  and btrim(p.image_url) <> ''
  and not exists (select 1 from part_images i where i.part_id = p.id);

-- ── RLS ──────────────────────────────────────────────────────────────────────
-- Mismo patrón que part_specs / part_compatibility (0002 + 0004): lectura
-- pública (la ficha se ve sin sesión) y escritura solo admin via is_admin().
-- Cada policy va con `drop policy if exists` delante porque Postgres no tiene
-- `create policy if not exists` y sin eso el script no se podría repetir.

alter table part_images enable row level security;

drop policy if exists "Lectura publica de fotos de pieza" on part_images;
create policy "Lectura publica de fotos de pieza" on part_images for select
  using (true);
drop policy if exists "Admin inserta fotos de pieza" on part_images;
create policy "Admin inserta fotos de pieza" on part_images for insert
  with check (is_admin());
drop policy if exists "Admin edita fotos de pieza" on part_images;
create policy "Admin edita fotos de pieza" on part_images for update
  using (is_admin()) with check (is_admin());
drop policy if exists "Admin borra fotos de pieza" on part_images;
create policy "Admin borra fotos de pieza" on part_images for delete
  using (is_admin());
