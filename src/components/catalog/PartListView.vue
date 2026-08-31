<script setup lang="ts">
import { computed } from 'vue'
import type { Part } from '@/types/part'
import PartListItem from './PartListItem.vue'

const props = defineProps<{
  parts: Part[]
}>()

interface GroupedParts {
  title: string
  parts: Part[]
}

const groupedParts = computed<GroupedParts[]>(() => {
  const groupsMap = new Map<string, Part[]>()

  for (const part of props.parts) {
    const compats = part.part_compatibility ?? []
    if (compats.length > 0) {
      for (const c of compats) {
        const brand = (c.vehicle_brand || '').toUpperCase()
        const model = (c.vehicle_model || '').toUpperCase()
        const motor = c.motor ? ` ${c.motor.toUpperCase()}` : ''
        const years =
          c.year_from || c.year_to
            ? ` (${c.year_from ?? ''} - ${c.year_to ?? 'PRESENTE'})`
            : ''
        const title = `${brand} / ${model}${motor}${years}`.trim()

        if (!groupsMap.has(title)) {
          groupsMap.set(title, [])
        }
        const list = groupsMap.get(title)!
        if (!list.some((p) => p.id === part.id)) {
          list.push(part)
        }
      }
    } else {
      const catName = (part.categories?.name || 'REPUESTOS GENERALES').toUpperCase()
      const title = `${catName} / COMPATIBILIDAD UNIVERSAL`
      if (!groupsMap.has(title)) {
        groupsMap.set(title, [])
      }
      groupsMap.get(title)!.push(part)
    }
  }

  const result: GroupedParts[] = []
  for (const [title, pList] of groupsMap.entries()) {
    result.push({ title, parts: pList })
  }
  return result
})
</script>

<template>
  <div class="list-view">
    <div v-for="group in groupedParts" :key="group.title" class="group-block">
      <!-- Cabecera de grupo por vehículo (estilo franja gris de la referencia) -->
      <div class="group-header">
        <h3 class="group-header__title mono">{{ group.title }}</h3>
      </div>

      <!-- Filas de repuestos de este grupo -->
      <div class="group-items">
        <PartListItem
          v-for="part in group.parts"
          :key="`${group.title}-${part.id}`"
          :part="part"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.list-view {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
  width: 100%;
}

.group-block {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
}

/* Cabecera de compatibilidad vehicular */
.group-header {
  background: var(--surface-2);
  border-bottom: 1px solid var(--border);
  padding: 10px var(--space-4);
}

.group-header__title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--cream);
  letter-spacing: 0.03em;
  margin: 0;
}

.group-items {
  display: flex;
  flex-direction: column;
}
</style>
