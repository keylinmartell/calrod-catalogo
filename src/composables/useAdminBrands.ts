import { supabase } from '@/services/supabase'
import type { Brand, BrandInput } from '@/types/part'

/** Convierte un nombre en slug estable: minúsculas, sin acentos, guiones. */
export function slugify(name: string): string {
  return name
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '') // quita acentos (marcas combinantes)
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

/**
 * useAdminBrands — CRUD de marcas de pieza (escritura sujeta a RLS de admin, 0012).
 * Espejo de useAdminCategories. Borrar una marca deja las piezas que la usaban con
 * brand_id = null (on delete set null), así el catálogo no se rompe.
 */
export function useAdminBrands() {
  async function createBrand(input: BrandInput): Promise<Brand> {
    const { data, error } = await supabase
      .from('brands')
      .insert(input)
      .select('*')
      .single()
    if (error) throw error
    return data as Brand
  }

  async function updateBrand(id: string, input: BrandInput): Promise<void> {
    const { error } = await supabase.from('brands').update(input).eq('id', id)
    if (error) throw error
  }

  async function deleteBrand(id: string): Promise<void> {
    const { error } = await supabase.from('brands').delete().eq('id', id)
    if (error) throw error
  }

  async function uploadBrandLogo(file: File, slug: string): Promise<string> {
    const ext = file.name.split('.').pop() || 'png'
    const path = `brands/${slug}-${crypto.randomUUID().slice(0, 8)}.${ext}`
    const { error } = await supabase.storage
      .from('part-images')
      .upload(path, file, { upsert: true, contentType: file.type })
    if (error) throw error
    const { data } = supabase.storage.from('part-images').getPublicUrl(path)
    return data.publicUrl
  }

  return { createBrand, updateBrand, deleteBrand, uploadBrandLogo }
}
