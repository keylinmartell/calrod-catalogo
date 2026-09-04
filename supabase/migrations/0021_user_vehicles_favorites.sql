-- supabase/migrations/0021_user_vehicles_favorites.sql
-- FAVORITOS DE AUTOS: el cliente marca sus autos y filtra el catálogo con un clic.
--
-- 0017 creó `user_vehicles` cuando el modelo era obligatorio. Desde 0019 una pieza
-- puede declararse compatible con solo la MARCA o con MARCA + MOTOR (motores que
-- cuelgan de la marca, sin modelo). El favorito tiene que poder guardar lo mismo
-- que la compatibilidad sabe expresar, así que aquí:
--   1. `vehicle_brand_id` pasa a ser la columna obligatoria (antes la marca se
--      deducía del modelo, que ya no siempre existe).
--   2. `vehicle_model_id` se vuelve OPCIONAL: "Toyota con motor 22R" y "toda la
--      marca Toyota" son favoritos válidos.
--   3. El UNIQUE se rehace sobre las tres columnas, con centinela para los nulos.
--
-- Idempotente a propósito: las migraciones se aplican a mano en el SQL Editor y
-- puede haberse quedado a medias, así que cada paso comprueba antes de actuar.

-- ── 0. La tabla, si 0017 nunca llegó a correr ───────────────────────────────
create table if not exists user_vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vehicle_brand_id uuid references vehicle_brands(id) on delete cascade,
  vehicle_model_id uuid references vehicle_models(id) on delete cascade,
  -- Sin FK inline: la nombrada (`user_vehicles_motor_fk`) la añade el paso 3, así
  -- la tabla recién creada y la que viene de 0017 acaban con la misma constraint.
  motor_id uuid,
  created_at timestamptz default now()
);

-- ── 1. Marca propia en la fila ──────────────────────────────────────────────
alter table user_vehicles
  add column if not exists vehicle_brand_id uuid references vehicle_brands(id) on delete cascade;

-- Backfill: la marca sale del modelo guardado y, si no hay modelo, del motor.
update user_vehicles uv
set vehicle_brand_id = m.vehicle_brand_id
from vehicle_models m
where uv.vehicle_model_id = m.id
  and uv.vehicle_brand_id is null;

update user_vehicles uv
set vehicle_brand_id = mo.vehicle_brand_id
from vehicle_motors mo
where uv.motor_id = mo.id
  and uv.vehicle_brand_id is null;

-- Una fila sin marca ni forma de deducirla no describe ningún auto: sobra.
-- (Hasta ahora la tabla no tenía UI que la llenara, así que en la práctica está
-- vacía; el delete existe para que el paso siguiente no falle.)
delete from user_vehicles where vehicle_brand_id is null;

-- ── 2. Modelo opcional, marca obligatoria ───────────────────────────────────
alter table user_vehicles alter column vehicle_model_id drop not null;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_name = 'user_vehicles'
      and column_name = 'vehicle_brand_id'
      and is_nullable = 'YES'
  ) and not exists (
    -- Si algo dejó filas sin marca, mejor seguir sin NOT NULL que abortar el
    -- resto de la migración a medias.
    select 1 from user_vehicles where vehicle_brand_id is null
  ) then
    alter table user_vehicles alter column vehicle_brand_id set not null;
  end if;
end $$;

-- ── 3. FK del motor: simple (0019 ya soltó la compuesta de 0017) ────────────
alter table user_vehicles drop constraint if exists user_vehicles_motor_belongs_to_model;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'user_vehicles_motor_fk'
  ) then
    alter table user_vehicles
      add constraint user_vehicles_motor_fk
      foreign key (motor_id) references vehicle_motors(id) on delete cascade;
  end if;
end $$;

-- ── 4. Índices ──────────────────────────────────────────────────────────────
create index if not exists idx_user_vehicles_user on user_vehicles(user_id);
create index if not exists idx_user_vehicles_brand on user_vehicles(vehicle_brand_id);

-- El UNIQUE de 0017 no incluía la marca y daba por hecho el modelo. Se rehace
-- sobre las tres columnas: Postgres trata cada NULL como distinto, así que sin
-- el coalesce a un uuid centinela "Toyota sin modelo" se podría guardar dos veces.
drop index if exists idx_user_vehicles_unique;
create unique index if not exists idx_user_vehicles_unique_v2
  on user_vehicles (
    user_id,
    vehicle_brand_id,
    coalesce(vehicle_model_id, '00000000-0000-0000-0000-000000000000'::uuid),
    coalesce(motor_id, '00000000-0000-0000-0000-000000000000'::uuid)
  );

-- ── 5. RLS: cada quien ve y gestiona SOLO sus autos ─────────────────────────
-- Dato personal, al contrario de los nomencladores: aquí NO hay lectura pública.
-- Sin policy de UPDATE: un favorito se agrega o se quita, no se edita.
alter table user_vehicles enable row level security;

drop policy if exists "Lectura de los propios autos" on user_vehicles;
create policy "Lectura de los propios autos" on user_vehicles for select
  using (auth.uid() = user_id);

drop policy if exists "Guardar auto propio" on user_vehicles;
create policy "Guardar auto propio" on user_vehicles for insert
  with check (auth.uid() = user_id);

drop policy if exists "Borrar auto propio" on user_vehicles;
create policy "Borrar auto propio" on user_vehicles for delete
  using (auth.uid() = user_id);

-- PostgREST cachea el esquema: sin esto la nueva FK a vehicle_brands no existe
-- para los embeds `user_vehicles(*, vehicle_brands(*))` hasta el próximo reinicio.
notify pgrst, 'reload schema';
