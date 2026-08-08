-- supabase/migrations/0003_auth_profiles.sql
-- Fase 1 (cierre): autenticación con Supabase Auth + rol por usuario.
-- Las contraseñas viven en auth.users (hasheadas, fuera del alcance de la anon key).
-- Aquí solo guardamos el rol: cada usuario nace con 'user' y el cliente promueve a 'admin'.

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  email text,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz default now()
);

alter table profiles enable row level security;

-- Cada quien lee su propio profile. No se expone el rol de nadie más.
create policy "Lectura del propio profile" on profiles for select
  using (auth.uid() = id);

-- El usuario puede actualizar su fila PERO no cambiarse el rol:
-- el rol nuevo debe seguir siendo igual al actual. Promover a admin es tarea
-- del cliente desde el panel de Supabase (service role), nunca desde el navegador.
create policy "Actualizar propio profile sin tocar rol" on profiles for update
  using (auth.uid() = id)
  with check (
    auth.uid() = id
    and role = (select p.role from profiles p where p.id = auth.uid())
  );

-- Al crearse un usuario en auth.users, se inserta su profile con rol 'user'.
-- SECURITY DEFINER: corre con permisos del owner, así el trigger puede escribir
-- en profiles aunque el usuario recién creado todavía no tenga sesión.
create function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into profiles (id, email, role)
  values (new.id, new.email, 'user');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Helper para las policies de escritura (0004). SECURITY DEFINER + STABLE:
-- evita la recursión de RLS al consultar profiles desde otra policy.
create function is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  );
$$;
