-- supabase/migrations/0006_seed_categories.sql
-- Siembra las categorías/sistemas reales del negocio. Los slugs son estables y
-- los usa el frontend para elegir el ícono de cada categoría (CategoryIcon.vue).
-- Idempotente por slug: re-correrla no duplica.

insert into categories (name, slug) values
  ('Alimentación e Inyección', 'alimentacion-e-inyeccion'),
  ('Carrocería',               'carroceria'),
  ('Dirección y Suspensión',   'direccion-y-suspension'),
  ('Freno',                    'freno'),
  ('Lubricantes',              'lubricantes'),
  ('Motor',                    'motor'),
  ('Sistema Eléctrico',        'sistema-electrico'),
  ('Sistema Escape',           'sistema-escape'),
  ('Transmisión',              'transmision')
on conflict (slug) do nothing;
