-- supabase/migrations/0007_store_settings.sql
-- Ubicación de la tienda editable desde el panel admin (una sola fila).
-- El catálogo la lee para pintar el mapa (MapPanel.vue con Leaflet + OSM).
--
-- Truco de fila única: `check (id = 1)` + default 1 fuerzan que solo exista
-- una configuración. Para actualizar se hace UPDATE ... where id = 1, nunca INSERT.

create table store_settings (
  id         int primary key default 1,
  address    text not null,
  lat        numeric not null,
  lng        numeric not null,
  updated_at timestamptz default now(),
  constraint single_row check (id = 1)
);

-- Fila inicial (placeholder — se edita desde el panel). Coordenadas: La Habana centro.
insert into store_settings (id, address, lat, lng)
values (1, 'La Habana, Cuba', 23.1136, -82.3666)
on conflict (id) do nothing;

-- ── RLS ───────────────────────────────────────────────────────────────────────
alter table store_settings enable row level security;

-- Lectura pública (el mapa del catálogo la necesita sin sesión).
create policy "Lectura publica de ubicacion" on store_settings for select
  using (true);

-- Solo admin puede actualizar (mismo patrón que parts/categories, via is_admin()).
create policy "Admin edita ubicacion" on store_settings for update
  using (is_admin()) with check (is_admin());
