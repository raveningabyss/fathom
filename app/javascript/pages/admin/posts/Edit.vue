<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { useForm } from '@inertiajs/vue3'
import { Check, Image as ImageIcon, LoaderCircle } from '@lucide/vue'

import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import CategorySelector from '@/components/CategorySelector.vue'
import FormField from '@/components/FormField.vue'
import TiptapEditor from '@/components/TiptapEditor.vue'
import Toast from '@/components/Toast.vue'
import { deleteMedia, uploadMedia } from '@/composables/useMediaUpload'
import type { Post } from '@/types/post'

const props = defineProps<{ post: Post }>()

const form = useForm<{
  title: string,
  content: string,
  slug: string,
  excerpt: string,
  cover_image_url: string
}>({
  title: props.post.title ?? '',
  content: props.post.content ?? '',
  slug: props.post.slug ?? '',
  excerpt: props.post.excerpt ?? '',
  cover_image_url: props.post.cover_image_url ?? ''
})

const selectedCategories = ref<string[]>([])

const coverImageInput = ref<HTMLInputElement>()
const coverImagePreview = ref<string | null>(props.post.cover_image_url)
const coverMediumId = ref<number | null>(null)
const isDraggingCover = ref(false)
const isUploadingCover = ref(false)

async function setCoverImage(file: File | null | undefined) {
  if (!file) return

  if (coverMediumId.value) await deleteMedia(coverMediumId.value)

  const objectUrl = URL.createObjectURL(file)
  coverImagePreview.value = objectUrl
  isUploadingCover.value = true

  try {
    const { id, publicUrl } = await uploadMedia(file)
    coverMediumId.value = id
    coverImagePreview.value = publicUrl
    form.cover_image_url = publicUrl
    URL.revokeObjectURL(objectUrl)
  } finally {
    isUploadingCover.value = false
  }
}

function onCoverFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  setCoverImage(input.files?.[0])
  input.value = ''
}

function onCoverDrop(event: DragEvent) {
  isDraggingCover.value = false
  setCoverImage(event.dataTransfer?.files?.[0])
}

async function removeCoverImage() {
  if (coverMediumId.value) await deleteMedia(coverMediumId.value)

  coverMediumId.value = null
  coverImagePreview.value = null
  form.cover_image_url = ''
  if (coverImageInput.value) coverImageInput.value.value = ''
}

function debounce<T extends (...args: unknown[]) => void>(func: T, delay: number) {
  let timer: ReturnType<typeof setTimeout>
  return function (...args: Parameters<T>) {
    clearTimeout(timer)
    timer = setTimeout(() => {
      func(...args)
    }, delay)
  }
}

const toastMessage = ref<string | null>(null)
const saveStatus = ref<'idle' | 'saving' | 'saved'>('idle')

function autoSave() {
  if (!form.isDirty) return

  saveStatus.value = 'saving'

  form.patch(`/admin/posts/${props.post.id}`, {
    // Without these, a successful/failed autosave triggers a full page
    // visit that remounts this component — wiping the editor's cursor,
    // undo history, etc. every 5s.
    preserveState: true,
    preserveScroll: true,
    onSuccess: () => {
      // Reset the dirty baseline to the just-saved values, so unchanged
      // data doesn't keep re-triggering a save every 5s.
      form.defaults(form.data())
      saveStatus.value = 'saved'
    },
    onError: (errors) => {
      saveStatus.value = 'idle'
      toastMessage.value = Object.entries(errors)
        .map(([field, message]) => `${field.charAt(0).toUpperCase()}${field.slice(1)} ${message}`)
        .join(' ')
    },
  })
}

const debouncedAutoSave = debounce(autoSave, 5000)

watch(form, () => {
  debouncedAutoSave()
}, { deep: true })

function onKeydown(event: KeyboardEvent) {
  if (!(event.ctrlKey || event.metaKey) || event.key.toLowerCase() !== 's') return

  event.preventDefault()
  autoSave()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between">
        <Button href="/admin/posts" variant="secondary">Back</Button>
        <div class="flex items-center gap-3">
          <Transition
            enter-active-class="transition duration-150 ease-out"
            enter-from-class="opacity-0"
            enter-to-class="opacity-100"
            leave-active-class="transition duration-150 ease-in"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
          >
            <span v-if="saveStatus !== 'idle'" class="flex items-center gap-1.5 text-sm font-medium text-primary">
              <LoaderCircle v-if="saveStatus === 'saving'" class="h-4 w-4 animate-spin" />
              <Check v-else class="h-4 w-4" />
              {{ saveStatus === 'saving' ? 'Saving...' : 'Saved' }}
            </span>
          </Transition>
          <Button type="button">Publish</Button>
        </div>
      </div>

      <div class="flex flex-1 gap-6 overflow-hidden">
        <div class="flex w-2/3 min-h-0 flex-col gap-4">
          <FormField label="Title">
            <input v-model="form.title" type="text" placeholder="Name your blog" class="form-input text-lg" />
          </FormField>

          <FormField label="Content" class="flex min-h-0 flex-1 flex-col overflow-hidden">
            <TiptapEditor v-model="form.content" />
          </FormField>
        </div>

        <div class="flex w-1/3 flex-col gap-4 overflow-y-auto">
          <FormField label="Slug">
            <input v-model="form.slug" type="text" placeholder="Select a slug for this blog" class="form-input" />
          </FormField>

          <FormField label="Excerpt">
            <textarea v-model="form.excerpt" rows="4" placeholder="Add a short excerpt to summarize this post" class="form-input resize-none" />
          </FormField>

          <FormField label="Category">
            <CategorySelector v-model="selectedCategories" />
          </FormField>

          <FormField label="Cover Image">
            <div
              class="relative flex flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-white/15 bg-surface-raised px-4 py-8 text-center transition-colors"
              :class="isDraggingCover ? 'border-primary bg-primary/5' : ''"
              @dragover.prevent="isDraggingCover = true"
              @dragleave.prevent="isDraggingCover = false"
              @drop.prevent="onCoverDrop"
            >
              <template v-if="coverImagePreview">
                <img :src="coverImagePreview" alt="Cover image preview" class="max-h-40 rounded-md object-cover" :class="isUploadingCover ? 'opacity-50' : ''" />
                <span v-if="isUploadingCover" class="flex items-center gap-1.5 text-xs text-white/50">
                  <LoaderCircle class="h-3.5 w-3.5 animate-spin" />
                  Uploading...
                </span>
                <button v-else type="button" class="text-xs font-medium text-red-400 transition-colors hover:text-red-300 cursor-pointer" @click="removeCoverImage">
                  Remove image
                </button>
              </template>
              <template v-else>
                <ImageIcon class="h-8 w-8 text-white/25" />
                <p class="text-sm text-white/50">
                  Drag and Drop Image or
                  <button type="button" class="font-medium text-primary transition-colors hover:text-primary-hover cursor-pointer" @click="coverImageInput?.click()">
                    Upload Image
                  </button>
                </p>
              </template>
              <input ref="coverImageInput" type="file" accept="image/*" class="hidden" @change="onCoverFileChange" />
            </div>
          </FormField>
        </div>
      </div>
    </div>

    <Toast :message="toastMessage" @dismissed="toastMessage = null" />
  </AppLayout>
</template>

<style scoped>
@reference '@/entrypoints/application.css';

.form-input {
  @apply w-full rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 text-sm text-white placeholder-white/30 outline-none transition-colors focus:border-primary focus:ring-2 focus:ring-primary/30;
}
</style>
