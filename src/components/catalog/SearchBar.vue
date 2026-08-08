<script setup lang="ts">
import { useFilters } from '@/composables/useFilters'

withDefaults(defineProps<{ placeholder?: string }>(), {
  placeholder: 'Busca por nombre o código (ej. BR-4471-C)',
})

const { search, setSearch } = useFilters()

function onInput(e: Event) {
  setSearch((e.target as HTMLInputElement).value)
}
</script>

<template>
  <div class="search">
    <svg
      class="search__icon"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2" />
      <path
        d="M20 20l-3.5-3.5"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
      />
    </svg>
    <input
      type="search"
      class="search__input"
      :placeholder="placeholder"
      :value="search"
      aria-label="Buscar piezas por nombre o código"
      @input="onInput"
    />
  </div>
</template>

<style scoped>
.search {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 0 var(--space-4);
  height: 44px;
  width: 100%;
  transition: border-color 0.15s ease;
}

.search:focus-within {
  border-color: var(--orange);
}

.search__icon {
  width: 18px;
  height: 18px;
  color: var(--charcoal);
  flex-shrink: 0;
}

.search__input {
  flex: 1;
  background: none;
  border: none;
  color: var(--cream);
  font-size: 0.95rem;
  outline: none;
  min-width: 0;
}

.search__input::placeholder {
  color: var(--charcoal);
}
</style>
