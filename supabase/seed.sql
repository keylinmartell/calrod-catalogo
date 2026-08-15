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

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1000-X', 'Disco de freno ventilado', (select id from categories where slug = 'freno'), 'CalRod Original', 'original', 822.30, 'disponible', 'Disco de freno ventilado CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1000-x.jpg')
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
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Fit', 2011, 2013),
  ((select id from p), 'Mazda', 'CX-3', 2014, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1001-Z', 'Cilindro maestro de freno', (select id from categories where slug = 'freno'), 'CalRod Original', 'remanufacturada', 5363.07, 'disponible', 'Cilindro maestro de freno CalRod Original. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1001-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '269mm'),
  ((select id from p), 'Diámetro', '291mm'),
  ((select id from p), 'Espesor', '10mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'City', 2009, 2015),
  ((select id from p), 'Mazda', 'Mazda6', 2010, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1002-E', 'Balatas delanteras cerámicas', (select id from categories where slug = 'freno'), 'TorqueLine', 'remanufacturada', 1515.21, 'agotado', 'Balatas delanteras cerámicas TorqueLine. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1002-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Cerámica'),
  ((select id from p), 'Diámetro', '307mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sorento', 2019, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1003-P', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), 'CalRod Plus', 'original', 5933.71, 'stock_bajo', 'Balatas traseras semimetálicas CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1003-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '272mm'),
  ((select id from p), 'Espesor', '14mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'March', 2019, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1004-S', 'Cable de freno de mano', (select id from categories where slug = 'freno'), 'CalRod Original', 'original', 1919.60, 'disponible', 'Cable de freno de mano CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1004-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Longitud', '276mm'),
  ((select id from p), 'Diámetro', '263mm'),
  ((select id from p), 'Espesor', '12mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Camry', 2018, 2018),
  ((select id from p), 'Honda', 'City', 2013, 2018),
  ((select id from p), 'Toyota', 'Avanza', 2015, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1005-K', 'Balatas delanteras cerámicas', (select id from categories where slug = 'freno'), 'CalRod Plus', 'original', 2878.60, 'agotado', 'Balatas delanteras cerámicas CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1005-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Cerámica'),
  ((select id from p), 'Diámetro', '266mm'),
  ((select id from p), 'Espesor', '17mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Avanza', 2018, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1006-S', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), 'ProAuto', 'remanufacturada', 4069.17, 'disponible', 'Balatas traseras semimetálicas ProAuto. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1006-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '299mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Jetta', 2014, 2016),
  ((select id from p), 'Toyota', 'RAV4', 2010, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1007-L', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), 'TorqueLine', 'original', 1553.27, 'disponible', 'Balatas traseras semimetálicas TorqueLine. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1007-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '278mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sorento', 2020, 2022),
  ((select id from p), 'Mazda', 'Mazda3', 2010, 2013),
  ((select id from p), 'Volkswagen', 'Gol', 2013, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1008-Y', 'Cable de freno de mano', (select id from categories where slug = 'freno'), 'MotorMex', 'remanufacturada', 902.86, 'stock_bajo', 'Cable de freno de mano MotorMex. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1008-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Longitud', '277mm'),
  ((select id from p), 'Diámetro', '298mm'),
  ((select id from p), 'Espesor', '26mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Cruze', 2016, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1009-Z', 'Disco de freno sólido', (select id from categories where slug = 'freno'), 'TorqueLine', 'remanufacturada', 4698.27, 'disponible', 'Disco de freno sólido TorqueLine. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1009-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '245mm'),
  ((select id from p), 'Espesor', '24mm'),
  ((select id from p), 'Diámetro', '281mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Aveo', 2011, 2012),
  ((select id from p), 'Mazda', 'Mazda6', 2013, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1010-Z', 'Kit de tambor de freno', (select id from categories where slug = 'freno'), 'ProAuto', 'original', 1401.52, 'agotado', 'Kit de tambor de freno ProAuto. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1010-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '293mm'),
  ((select id from p), 'Diámetro', '255mm'),
  ((select id from p), 'Espesor', '26mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'RAV4', 2011, 2011),
  ((select id from p), 'Nissan', 'March', 2020, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1011-I', 'Disco de freno ventilado', (select id from categories where slug = 'freno'), 'TorqueLine', 'original', 6036.98, 'disponible', 'Disco de freno ventilado TorqueLine. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cerámica', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1011-i.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '309mm'),
  ((select id from p), 'Espesor', '15mm'),
  ((select id from p), 'Diámetro', '303mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sportage', 2018, 2023),
  ((select id from p), 'Chevrolet', 'Silverado', 2010, 2016),
  ((select id from p), 'Toyota', 'Corolla', 2012, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1012-K', 'Balatas traseras semimetálicas', (select id from categories where slug = 'freno'), 'CalRod Original', 'original', 4809.25, 'agotado', 'Balatas traseras semimetálicas CalRod Original. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1012-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Semimetálica'),
  ((select id from p), 'Diámetro', '318mm'),
  ((select id from p), 'Espesor', '13mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sorento', 2008, 2011),
  ((select id from p), 'Honda', 'Civic', 2016, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1013-X', 'Disco de freno ventilado', (select id from categories where slug = 'freno'), 'CalRod Original', 'remanufacturada', 4806.95, 'disponible', 'Disco de freno ventilado CalRod Original. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1013-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '259mm'),
  ((select id from p), 'Espesor', '24mm'),
  ((select id from p), 'Diámetro', '263mm'),
  ((select id from p), 'Espesor', '11mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Polo', 2015, 2017),
  ((select id from p), 'Nissan', 'Sentra', 2010, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1014-Z', 'Cilindro maestro de freno', (select id from categories where slug = 'freno'), 'TorqueLine', 'remanufacturada', 4867.37, 'stock_bajo', 'Cilindro maestro de freno TorqueLine. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Semimetálico', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1014-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '318mm'),
  ((select id from p), 'Diámetro', '307mm'),
  ((select id from p), 'Espesor', '28mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Golf', 2013, 2014),
  ((select id from p), 'Chevrolet', 'Cavalier', 2011, 2012),
  ((select id from p), 'Chevrolet', 'Silverado', 2015, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1015-Y', 'Disco de freno sólido', (select id from categories where slug = 'freno'), 'CalRod Original', 'remanufacturada', 4009.95, 'disponible', 'Disco de freno sólido CalRod Original. Refacción para frenos, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Hierro fundido', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1015-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '280mm'),
  ((select id from p), 'Espesor', '19mm'),
  ((select id from p), 'Diámetro', '260mm'),
  ((select id from p), 'Espesor', '13mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Corolla', 2015, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('BR-1016-O', 'Cilindro maestro de freno', (select id from categories where slug = 'freno'), 'CalRod Plus', 'original', 6200.15, 'disponible', 'Cilindro maestro de freno CalRod Plus. Refacción para frenos, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/br-1016-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Diámetro', '304mm'),
  ((select id from p), 'Diámetro', '316mm'),
  ((select id from p), 'Espesor', '11mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Spark', 2018, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1017-R', 'Bujía de iridio', (select id from categories where slug = 'motor'), 'MotorMex', 'remanufacturada', 1585.03, 'disponible', 'Bujía de iridio MotorMex. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1017-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '59 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Rio', 2017, 2021),
  ((select id from p), 'Volkswagen', 'Vento', 2017, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1018-K', 'Bujía de iridio', (select id from categories where slug = 'motor'), 'MotorMex', 'alternativa', 3211.11, 'stock_bajo', 'Bujía de iridio MotorMex. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1018-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '42 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Hilux', 2016, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1019-I', 'Termostato', (select id from categories where slug = 'motor'), 'TorqueLine', 'remanufacturada', 4813.30, 'stock_bajo', 'Termostato TorqueLine. Refacción para motor, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1019-i.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Apertura', '25°C'),
  ((select id from p), 'Presión', '36 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Vento', 2010, 2010),
  ((select id from p), 'Toyota', 'Camry', 2018, 2023),
  ((select id from p), 'Nissan', 'X-Trail', 2013, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1020-P', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), 'CalRod Original', 'original', 718.28, 'stock_bajo', 'Sensor de oxígeno CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1020-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '139'),
  ((select id from p), 'Presión', '55 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Jetta', 2015, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1021-V', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), 'CalRod Plus', 'original', 3629.01, 'disponible', 'Sensor de oxígeno CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1021-v.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '120'),
  ((select id from p), 'Presión', '30 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Jetta', 2008, 2014),
  ((select id from p), 'Nissan', 'Altima', 2011, 2017),
  ((select id from p), 'Volkswagen', 'Golf', 2017, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1022-D', 'Bomba de agua', (select id from categories where slug = 'motor'), 'MotorMex', 'original', 3856.04, 'disponible', 'Bomba de agua MotorMex. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1022-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '316mm'),
  ((select id from p), 'Presión', '63 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Corolla', 2018, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1023-D', 'Bomba de gasolina', (select id from categories where slug = 'motor'), 'MotorMex', 'alternativa', 2966.55, 'stock_bajo', 'Bomba de gasolina MotorMex. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1023-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Presión', '122 psi'),
  ((select id from p), 'Presión', '64 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Yaris', 2019, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1024-O', 'Bomba de agua', (select id from categories where slug = 'motor'), 'TorqueLine', 'alternativa', 4539.63, 'disponible', 'Bomba de agua TorqueLine. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1024-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '296mm'),
  ((select id from p), 'Presión', '45 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Onix', 2018, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1025-M', 'Sensor de oxígeno', (select id from categories where slug = 'motor'), 'CalRod Original', 'original', 340.58, 'disponible', 'Sensor de oxígeno CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1025-m.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Cables', '105'),
  ((select id from p), 'Presión', '59 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Fit', 2009, 2010),
  ((select id from p), 'Volkswagen', 'Vento', 2018, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1026-N', 'Banda de distribución', (select id from categories where slug = 'motor'), 'CalRod Plus', 'alternativa', 907.16, 'disponible', 'Banda de distribución CalRod Plus. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1026-n.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Dientes', '139'),
  ((select id from p), 'Ancho', '28mm'),
  ((select id from p), 'Presión', '58 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Sentra', 2008, 2009),
  ((select id from p), 'Toyota', 'RAV4', 2019, 2024),
  ((select id from p), 'Nissan', 'March', 2020, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1027-L', 'Bujía de iridio', (select id from categories where slug = 'motor'), 'CalRod Plus', 'original', 974.03, 'disponible', 'Bujía de iridio CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1027-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '50 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Rio', 2015, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1028-B', 'Bujía de iridio', (select id from categories where slug = 'motor'), 'CalRod Original', 'original', 1751.11, 'disponible', 'Bujía de iridio CalRod Original. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1028-b.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Apertura', '0.9mm'),
  ((select id from p), 'Presión', '38 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda6', 2012, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1029-F', 'Banda de distribución', (select id from categories where slug = 'motor'), 'ProAuto', 'alternativa', 2449.64, 'agotado', 'Banda de distribución ProAuto. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Iridio', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1029-f.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Dientes', '4'),
  ((select id from p), 'Ancho', '27mm'),
  ((select id from p), 'Presión', '63 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Sentra', 2015, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1030-F', 'Termostato', (select id from categories where slug = 'motor'), 'TorqueLine', 'original', 1002.79, 'agotado', 'Termostato TorqueLine. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1030-f.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Apertura', '107°C'),
  ((select id from p), 'Presión', '46 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Accord', 2014, 2014),
  ((select id from p), 'Chevrolet', 'Onix', 2010, 2015),
  ((select id from p), 'Mazda', 'Mazda6', 2009, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1031-R', 'Termostato', (select id from categories where slug = 'motor'), 'TorqueLine', 'original', 5408.03, 'disponible', 'Termostato TorqueLine. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1031-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Apertura', '127°C'),
  ((select id from p), 'Presión', '51 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Altima', 2019, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1032-G', 'Bomba de agua', (select id from categories where slug = 'motor'), 'MotorMex', 'alternativa', 1951.02, 'disponible', 'Bomba de agua MotorMex. Refacción para motor, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero inoxidable', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1032-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '302mm'),
  ((select id from p), 'Presión', '61 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda3', 2017, 2023),
  ((select id from p), 'Chevrolet', 'Cavalier', 2012, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EN-1033-J', 'Junta de cabeza', (select id from categories where slug = 'motor'), 'CalRod Plus', 'original', 5016.82, 'agotado', 'Junta de cabeza CalRod Plus. Refacción para motor, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/en-1033-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'MLS'),
  ((select id from p), 'Presión', '44 psi')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'RAV4', 2018, 2024),
  ((select id from p), 'Nissan', 'March', 2020, 2021),
  ((select id from p), 'Volkswagen', 'Polo', 2012, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1034-Q', 'Resorte helicoidal', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Original', 'alternativa', 2333.33, 'disponible', 'Resorte helicoidal CalRod Original. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1034-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Espiras', '124'),
  ((select id from p), 'Longitud', '421mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Camry', 2020, 2020),
  ((select id from p), 'Chevrolet', 'Spark', 2019, 2025),
  ((select id from p), 'Chevrolet', 'Cruze', 2009, 2011);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1035-D', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Plus', 'original', 393.81, 'disponible', 'Amortiguador delantero de gas CalRod Plus. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1035-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '451mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda6', 2013, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1036-S', 'Resorte helicoidal', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Original', 'original', 560.22, 'disponible', 'Resorte helicoidal CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1036-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Espiras', '129'),
  ((select id from p), 'Longitud', '442mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-3', 2009, 2012),
  ((select id from p), 'Toyota', 'Corolla', 2011, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1037-J', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), 'MotorMex', 'alternativa', 2006.71, 'disponible', 'Terminal de dirección MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1037-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '300mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Silverado', 2020, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1038-F', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Plus', 'original', 5058.11, 'agotado', 'Horquilla de suspensión CalRod Plus. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1038-f.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '514mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-5', 2013, 2016),
  ((select id from p), 'Chevrolet', 'Aveo', 2013, 2019),
  ((select id from p), 'Honda', 'Civic', 2015, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1039-Q', 'Rótula inferior', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Original', 'original', 3590.09, 'stock_bajo', 'Rótula inferior CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1039-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M12'),
  ((select id from p), 'Longitud', '307mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Soul', 2020, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1040-Y', 'Terminal de dirección', (select id from categories where slug = 'direccion-y-suspension'), 'MotorMex', 'alternativa', 3482.37, 'disponible', 'Terminal de dirección MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1040-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M14'),
  ((select id from p), 'Longitud', '420mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-3', 2010, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1041-H', 'Amortiguador trasero hidráulico', (select id from categories where slug = 'direccion-y-suspension'), 'MotorMex', 'alternativa', 526.15, 'disponible', 'Amortiguador trasero hidráulico MotorMex. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1041-h.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Trasera'),
  ((select id from p), 'Tipo', 'Hidráulico'),
  ((select id from p), 'Longitud', '422mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Altima', 2009, 2012),
  ((select id from p), 'Chevrolet', 'Cruze', 2019, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1042-W', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), 'ProAuto', 'alternativa', 6043.29, 'disponible', 'Amortiguador delantero de gas ProAuto. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1042-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '388mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'City', 2009, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1043-U', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Original', 'original', 2980.51, 'stock_bajo', 'Horquilla de suspensión CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1043-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '439mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Silverado', 2009, 2010);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1044-T', 'Base de amortiguador', (select id from categories where slug = 'direccion-y-suspension'), 'TorqueLine', 'original', 2209.63, 'disponible', 'Base de amortiguador TorqueLine. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1044-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Material', 'Caucho-metal'),
  ((select id from p), 'Longitud', '427mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Gol', 2016, 2016),
  ((select id from p), 'Nissan', 'March', 2015, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1045-U', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), 'MotorMex', 'remanufacturada', 1353.47, 'disponible', 'Amortiguador delantero de gas MotorMex. Refacción para suspension, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1045-u.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '497mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Fit', 2008, 2014),
  ((select id from p), 'Nissan', 'March', 2009, 2009);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1046-Z', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), 'TorqueLine', 'alternativa', 2171.58, 'agotado', 'Horquilla de suspensión TorqueLine. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Caucho', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1046-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '371mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'X-Trail', 2010, 2011),
  ((select id from p), 'Toyota', 'Hilux', 2019, 2019),
  ((select id from p), 'Nissan', 'March', 2014, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1047-D', 'Amortiguador delantero de gas', (select id from categories where slug = 'direccion-y-suspension'), 'TorqueLine', 'remanufacturada', 3355.56, 'disponible', 'Amortiguador delantero de gas TorqueLine. Refacción para suspension, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1047-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Tipo', 'Gas'),
  ((select id from p), 'Longitud', '283mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Civic', 2016, 2019),
  ((select id from p), 'Mazda', 'Mazda6', 2013, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1048-N', 'Resorte helicoidal', (select id from categories where slug = 'direccion-y-suspension'), 'CalRod Original', 'original', 5771.28, 'disponible', 'Resorte helicoidal CalRod Original. Refacción para suspension, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1048-n.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Espiras', '73'),
  ((select id from p), 'Longitud', '426mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Aveo', 2008, 2013),
  ((select id from p), 'Kia', 'Sportage', 2009, 2014),
  ((select id from p), 'Volkswagen', 'Polo', 2017, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1049-D', 'Resorte helicoidal', (select id from categories where slug = 'direccion-y-suspension'), 'TorqueLine', 'alternativa', 452.56, 'disponible', 'Resorte helicoidal TorqueLine. Refacción para suspension, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1049-d.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Espiras', '130'),
  ((select id from p), 'Longitud', '482mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Soul', 2017, 2023),
  ((select id from p), 'Toyota', 'RAV4', 2010, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('SU-1050-V', 'Horquilla de suspensión', (select id from categories where slug = 'direccion-y-suspension'), 'ProAuto', 'remanufacturada', 4027.89, 'disponible', 'Horquilla de suspensión ProAuto. Refacción para suspension, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aluminio forjado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/su-1050-v.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Longitud', '467mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Forte', 2010, 2010);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1051-W', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), 'CalRod Plus', 'remanufacturada', 3301.85, 'disponible', 'Marcha / motor de arranque CalRod Plus. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1051-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '27kW'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '67A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Corolla', 2017, 2018),
  ((select id from p), 'Chevrolet', 'Aveo', 2008, 2012);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1052-E', 'Motor de limpiaparabrisas', (select id from categories where slug = 'sistema-electrico'), 'CalRod Original', 'remanufacturada', 5717.21, 'disponible', 'Motor de limpiaparabrisas CalRod Original. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1052-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '101A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Accord', 2010, 2012),
  ((select id from p), 'Kia', 'Rio', 2014, 2018),
  ((select id from p), 'Nissan', 'Frontier', 2010, 2010);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1053-E', 'Motor de limpiaparabrisas', (select id from categories where slug = 'sistema-electrico'), 'TorqueLine', 'original', 3474.04, 'disponible', 'Motor de limpiaparabrisas TorqueLine. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1053-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '105A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'March', 2011, 2011),
  ((select id from p), 'Nissan', 'X-Trail', 2016, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1054-W', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'remanufacturada', 4052.88, 'disponible', 'Marcha / motor de arranque MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1054-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '86kW'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '76A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda3', 2009, 2011);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1055-I', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'alternativa', 5227.88, 'agotado', 'Marcha / motor de arranque MotorMex. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1055-i.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '135kW'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Cruze', 2013, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1056-Q', 'Bobina de encendido', (select id from categories where slug = 'sistema-electrico'), 'CalRod Original', 'remanufacturada', 203.44, 'disponible', 'Bobina de encendido CalRod Original. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1056-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '107A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'RAV4', 2015, 2020),
  ((select id from p), 'Honda', 'City', 2016, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1057-E', 'Faro delantero halógeno', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'alternativa', 4779.21, 'disponible', 'Faro delantero halógeno MotorMex. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1057-e.jpg')
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
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda6', 2011, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1058-Y', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), 'TorqueLine', 'original', 1991.00, 'agotado', 'Regulador de voltaje TorqueLine. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1058-y.jpg')
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
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Forte', 2008, 2009),
  ((select id from p), 'Volkswagen', 'Golf', 2019, 2022),
  ((select id from p), 'Honda', 'CR-V', 2015, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1059-Z', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'remanufacturada', 3954.99, 'disponible', 'Marcha / motor de arranque MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1059-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '17kW'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '66A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Forte', 2015, 2015),
  ((select id from p), 'Kia', 'Rio', 2019, 2025),
  ((select id from p), 'Chevrolet', 'Onix', 2013, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1060-B', 'Marcha / motor de arranque', (select id from categories where slug = 'sistema-electrico'), 'TorqueLine', 'alternativa', 1660.26, 'stock_bajo', 'Marcha / motor de arranque TorqueLine. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1060-b.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Potencia', '96kW'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Tiguan', 2019, 2019),
  ((select id from p), 'Toyota', 'Yaris', 2014, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1061-G', 'Bobina de encendido', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'original', 6374.29, 'stock_bajo', 'Bobina de encendido MotorMex. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1061-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '102A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Rio', 2015, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1062-W', 'Alternador 90A', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'remanufacturada', 1366.52, 'stock_bajo', 'Alternador 90A MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1062-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Amperaje', '90A'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '89A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-3', 2014, 2020),
  ((select id from p), 'Chevrolet', 'Cruze', 2015, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1063-X', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'original', 903.01, 'disponible', 'Regulador de voltaje MotorMex. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Aleación', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1063-x.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '76A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda6', 2020, 2021),
  ((select id from p), 'Honda', 'HR-V', 2008, 2012);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1064-G', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), 'CalRod Plus', 'original', 3539.87, 'agotado', 'Regulador de voltaje CalRod Plus. Refacción para electrico, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1064-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '63A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda6', 2016, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1065-Y', 'Batería 12V 65Ah', (select id from categories where slug = 'sistema-electrico'), 'CalRod Plus', 'alternativa', 606.42, 'disponible', 'Batería 12V 65Ah CalRod Plus. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1065-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Capacidad', '65Ah'),
  ((select id from p), 'CCA', '37A'),
  ((select id from p), 'Voltaje', '12V')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Silverado', 2018, 2024),
  ((select id from p), 'Mazda', 'Mazda6', 2016, 2017),
  ((select id from p), 'Toyota', 'Avanza', 2010, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1066-G', 'Regulador de voltaje', (select id from categories where slug = 'sistema-electrico'), 'MotorMex', 'remanufacturada', 6447.78, 'stock_bajo', 'Regulador de voltaje MotorMex. Refacción para electrico, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1066-g.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '14.4V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '60A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Jetta', 2015, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('EL-1067-S', 'Motor de limpiaparabrisas', (select id from categories where slug = 'sistema-electrico'), 'CalRod Original', 'alternativa', 429.20, 'disponible', 'Motor de limpiaparabrisas CalRod Original. Refacción para electrico, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cobre', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/el-1067-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Voltaje', '12V'),
  ((select id from p), 'Amperaje', '105A')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Golf', 2019, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1068-S', 'Parrilla frontal', (select id from categories where slug = 'carroceria'), 'CalRod Original', 'original', 933.69, 'disponible', 'Parrilla frontal CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1068-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Acabado', 'Negro brillante'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Tiguan', 2010, 2010),
  ((select id from p), 'Volkswagen', 'Polo', 2020, 2025);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1069-G', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), 'CalRod Plus', 'original', 2223.61, 'agotado', 'Espejo lateral eléctrico CalRod Plus. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1069-g.jpg')
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
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-5', 2015, 2019),
  ((select id from p), 'Honda', 'Civic', 2009, 2015);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1070-L', 'Moldura de defensa', (select id from categories where slug = 'carroceria'), 'MotorMex', 'original', 4967.11, 'agotado', 'Moldura de defensa MotorMex. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1070-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Tiguan', 2011, 2017),
  ((select id from p), 'Mazda', 'Mazda2', 2018, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1071-J', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), 'CalRod Original', 'remanufacturada', 2913.88, 'disponible', 'Manija exterior de puerta CalRod Original. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1071-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Accord', 2011, 2016),
  ((select id from p), 'Nissan', 'March', 2019, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1072-J', 'Moldura de defensa', (select id from categories where slug = 'carroceria'), 'CalRod Original', 'original', 4956.11, 'agotado', 'Moldura de defensa CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1072-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Polo', 2014, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1073-L', 'Cristal de puerta', (select id from categories where slug = 'carroceria'), 'TorqueLine', 'alternativa', 2629.36, 'disponible', 'Cristal de puerta TorqueLine. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1073-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Trasera der.'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-5', 2011, 2014);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1074-E', 'Espejo lateral eléctrico', (select id from categories where slug = 'carroceria'), 'MotorMex', 'remanufacturada', 3245.86, 'disponible', 'Espejo lateral eléctrico MotorMex. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1074-e.jpg')
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
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Chevrolet', 'Cavalier', 2012, 2017),
  ((select id from p), 'Volkswagen', 'Polo', 2017, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1075-I', 'Faro de niebla', (select id from categories where slug = 'carroceria'), 'CalRod Plus', 'remanufacturada', 842.49, 'agotado', 'Faro de niebla CalRod Plus. Refacción para carroceria, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cromo', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1075-i.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Conector', 'H11'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sportage', 2020, 2023);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1076-Y', 'Bisagra de cofre', (select id from categories where slug = 'carroceria'), 'TorqueLine', 'alternativa', 4258.17, 'agotado', 'Bisagra de cofre TorqueLine. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1076-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Izquierdo'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Yaris', 2009, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1077-A', 'Faro de niebla', (select id from categories where slug = 'carroceria'), 'CalRod Plus', 'alternativa', 1462.61, 'stock_bajo', 'Faro de niebla CalRod Plus. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1077-a.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Conector', 'H11'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Sorento', 2014, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1078-Z', 'Parrilla frontal', (select id from categories where slug = 'carroceria'), 'MotorMex', 'original', 5339.09, 'disponible', 'Parrilla frontal MotorMex. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1078-z.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Acabado', 'Negro brillante'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'CR-V', 2008, 2009),
  ((select id from p), 'Mazda', 'Mazda3', 2013, 2018),
  ((select id from p), 'Honda', 'HR-V', 2013, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1079-T', 'Moldura de defensa', (select id from categories where slug = 'carroceria'), 'CalRod Plus', 'original', 3774.97, 'disponible', 'Moldura de defensa CalRod Plus. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Plástico ABS', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1079-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Fit', 2020, 2025);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1080-J', 'Manija exterior de puerta', (select id from categories where slug = 'carroceria'), 'CalRod Original', 'original', 4787.09, 'disponible', 'Manija exterior de puerta CalRod Original. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1080-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Delantera izq.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'X-Trail', 2009, 2015),
  ((select id from p), 'Volkswagen', 'Jetta', 2019, 2023),
  ((select id from p), 'Mazda', 'Mazda3', 2015, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1081-A', 'Cristal de puerta', (select id from categories where slug = 'carroceria'), 'ProAuto', 'alternativa', 3683.88, 'disponible', 'Cristal de puerta ProAuto. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cromo', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1081-a.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Lado', 'Trasera der.'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Honda', 'Accord', 2017, 2021),
  ((select id from p), 'Volkswagen', 'Gol', 2017, 2021),
  ((select id from p), 'Mazda', 'Mazda6', 2008, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1082-M', 'Faro de niebla', (select id from categories where slug = 'carroceria'), 'TorqueLine', 'alternativa', 5192.45, 'stock_bajo', 'Faro de niebla TorqueLine. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Cromo', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1082-m.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Conector', 'H11'),
  ((select id from p), 'Acabado', 'Cromo')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Soul', 2015, 2017);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1083-Q', 'Parrilla frontal', (select id from categories where slug = 'carroceria'), 'ProAuto', 'original', 3248.60, 'disponible', 'Parrilla frontal ProAuto. Refacción para carroceria, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Acero', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1083-q.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Acabado', 'Negro brillante'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Yaris', 2012, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('CA-1084-O', 'Moldura de defensa', (select id from categories where slug = 'carroceria'), 'TorqueLine', 'alternativa', 3945.67, 'stock_bajo', 'Moldura de defensa TorqueLine. Refacción para carroceria, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Vidrio templado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/ca-1084-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Posición', 'Delantera'),
  ((select id from p), 'Acabado', 'Negro')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Corolla', 2008, 2010);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1085-J', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Plus', 'original', 6400.11, 'disponible', 'Filtro de aire de alto flujo CalRod Plus. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1085-j.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '65mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Vento', 2016, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1086-O', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'MotorMex', 'original', 3545.95, 'disponible', 'Filtro de aire de alto flujo MotorMex. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1086-o.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '89mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Polo', 2011, 2015),
  ((select id from p), 'Chevrolet', 'Silverado', 2017, 2021);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1087-P', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Plus', 'remanufacturada', 5991.36, 'disponible', 'Filtro de gasolina CalRod Plus. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1087-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '101mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'Yaris', 2011, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1088-Y', 'Filtro de aire de motor', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'TorqueLine', 'original', 2216.42, 'disponible', 'Filtro de aire de motor TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1088-y.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Forma', 'Panel'),
  ((select id from p), 'Altura', '147mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Toyota', 'RAV4', 2018, 2023),
  ((select id from p), 'Honda', 'Civic', 2016, 2022),
  ((select id from p), 'Toyota', 'Yaris', 2014, 2019);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1089-W', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Original', 'original', 4582.66, 'disponible', 'Filtro de gasolina CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1089-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '116mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'Mazda2', 2018, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1090-A', 'Filtro de aire de motor', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'ProAuto', 'original', 5974.43, 'disponible', 'Filtro de aire de motor ProAuto. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1090-a.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Forma', 'Panel'),
  ((select id from p), 'Altura', '147mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Gol', 2013, 2017),
  ((select id from p), 'Chevrolet', 'Cruze', 2019, 2023),
  ((select id from p), 'Mazda', 'CX-3', 2012, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1091-W', 'Filtro de aire de motor', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Plus', 'original', 3376.70, 'disponible', 'Filtro de aire de motor CalRod Plus. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1091-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Forma', 'Panel'),
  ((select id from p), 'Altura', '139mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Sentra', 2020, 2023);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1092-S', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Original', 'original', 3496.47, 'agotado', 'Filtro de gasolina CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1092-s.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '133mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Golf', 2012, 2014),
  ((select id from p), 'Mazda', 'Mazda2', 2017, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1093-P', 'Filtro de aire de motor', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Original', 'remanufacturada', 4401.59, 'disponible', 'Filtro de aire de motor CalRod Original. Refacción para filtros, calidad remanufacturada. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1093-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Forma', 'Panel'),
  ((select id from p), 'Altura', '120mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'X-Trail', 2020, 2021),
  ((select id from p), 'Volkswagen', 'Polo', 2014, 2014),
  ((select id from p), 'Volkswagen', 'Golf', 2018, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1094-W', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'MotorMex', 'alternativa', 3400.80, 'disponible', 'Filtro de aire de alto flujo MotorMex. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1094-w.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '70mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Kia', 'Soul', 2011, 2016),
  ((select id from p), 'Mazda', 'Mazda6', 2010, 2014),
  ((select id from p), 'Toyota', 'Camry', 2020, 2024);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1095-P', 'Filtro de aceite', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Plus', 'alternativa', 929.75, 'disponible', 'Filtro de aceite CalRod Plus. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Carbón activado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1095-p.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Rosca', 'M20x1.5'),
  ((select id from p), 'Altura', '91mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Jetta', 2018, 2021),
  ((select id from p), 'Volkswagen', 'Polo', 2008, 2009),
  ((select id from p), 'Toyota', 'Avanza', 2016, 2016);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1096-R', 'Filtro de gasolina', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'MotorMex', 'original', 5606.33, 'disponible', 'Filtro de gasolina MotorMex. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1096-r.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Entrada', '8mm'),
  ((select id from p), 'Altura', '90mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Volkswagen', 'Golf', 2017, 2022);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1097-T', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Original', 'original', 5016.75, 'disponible', 'Filtro de cabina de carbón CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Sintético', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1097-t.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '96mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-3', 2015, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1098-E', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'ProAuto', 'alternativa', 5139.93, 'disponible', 'Filtro de cabina de carbón ProAuto. Refacción para filtros, calidad alternativa. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1098-e.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '65mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Frontier', 2010, 2014),
  ((select id from p), 'Mazda', 'Mazda3', 2014, 2017),
  ((select id from p), 'Toyota', 'Hilux', 2016, 2018);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1099-L', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'TorqueLine', 'original', 753.47, 'stock_bajo', 'Filtro de aire de alto flujo TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1099-l.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '147mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Sentra', 2008, 2013),
  ((select id from p), 'Toyota', 'Camry', 2015, 2020);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1100-K', 'Filtro de cabina de carbón', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'CalRod Original', 'original', 4865.24, 'disponible', 'Filtro de cabina de carbón CalRod Original. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Papel plisado', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1100-k.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Carbón activado'),
  ((select id from p), 'Altura', '141mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Nissan', 'Sentra', 2017, 2018),
  ((select id from p), 'Kia', 'Rio', 2010, 2013);

with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('FI-1101-M', 'Filtro de aire de alto flujo', (select id from categories where slug = 'alimentacion-e-inyeccion'), 'TorqueLine', 'original', 6408.94, 'stock_bajo', 'Filtro de aire de alto flujo TorqueLine. Refacción para filtros, calidad original. Compatible con múltiples modelos; revisa la lista de compatibilidad.', 'Algodón', 'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images/fi-1101-m.jpg')
  on conflict (code) do update set name = excluded.name
  returning id
),
s as (
  insert into part_specs (part_id, label, value) values
  ((select id from p), 'Tipo', 'Lavable'),
  ((select id from p), 'Altura', '96mm')
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
  ((select id from p), 'Mazda', 'CX-5', 2015, 2015);

