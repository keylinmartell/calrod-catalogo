-- supabase/migrations/0016_vehicle_models_motors.sql
-- Nomencladores de MODELO y MOTOR de auto. Completa la jerarquía del vehículo:
--
--   vehicle_brands  (Toyota)   1 ─── N   vehicle_models  (Corolla)
--   vehicle_models  (Corolla)  1 ─── N   vehicle_motors  (1.8L)
--   vehicle_motors  (1.8L)     1 ─── N   part_compatibility
--
-- Hasta 0013 solo la marca era una entidad; modelo y motor eran texto libre en
-- part_compatibility. Eso impedía dos cosas: que el panel administrara qué
-- modelos existen por marca, y que un cliente guardara SU auto como referencia
-- estable (0017) — un texto no se puede referenciar.
--
-- Tras esta migración part_compatibility ya NO guarda la marca: se deriva del
-- modelo (vehicle_models.vehicle_brand_id). Un solo lugar dice a qué marca
-- pertenece un modelo, así que no hay dato duplicado que pueda desincronizarse.
--
-- El motor sigue siendo OPCIONAL (misma regla que 0011): no todas las piezas
-- dependen del motor. motor_id null = la pieza aplica sin importar el motor.
--
-- ── Por qué cada paso va con guarda ──────────────────────────────────────────
-- El script es IDEMPOTENTE: corre igual sobre una base donde no se aplicó nunca,
-- donde se aplicó entera, o donde se aplicó A MEDIAS. Ese último caso no es
-- hipotético: una corrida parcial dejó vehicle_models/vehicle_motors creadas
-- pero part_compatibility con el esquema viejo (vehicle_model y motor en texto,
-- más vehicle_brand_id). En ese estado PostgREST no encuentra la relación
-- part_compatibility → vehicle_models y TODO el catálogo falla con PGRST200
-- ("Could not find a relationship ... in the schema cache").

-- ── Tablas del nomenclador ───────────────────────────────────────────────────

create table if not exists vehicle_models (
  id uuid primary key default gen_random_uuid(),
  vehicle_brand_id uuid not null references vehicle_brands(id) on delete cascade,
  name text not null,                 -- ej. "Corolla"
  slug text not null,                 -- ej. "corolla"
  created_at timestamptz default now(),
  -- El slug es único DENTRO de la marca, no globalmente: dos marcas pueden
  -- tener un modelo con el mismo nombre y son modelos distintos.
  unique (vehicle_brand_id, slug)
);

create index if not exists idx_vehicle_models_brand on vehicle_models(vehicle_brand_id);

create table if not exists vehicle_motors (
  id uuid primary key default gen_random_uuid(),
  vehicle_model_id uuid not null references vehicle_models(id) on delete cascade,
  name text not null,                 -- ej. "1.8L", "2.0 TDI", "V6 3.5"
  slug text not null,                 -- ej. "1-8l"
  created_at timestamptz default now(),
  unique (vehicle_model_id, slug)
);

create index if not exists idx_vehicle_motors_model on vehicle_motors(vehicle_model_id);

-- Necesaria para la FK compuesta de más abajo, que es lo que impide asignarle a
-- una compatibilidad un motor que pertenece a OTRO modelo. user_vehicles (0017)
-- también la usa, así que puede existir ya: de ahí la guarda.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'vehicle_motors_id_model_key'
  ) then
    alter table vehicle_motors
      add constraint vehicle_motors_id_model_key unique (id, vehicle_model_id);
  end if;
end $$;

-- ── part_compatibility: modelo y motor pasan a ser FK ────────────────────────
-- Las columnas se agregan SIN referencia inline: `add column if not exists` no
-- agregaría la FK sobre una columna que ya existiera, así que cada FK va en su
-- propio bloque con guarda más abajo.
alter table part_compatibility
  add column if not exists vehicle_model_id uuid,
  add column if not exists motor_id uuid;

-- ── Semilla + backfill desde el texto libre ──────────────────────────────────
-- Solo corre si las columnas de texto TODAVÍA existen. Si una corrida anterior
-- ya las soltó no hay nada que migrar y el bloque se saltea entero: plpgsql no
-- prepara las sentencias de una rama que no se ejecuta, así que referenciar
-- columnas ya inexistentes ahí adentro no rompe nada.
--
-- Igual que 0012 y 0013, el texto existente no se descarta: se convierte en
-- nomenclador. El slug se deriva con la misma fórmula que slugify() del
-- frontend (minúsculas + guiones) para que ambos lados coincidan.
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'part_compatibility'
      and column_name = 'vehicle_model'
  ) then
    raise notice '0016: part_compatibility ya migrada, no hay backfill que hacer';
    return;
  end if;

  -- Modelos. `on conflict do nothing` porque el nomenclador puede tener filas
  -- de una corrida anterior o cargadas a mano desde el panel admin.
  insert into vehicle_models (vehicle_brand_id, name, slug)
  select distinct on (brand_id, slug) brand_id, name, slug
  from (
    select
      c.vehicle_brand_id as brand_id,
      btrim(c.vehicle_model) as name,
      regexp_replace(
        regexp_replace(lower(btrim(c.vehicle_model)), '[^a-z0-9]+', '-', 'g'),
        '(^-+|-+$)', '', 'g'
      ) as slug
    from part_compatibility c
    where btrim(c.vehicle_model) <> ''
  ) src
  where slug <> ''
  -- El primer nombre por (marca, slug) gana: "CX-5" y "CX 5" caen en el mismo
  -- modelo en vez de duplicarlo.
  order by brand_id, slug, name
  on conflict (vehicle_brand_id, slug) do nothing;

  insert into vehicle_motors (vehicle_model_id, name, slug)
  select distinct on (model_id, slug) model_id, name, slug
  from (
    select
      m.id as model_id,
      btrim(c.motor) as name,
      regexp_replace(
        regexp_replace(lower(btrim(c.motor)), '[^a-z0-9]+', '-', 'g'),
        '(^-+|-+$)', '', 'g'
      ) as slug
    from part_compatibility c
    join vehicle_models m
      on m.vehicle_brand_id = c.vehicle_brand_id
     and m.slug = regexp_replace(
           regexp_replace(lower(btrim(c.vehicle_model)), '[^a-z0-9]+', '-', 'g'),
           '(^-+|-+$)', '', 'g'
         )
    where c.motor is not null and btrim(c.motor) <> ''
  ) src
  where slug <> ''
  order by model_id, slug, name
  on conflict (vehicle_model_id, slug) do nothing;

  -- Enlaza cada compatibilidad con su modelo y, si lo tenía, con su motor.
  update part_compatibility c
  set vehicle_model_id = m.id
  from vehicle_models m
  where c.vehicle_model_id is null
    and m.vehicle_brand_id = c.vehicle_brand_id
    and m.slug = regexp_replace(
          regexp_replace(lower(btrim(c.vehicle_model)), '[^a-z0-9]+', '-', 'g'),
          '(^-+|-+$)', '', 'g'
        );

  update part_compatibility c
  set motor_id = mo.id
  from vehicle_motors mo
  where c.motor_id is null
    and mo.vehicle_model_id = c.vehicle_model_id
    and mo.slug = regexp_replace(
          regexp_replace(lower(btrim(c.motor)), '[^a-z0-9]+', '-', 'g'),
          '(^-+|-+$)', '', 'g'
        );

  -- Filas cuyo modelo era texto vacío: no dicen para qué auto sirve la pieza,
  -- así que no hay dato que preservar (mismo criterio que 0013 con la marca).
  delete from part_compatibility where vehicle_model_id is null;
end $$;

alter table part_compatibility alter column vehicle_model_id set not null;

-- La guarda mira si YA existe alguna FK de part_compatibility hacia
-- vehicle_models, no un nombre concreto: una corrida vieja pudo dejarla con el
-- nombre automático de Postgres y no queremos una FK duplicada.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.part_compatibility'::regclass
      and contype = 'f'
      and confrelid = 'public.vehicle_models'::regclass
  ) then
    alter table part_compatibility
      add constraint part_compat_model_fk
      foreign key (vehicle_model_id) references vehicle_models(id) on delete restrict;
  end if;
end $$;

-- FK compuesta: un motor solo se puede usar junto al modelo al que pertenece.
-- Con MATCH SIMPLE (el default), si motor_id es null la FK NO se comprueba, que
-- es justo lo que hace falta para que el motor siga siendo opcional. Por eso
-- motor_id no lleva además una FK simple a vehicle_motors: sería redundante.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'part_compat_motor_belongs_to_model'
  ) then
    alter table part_compatibility
      add constraint part_compat_motor_belongs_to_model
      foreign key (motor_id, vehicle_model_id)
      references vehicle_motors (id, vehicle_model_id)
      on delete restrict;
  end if;
end $$;

-- El texto libre ya no se usa. Al soltar las columnas Postgres se lleva los
-- índices que las incluían (idx_compat_vehicle de 0013, idx_compat_motor de
-- 0011), así que se recrean sobre las FK nuevas.
alter table part_compatibility
  drop column if exists vehicle_brand_id,
  drop column if exists vehicle_model,
  drop column if exists motor;

create index if not exists idx_compat_model on part_compatibility(vehicle_model_id);
create index if not exists idx_compat_motor on part_compatibility(motor_id);

-- ── RLS ──────────────────────────────────────────────────────────────────────
-- Mismo patrón que categories (0005), brands (0012) y vehicle_brands (0013):
-- lectura pública (los filtros del catálogo y el selector de "Mis autos" los
-- necesitan sin sesión) y escritura solo admin via is_admin() de 0003.
--
-- Cada policy va con `drop policy if exists` delante: Postgres no tiene
-- `create policy if not exists` y sin eso el script no se podría repetir.

alter table vehicle_models enable row level security;

drop policy if exists "Lectura publica de modelos de auto" on vehicle_models;
create policy "Lectura publica de modelos de auto" on vehicle_models for select
  using (true);
drop policy if exists "Admin inserta modelos de auto" on vehicle_models;
create policy "Admin inserta modelos de auto" on vehicle_models for insert
  with check (is_admin());
drop policy if exists "Admin edita modelos de auto" on vehicle_models;
create policy "Admin edita modelos de auto" on vehicle_models for update
  using (is_admin()) with check (is_admin());
drop policy if exists "Admin borra modelos de auto" on vehicle_models;
create policy "Admin borra modelos de auto" on vehicle_models for delete
  using (is_admin());

alter table vehicle_motors enable row level security;

drop policy if exists "Lectura publica de motores" on vehicle_motors;
create policy "Lectura publica de motores" on vehicle_motors for select
  using (true);
drop policy if exists "Admin inserta motores" on vehicle_motors;
create policy "Admin inserta motores" on vehicle_motors for insert
  with check (is_admin());
drop policy if exists "Admin edita motores" on vehicle_motors;
create policy "Admin edita motores" on vehicle_motors for update
  using (is_admin()) with check (is_admin());
drop policy if exists "Admin borra motores" on vehicle_motors;
create policy "Admin borra motores" on vehicle_motors for delete
  using (is_admin());
