# Refacciones CalRod — Catálogo (Fase 1)

Catálogo web de piezas automotrices. Frontend **Vue 3 + TypeScript + Vite**, datos y fotos en **Supabase** (Postgres + Storage), despliegue en **Vercel**. Modo oscuro por defecto. Fase 1 = solo catálogo (sin carrito ni pagos); el esquema ya queda listo para Fase 2.

## Stack

- Vue 3 (Composition API + `<script setup>`), Vue Router, Pinia
- TypeScript + Vite
- Supabase (`@supabase/supabase-js`) — lectura pública vía RLS
- CSS con design tokens (`src/styles/tokens.css`)

## Requisitos

- Node 18+ (probado con Node 22)
- Un proyecto de Supabase (URL + anon key)

## Correr en local

```bash
npm install
cp .env.example .env.local   # y rellena tus valores de Supabase
npm run dev
```

Abre http://localhost:5173.

### Variables de entorno (`.env.local`)

```
VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key-publica
```

> La anon key es **pública por diseño**: queda protegida por las policies de RLS de solo lectura. **Nunca** pongas la service role key en el frontend.

## Base de datos (Supabase)

Las migraciones y el seed están en `supabase/`:

- `migrations/0001_init.sql` — tablas `parts`, `part_specs`, `part_compatibility` + índices.
- `migrations/0002_rls_policies.sql` — activa RLS y agrega policies de `SELECT` público.
- `seed.sql` — ~100 piezas de ejemplo con specs y compatibilidad (generado por `generate-seed.mjs`).

### Pasos

1. **Crear proyecto** en [supabase.com](https://supabase.com) (región cercana al mercado).
2. En **SQL Editor**, correr en orden: `0001_init.sql`, luego `0002_rls_policies.sql`.
3. En **Storage**, crear un bucket **público** llamado `part-images`.
4. Subir las fotos de ejemplo al bucket. Los nombres de archivo esperados por el seed son `<code-en-minúsculas>.jpg` (p. ej. `br-1000-a.jpg`). Si usas otros nombres o placeholders, regenera el seed (ver abajo) o edita `image_url` en la tabla.
5. En **SQL Editor**, correr `seed.sql`.
6. Verificar en **Table Editor** que los datos y las `image_url` quedaron bien.

### Regenerar el seed

El seed se genera de forma determinista. Si cambias el project ref o los nombres de imagen, edita `BUCKET_BASE` en `supabase/generate-seed.mjs` y corre:

```bash
node supabase/generate-seed.mjs
```

> Nota: si tus piezas no tienen imagen todavía, el catálogo muestra un placeholder "Sin imagen" — no rompe nada. Puedes dejar `image_url` en `NULL`.

## Estructura

```
src/
  components/
    layout/      AppHeader, AppFooter
    brand/       LogoMark, WrenchWatermark
    catalog/     SearchBar, FilterBar, PartCard, PartGrid, HeroPanel
    part-detail/ PartSpecSheet, CompatibilityList
  composables/   useParts.ts, useFilters.ts
  services/      supabase.ts
  stores/        catalogStore.ts (Pinia)
  types/         part.ts
  views/         CatalogView, PartDetailView, NotFoundView
  styles/        tokens.css, base.css
supabase/
  migrations/    0001_init.sql, 0002_rls_policies.sql
  seed.sql, generate-seed.mjs
```

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run dev` | Servidor de desarrollo (Vite) |
| `npm run build` | Type-check (`vue-tsc`) + build de producción a `dist/` |
| `npm run preview` | Sirve el build de `dist/` localmente |
| `npm run type-check` | Solo chequeo de tipos |

## Despliegue en Vercel

1. Conectar el repo a un nuevo proyecto de Vercel (framework preset: **Vite**).
2. En **Project Settings → Environment Variables**, agregar `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY`.
3. Build command `npm run build`, output `dist/` (Vercel lo detecta solo).
4. `vercel.json` ya incluye el rewrite de SPA para que las rutas `/pieza/:id` funcionen en recarga directa.
5. Cada push a la rama principal genera un deploy de producción; cada PR genera un preview URL.

## Fase 2 (no incluida)

Puntos de extensión ya reservados en el código (busca comentarios `Fase 2`):

- `cartStore.ts` (Pinia) + `CartDrawer.vue`; botón "Agregar al carrito" en `PartCard.vue` y `PartDetailView.vue`.
- Vista de checkout y confirmación de pedido.
- Tablas `orders`, `order_items` y activación de **Supabase Auth**.
- Policies de RLS por usuario.

Las tablas de Fase 2 se agregan **sin tocar** `parts` / `part_specs` / `part_compatibility`.
