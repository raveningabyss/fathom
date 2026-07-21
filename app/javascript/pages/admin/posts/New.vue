<script setup lang="ts">
import { computed, ref } from 'vue'
import { ChevronDown, Image as ImageIcon, X } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Button from '@/components/Button.vue'
import FormField from '@/components/FormField.vue'
import TiptapEditor from '@/components/TiptapEditor.vue'

const title = ref('')
const content = ref('')
const slug = ref('')
const excerpt = ref('')

const inputClass = 'w-full rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 text-sm text-white placeholder-white/30 outline-none transition-colors focus:border-primary focus:ring-2 focus:ring-primary/30'

const availableCategories = ['Health', 'Gym', 'High-Converting', 'Marketing', 'Lifestyle', 'Technology']
const selectedCategories = ref<string[]>([])
const categoryMenuOpen = ref(false)
const unselectedCategories = computed(() => availableCategories.filter(category => !selectedCategories.value.includes(category)))

function addCategory(category: string) {
  selectedCategories.value.push(category)
  categoryMenuOpen.value = false
}

function removeCategory(category: string) {
  selectedCategories.value = selectedCategories.value.filter(c => c !== category)
}

const coverImageInput = ref<HTMLInputElement>()
const coverImagePreview = ref<string | null>(null)
const isDraggingCover = ref(false)

function setCoverImage(file: File | null | undefined) {
  if (!file) return
  coverImagePreview.value = URL.createObjectURL(file)
}

function onCoverFileChange(event: Event) {
  setCoverImage((event.target as HTMLInputElement).files?.[0])
}

function onCoverDrop(event: DragEvent) {
  isDraggingCover.value = false
  setCoverImage(event.dataTransfer?.files?.[0])
}

function removeCoverImage() {
  coverImagePreview.value = null
  if (coverImageInput.value) coverImageInput.value.value = ''
}
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <div class="flex items-center justify-between">
        <Button href="/admin/posts" variant="secondary">Back</Button>
        <Button type="button">Publish</Button>
      </div>

      <div class="flex flex-1 gap-6 overflow-hidden">
        <div class="flex w-2/3 min-h-0 flex-col gap-4">
          <FormField label="Title">
            <input v-model="title" type="text" placeholder="Name your blog" :class="inputClass + ' text-lg'" />
          </FormField>

          <FormField label="Content" class="flex min-h-0 flex-1 flex-col overflow-hidden">
            <TiptapEditor v-model="content" />
          </FormField>
        </div>

        <div class="flex w-1/3 flex-col gap-4 overflow-y-auto">
          <FormField label="Slug">
            <input v-model="slug" type="text" placeholder="Select a slug for this blog" :class="inputClass" />
          </FormField>

          <FormField label="Excerpt">
            <textarea v-model="excerpt" rows="4" placeholder="Add a short excerpt to summarize this post" :class="inputClass + ' resize-none'" />
          </FormField>

          <FormField label="Category">
            <div class="relative flex flex-wrap items-center gap-1.5 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 transition-colors focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/30">
              <span v-if="!selectedCategories.length" class="text-sm text-white/30">Select a category your blog belongs to</span>
              <span
                v-for="category in selectedCategories"
                :key="category"
                class="inline-flex items-center gap-1 rounded-md bg-primary/10 px-2 py-1 text-xs font-medium text-primary"
              >
                {{ category }}
                <button type="button" class="cursor-pointer hover:text-white" @click="removeCategory(category)">
                  <X class="h-3 w-3" />
                </button>
              </span>

              <button
                type="button"
                class="ml-auto flex h-6 w-6 shrink-0 items-center justify-center rounded-md text-white/40 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
                @click="categoryMenuOpen = !categoryMenuOpen"
              >
                <ChevronDown class="h-4 w-4" />
              </button>

              <div v-if="categoryMenuOpen" class="fixed inset-0 z-40" @click="categoryMenuOpen = false" />

              <div
                v-if="categoryMenuOpen"
                class="absolute left-0 top-full z-50 mt-1 w-full overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
              >
                <button
                  v-for="category in unselectedCategories"
                  :key="category"
                  type="button"
                  class="block w-full px-3 py-2 text-left text-sm text-white/80 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
                  @click="addCategory(category)"
                >
                  {{ category }}
                </button>
                <p v-if="!unselectedCategories.length" class="px-3 py-2 text-sm text-white/40">No more categories</p>
              </div>
            </div>
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
                <img :src="coverImagePreview" alt="Cover image preview" class="max-h-40 rounded-md object-cover" />
                <button type="button" class="text-xs font-medium text-red-400 transition-colors hover:text-red-300 cursor-pointer" @click="removeCoverImage">
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
  </AppLayout>
</template>
