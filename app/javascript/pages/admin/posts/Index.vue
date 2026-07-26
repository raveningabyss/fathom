<script setup lang="ts">
import { computed, ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import { Search, SquarePen, Trash2, X } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import DataTable, { type DataTableColumn } from '@/components/DataTable.vue'
import Toast from '@/components/Toast.vue'
import { useFlashToast } from '@/composables/useFlashToast'
import type { Post, PostStatus } from '@/types/post'

const props = defineProps<{ posts: Post[] }>()
const posts = computed(() => props.posts ?? [])

const statusStyles: Record<PostStatus, { label: string, class: string }> = {
  published: { label: 'Published', class: 'bg-success/10 text-success border-success/20' },
  draft: { label: 'Draft', class: 'bg-white/5 text-white/60 border-white/10' },
}

const search = ref('')

const filteredPosts = computed(() =>
  posts.value.filter(post => (post.title || '').toLowerCase().includes(search.value.toLowerCase()))
)

const columns: DataTableColumn<Post>[] = [
  { id: 'title', label: 'Title', sortable: true, accessor: post => post.title || 'Untitled' },
  { id: 'status', label: 'Status', sortable: true, accessor: post => post.status },
  { id: 'created_at', label: 'Created', sortable: true, accessor: post => post.created_at },
  { id: 'updated_at', label: 'Last updated', sortable: true, accessor: post => post.updated_at },
  { id: 'actions', label: '', class: 'w-20' },
]

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

const toastMessage = useFlashToast()
const pendingDeletePost = ref<Post | null>(null)

function requestDelete(post: Post) {
  pendingDeletePost.value = post
}

function confirmDelete() {
  if (!pendingDeletePost.value) return
  const id = pendingDeletePost.value.id
  pendingDeletePost.value = null

  router.delete(`/admin/posts/${id}`, {
    preserveScroll: true,
    onError: (errors) => {
      toastMessage.value = Object.entries(errors)
        .map(([field, message]) => `${field.charAt(0).toUpperCase()}${field.slice(1)} ${message}`)
        .join(' ')
    },
  })
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

        <Button href="/admin/posts" method="post">New Post</Button>
      </div>

      <div class="flex-1 overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
        <div class="h-full overflow-auto">
          <DataTable :columns="columns" :rows="filteredPosts" :row-key="post => post.id" empty-message="No posts found">
            <template #cell-title="{ row }">
              <span v-for="(part, i) in titleParts(row.title || 'Untitled')" :key="i" :class="part.match ? 'text-primary' : 'text-white/90'">{{ part.text }}</span>
            </template>

            <template #cell-status="{ row }">
              <span
                class="inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium"
                :class="statusStyles[row.status].class"
              >
                {{ statusStyles[row.status].label }}
              </span>
            </template>

            <template #cell-created_at="{ row }">
              <span class="whitespace-nowrap text-white/70">{{ formatDate(row.created_at) }}</span>
            </template>

            <template #cell-updated_at="{ row }">
              <span class="whitespace-nowrap text-white/70">{{ formatDate(row.updated_at) }}</span>
            </template>

            <template #cell-actions="{ row }">
              <div class="flex items-center gap-1">
                <Link :href="`/admin/posts/${row.id}/edit`" class="text-white/40 transition-colors hover:text-white cursor-pointer">
                  <SquarePen class="h-5 w-5" />
                </Link>
                <button type="button" class="text-white/40 transition-colors hover:text-red-400 cursor-pointer" @click="requestDelete(row)">
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
      :open="pendingDeletePost !== null"
      :title="`Delete “${pendingDeletePost?.title || 'Untitled'}”?`"
      message="This can't be undone."
      confirm-label="Delete"
      @confirm="confirmDelete"
      @cancel="pendingDeletePost = null"
    />
  </AppLayout>
</template>
