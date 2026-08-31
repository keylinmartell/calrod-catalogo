-- supabase/migrations/0012_brands.sql
-- La marca de la pieza (parts.brand, texto libre) pasa a su propia tabla,
-- gestionable desde el panel admin — mismo patrón que categories (0005).
-- Cada pieza referencia una marca por FK (parts.brand_id → brands.id).
--
-- A diferencia de categories, aquí SÍ migramos los valores existentes: las marcas
-- de texto libre que ya viven en parts.brand se insertan en `brands` y se enlazan,
-- para no perder los datos del seed / catálogo actual.
--
-- Decisión: al borrar una marca, las piezas quedan con brand_id = null
-- (on delete set null); el catálogo no se rompe por gestionar marcas.

create table brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,          -- estable, para filtros/URLs
  created_at timestamptz default now()
);

create index idx_brands_slug on brands(slug);

-- ── parts: nueva referencia por FK ───────────────────────────────────────────
alter table parts add column brand_id uuid references brands(id) on delete set null;

-- Migración de datos: cada marca de texto distinta se vuelve una fila en brands.
-- El slug se deriva igual que en el frontend (minúsculas, sin acentos, guiones);
-- lower()+unaccent no está garantizado, así que hacemos un slug simple y estable.
insert into brands (name, slug)
select distinct
  btrim(brand),
  regexp_replace(regexp_replace(lower(btrim(brand)), '[^a-z0-9]+', '-', 'g'), '(^-+|-+$)', '', 'g')
from parts
where brand is not null and btrim(brand) <> ''
on conflict (slug) do nothing;

-- Enlaza cada pieza con la marca recién creada (match por nombre normalizado).
update parts p
set brand_id = b.id
from brands b
where b.name = btrim(p.brand);

-- La columna de texto libre ya no se usa: la marca vive en brands vía brand_id.
alter table parts drop column brand;

create index idx_parts_brand on parts(brand_id);

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table brands enable row level security;

-- Lectura pública (los filtros del catálogo las necesitan sin sesión).
create policy "Lectura publica de marcas" on brands for select
  using (true);

-- Escritura solo admin (mismo patrón que categories en 0005, via is_admin() de 0003).
create policy "Admin inserta marcas" on brands for insert
  with check (is_admin());
create policy "Admin edita marcas" on brands for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra marcas" on brands for delete
  using (is_admin());
