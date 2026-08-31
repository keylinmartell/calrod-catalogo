<script setup lang="ts">
import { useFilters } from '@/composables/useFilters'

/**
 * BrandFilterBar — filtros globales del catálogo, al estilo mundorepuestos:
 *  • Marca de la pieza (chips), toggle múltiple.
 *  • Vehículo compatible: marca → modelo (dependiente) → motor, como selects.
 * Las opciones de vehículo/motor se derivan del resultado actual (facetas), así
 * solo se muestran valores que realmente existen. La marca de pieza viene del
 * catálogo completo (store.brands) para que el filtro esté siempre disponible.
 */
const {
  brands,
  activeBrands,
  toggleBrand,
  vehicleBrand,
  vehicleModel,
  motor,
  vehicleBrandOptions,
  vehicleModelOptions,
  motorOptions,
  setVehicleBrand,
  setVehicleModel,
  setMotor,
  hasActiveFilters,
  clearFilters,
} = useFilters()
</script>

<template>
  <div class="brandfilter">
    <!-- Marca de la pieza: chips -->
    <div v-if="brands.length" class="brandfilter__group">
      <span class="brandfilter__label mono">Marca</span>
      <div class="brandfilter__chips">
        <button
          v-for="b in brands"
          :key="b.id"
          class="chip"
          :class="{ 'chip--active': activeBrands.includes(b.id) }"
          :aria-pressed="activeBrands.includes(b.id)"
          @click="toggleBrand(b.id)"
        >
          {{ b.name }}
        </button>
      </div>
    </div>

    <!-- Vehículo compatible: marca → modelo → motor -->
    <div class="brandfilter__group brandfilter__group--vehicle">
      <span class="brandfilter__label mono">Vehículo</span>
      <div class="brandfilter__selects">
        <select
          class="brandfilter__select"
          :value="vehicleBrand"
          aria-label="Marca del vehículo"
          @change="setVehicleBrand(($event.target as HTMLSelectElement).value)"
        >
          <option value="">Marca del auto</option>
          <option v-for="vb in vehicleBrandOptions" :key="vb" :value="vb">
            {{ vb }}
          </option>
        </select>

        <select
          class="brandfilter__select"
          :value="vehicleModel"
          aria-label="Modelo del vehículo"
          :disabled="!vehicleModelOptions.length"
          @change="setVehicleModel(($event.target as HTMLSelectElement).value)"
        >
          <option value="">Modelo</option>
          <option v-for="vm in vehicleModelOptions" :key="vm" :value="vm">
            {{ vm }}
          </option>
        </select>

        <select
          class="brandfilter__select"
          :value="motor"
          aria-label="Motor"
          :disabled="!motorOptions.length"
          @change="setMotor(($event.target as HTMLSelectElement).value)"
        >
          <option value="">Motor</option>
          <option v-for="m in motorOptions" :key="m" :value="m">
            {{ m }}
          </option>
        </select>
      </div>
    </div>

    <button
      v-if="hasActiveFilters"
      class="brandfilter__clear"
      @click="clearFilters"
    >
      Limpiar filtros
    </button>
  </div>
</template>

<style scoped>
.brandfilter {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: var(--space-5);
  padding: var(--space-4) var(--space-5);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
}

.brandfilter__group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  min-width: 0;
}

.brandfilter__group--vehicle {
  margin-left: auto;
}

.brandfilter__label {
  font-size: 0.72rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--blue-2);
}

.brandfilter__chips {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
}

.chip {
  padding: 6px var(--space-3);
  border-radius: 999px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  color: var(--cream);
  font-size: 0.82rem;
  font-weight: 500;
  white-space: nowrap;
  transition: all 0.15s ease;
  cursor: pointer;
}

.chip:hover {
  border-color: var(--border-strong);
}

.chip--active {
  background: rgba(26, 61, 110, 0.14);
  border-color: var(--blue);
  color: var(--blue-2);
}

.brandfilter__selects {
  display: flex;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.brandfilter__select {
  appearance: none;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  color: var(--cream);
  font-size: 0.85rem;
  padding: 0 var(--space-3);
  height: 38px;
  outline: none;
  cursor: pointer;
  transition: border-color 0.15s ease;
}

.brandfilter__select:focus {
  border-color: var(--blue);
}

.brandfilter__select:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.brandfilter__clear {
  color: var(--blue-2);
  font-size: 0.85rem;
  font-weight: 500;
  text-decoration: underline;
  text-underline-offset: 3px;
  align-self: center;
}

@media (max-width: 640px) {
  .brandfilter__group--vehicle {
    margin-left: 0;
  }
  .brandfilter__selects {
    width: 100%;
  }
  .brandfilter__select {
    flex: 1;
    min-width: 90px;
  }
}
</style>
