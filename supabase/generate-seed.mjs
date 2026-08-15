// Genera supabase/seed.sql de forma determinista (~100 piezas realistas
// en las 6 categorías, con specs y 1-3 registros de compatibilidad c/u).
// Uso: node supabase/generate-seed.mjs  ->  escribe supabase/seed.sql
//
// image_url apunta al bucket público 'part-images'. Ajusta BUCKET_BASE si tu
// project ref cambia, o sube fotos con esos mismos nombres de archivo.
import { writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const BUCKET_BASE =
  'https://hmlrgoylsevzlaereeco.supabase.co/storage/v1/object/public/part-images'

// PRNG determinista (mulberry32) para que el seed sea reproducible sin Math.random.
let _s = 0x9e3779b9
function rnd() {
  _s |= 0
  _s = (_s + 0x6d2b79f5) | 0
  let t = Math.imul(_s ^ (_s >>> 15), 1 | _s)
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296
}
const pick = (arr) => arr[Math.floor(rnd() * arr.length)]
const int = (min, max) => min + Math.floor(rnd() * (max - min + 1))
const esc = (s) => String(s).replace(/'/g, "''")

const VEHICLES = {
  Nissan: ['Sentra', 'Versa', 'March', 'Altima', 'Frontier', 'X-Trail'],
  Toyota: ['Corolla', 'Yaris', 'Hilux', 'RAV4', 'Camry', 'Avanza'],
  Chevrolet: ['Aveo', 'Spark', 'Cruze', 'Onix', 'Cavalier', 'Silverado'],
  Volkswagen: ['Jetta', 'Vento', 'Golf', 'Tiguan', 'Polo', 'Gol'],
  Kia: ['Rio', 'Forte', 'Sportage', 'Sorento', 'Soul'],
  Mazda: ['Mazda3', 'Mazda2', 'CX-5', 'CX-3', 'Mazda6'],
  Honda: ['Civic', 'City', 'CR-V', 'Fit', 'Accord', 'HR-V'],
}
const VEHICLE_BRANDS = Object.keys(VEHICLES)

// Plantillas por categoría: nombre, prefijo de SKU, specs típicas, materiales.
const CATS = {
  frenos: {
    prefix: 'BR',
    items: [
      ['Balatas delanteras cerámicas', [['Posición', 'Delantera'], ['Tipo', 'Cerámica']]],
      ['Balatas traseras semimetálicas', [['Posición', 'Trasera'], ['Tipo', 'Semimetálica']]],
      ['Disco de freno ventilado', [['Diámetro', '{d}mm'], ['Espesor', '{t}mm']]],
      ['Disco de freno sólido', [['Diámetro', '{d}mm'], ['Espesor', '{t}mm']]],
      ['Kit de tambor de freno', [['Diámetro', '{d}mm']]],
      ['Cilindro maestro de freno', [['Diámetro', '{d}mm']]],
      ['Cable de freno de mano', [['Longitud', '{d}mm']]],
    ],
    materials: ['Cerámica', 'Hierro fundido', 'Acero', 'Semimetálico'],
    specExtra: () => [['Diámetro', `${int(240, 320)}mm`], ['Espesor', `${int(10, 30)}mm`]],
  },
  motor: {
    prefix: 'EN',
    items: [
      ['Bujía de iridio', [['Rosca', 'M14'], ['Apertura', '0.9mm']]],
      ['Bomba de agua', [['Entrada', '{d}mm']]],
      ['Banda de distribución', [['Dientes', '{n}'], ['Ancho', '{t}mm']]],
      ['Junta de cabeza', [['Material', 'MLS']]],
      ['Termostato', [['Apertura', '{n}°C']]],
      ['Sensor de oxígeno', [['Cables', '{n}']]],
      ['Bomba de gasolina', [['Presión', '{n} psi']]],
    ],
    materials: ['Aluminio', 'Acero inoxidable', 'Iridio', 'Aleación'],
    specExtra: () => [['Presión', `${int(30, 65)} psi`]],
  },
  suspension: {
    prefix: 'SU',
    items: [
      ['Amortiguador delantero de gas', [['Posición', 'Delantera'], ['Tipo', 'Gas']]],
      ['Amortiguador trasero hidráulico', [['Posición', 'Trasera'], ['Tipo', 'Hidráulico']]],
      ['Rótula inferior', [['Rosca', 'M12']]],
      ['Terminal de dirección', [['Rosca', 'M14']]],
      ['Base de amortiguador', [['Material', 'Caucho-metal']]],
      ['Horquilla de suspensión', [['Lado', 'Izquierdo']]],
      ['Resorte helicoidal', [['Espiras', '{n}']]],
    ],
    materials: ['Acero', 'Caucho', 'Aluminio forjado'],
    specExtra: () => [['Longitud', `${int(280, 520)}mm`]],
  },
  electrico: {
    prefix: 'EL',
    items: [
      ['Alternador 90A', [['Amperaje', '90A'], ['Voltaje', '12V']]],
      ['Marcha / motor de arranque', [['Voltaje', '12V'], ['Potencia', '{n}kW']]],
      ['Batería 12V 65Ah', [['Capacidad', '65Ah'], ['CCA', '{n}A']]],
      ['Bobina de encendido', [['Voltaje', '12V']]],
      ['Regulador de voltaje', [['Voltaje', '14.4V']]],
      ['Faro delantero halógeno', [['Conector', 'H4']]],
      ['Motor de limpiaparabrisas', [['Voltaje', '12V']]],
    ],
    materials: ['Cobre', 'Plástico ABS', 'Aleación'],
    specExtra: () => [['Voltaje', '12V'], ['Amperaje', `${int(60, 120)}A`]],
  },
  carroceria: {
    prefix: 'CA',
    items: [
      ['Espejo lateral eléctrico', [['Lado', 'Derecho'], ['Ajuste', 'Eléctrico']]],
      ['Faro de niebla', [['Conector', 'H11']]],
      ['Manija exterior de puerta', [['Lado', 'Delantera izq.']]],
      ['Parrilla frontal', [['Acabado', 'Negro brillante']]],
      ['Moldura de defensa', [['Posición', 'Delantera']]],
      ['Cristal de puerta', [['Lado', 'Trasera der.']]],
      ['Bisagra de cofre', [['Lado', 'Izquierdo']]],
    ],
    materials: ['Plástico ABS', 'Vidrio templado', 'Acero', 'Cromo'],
    specExtra: () => [['Acabado', pick(['Negro', 'Cromo', 'Pintable'])]],
  },
  filtros: {
    prefix: 'FI',
    items: [
      ['Filtro de aceite', [['Rosca', 'M20x1.5']]],
      ['Filtro de aire de motor', [['Forma', 'Panel']]],
      ['Filtro de cabina de carbón', [['Tipo', 'Carbón activado']]],
      ['Filtro de gasolina', [['Entrada', '8mm']]],
      ['Filtro de transmisión', [['Tipo', 'Automática']]],
      ['Filtro de aire de alto flujo', [['Tipo', 'Lavable']]],
    ],
    materials: ['Papel plisado', 'Algodón', 'Carbón activado', 'Sintético'],
    specExtra: () => [['Altura', `${int(60, 160)}mm`]],
  },
}

const ORIGINS = ['original', 'alternativa', 'remanufacturada']
const AVAIL = ['disponible', 'disponible', 'disponible', 'stock_bajo', 'agotado']
const REFACTION_BRANDS = ['CalRod Original', 'CalRod Plus', 'TorqueLine', 'MotorMex', 'ProAuto']

function fillSpec(v) {
  return v
    .replace('{d}', int(240, 320))
    .replace('{t}', int(8, 28))
    .replace('{n}', int(2, 140))
}

const rows = []
let counter = 1000

for (const [cat, cfg] of Object.entries(CATS)) {
  // ~16-17 piezas por categoría -> ~100 en total.
  for (let i = 0; i < 17; i++) {
    const [baseName, baseSpecs] = pick(cfg.items)
    const brand = pick(REFACTION_BRANDS)
    const origin = brand.startsWith('CalRod') && rnd() > 0.4 ? 'original' : pick(ORIGINS)
    const code = `${cfg.prefix}-${counter++}-${String.fromCharCode(65 + int(0, 25))}`
    const name = baseName
    const price = (int(180, 6500) + rnd()).toFixed(2)
    const availability = pick(AVAIL)
    const material = pick(cfg.materials)
    const fileName = `${code.toLowerCase()}.jpg`
    const image_url = `${BUCKET_BASE}/${fileName}`
    const description = `${name} ${brand}. Refacción para ${cat}, calidad ${origin}. Compatible con múltiples modelos; revisa la lista de compatibilidad.`

    const specs = [...baseSpecs, ...cfg.specExtra()]
      .slice(0, int(3, 5))
      .map(([label, value]) => [label, fillSpec(value)])

    // 1-3 registros de compatibilidad, marcas/modelos reales.
    const compat = []
    const nCompat = int(1, 3)
    const usedBrands = new Set()
    for (let c = 0; c < nCompat; c++) {
      const vb = pick(VEHICLE_BRANDS)
      const vm = pick(VEHICLES[vb])
      const key = `${vb}|${vm}`
      if (usedBrands.has(key)) continue
      usedBrands.add(key)
      const yFrom = int(2008, 2020)
      const yTo = Math.min(yFrom + int(0, 6), 2025)
      compat.push([vb, vm, yFrom, yTo])
    }

    rows.push({ code, name, cat, brand, origin, price, availability, description, material, image_url, specs, compat })
  }
}

// Ensamblar SQL. Primero se crean las categorías reales del negocio; luego cada
// pieza resuelve su category_id por slug con una subconsulta. Los slugs coinciden
// con los usados por CategoryIcon.vue en el frontend. La clave de CATS (arriba)
// mapea a estos slugs vía CAT_SLUG.
const CATEGORY_ROWS = [
  ['Alimentación e Inyección', 'alimentacion-e-inyeccion'],
  ['Carrocería', 'carroceria'],
  ['Dirección y Suspensión', 'direccion-y-suspension'],
  ['Freno', 'freno'],
  ['Lubricantes', 'lubricantes'],
  ['Motor', 'motor'],
  ['Sistema Eléctrico', 'sistema-electrico'],
  ['Sistema Escape', 'sistema-escape'],
  ['Transmisión', 'transmision'],
]

// Mapa de la clave interna de CATS al slug real de la categoría.
const CAT_SLUG = {
  frenos: 'freno',
  motor: 'motor',
  suspension: 'direccion-y-suspension',
  electrico: 'sistema-electrico',
  carroceria: 'carroceria',
  filtros: 'alimentacion-e-inyeccion',
}

let sql = `-- supabase/seed.sql
-- Datos de ejemplo del catálogo CalRod (${rows.length} piezas).
-- Correr UNA sola vez desde el SQL Editor de Supabase (o via Supabase CLI).
-- Idempotente en 'parts' por 'code' (on conflict do nothing); specs/compat se
-- insertan resolviendo el id por code, así puedes re-correrlo tras un truncate.

-- Categorías (slug estable; parts.category_id apunta aquí).
insert into categories (name, slug) values
${CATEGORY_ROWS.map(([name, slug]) => `  ('${esc(name)}', '${slug}')`).join(',\n')}
on conflict (slug) do nothing;

`

for (const r of rows) {
  const catSlug = CAT_SLUG[r.cat] ?? r.cat
  sql += `with p as (
  insert into parts (code, name, category_id, brand, origin_type, price, availability, description, material, image_url)
  values ('${esc(r.code)}', '${esc(r.name)}', (select id from categories where slug = '${catSlug}'), '${esc(r.brand)}', '${r.origin}', ${r.price}, '${r.availability}', '${esc(r.description)}', '${esc(r.material)}', '${esc(r.image_url)}')
  on conflict (code) do update set name = excluded.name
  returning id
)`
  const specVals = r.specs
    .map(([l, v]) => `  ((select id from p), '${esc(l)}', '${esc(v)}')`)
    .join(',\n')
  const compatVals = r.compat
    .map(([vb, vm, yf, yt]) => `  ((select id from p), '${esc(vb)}', '${esc(vm)}', ${yf}, ${yt})`)
    .join(',\n')

  sql += `,
s as (
  insert into part_specs (part_id, label, value) values
${specVals}
  returning 1
)
insert into part_compatibility (part_id, vehicle_brand, vehicle_model, year_from, year_to) values
${compatVals};

`
}

writeFileSync(join(__dirname, 'seed.sql'), sql, 'utf8')
console.log(`seed.sql generado con ${rows.length} piezas.`)
