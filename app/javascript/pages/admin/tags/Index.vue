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
import type { Tag } from '@/types/tag'

const props = defineProps<{ tags: Tag[] }>()

const columns: DataTableColumn<Tag>[] = [
  { id: 'name', label: 'Name', sortable: true, accessor: tag => tag.name },
  { id: 'posts_count', label: 'Posts', sortable: true, accessor: tag => tag.posts_count ?? 0 },
  { id: 'actions', label: '', class: 'w-20' },
]

const tags = ref([...props.tags])
const newTagName = ref('')
const isCreating = ref(false)
const toastMessage = useFlashToast()
const pendingDeleteTag = ref<Tag | null>(null)

async function createTag() {
  const name = newTagName.value.trim()
  if (!name || isCreating.value) return

  isCreating.value = true
  try {
    const response = await fetch('/admin/tags', {
      method: 'POST',
      headers: csrfHeaders(),
      body: JSON.stringify({ tag: { name } }),
    })

    if (!response.ok) {
      const data = await response.json()
      toastMessage.value = data.errors?.join(', ') || 'Failed to create tag.'
      return
    }

    const tag = await response.json()
    tags.value = [...tags.value, { ...tag, posts_count: 0 }].sort((a, b) => a.name.localeCompare(b.name))
    newTagName.value = ''
  } finally {
    isCreating.value = false
  }
}

function requestDelete(tag: Tag) {
  pendingDeleteTag.value = tag
}

async function confirmDelete() {
  if (!pendingDeleteTag.value) return
  const tag = pendingDeleteTag.value
  pendingDeleteTag.value = null

  const response = await fetch(`/admin/tags/${tag.id}`, { method: 'DELETE', headers: csrfHeaders() })
  if (response.ok) {
    tags.value = tags.value.filter(t => t.id !== tag.id)
    toastMessage.value = 'Tag destroyed.'
  } else {
    toastMessage.value = 'This tag can only be destroyed once no posts use it.'
  }
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between gap-3">
        <h1 class="text-lg font-semibold text-white">Tags</h1>
        <div class="flex items-center gap-2">
          <input
            v-model="newTagName"
            type="text"
            placeholder="New tag name..."
            class="w-64 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 text-sm text-white placeholder-white/30 outline-none focus:border-primary focus:ring-2 focus:ring-primary/30"
            @keydown.enter="createTag"
          />
          <Button type="button" :disabled="isCreating" @click="createTag">
            <span class="flex items-center gap-1.5"><Plus class="h-4 w-4" /> Add</span>
          </Button>
        </div>
      </div>

      <div class="flex-1 overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
        <div class="h-full overflow-auto">
          <DataTable :columns="columns" :rows="tags" :row-key="tag => tag.id" empty-message="No tags yet">
            <template #cell-name="{ row }">
              <span class="text-white/90">{{ row.name }}</span>
            </template>

            <template #cell-posts_count="{ row }">
              <span class="text-white/70">{{ row.posts_count }}</span>
            </template>

            <template #cell-actions="{ row }">
              <div class="flex items-center gap-1">
                <Link :href="`/admin/tags/${row.id}`" class="text-white/40 transition-colors hover:text-white cursor-pointer">
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
      :open="pendingDeleteTag !== null"
      :title="`Delete “${pendingDeleteTag?.name}”?`"
      message="This can't be undone."
      confirm-label="Delete"
      @confirm="confirmDelete"
      @cancel="pendingDeleteTag = null"
    />
  </AppLayout>
</template>
