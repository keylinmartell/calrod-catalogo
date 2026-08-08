-- supabase/migrations/0001_init.sql
-- Esquema base del catálogo CalRod (Fase 1).
-- La compatibilidad se modela como tabla aparte (una pieza sirve para varios autos),
-- así el filtro por marca/modelo es una consulta real y no texto libre.

create table parts (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,          -- número de parte / SKU, ej. "BR-4471-C"
  name text not null,
  category text not null,             -- frenos | motor | suspension | electrico | carroceria | filtros
  brand text not null,                -- marca de la refacción (ej. "CalRod Original")
  origin_type text not null,          -- 'original' | 'alternativa' | 'remanufacturada'
  price numeric not null,
  availability text not null,         -- 'disponible' | 'stock_bajo' | 'agotado'
  description text,
  material text,
  image_url text,                     -- URL pública del bucket part-images
  created_at timestamptz default now()
);

create table part_specs (
  id bigint generated always as identity primary key,
  part_id uuid not null references parts(id) on delete cascade,
  label text not null,                -- ej. "Diámetro"
  value text not null                 -- ej. "280mm"
);

create table part_compatibility (
  id bigint generated always as identity primary key,
  part_id uuid not null references parts(id) on delete cascade,
  vehicle_brand text not null,        -- ej. "Nissan"
  vehicle_model text not null,        -- ej. "Sentra"
  year_from int not null,
  year_to int not null
);

create index idx_parts_code on parts(code);
create index idx_parts_name on parts(name);
create index idx_compat_vehicle on part_compatibility(vehicle_brand, vehicle_model);
