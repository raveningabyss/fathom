<script setup lang="ts">
import { ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import { Eye, Unlink } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import DataTable, { type DataTableColumn } from '@/components/DataTable.vue'
import FormField from '@/components/FormField.vue'
import Toast from '@/components/Toast.vue'
import { csrfHeaders } from '@/composables/useMediaUpload'
import type { Category } from '@/types/category'
import type { PostSummary } from '@/types/postSummary'

const props = defineProps<{ category: Category, posts: PostSummary[] }>()

const columns: DataTableColumn<PostSummary>[] = [
  { id: 'title', label: 'Title', sortable: true, accessor: post => post.title || 'Untitled' },
  { id: 'actions', label: '', class: 'w-16' },
]

const posts = ref([...props.posts])
const confirmDestroyOpen = ref(false)
const toastMessage = ref<string | null>(null)
const pendingUnlink = ref<PostSummary | null>(null)

async function destroyCategory() {
  confirmDestroyOpen.value = false

  const response = await fetch(`/admin/categories/${props.category.id}`, { method: 'DELETE', headers: csrfHeaders() })
  if (response.ok) {
    router.visit('/admin/categories')
  } else {
    toastMessage.value = 'This category can only be destroyed once no posts use it.'
  }
}

async function confirmUnlink() {
  if (!pendingUnlink.value) return
  const post = pendingUnlink.value
  pendingUnlink.value = null

  const response = await fetch(`/admin/posts/${post.id}/categories/${props.category.id}/unlink`, { method: 'DELETE', headers: csrfHeaders() })
  if (response.ok) {
    posts.value = posts.value.filter(p => p.id !== post.id)
    toastMessage.value = `Unlinked from “${post.title || 'Untitled'}”.`
  } else {
    toastMessage.value = 'Failed to unlink this post.'
  }
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between">
        <Button href="/admin/categories" variant="secondary">Back</Button>
        <Button
          type="button"
          variant="danger"
          :disabled="posts.length > 0"
          :title="posts.length > 0 ? 'Unlink from all posts before destroying' : undefined"
          @click="confirmDestroyOpen = true"
        >
          Destroy
        </Button>
      </div>

      <h1 class="text-lg font-semibold text-white">{{ props.category.name }}</h1>

      <FormField label="Post references">
        <div class="overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
          <DataTable :columns="columns" :rows="posts" :row-key="post => post.id" empty-message="No posts reference this category yet.">
            <template #cell-title="{ row }">
              <span class="font-medium text-white">{{ row.title || 'Untitled' }}</span>
            </template>

            <template #cell-actions="{ row }">
              <div class="flex items-center gap-1">
                <Link :href="`/admin/posts/${row.id}/edit`" title="View" class="text-white/40 transition-colors hover:text-white cursor-pointer">
                  <Eye class="h-4 w-4" />
                </Link>
                <button type="button" title="Unlink" class="text-white/40 transition-colors hover:text-red-400 cursor-pointer" @click="pendingUnlink = row">
                  <Unlink class="h-4 w-4" />
                </button>
              </div>
            </template>
          </DataTable>
        </div>
      </FormField>
    </div>

    <Toast :message="toastMessage" @dismissed="toastMessage = null" />

    <ConfirmDialog
      :open="confirmDestroyOpen"
      title="Destroy this category?"
      message="This can't be undone."
      confirm-label="Destroy"
      @confirm="destroyCategory"
      @cancel="confirmDestroyOpen = false"
    />

    <ConfirmDialog
      :open="pendingUnlink !== null"
      :title="`Unlink from “${pendingUnlink?.title || 'Untitled'}”?`"
      message="This post will no longer reference this category."
      confirm-label="Unlink"
      @confirm="confirmUnlink"
      @cancel="pendingUnlink = null"
    />
  </AppLayout>
</template>
