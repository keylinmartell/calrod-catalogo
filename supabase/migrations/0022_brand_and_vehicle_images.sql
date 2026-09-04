-- supabase/migrations/0022_brand_and_vehicle_images.sql
-- Añade soporte para logos de marcas y fotos de modelos de vehículos.

-- 1. Logo para marcas de auto (nomenclador de vehículos: Toyota, Chevrolet, etc.)
alter table vehicle_brands
  add column if not exists logo_url text;

-- 2. Logo para marcas de repuestos (fabricantes de piezas: Wurtex, STP, etc.)
alter table brands
  add column if not exists logo_url text;

-- 3. Foto para modelos de auto (ej. foto de la camioneta/auto)
alter table vehicle_models
  add column if not exists image_url text;

-- Recargar esquema de PostgREST
notify pgrst, 'reload schema';
