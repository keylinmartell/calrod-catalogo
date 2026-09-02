-- supabase/migrations/0019_motors_and_compat_without_model.sql
-- Flexibilización del vehículo: permite MOTORES a nivel de Marca y compatibilidad SIN modelo obligatorio.
--
-- Caso de negocio:
-- En refacciones, muchas piezas (bujías, juntas, bombas, pistones) aplican a un MOTOR o FAMILIA DE MOTOR
-- (ej. Toyota 22R, GM 350, VW 1.8T) sin importar el modelo específico de carro en que esté montado.
--
-- Con esta migración:
-- 1. vehicle_motors pasa a pertenecer directamente a vehicle_brands (con vehicle_model_id opcional/nullable).
-- 2. part_compatibility guarda vehicle_brand_id explícito y vehicle_model_id pasa a ser opcional (nullable).
-- 3. Una pieza puede declararse compatible con:
--    - Solo Marca (ej. Toyota)
--    - Marca + Modelo (ej. Toyota Corolla)
--    - Marca + Motor (ej. Toyota con motor 22R)
--    - Marca + Modelo + Motor (ej. Toyota Corolla 1.8L)

-- ── 1. vehicle_motors: marca obligatoria, modelo opcional ───────────────────

alter table vehicle_motors
  add column if not exists vehicle_brand_id uuid references vehicle_brands(id) on delete cascade;

-- Backfill: llenar vehicle_brand_id desde vehicle_models para los motores ya existentes
update vehicle_motors mo
set vehicle_brand_id = m.vehicle_brand_id
from vehicle_models m
where mo.vehicle_model_id = m.id
  and mo.vehicle_brand_id is null;

-- Hacer vehicle_model_id nullable
alter table vehicle_motors alter column vehicle_model_id drop not null;

-- Índice por marca
create index if not exists idx_vehicle_motors_brand on vehicle_motors(vehicle_brand_id);

-- ── 2. part_compatibility: marca explícita, modelo y motor opcionales ───────

alter table part_compatibility
  add column if not exists vehicle_brand_id uuid references vehicle_brands(id) on delete restrict;

-- Backfill: llenar vehicle_brand_id desde vehicle_models o vehicle_motors
update part_compatibility c
set vehicle_brand_id = m.vehicle_brand_id
from vehicle_models m
where c.vehicle_model_id = m.id
  and c.vehicle_brand_id is null;

update part_compatibility c
set vehicle_brand_id = mo.vehicle_brand_id
from vehicle_motors mo
where c.motor_id = mo.id
  and c.vehicle_brand_id is null;

-- Hacer vehicle_model_id nullable en part_compatibility
alter table part_compatibility alter column vehicle_model_id drop not null;

-- Soltar la FK compuesta vieja si existía (exigía que motor_id y vehicle_model_id coincidieran)
alter table part_compatibility drop constraint if exists part_compat_motor_belongs_to_model;

-- Agregar FK simple para motor_id si no existe
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'part_compat_motor_fk'
  ) then
    alter table part_compatibility
      add constraint part_compat_motor_fk
      foreign key (motor_id) references vehicle_motors(id) on delete restrict;
  end if;
end $$;

-- Índice para búsquedas por marca en part_compatibility
create index if not exists idx_compat_brand on part_compatibility(vehicle_brand_id);

-- ── 3. user_vehicles: soltar constraint compuesta rígida ───────────────────
alter table user_vehicles drop constraint if exists user_vehicles_motor_belongs_to_model;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'user_vehicles_motor_fk'
  ) then
    alter table user_vehicles
      add constraint user_vehicles_motor_fk
      foreign key (motor_id) references vehicle_motors(id) on delete cascade;
  end if;
end $$;
