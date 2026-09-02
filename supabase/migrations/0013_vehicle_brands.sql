-- supabase/migrations/0013_vehicle_brands.sql
-- Nomenclador de MARCAS DE AUTO. Antes vivía en dos lugares que nadie podía
-- administrar: una lista fija de 33 marcas en el frontend
-- (COMMON_VEHICLE_BRANDS, src/composables/useFilters.ts) y texto libre en
-- part_compatibility.vehicle_brand. Ahora es una tabla gestionable desde el
-- panel admin y cada fila de compatibilidad la referencia por FK.
--
-- Mismo patrón que categories (0005) y brands (0012). Como en 0012, los valores
-- de texto que ya existen SÍ se migran: no se pierde la compatibilidad sembrada.
--
-- OJO con el borrado: aquí es `on delete restrict`, no el `set null` de
-- categories/brands. Una fila de compatibilidad sin marca de auto no dice nada
-- ("sirve para cualquier auto" no es algo que el negocio quiera afirmar por
-- accidente), así que Postgres bloquea borrar una marca en uso y el panel avisa
-- cuántas piezas la usan.

create table vehicle_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,                 -- ej. "Toyota"
  slug text unique not null,          -- ej. "toyota" (estable, para filtros/URLs)
  created_at timestamptz default now()
);

create index idx_vehicle_brands_slug on vehicle_brands(slug);

-- ── Semilla 1: las marcas que ya usa el catálogo ─────────────────────────────
-- Se insertan primero para que gane el nombre REAL del dato (si la BD dice
-- "BYD", el nomenclador queda con "BYD", no con la variante de la lista fija).
-- El slug se deriva igual que slugify() del frontend: minúsculas + guiones.
insert into vehicle_brands (name, slug)
select distinct
  btrim(vehicle_brand),
  regexp_replace(
    regexp_replace(lower(btrim(vehicle_brand)), '[^a-z0-9]+', '-', 'g'),
    '(^-+|-+$)', '', 'g'
  )
from part_compatibility
where vehicle_brand is not null and btrim(vehicle_brand) <> ''
on conflict (slug) do nothing;

-- ── Semilla 2: la lista fija que vivía en el frontend ────────────────────────
-- Arranca el nomenclador con las marcas habituales del mercado para que el
-- filtro del catálogo se vea igual que antes desde el minuto uno. El admin las
-- edita o borra desde el panel; no vuelven a aparecer solas.
insert into vehicle_brands (name, slug) values
  ('Asia', 'asia'),
  ('Audi', 'audi'),
  ('Byd', 'byd'),
  ('Changan', 'changan'),
  ('Chery', 'chery'),
  ('Chevrolet', 'chevrolet'),
  ('Citroen', 'citroen'),
  ('Daewoo', 'daewoo'),
  ('Daihatsu', 'daihatsu'),
  ('Dodge', 'dodge'),
  ('Fiat', 'fiat'),
  ('Ford', 'ford'),
  ('Geely', 'geely'),
  ('Great Wall', 'great-wall'),
  ('Haval', 'haval'),
  ('Honda', 'honda'),
  ('Hyundai', 'hyundai'),
  ('JAC', 'jac'),
  ('Jeep', 'jeep'),
  ('Kia', 'kia'),
  ('Mazda', 'mazda'),
  ('Mercedes-Benz', 'mercedes-benz'),
  ('MG', 'mg'),
  ('Mitsubishi', 'mitsubishi'),
  ('Nissan', 'nissan'),
  ('Peugeot', 'peugeot'),
  ('Renault', 'renault'),
  ('Seat', 'seat'),
  ('Skoda', 'skoda'),
  ('Subaru', 'subaru'),
  ('Suzuki', 'suzuki'),
  ('Toyota', 'toyota'),
  ('Volkswagen', 'volkswagen')
on conflict (slug) do nothing;

-- ── part_compatibility: la marca pasa a ser FK ───────────────────────────────
alter table part_compatibility
  add column vehicle_brand_id uuid references vehicle_brands(id) on delete restrict;

-- Enlaza cada fila con su marca por slug (no por nombre: así "BYD" y "Byd"
-- caen en la misma marca en vez de quedarse sin enlazar).
update part_compatibility c
set vehicle_brand_id = b.id
from vehicle_brands b
where b.slug = regexp_replace(
  regexp_replace(lower(btrim(c.vehicle_brand)), '[^a-z0-9]+', '-', 'g'),
  '(^-+|-+$)', '', 'g'
);

-- Filas cuya marca era texto vacío: no se pueden migrar porque no dicen para
-- qué auto sirve la pieza. No hay dato que preservar, se van.
delete from part_compatibility where vehicle_brand_id is null;

alter table part_compatibility alter column vehicle_brand_id set not null;

-- La columna de texto libre ya no se usa. Al soltarla, Postgres se lleva el
-- índice idx_compat_vehicle de 0001 (lo incluía), así que se recrea abajo.
alter table part_compatibility drop column vehicle_brand;

create index idx_compat_vehicle on part_compatibility(vehicle_brand_id, vehicle_model);

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table vehicle_brands enable row level security;

-- Lectura pública (los filtros del catálogo las necesitan sin sesión).
create policy "Lectura publica de marcas de auto" on vehicle_brands for select
  using (true);

-- Escritura solo admin (mismo patrón que categories/brands, via is_admin() de 0003).
create policy "Admin inserta marcas de auto" on vehicle_brands for insert
  with check (is_admin());
create policy "Admin edita marcas de auto" on vehicle_brands for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra marcas de auto" on vehicle_brands for delete
  using (is_admin());
