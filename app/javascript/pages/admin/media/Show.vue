<script setup lang="ts">
import { ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import { Check, Eye, Unlink } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import DataTable, { type DataTableColumn } from '@/components/DataTable.vue'
import FormField from '@/components/FormField.vue'
import Toast from '@/components/Toast.vue'
import { csrfHeaders, unlinkMedia } from '@/composables/useMediaUpload'
import type { Medium, MediumPostUsage } from '@/types/medium'

const props = defineProps<{ medium: Medium, post_media: MediumPostUsage[] }>()

const columns: DataTableColumn<MediumPostUsage>[] = [
  { id: 'title', label: 'Title', sortable: true, accessor: usage => usage.title || 'Untitled' },
  { id: 'caption', label: 'Caption', sortable: true, accessor: usage => usage.caption || '' },
  { id: 'cover_image', label: 'Cover Image', sortable: true, accessor: usage => usage.cover_image ? 1 : 0 },
  { id: 'actions', label: '', class: 'w-16' },
]

const postMedia = ref([...props.post_media])
const confirmDestroyOpen = ref(false)
const toastMessage = ref<string | null>(null)

async function destroyMedium() {
  confirmDestroyOpen.value = false

  const response = await fetch(`/admin/media/${props.medium.id}`, { method: 'DELETE', headers: csrfHeaders() })
  if (response.ok) {
    router.visit('/admin/media')
  } else {
    toastMessage.value = 'This medium can only be destroyed once it\'s unlinked from all posts.'
  }
}

const pendingUnlink = ref<MediumPostUsage | null>(null)

async function confirmUnlink() {
  if (!pendingUnlink.value) return
  const usage = pendingUnlink.value
  pendingUnlink.value = null

  const ok = await unlinkMedia(usage.post_id, props.medium.id)
  if (ok) {
    postMedia.value = postMedia.value.filter(pm => pm.post_id !== usage.post_id)
    toastMessage.value = `Unlinked from “${usage.title || 'Untitled'}”.`
  } else {
    toastMessage.value = 'Failed to unlink this post.'
  }
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between">
        <Button href="/admin/media" variant="secondary">Back</Button>
        <Button
          type="button"
          variant="danger"
          :disabled="postMedia.length > 0"
          :title="postMedia.length > 0 ? 'Unlink from all posts before destroying' : undefined"
          @click="confirmDestroyOpen = true"
        >
          Destroy
        </Button>
      </div>

      <div class="flex flex-1 gap-6 overflow-hidden">
        <div class="flex w-1/3 min-h-0 items-center justify-center overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised p-4">
          <img :src="props.medium.media_url" :alt="`Media ${props.medium.id}`" class="max-h-full max-w-full rounded-lg object-contain" />
        </div>

        <div class="flex w-2/3 flex-col gap-4 overflow-y-auto">
          <FormField label="Post references">
            <div class="overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
              <DataTable :columns="columns" :rows="postMedia" :row-key="usage => usage.post_id" empty-message="No posts reference this media yet.">
                <template #cell-title="{ row }">
                  <span class="font-medium text-white">{{ row.title || 'Untitled' }}</span>
                </template>

                <template #cell-caption="{ row }">
                  <span class="text-white/70">{{ row.caption || 'Not available' }}</span>
                </template>

                <template #cell-cover_image="{ row }">
                  <Check v-if="row.cover_image" class="h-4 w-4 text-primary" />
                  <span v-else class="text-white/30">—</span>
                </template>

                <template #cell-actions="{ row }">
                  <div class="flex items-center gap-1">
                    <Link :href="`/admin/posts/${row.post_id}/edit`" title="View" class="text-white/40 transition-colors hover:text-white cursor-pointer">
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
      </div>
    </div>

    <Toast :message="toastMessage" @dismissed="toastMessage = null" />

    <ConfirmDialog
      :open="confirmDestroyOpen"
      title="Destroy this media?"
      message="This can't be undone."
      confirm-label="Destroy"
      @confirm="destroyMedium"
      @cancel="confirmDestroyOpen = false"
    />

    <ConfirmDialog
      :open="pendingUnlink !== null"
      :title="`Unlink from “${pendingUnlink?.title || 'Untitled'}”?`"
      message="This post will no longer reference this media."
      confirm-label="Unlink"
      @confirm="confirmUnlink"
      @cancel="pendingUnlink = null"
    />
  </AppLayout>
</template>
