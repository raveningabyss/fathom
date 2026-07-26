<script setup lang="ts">
import { ref } from 'vue'
import { Link } from '@inertiajs/vue3'
import { Eye, Plus, Trash2 } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import DataTable, { type DataTableColumn } from '@/components/DataTable.vue'
import Toast from '@/components/Toast.vue'
import { csrfHeaders } from '@/composables/useMediaUpload'
import { useFlashToast } from '@/composables/useFlashToast'
import type { Category } from '@/types/category'

const props = defineProps<{ categories: Category[] }>()

const columns: DataTableColumn<Category>[] = [
  { id: 'name', label: 'Name', sortable: true, accessor: category => category.name },
  { id: 'posts_count', label: 'Posts', sortable: true, accessor: category => category.posts_count ?? 0 },
  { id: 'actions', label: '', class: 'w-20' },
]

const categories = ref([...props.categories])
const newCategoryName = ref('')
const isCreating = ref(false)
const toastMessage = useFlashToast()
const pendingDeleteCategory = ref<Category | null>(null)

async function createCategory() {
  const name = newCategoryName.value.trim()
  if (!name || isCreating.value) return

  isCreating.value = true
  try {
    const response = await fetch('/admin/categories', {
      method: 'POST',
      headers: csrfHeaders(),
      body: JSON.stringify({ category: { name } }),
    })

    if (!response.ok) {
      const data = await response.json()
      toastMessage.value = data.errors?.join(', ') || 'Failed to create category.'
      return
    }

    const category = await response.json()
    categories.value = [...categories.value, { ...category, posts_count: 0 }].sort((a, b) => a.name.localeCompare(b.name))
    newCategoryName.value = ''
  } finally {
    isCreating.value = false
  }
}

function requestDelete(category: Category) {
  pendingDeleteCategory.value = category
}

async function confirmDelete() {
  if (!pendingDeleteCategory.value) return
  const category = pendingDeleteCategory.value
  pendingDeleteCategory.value = null

  const response = await fetch(`/admin/categories/${category.id}`, { method: 'DELETE', headers: csrfHeaders() })
  if (response.ok) {
    categories.value = categories.value.filter(c => c.id !== category.id)
    toastMessage.value = 'Category destroyed.'
  } else {
    toastMessage.value = 'This category can only be destroyed once no posts use it.'
  }
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between gap-3">
        <h1 class="text-lg font-semibold text-white">Categories</h1>
        <div class="flex items-center gap-2">
          <input
            v-model="newCategoryName"
            type="text"
            placeholder="New category name..."
            class="w-64 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 text-sm text-white placeholder-white/30 outline-none focus:border-primary focus:ring-2 focus:ring-primary/30"
            @keydown.enter="createCategory"
          />
          <Button type="button" :disabled="isCreating" @click="createCategory">
            <span class="flex items-center gap-1.5"><Plus class="h-4 w-4" /> Add</span>
          </Button>
        </div>
      </div>

      <div class="flex-1 overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
        <div class="h-full overflow-auto">
          <DataTable :columns="columns" :rows="categories" :row-key="category => category.id" empty-message="No categories yet">
            <template #cell-name="{ row }">
              <span class="text-white/90">{{ row.name }}</span>
            </template>

            <template #cell-posts_count="{ row }">
              <span class="text-white/70">{{ row.posts_count }}</span>
            </template>

            <template #cell-actions="{ row }">
              <div class="flex items-center gap-1">
                <Link :href="`/admin/categories/${row.id}`" class="text-white/40 transition-colors hover:text-white cursor-pointer">
                  <Eye class="h-5 w-5" />
                </Link>
                <button
                  type="button"
                  class="text-white/40 transition-colors hover:text-red-400 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer"
                  :disabled="!!row.posts_count"
                  :title="row.posts_count ? 'Unlink from all posts before destroying' : undefined"
                  @click="requestDelete(row)"
                >
                  <Trash2 class="h-5 w-5" />
                </button>
              </div>
            </template>
          </DataTable>
        </div>
      </div>
    </div>

    <Toast :message="toastMessage" @dismissed="toastMessage = null" />

    <ConfirmDialog
      :open="pendingDeleteCategory !== null"
      :title="`Delete “${pendingDeleteCategory?.name}”?`"
      message="This can't be undone."
      confirm-label="Delete"
      @confirm="confirmDelete"
      @cancel="pendingDeleteCategory = null"
    />
  </AppLayout>
</template>
