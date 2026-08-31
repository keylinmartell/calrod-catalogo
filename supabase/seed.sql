-- supabase/seed.sql
-- Datos de ejemplo del catálogo CalRod (102 piezas).
-- Correr UNA sola vez desde el SQL Editor de Supabase (o via Supabase CLI).
-- Idempotente en 'parts' por 'code' (on conflict do nothing); specs/compat se
-- insertan resolviendo el id por code, así puedes re-correrlo tras un truncate.

-- Categorías (slug estable; parts.category_id apunta aquí).
insert into categories (name, slug) values
  ('Alimentación e Inyección', 'alimentacion-e-inyeccion'),
  ('Carrocería', 'carroceria'),
  ('Dirección y Suspensión', 'direccion-y-suspension'),
  ('Freno', 'freno'),
  ('Lubricantes', 'lubricantes'),
  ('Motor', 'motor'),
  ('Sistema Eléctrico', 'sistema-electrico'),
  ('Sistema Escape', 'sistema-escape'),
  ('Transmisión', 'transmision')
on conflict (slug) do nothing;

-- Nota: las marcas (brands) NO se siembran. Se introducen manualmente desde el
-- panel admin; las piezas nacen sin marca (brand_id = null) y se asignan luego.

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1000-X', 'Disco de freno ventilado', (select id from categories where slug = 'freno'), null, 'original', 822.30, 'disponible', 'Disco de freno ventilado CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1000-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '264mm'),
  ((select id from p), 'Espesor', '13mm'),
  ((select id from p), 'Diámetro', '275mm'),
  ((select id from p), 'Espesor', '21mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Fit', 2011, 2013, '1.5 Turbo'),
  ((select id from p), 'Kia', 'Soul', 2017, 2020, null),
  ((select id from p), 'Mazda', 'Mazda3', 2012, 2017, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1001-Q', 'Cilindro maestro de freno', (select id from categories where slug = 'freno'), null, 'original', 456.95, 'disponible', 'Cilindro maestro de freno CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1001-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '254mm'),
  ((select id from p), 'Diámetro', '289mm'),
  ((select id from p), 'Espesor', '24mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'City', 2013, 2013, '1.8L'),
  ((select id from p), 'Honda', 'Civic', 2010, 2011, '1.5 Turbo'),
  ((select id from p), 'Volkswagen', 'Polo', 2008, 2009, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1002-M', 'Disco de freno ventilado', (select id from categories where slug = 'freno'), null, 'alternativa', 2409.61, 'disponible', 'Disco de freno ventilado CalRod Original. Refacción para frenos, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1002-m.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '278mm'),
  ((select id from p), 'Espesor', '20mm'),
  ((select id from p), 'Diámetro', '292mm'),
  ((select id from p), 'Espesor', '26mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Spark', 2017, 2020, 'V6 3.5'),
  ((select id from p), 'Volkswagen', 'Golf', 2009, 2013, null),
  ((select id from p), 'Chevrolet', 'Aveo', 2008, 2011, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1003-O', 'Disco de freno sólido', (select id from categories where slug = 'freno'), null, 'original', 4580.28, 'disponible', 'Disco de freno sólido ProAuto. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1003-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '273mm'),
  ((select id from p), 'Espesor', '16mm'),
  ((select id from p), 'Diámetro', '291mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda2', 2018, 2023, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1004-T', 'Cable de freno de mano', (select id from categories where slug = 'freno'), null, 'original', 1311.93, 'stock_bajo', 'Cable de freno de mano CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1004-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Longitud', '271mm'),
  ((select id from p), 'Diámetro', '240mm'),
  ((select id from p), 'Espesor', '15mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Soul', 2019, 2020, null),
  ((select id from p), 'Honda', 'CR-V', 2015, 2019, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1005-U', 'Balatas delanteras cerámicas', (select id from categories where slug = 'freno'), null, 'original', 793.21, 'agotado', 'Balatas delanteras cerámicas CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1005-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Cerámica'),
  ((select id from p), 'Diámetro', '297mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Camry', 2020, 2021, '1.8L'),
  ((select id from p), 'Volkswagen', 'Jetta', 2014, 2016, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1006-D', 'Kit de tambor de freno', (select id from categories where slug = 'freno'), null, 'original', 3849.16, 'disponible', 'Kit de tambor de freno CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1006-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '278mm'),
  ((select id from p), 'Diámetro', '262mm'),
  ((select id from p), 'Espesor', '12mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Sportage', 2016, 2020, '2.4L'),
  ((select id from p), 'Honda', 'CR-V', 2018, 2018, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1007-L', 'Disco de freno sólido', (select id from categories where slug = 'freno'), null, 'remanufacturada', 5621.89, 'stock_bajo', 'Disco de freno sólido TorqueLine. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1007-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '304mm'),
  ((select id from p), 'Espesor', '13mm'),
  ((select id from p), 'Diámetro', '316mm'),
  ((select id from p), 'Espesor', '12mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2012, 2014, '2.4L'),
  ((select id from p), 'Honda', 'CR-V', 2015, 2020, '1.5 Turbo'),
  ((select id from p), 'Mazda', 'Mazda2', 2009, 2015, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1008-T', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), null, 'original', 1039.77, 'agotado', 'Balatas traseras semimetálicas CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1008-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '306mm'),
  ((select id from p), 'Espesor', '13mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'City', 2014, 2019, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1009-R', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), null, 'original', 4459.71, 'disponible', 'Balatas traseras semimetálicas ProAuto. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1009-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '303mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Onix', 2010, 2012, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1010-U', 'Cable de freno de mano', (select id from categories where slug = 'freno'), null, 'remanufacturada', 1322.85, 'stock_bajo', 'Cable de freno de mano CalRod Plus. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1010-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Longitud', '287mm'),
  ((select id from p), 'Diámetro', '294mm'),
  ((select id from p), 'Espesor', '17mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Avanza', 2011, 2011, null),
  ((select id from p), 'Kia', 'Forte', 2010, 2013, '1.6L'),
  ((select id from p), 'Mazda', 'Mazda2', 2018, 2024, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1011-O', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), null, 'alternativa', 2520.09, 'disponible', 'Balatas traseras semimetálicas TorqueLine. Refacción para frenos, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1011-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '299mm'),
  ((select id from p), 'Espesor', '23mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Sentra', 2019, 2025, '2.4L'),
  ((select id from p), 'Honda', 'Civic', 2012, 2014, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1012-V', 'Cable de freno de mano', (select id from categories where slug = 'freno'), null, 'original', 5185.09, 'agotado', 'Cable de freno de mano CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1012-v.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Longitud', '266mm'),
  ((select id from p), 'Diámetro', '319mm'),
  ((select id from p), 'Espesor', '14mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-5', 2018, 2024, '2.4L'),
  ((select id from p), 'Chevrolet', 'Cavalier', 2018, 2023, '1.5 Turbo'),
  ((select id from p), 'Honda', 'HR-V', 2009, 2009, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1013-L', 'Balatas delanteras cerámicas', (select id from categories where slug = 'freno'), null, 'remanufacturada', 2650.98, 'disponible', 'Balatas delanteras cerámicas MotorMex. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1013-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Cerámica'),
  ((select id from p), 'Diámetro', '271mm'),
  ((select id from p), 'Espesor', '14mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'City', 2013, 2014, null),
  ((select id from p), 'Kia', 'Sportage', 2011, 2016, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1014-B', 'Disco de freno sólido', (select id from categories where slug = 'freno'), null, 'remanufacturada', 5847.13, 'disponible', 'Disco de freno sólido ProAuto. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1014-b.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '287mm'),
  ((select id from p), 'Espesor', '14mm'),
  ((select id from p), 'Diámetro', '258mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Soul', 2009, 2014, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1015-H', 'Cilindro maestro de freno', (select id from categories where slug = 'freno'), null, 'alternativa', 5995.44, 'agotado', 'Cilindro maestro de freno MotorMex. Refacción para frenos, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1015-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '304mm'),
  ((select id from p), 'Diámetro', '241mm'),
  ((select id from p), 'Espesor', '16mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda6', 2019, 2021, 'V6 3.5'),
  ((select id from p), 'Volkswagen', 'Gol', 2017, 2022, '1.5 Turbo'),
  ((select id from p), 'Mazda', 'CX-5', 2015, 2015, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('BR-1016-S', 'Kit de tambor de freno', (select id from categories where slug = 'freno'), null, 'original', 2863.02, 'stock_bajo', 'Kit de tambor de freno TorqueLine. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1016-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '289mm'),
  ((select id from p), 'Diámetro', '271mm'),
  ((select id from p), 'Espesor', '20mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Spark', 2011, 2012, null),
  ((select id from p), 'Volkswagen', 'Polo', 2011, 2015, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1017-H', 'Bomba de gasolina', (select id from categories where slug = 'motor'), null, 'original', 4013.14, 'disponible', 'Bomba de gasolina CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1017-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Presión', '39 psi'),
  ((select id from p), 'Presión', '59 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Corolla', 2011, 2016, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1018-L', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), null, 'original', 1964.74, 'disponible', 'Sensor de oxígeno CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1018-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '21'),
  ((select id from p), 'Presión', '51 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'CR-V', 2017, 2022, null),
  ((select id from p), 'Volkswagen', 'Jetta', 2015, 2017, 'V6 3.5'),
  ((select id from p), 'Chevrolet', 'Spark', 2009, 2014, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1019-K', 'Bujía de iridio', (select id from categories where slug = 'motor'), null, 'original', 3045.98, 'agotado', 'Bujía de iridio CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1019-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '48 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Cavalier', 2011, 2012, '2.4L'),
  ((select id from p), 'Toyota', 'Corolla', 2015, 2015, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1020-Y', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), null, 'remanufacturada', 4604.84, 'stock_bajo', 'Sensor de oxígeno ProAuto. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1020-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '118'),
  ((select id from p), 'Presión', '54 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Hilux', 2015, 2020, '1.5 Turbo'),
  ((select id from p), 'Honda', 'Civic', 2017, 2022, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1021-C', 'Junta de cabeza', (select id from categories where slug = 'motor'), null, 'alternativa', 1540.20, 'agotado', 'Junta de cabeza MotorMex. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1021-c.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'MLS'),
  ((select id from p), 'Presión', '38 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Polo', 2012, 2012, '1.5 Turbo'),
  ((select id from p), 'Honda', 'Civic', 2009, 2011, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1022-C', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), null, 'remanufacturada', 3942.46, 'disponible', 'Sensor de oxígeno MotorMex. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1022-c.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '71'),
  ((select id from p), 'Presión', '36 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Silverado', 2020, 2024, null),
  ((select id from p), 'Toyota', 'Hilux', 2010, 2015, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1023-C', 'Junta de cabeza', (select id from categories where slug = 'motor'), null, 'alternativa', 2670.51, 'disponible', 'Junta de cabeza CalRod Plus. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1023-c.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'MLS'),
  ((select id from p), 'Presión', '30 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Onix', 2008, 2012, 'V6 3.5'),
  ((select id from p), 'Nissan', 'Sentra', 2008, 2009, null),
  ((select id from p), 'Kia', 'Soul', 2018, 2018, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1024-N', 'Bomba de gasolina', (select id from categories where slug = 'motor'), null, 'original', 2891.13, 'disponible', 'Bomba de gasolina CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1024-n.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Presión', '37 psi'),
  ((select id from p), 'Presión', '65 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Accord', 2008, 2009, '1.8L'),
  ((select id from p), 'Nissan', 'Altima', 2020, 2020, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1025-H', 'Termostato', (select id from categories where slug = 'motor'), null, 'original', 5769.22, 'stock_bajo', 'Termostato CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1025-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Apertura', '66°C'),
  ((select id from p), 'Presión', '47 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda6', 2012, 2016, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1026-J', 'Bomba de gasolina', (select id from categories where slug = 'motor'), null, 'original', 4250.81, 'disponible', 'Bomba de gasolina TorqueLine. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1026-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Presión', '87 psi'),
  ((select id from p), 'Presión', '54 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Vento', 2008, 2008, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1027-C', 'Bomba de agua', (select id from categories where slug = 'motor'), null, 'alternativa', 1624.13, 'stock_bajo', 'Bomba de agua TorqueLine. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1027-c.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '266mm'),
  ((select id from p), 'Presión', '47 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda6', 2018, 2021, null),
  ((select id from p), 'Chevrolet', 'Onix', 2010, 2015, '2.4L'),
  ((select id from p), 'Honda', 'Civic', 2020, 2024, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1028-A', 'Bujía de iridio', (select id from categories where slug = 'motor'), null, 'remanufacturada', 2432.32, 'disponible', 'Bujía de iridio MotorMex. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1028-a.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '44 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Forte', 2011, 2012, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1029-L', 'Bomba de agua', (select id from categories where slug = 'motor'), null, 'original', 5023.45, 'disponible', 'Bomba de agua CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1029-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '270mm'),
  ((select id from p), 'Presión', '53 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Spark', 2014, 2015, '1.5 Turbo'),
  ((select id from p), 'Chevrolet', 'Cavalier', 2018, 2024, 'V6 3.5'),
  ((select id from p), 'Chevrolet', 'Aveo', 2013, 2018, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1030-W', 'Banda de distribución', (select id from categories where slug = 'motor'), null, 'remanufacturada', 1509.65, 'agotado', 'Banda de distribución MotorMex. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1030-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Dientes', '79'),
  ((select id from p), 'Ancho', '14mm'),
  ((select id from p), 'Presión', '32 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Forte', 2012, 2012, 'V6 3.5'),
  ((select id from p), 'Kia', 'Soul', 2018, 2022, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1031-X', 'Termostato', (select id from categories where slug = 'motor'), null, 'remanufacturada', 1521.77, 'agotado', 'Termostato TorqueLine. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1031-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Apertura', '48°C'),
  ((select id from p), 'Presión', '41 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Cruze', 2009, 2009, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1032-J', 'Junta de cabeza', (select id from categories where slug = 'motor'), null, 'original', 5460.33, 'agotado', 'Junta de cabeza CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1032-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'MLS'),
  ((select id from p), 'Presión', '31 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Avanza', 2009, 2015, '2.4L'),
  ((select id from p), 'Nissan', 'Versa', 2014, 2017, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EN-1033-X', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), null, 'remanufacturada', 5353.69, 'disponible', 'Sensor de oxígeno MotorMex. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1033-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '24'),
  ((select id from p), 'Presión', '60 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda2', 2012, 2014, '2.4L'),
  ((select id from p), 'Toyota', 'Yaris', 2009, 2012, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1034-F', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 5657.18, 'disponible', 'Horquilla de suspensión ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1034-f.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '518mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Avanza', 2019, 2022, null),
  ((select id from p), 'Honda', 'HR-V', 2013, 2014, '2.4L'),
  ((select id from p), 'Mazda', 'CX-5', 2013, 2016, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1035-W', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 1187.61, 'disponible', 'Amortiguador delantero de gas CalRod Plus. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1035-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '319mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Onix', 2016, 2017, '1.8L'),
  ((select id from p), 'Honda', 'HR-V', 2009, 2012, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1036-J', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), null, 'alternativa', 2356.82, 'disponible', 'Terminal de dirección ProAuto. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1036-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '338mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Camry', 2010, 2014, '1.8L'),
  ((select id from p), 'Chevrolet', 'Aveo', 2009, 2011, null),
  ((select id from p), 'Kia', 'Sportage', 2018, 2023, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1037-T', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), null, 'alternativa', 1705.91, 'disponible', 'Horquilla de suspensión MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1037-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '419mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Silverado', 2020, 2022, null),
  ((select id from p), 'Mazda', 'CX-5', 2011, 2017, '1.6L'),
  ((select id from p), 'Nissan', 'X-Trail', 2019, 2024, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1038-Y', 'Resorte helicoidal', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 1926.08, 'stock_bajo', 'Resorte helicoidal ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1038-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Espiras', '72'),
  ((select id from p), 'Longitud', '320mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2010, 2014, null),
  ((select id from p), 'Nissan', 'Sentra', 2013, 2019, null),
  ((select id from p), 'Toyota', 'RAV4', 2013, 2014, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1039-S', 'Rótula inferior', (select id from categories where slug = 'direccion-y-suspension'), null, 'alternativa', 4049.20, 'disponible', 'Rótula inferior MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1039-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M12'),
  ((select id from p), 'Longitud', '468mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'March', 2015, 2015, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1040-E', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), null, 'remanufacturada', 3181.21, 'disponible', 'Horquilla de suspensión MotorMex. Refacción para suspension, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1040-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '411mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-5', 2020, 2024, null),
  ((select id from p), 'Honda', 'Civic', 2013, 2013, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1041-P', 'Rótula inferior', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 5929.47, 'disponible', 'Rótula inferior ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1041-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M12'),
  ((select id from p), 'Longitud', '430mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2009, 2011, 'V6 3.5'),
  ((select id from p), 'Nissan', 'Sentra', 2013, 2016, '1.8L'),
  ((select id from p), 'Nissan', 'Altima', 2020, 2020, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1042-A', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 2093.59, 'disponible', 'Terminal de dirección CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1042-a.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '494mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Sportage', 2017, 2022, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1043-T', 'Rótula inferior', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 3490.88, 'disponible', 'Rótula inferior ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1043-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M12'),
  ((select id from p), 'Longitud', '292mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'CR-V', 2008, 2008, 'V6 3.5'),
  ((select id from p), 'Kia', 'Sportage', 2009, 2014, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1044-W', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), null, 'alternativa', 2870.38, 'disponible', 'Horquilla de suspensión MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1044-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '415mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Soul', 2016, 2020, '1.5 Turbo'),
  ((select id from p), 'Mazda', 'Mazda6', 2010, 2014, null),
  ((select id from p), 'Honda', 'Accord', 2019, 2024, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1045-V', 'Base de amortiguador', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 5105.04, 'disponible', 'Base de amortiguador ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1045-v.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'Caucho-metal'),
  ((select id from p), 'Longitud', '441mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2010, 2015, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1046-B', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 1001.87, 'stock_bajo', 'Terminal de dirección ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1046-b.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '450mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Sportage', 2010, 2010, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1047-Q', 'Amortiguador trasero hidráulico', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 5982.11, 'disponible', 'Amortiguador trasero hidráulico CalRod Plus. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1047-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Hidráulico'),
  ((select id from p), 'Longitud', '322mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'RAV4', 2011, 2017, 'V6 3.5'),
  ((select id from p), 'Honda', 'Accord', 2010, 2012, '1.8L'),
  ((select id from p), 'Nissan', 'Altima', 2016, 2016, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1048-M', 'Amortiguador trasero hidráulico', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 1659.16, 'disponible', 'Amortiguador trasero hidráulico CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1048-m.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Hidráulico'),
  ((select id from p), 'Longitud', '387mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Hilux', 2009, 2011, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1049-R', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 3346.22, 'stock_bajo', 'Amortiguador delantero de gas CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1049-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '489mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Rio', 2011, 2013, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('SU-1050-S', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), null, 'original', 1398.12, 'disponible', 'Terminal de dirección ProAuto. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1050-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '451mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Cavalier', 2008, 2010, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1051-R', 'Motor de limpiaparabrisas', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 1699.40, 'disponible', 'Motor de limpiaparabrisas MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1051-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '97A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Polo', 2019, 2025, '2.0L'),
  ((select id from p), 'Chevrolet', 'Cavalier', 2013, 2016, '1.6L'),
  ((select id from p), 'Toyota', 'RAV4', 2015, 2020, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1052-T', 'Batería 12V 65Ah', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 3983.34, 'disponible', 'Batería 12V 65Ah MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1052-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Capacidad', '65Ah'),
  ((select id from p), 'CCA', '42A'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '73A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda6', 2011, 2014, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1053-H', 'Bobina de encendido', (select id from categories where slug = 'sistema-electrico'), null, 'original', 209.95, 'stock_bajo', 'Bobina de encendido CalRod Original. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1053-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '67A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Aveo', 2011, 2014, '1.6L'),
  ((select id from p), 'Honda', 'Fit', 2019, 2022, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1054-U', 'Faro delantero halógeno', (select id from categories where slug = 'sistema-electrico'), null, 'original', 6337.60, 'agotado', 'Faro delantero halógeno CalRod Original. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1054-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Conector', 'H4'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '95A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Accord', 2014, 2020, '1.8L'),
  ((select id from p), 'Toyota', 'RAV4', 2008, 2012, null),
  ((select id from p), 'Honda', 'HR-V', 2013, 2016, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1055-P', 'Batería 12V 65Ah', (select id from categories where slug = 'sistema-electrico'), null, 'original', 637.23, 'disponible', 'Batería 12V 65Ah CalRod Plus. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1055-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Capacidad', '65Ah'),
  ((select id from p), 'CCA', '50A'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '94A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Civic', 2010, 2011, '2.0L'),
  ((select id from p), 'Nissan', 'March', 2018, 2018, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1056-X', 'Motor de limpiaparabrisas', (select id from categories where slug = 'sistema-electrico'), null, 'original', 4602.06, 'disponible', 'Motor de limpiaparabrisas CalRod Plus. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1056-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '97A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Altima', 2020, 2025, null),
  ((select id from p), 'Volkswagen', 'Polo', 2019, 2022, '1.6L'),
  ((select id from p), 'Honda', 'City', 2014, 2015, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1057-V', 'Bobina de encendido', (select id from categories where slug = 'sistema-electrico'), null, 'original', 3834.95, 'disponible', 'Bobina de encendido CalRod Original. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1057-v.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '111A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Sentra', 2015, 2021, null),
  ((select id from p), 'Honda', 'Civic', 2012, 2015, null),
  ((select id from p), 'Kia', 'Sportage', 2018, 2020, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1058-Y', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 1495.91, 'agotado', 'Regulador de voltaje ProAuto. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1058-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '96A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Aveo', 2010, 2016, '1.6L'),
  ((select id from p), 'Toyota', 'RAV4', 2014, 2015, 'V6 3.5'),
  ((select id from p), 'Honda', 'Fit', 2010, 2012, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1059-B', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 2822.46, 'disponible', 'Marcha / motor de arranque TorqueLine. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1059-b.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '139kW'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Accord', 2019, 2024, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1060-E', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 2992.68, 'stock_bajo', 'Regulador de voltaje CalRod Plus. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1060-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '75A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Vento', 2019, 2022, null),
  ((select id from p), 'Volkswagen', 'Jetta', 2015, 2020, '1.5 Turbo'),
  ((select id from p), 'Nissan', 'Sentra', 2016, 2020, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1061-T', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), null, 'original', 453.99, 'agotado', 'Marcha / motor de arranque TorqueLine. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1061-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '79kW'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '79A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Frontier', 2013, 2016, null),
  ((select id from p), 'Mazda', 'Mazda6', 2015, 2017, null),
  ((select id from p), 'Volkswagen', 'Golf', 2015, 2018, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1062-T', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), null, 'original', 6339.96, 'disponible', 'Marcha / motor de arranque CalRod Original. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1062-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '30kW'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Frontier', 2012, 2015, '2.0L'),
  ((select id from p), 'Honda', 'CR-V', 2017, 2020, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1063-D', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), null, 'original', 6180.65, 'stock_bajo', 'Regulador de voltaje ProAuto. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1063-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '88A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Fit', 2014, 2017, null),
  ((select id from p), 'Honda', 'Accord', 2013, 2018, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1064-J', 'Batería 12V 65Ah', (select id from categories where slug = 'sistema-electrico'), null, 'remanufacturada', 2913.88, 'disponible', 'Batería 12V 65Ah CalRod Original. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1064-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Capacidad', '65Ah'),
  ((select id from p), 'CCA', '129A'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '67A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'City', 2017, 2017, null),
  ((select id from p), 'Toyota', 'Hilux', 2017, 2017, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1065-O', 'Bobina de encendido', (select id from categories where slug = 'sistema-electrico'), null, 'alternativa', 5181.35, 'disponible', 'Bobina de encendido TorqueLine. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1065-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '72A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2013, 2019, null),
  ((select id from p), 'Volkswagen', 'Jetta', 2011, 2016, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1066-H', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), null, 'alternativa', 3640.80, 'disponible', 'Regulador de voltaje MotorMex. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1066-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '98A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Gol', 2013, 2019, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('EL-1067-U', 'Batería 12V 65Ah', (select id from categories where slug = 'sistema-electrico'), null, 'original', 2476.81, 'disponible', 'Batería 12V 65Ah TorqueLine. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1067-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Capacidad', '65Ah'),
  ((select id from p), 'CCA', '16A'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Rio', 2011, 2014, '1.6L'),
  ((select id from p), 'Mazda', 'Mazda3', 2011, 2015, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1068-L', 'Bisagra de cofre', (select id from categories where slug = 'carroceria'), null, 'remanufacturada', 2425.94, 'stock_bajo', 'Bisagra de cofre TorqueLine. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1068-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Acabado', 'Pintable')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Spark', 2010, 2012, null),
  ((select id from p), 'Kia', 'Rio', 2013, 2015, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1069-T', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), null, 'original', 1903.17, 'disponible', 'Espejo lateral eléctrico CalRod Plus. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1069-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Derecho'),
  ((select id from p), 'Ajuste', 'Eléctrico'),
  ((select id from p), 'Acabado', 'Pintable')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Tiguan', 2009, 2015, 'V6 3.5'),
  ((select id from p), 'Nissan', 'Sentra', 2015, 2015, null),
  ((select id from p), 'Honda', 'Accord', 2017, 2021, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1070-K', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), null, 'remanufacturada', 356.16, 'stock_bajo', 'Espejo lateral eléctrico ProAuto. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1070-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Derecho'),
  ((select id from p), 'Ajuste', 'Eléctrico'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2015, 2018, '2.0L'),
  ((select id from p), 'Volkswagen', 'Tiguan', 2013, 2018, '1.6L'),
  ((select id from p), 'Nissan', 'X-Trail', 2016, 2022, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1071-J', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), null, 'original', 4787.09, 'disponible', 'Manija exterior de puerta CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1071-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'X-Trail', 2009, 2015, '2.0L'),
  ((select id from p), 'Toyota', 'Avanza', 2015, 2020, null),
  ((select id from p), 'Volkswagen', 'Tiguan', 2017, 2023, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1072-J', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), null, 'remanufacturada', 5524.13, 'agotado', 'Espejo lateral eléctrico TorqueLine. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1072-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Derecho'),
  ((select id from p), 'Ajuste', 'Eléctrico'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-3', 2018, 2023, null),
  ((select id from p), 'Mazda', 'Mazda3', 2013, 2017, '2.0L'),
  ((select id from p), 'Mazda', 'CX-5', 2016, 2021, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1073-C', 'Bisagra de cofre', (select id from categories where slug = 'carroceria'), null, 'original', 3341.18, 'disponible', 'Bisagra de cofre TorqueLine. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1073-c.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Sportage', 2014, 2014, null),
  ((select id from p), 'Chevrolet', 'Aveo', 2016, 2017, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1074-I', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), null, 'original', 1931.61, 'disponible', 'Espejo lateral eléctrico CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1074-i.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Derecho'),
  ((select id from p), 'Ajuste', 'Eléctrico'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Honda', 'Civic', 2010, 2010, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1075-T', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), null, 'original', 2410.98, 'disponible', 'Manija exterior de puerta ProAuto. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1075-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Onix', 2010, 2014, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1076-O', 'Cristal de puerta', (select id from categories where slug = 'carroceria'), null, 'original', 3545.95, 'disponible', 'Cristal de puerta MotorMex. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1076-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Trasera der.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Polo', 2011, 2015, '1.6L'),
  ((select id from p), 'Mazda', 'CX-3', 2016, 2020, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1077-X', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), null, 'alternativa', 2455.18, 'disponible', 'Manija exterior de puerta ProAuto. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1077-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2018, 2019, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1078-K', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), null, 'original', 787.00, 'agotado', 'Manija exterior de puerta ProAuto. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cromo', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1078-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-3', 2019, 2019, '1.8L'),
  ((select id from p), 'Honda', 'City', 2011, 2014, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1079-W', 'Moldura de defensa', (select id from categories where slug = 'carroceria'), null, 'original', 4582.66, 'disponible', 'Moldura de defensa CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1079-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda2', 2018, 2022, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1080-L', 'Bisagra de cofre', (select id from categories where slug = 'carroceria'), null, 'remanufacturada', 2120.67, 'agotado', 'Bisagra de cofre CalRod Original. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1080-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Acabado', 'Pintable')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Polo', 2012, 2014, 'V6 3.5'),
  ((select id from p), 'Kia', 'Soul', 2018, 2020, null),
  ((select id from p), 'Toyota', 'Hilux', 2010, 2010, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1081-G', 'Parrilla frontal', (select id from categories where slug = 'carroceria'), null, 'alternativa', 5148.41, 'disponible', 'Parrilla frontal MotorMex. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1081-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Acabado', 'Negro brillante'),
  ((select id from p), 'Acabado', 'Pintable')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Kia', 'Rio', 2018, 2022, '2.0L'),
  ((select id from p), 'Volkswagen', 'Gol', 2017, 2022, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1082-E', 'Bisagra de cofre', (select id from categories where slug = 'carroceria'), null, 'original', 555.94, 'disponible', 'Bisagra de cofre CalRod Plus. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1082-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Chevrolet', 'Silverado', 2015, 2019, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1083-X', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), null, 'original', 1529.84, 'stock_bajo', 'Manija exterior de puerta CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1083-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Jetta', 2015, 2017, 'V6 3.5'),
  ((select id from p), 'Chevrolet', 'Silverado', 2018, 2022, 'V6 3.5'),
  ((select id from p), 'Volkswagen', 'Polo', 2010, 2013, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('CA-1084-K', 'Faro de niebla', (select id from categories where slug = 'carroceria'), null, 'alternativa', 3519.78, 'stock_bajo', 'Faro de niebla ProAuto. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cromo', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1084-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Conector', 'H11'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda6', 2016, 2016, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1085-D', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'alternativa', 4937.53, 'stock_bajo', 'Filtro de aceite MotorMex. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1085-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '147mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'X-Trail', 2014, 2017, '2.4L'),
  ((select id from p), 'Nissan', 'Versa', 2010, 2015, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1086-E', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'alternativa', 4320.86, 'disponible', 'Filtro de aceite TorqueLine. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1086-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '60mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Hilux', 2014, 2018, 'V6 3.5');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1087-T', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 5016.75, 'disponible', 'Filtro de cabina de carbón CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1087-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '96mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-3', 2015, 2018, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1088-U', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 6048.42, 'disponible', 'Filtro de aire de alto flujo TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1088-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '156mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda3', 2017, 2022, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1089-J', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 4544.37, 'agotado', 'Filtro de gasolina TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1089-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '81mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-3', 2010, 2010, null),
  ((select id from p), 'Kia', 'Rio', 2009, 2009, 'V6 3.5'),
  ((select id from p), 'Toyota', 'Camry', 2015, 2020, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1090-T', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'alternativa', 1721.49, 'disponible', 'Filtro de aceite TorqueLine. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1090-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '148mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Frontier', 2011, 2015, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1091-K', 'Filtro de aire de motor', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'remanufacturada', 972.47, 'agotado', 'Filtro de aire de motor TorqueLine. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1091-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Forma', 'Panel'),
  ((select id from p), 'Altura', '129mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Corolla', 2017, 2020, '1.8L'),
  ((select id from p), 'Nissan', 'Versa', 2014, 2014, '1.6L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1092-S', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'alternativa', 3270.31, 'stock_bajo', 'Filtro de aceite ProAuto. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1092-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '125mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Nissan', 'Frontier', 2014, 2015, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1093-Z', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 4238.71, 'disponible', 'Filtro de aceite CalRod Plus. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1093-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '104mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda2', 2009, 2011, 'V6 3.5'),
  ((select id from p), 'Toyota', 'Camry', 2012, 2012, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1094-D', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 3084.01, 'disponible', 'Filtro de aire de alto flujo TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1094-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '65mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Hilux', 2019, 2023, '2.0L'),
  ((select id from p), 'Kia', 'Rio', 2016, 2016, null),
  ((select id from p), 'Honda', 'Fit', 2015, 2020, '2.0L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1095-J', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'remanufacturada', 2484.96, 'stock_bajo', 'Filtro de gasolina TorqueLine. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1095-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '114mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Toyota', 'Yaris', 2012, 2017, null),
  ((select id from p), 'Kia', 'Rio', 2008, 2014, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1096-G', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'remanufacturada', 3285.02, 'disponible', 'Filtro de gasolina TorqueLine. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1096-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '118mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-3', 2008, 2013, '1.8L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1097-K', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'remanufacturada', 346.54, 'disponible', 'Filtro de cabina de carbón MotorMex. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1097-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '159mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Tiguan', 2013, 2018, '2.4L'),
  ((select id from p), 'Toyota', 'RAV4', 2012, 2017, '2.0L'),
  ((select id from p), 'Kia', 'Forte', 2012, 2018, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1098-X', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 5659.22, 'stock_bajo', 'Filtro de cabina de carbón CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1098-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '106mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Vento', 2017, 2023, null);

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1099-H', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'remanufacturada', 572.98, 'disponible', 'Filtro de gasolina CalRod Plus. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1099-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '83mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Volkswagen', 'Polo', 2018, 2020, '1.8L'),
  ((select id from p), 'Honda', 'Fit', 2016, 2020, '2.4L'),
  ((select id from p), 'Mazda', 'Mazda3', 2011, 2017, '1.5 Turbo');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1100-Y', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'alternativa', 4703.20, 'disponible', 'Filtro de aceite ProAuto. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1100-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '79mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'Mazda3', 2012, 2012, '2.4L'),
  ((select id from p), 'Honda', 'City', 2008, 2009, '2.4L');

with p as (
  insert into parts (code, name, category_id, brand_id, origin_type, price, availability, description, material, image_url)
  values ('FI-1101-Y', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), null, 'original', 2690.94, 'stock_bajo', 'Filtro de aceite CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1101-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '123mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to, motor) values
  ((select id from p), 'Mazda', 'CX-5', 2010, 2012, '1.5 Turbo'),
  ((select id from p), 'Toyota', 'RAV4', 2009, 2012, '1.6L');

