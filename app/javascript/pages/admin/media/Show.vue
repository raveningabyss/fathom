<script setup lang="ts">
import { ref } from 'vue'
import { Link, router } from '@inertiajs/vue3'
import { Check, Eye, Unlink } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import FormField from '@/components/FormField.vue'
import Toast from '@/components/Toast.vue'
import { csrfHeaders, unlinkMedia } from '@/composables/useMediaUpload'
import type { Medium, MediumPostUsage } from '@/types/medium'

const props = defineProps<{ medium: Medium, post_media: MediumPostUsage[] }>()

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
              <table v-if="postMedia.length" class="w-full text-left text-sm">
                <thead>
                  <tr class="border-b border-white/[0.08]">
                    <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-white/40">Title</th>
                    <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-white/40">Caption</th>
                    <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wide text-white/40">Cover Image</th>
                    <th class="w-16 px-4 py-3" />
                  </tr>
                </thead>
                <tbody class="divide-y divide-white/[0.06]">
                  <tr v-for="usage in postMedia" :key="usage.post_id" class="transition-colors hover:bg-white/[0.03]">
                    <td class="px-4 py-3.5 font-medium text-white">{{ usage.title || 'Untitled' }}</td>
                    <td class="px-4 py-3.5 text-white/70">{{ usage.caption || 'Not available' }}</td>
                    <td class="px-4 py-3.5">
                      <Check v-if="usage.cover_image" class="h-4 w-4 text-primary" />
                      <span v-else class="text-white/30">—</span>
                    </td>
                    <td class="px-4 py-3.5">
                      <div class="flex items-center gap-1">
                        <Link :href="`/admin/posts/${usage.post_id}/edit`" title="View" class="text-white/40 transition-colors hover:text-white cursor-pointer">
                          <Eye class="h-4 w-4" />
                        </Link>
                        <button type="button" title="Unlink" class="text-white/40 transition-colors hover:text-red-400 cursor-pointer" @click="pendingUnlink = usage">
                          <Unlink class="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>

              <p v-else class="px-4 py-10 text-center text-sm text-white/40">No posts reference this media yet.</p>
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
