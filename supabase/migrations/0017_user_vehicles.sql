-- supabase/migrations/0017_user_vehicles.sql
-- "MIS AUTOS": los vehículos favoritos de cada cliente.
--
-- Un cliente que ya sabe qué auto tiene no debería volver a armar el filtro
-- marca → modelo → motor en cada visita. Guarda su auto una vez y el catálogo
-- se filtra con un clic.
--
-- Apunta al NOMENCLADOR (0016), no a texto: si el admin corrige "Corola" a
-- "Corolla", el auto guardado del cliente se corrige con él.
--
-- El motor es opcional por la misma razón que en la compatibilidad: mucha gente
-- sabe su marca y modelo pero no la cilindrada, y sin motor el filtro ya sirve.

create table user_vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vehicle_model_id uuid not null references vehicle_models(id) on delete cascade,
  motor_id uuid,
  created_at timestamptz default now(),
  -- Misma FK compuesta que part_compatibility (0016): el motor guardado tiene
  -- que pertenecer al modelo guardado. Con motor_id null la FK no se comprueba
  -- (MATCH SIMPLE), así el motor sigue siendo opcional.
  --
  -- `on delete cascade` y no `set null` porque poner a null solo una columna de
  -- una FK compuesta no está disponible en todas las versiones de Postgres, y
  -- vehicle_model_id es NOT NULL. Borrar un motor del nomenclador es raro; el
  -- costo es que el cliente vuelva a guardar ese auto.
  constraint user_vehicles_motor_belongs_to_model
    foreign key (motor_id, vehicle_model_id)
    references vehicle_motors (id, vehicle_model_id)
    on delete cascade
);

create index idx_user_vehicles_user on user_vehicles(user_id);

-- Sin autos repetidos por usuario. Un UNIQUE normal no bastaría: Postgres trata
-- cada NULL como distinto, así que "Corolla sin motor" se podría guardar dos
-- veces. Con coalesce a un uuid centinela ese caso también queda cubierto.
create unique index idx_user_vehicles_unique
  on user_vehicles (
    user_id,
    vehicle_model_id,
    coalesce(motor_id, '00000000-0000-0000-0000-000000000000'::uuid)
  );

alter table user_vehicles enable row level security;

-- Cada quien ve y gestiona SOLO sus autos. Aquí NO hay lectura pública: es dato
-- personal, al contrario de los nomencladores. Tampoco hay policy de UPDATE: un
-- auto guardado se agrega o se quita, no se edita.
create policy "Lectura de los propios autos" on user_vehicles for select
  using (auth.uid() = user_id);

create policy "Guardar auto propio" on user_vehicles for insert
  with check (auth.uid() = user_id);

create policy "Borrar auto propio" on user_vehicles for delete
  using (auth.uid() = user_id);
