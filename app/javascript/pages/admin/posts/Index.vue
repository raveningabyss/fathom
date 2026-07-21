<script setup lang="ts">
import { computed, ref } from 'vue'
import {
  createColumnHelper,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  useVueTable,
  type RowSelectionState,
  type SortingState,
} from '@tanstack/vue-table'
import { ArrowDown, ArrowUp, ChevronsUpDown, CircleCheck, Inbox, Pencil, Search, SquarePen, Trash2, X } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import type { Post, PostStatus } from '@/types/post'

const posts = ref<Post[]>([])

const statusStyles: Record<PostStatus, { label: string, icon: typeof CircleCheck, class: string }> = {
  published: { label: 'Published', icon: CircleCheck, class: 'bg-success/10 text-success border-success/20' },
  draft: { label: 'Draft', icon: Pencil, class: 'bg-white/5 text-white/60 border-white/10' },
}

const search = ref('')
const sorting = ref<SortingState>([])
const rowSelection = ref<RowSelectionState>({})

const columnHelper = createColumnHelper<Post>()

const columns = [
  columnHelper.accessor('title', { header: 'Title' }),
  columnHelper.accessor('status', { header: 'Status' }),
  columnHelper.accessor('updatedAt', { header: 'Last updated' }),
]

const table = useVueTable({
  get data() { return posts.value },
  columns,
  state: {
    get sorting() { return sorting.value },
    get globalFilter() { return search.value },
    get rowSelection() { return rowSelection.value },
  },
  onSortingChange: (updaterOrValue) => {
    sorting.value = typeof updaterOrValue === 'function' ? updaterOrValue(sorting.value) : updaterOrValue
  },
  onRowSelectionChange: (updaterOrValue) => {
    rowSelection.value = typeof updaterOrValue === 'function' ? updaterOrValue(rowSelection.value) : updaterOrValue
  },
  enableRowSelection: true,
  globalFilterFn: (row, _columnId, filterValue) =>
    row.original.title.toLowerCase().includes(String(filterValue).toLowerCase()),
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
})

const rows = computed(() => table.getRowModel().rows)

function formatDate(value: string) {
  return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function titleParts(title: string) {
  if (!search.value) return [{ text: title, match: false }]

  const query = search.value.toLowerCase()
  const lower = title.toLowerCase()
  const parts: { text: string, match: boolean }[] = []
  let cursor = 0

  while (cursor < title.length) {
    const index = lower.indexOf(query, cursor)
    if (index === -1) {
      parts.push({ text: title.slice(cursor), match: false })
      break
    }
    if (index > cursor) parts.push({ text: title.slice(cursor, index), match: false })
    parts.push({ text: title.slice(index, index + query.length), match: true })
    cursor = index + query.length
  }

  return parts
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between gap-3">
        <div class="flex w-96 items-center gap-2 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 transition-colors focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/30">
          <Search class="h-3.5 w-3.5 shrink-0 text-white/40" />
          <input
            v-model="search"
            type="text"
            placeholder="Search posts..."
            class="min-w-0 flex-1 border-0 bg-transparent p-0 text-sm text-white placeholder-white/30 outline-none focus:border-0 focus:ring-0"
          />
          <button
            v-if="search"
            type="button"
            class="shrink-0 text-white/40 transition-colors hover:text-white cursor-pointer"
            @click="search = ''"
          >
            <X class="h-3.5 w-3.5" />
          </button>
        </div>

        <Button href="/admin/posts/new">New Post</Button>
      </div>

      <div class="flex-1 overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
        <div class="h-full overflow-auto">
          <table v-if="rows.length" class="w-full text-left text-sm">
            <thead class="sticky top-0 bg-surface-raised">
              <tr class="border-b border-white/[0.08]">
                <th class="w-12 px-4 py-3">
                  <input
                    type="checkbox"
                    class="rounded border-white/20 bg-transparent text-primary focus:ring-primary/40 focus:ring-offset-0"
                    :checked="table.getIsAllRowsSelected()"
                    @change="table.toggleAllRowsSelected(($event.target as HTMLInputElement).checked)"
                  />
                </th>
                <th
                  v-for="header in table.getFlatHeaders()"
                  :key="header.id"
                  class="px-4 py-3 text-sm font-semibold uppercase tracking-wide text-white/40"
                >
                  <button
                    type="button"
                    class="flex items-center gap-1.5 cursor-pointer hover:text-white/70"
                    @click="header.column.getToggleSortingHandler()?.($event)"
                  >
                    {{ header.column.columnDef.header }}
                    <ArrowUp v-if="header.column.getIsSorted() === 'asc'" class="h-3.5 w-3.5" />
                    <ArrowDown v-else-if="header.column.getIsSorted() === 'desc'" class="h-3.5 w-3.5" />
                    <ChevronsUpDown v-else class="h-3.5 w-3.5 opacity-50" />
                  </button>
                </th>
                <th class="w-20 px-4 py-3" />
              </tr>
            </thead>
            <tbody class="divide-y divide-white/[0.06]">
              <tr v-for="row in rows" :key="row.id" class="transition-colors hover:bg-white/[0.03]">
                <td class="px-4 py-3.5">
                  <input
                    type="checkbox"
                    class="rounded border-white/20 bg-transparent text-primary focus:ring-primary/40 focus:ring-offset-0"
                    :checked="row.getIsSelected()"
                    @change="row.toggleSelected(($event.target as HTMLInputElement).checked)"
                  />
                </td>
                <td class="px-4 py-3.5 text-white/90">
                  <span v-for="(part, i) in titleParts(row.original.title)" :key="i" :class="part.match ? 'text-primary' : ''">{{ part.text }}</span>
                </td>
                <td class="px-4 py-3.5">
                  <span
                    class="inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium"
                    :class="statusStyles[row.original.status].class"
                  >
                    <component :is="statusStyles[row.original.status].icon" class="h-3.5 w-3.5" />
                    {{ statusStyles[row.original.status].label }}
                  </span>
                </td>
                <td class="px-4 py-3.5 whitespace-nowrap text-white/70">{{ formatDate(row.original.updatedAt) }}</td>
                <td class="px-4 py-3.5">
                  <div class="flex items-center gap-1">
                    <button type="button" class="text-white/40 transition-colors hover:text-white cursor-pointer">
                      <SquarePen class="h-4 w-4" />
                    </button>
                    <button type="button" class="text-white/40 transition-colors hover:text-red-400 cursor-pointer">
                      <Trash2 class="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>

          <div v-else class="flex h-full flex-col items-center justify-center gap-3 text-white/40">
            <Inbox class="h-10 w-10" />
            <p class="text-sm">No posts found</p>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
