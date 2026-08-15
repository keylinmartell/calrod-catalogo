import { supabase } from '@/services/supabase'
import type { Category, CategoryInput } from '@/types/part'

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
 * useAdminCategories — CRUD de categorías (escritura sujeta a RLS de admin, 0005).
 * Borrar una categoría deja las piezas que la usaban con category_id = null
 * (on delete set null), así el catálogo no se rompe.
 */
export function useAdminCategories() {
  async function createCategory(input: CategoryInput): Promise<Category> {
    const { data, error } = await supabase
      .from('categories')
      .insert(input)
      .select('*')
      .single()
    if (error) throw error
    return data as Category
  }

  async function updateCategory(id: string, input: CategoryInput): Promise<void> {
    const { error } = await supabase.from('categories').update(input).eq('id', id)
    if (error) throw error
  }

  async function deleteCategory(id: string): Promise<void> {
    const { error } = await supabase.from('categories').delete().eq('id', id)
    if (error) throw error
  }

  return { createCategory, updateCategory, deleteCategory }
}
