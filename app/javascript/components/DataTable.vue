<script setup lang="ts" generic="T">
import { computed, ref } from 'vue'
import { ArrowDown, ArrowUp, ChevronsUpDown, Inbox } from '@lucide/vue'

export type DataTableColumn<T> = {
  id: string
  label: string
  sortable?: boolean
  accessor?: (row: T) => string | number
  class?: string
}

const props = defineProps<{
  columns: DataTableColumn<T>[]
  rows: T[]
  rowKey: (row: T) => string | number
  emptyMessage?: string
}>()

const sortColumnId = ref<string | null>(null)
const sortDirection = ref<'asc' | 'desc'>('asc')

function toggleSort(column: DataTableColumn<T>) {
  if (!column.sortable) return

  if (sortColumnId.value === column.id) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortColumnId.value = column.id
    sortDirection.value = 'asc'
  }
}

const sortedRows = computed(() => {
  const column = props.columns.find(c => c.id === sortColumnId.value)
  if (!column?.accessor) return props.rows

  const accessor = column.accessor
  const direction = sortDirection.value === 'asc' ? 1 : -1

  return [...props.rows].sort((a, b) => {
    const aValue = accessor(a)
    const bValue = accessor(b)
    if (aValue === bValue) return 0
    return aValue > bValue ? direction : -direction
  })
})
</script>

<template>
  <table v-if="rows.length" class="w-full text-left text-sm">
    <thead class="sticky top-0 bg-surface-raised">
      <tr class="border-b border-white/[0.08]">
        <th v-for="column in columns" :key="column.id" class="px-4 py-3 text-sm font-semibold uppercase tracking-wide text-white/40" :class="column.class">
          <button
            v-if="column.sortable"
            type="button"
            class="flex items-center gap-1.5 cursor-pointer hover:text-white/70"
            @click="toggleSort(column)"
          >
            {{ column.label }}
            <ArrowUp v-if="sortColumnId === column.id && sortDirection === 'asc'" class="h-3.5 w-3.5" />
            <ArrowDown v-else-if="sortColumnId === column.id && sortDirection === 'desc'" class="h-3.5 w-3.5" />
            <ChevronsUpDown v-else class="h-3.5 w-3.5 opacity-50" />
          </button>
          <span v-else>{{ column.label }}</span>
        </th>
      </tr>
    </thead>
    <tbody class="divide-y divide-white/[0.06]">
      <tr v-for="row in sortedRows" :key="rowKey(row)" class="transition-colors hover:bg-white/[0.03]">
        <td v-for="column in columns" :key="column.id" class="px-4 py-3.5">
          <slot :name="`cell-${column.id}`" :row="row">{{ column.accessor?.(row) }}</slot>
        </td>
      </tr>
    </tbody>
  </table>

  <div v-else class="flex h-full flex-col items-center justify-center gap-3 px-4 py-10 text-white/40">
    <slot name="empty">
      <Inbox class="h-10 w-10" />
      <p class="text-sm">{{ emptyMessage ?? 'No results' }}</p>
    </slot>
  </div>
</template>
