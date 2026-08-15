-- supabase/migrations/0005_categories.sql
-- Fase 1 (extensión): las categorías dejan de ser texto libre en `parts` y pasan
-- a su propia tabla, gestionable desde el panel admin. Cada pieza referencia una
-- categoría por FK (parts.category_id → categories.id).
--
-- Decisión: al borrar una categoría, las piezas que la usaban quedan con
-- category_id = null (on delete set null) en vez de bloquear el borrado o
-- arrastrar las piezas. Así el catálogo nunca se rompe por gestionar categorías.

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,                 -- ej. "Frenos"
  slug text unique not null,          -- ej. "frenos" (estable, para URLs/filtros)
  created_at timestamptz default now()
);

create index idx_categories_slug on categories(slug);

-- ── parts: nueva referencia por FK ───────────────────────────────────────────
-- Se agrega category_id y se elimina la vieja columna de texto `category`.
-- Las categorías previas (texto) se descartan: se recrean desde el panel admin.
alter table parts add column category_id uuid references categories(id) on delete set null;
alter table parts drop column category;

create index idx_parts_category on parts(category_id);

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table categories enable row level security;

-- Lectura pública (los filtros del catálogo las necesitan sin sesión).
create policy "Lectura publica de categorias" on categories for select
  using (true);

-- Escritura solo admin (mismo patrón que parts en 0004, via is_admin() de 0003).
create policy "Admin inserta categorias" on categories for insert
  with check (is_admin());
create policy "Admin edita categorias" on categories for update
  using (is_admin()) with check (is_admin());
create policy "Admin borra categorias" on categories for delete
  using (is_admin());
