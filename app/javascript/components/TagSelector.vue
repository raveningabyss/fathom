<script setup lang="ts">
import { computed, ref } from 'vue'
import { ChevronDown, Plus, X } from '@lucide/vue'
import { csrfHeaders } from '@/composables/useMediaUpload'
import type { Tag } from '@/types/tag'

const props = defineProps<{ options: Tag[] }>()
const selected = defineModel<number[]>({ default: () => [] })

const tags = ref<Tag[]>([...props.options])
const menuOpen = ref(false)
const search = ref('')
const isCreating = ref(false)
const errorMessage = ref<string | null>(null)

const selectedTags = computed(() => tags.value.filter(t => selected.value.includes(t.id)))

const filteredTags = computed(() => {
  const query = search.value.trim().toLowerCase()
  return tags.value.filter(t => !selected.value.includes(t.id) && (!query || t.name.toLowerCase().includes(query)))
})

const hasExactMatch = computed(() =>
  tags.value.some(t => t.name.toLowerCase() === search.value.trim().toLowerCase())
)

const showCreateOption = computed(() => search.value.trim().length > 0 && !hasExactMatch.value)

function toggleMenu() {
  if (menuOpen.value) {
    menuOpen.value = false
    return
  }

  search.value = ''
  errorMessage.value = null
  menuOpen.value = true
}

function addTag(tag: Tag) {
  selected.value = [...selected.value, tag.id]
  menuOpen.value = false
}

function removeTag(tagId: number) {
  selected.value = selected.value.filter(id => id !== tagId)
}

async function createTag() {
  const name = search.value.trim()
  if (!name || isCreating.value) return

  isCreating.value = true
  errorMessage.value = null

  try {
    const response = await fetch('/admin/tags', {
      method: 'POST',
      headers: csrfHeaders(),
      body: JSON.stringify({ tag: { name } }),
    })

    if (!response.ok) {
      const data = await response.json()
      errorMessage.value = data.errors?.join(', ') || 'Failed to create tag.'
      return
    }

    const tag = await response.json()
    tags.value = [...tags.value, tag]
    selected.value = [...selected.value, tag.id]
    menuOpen.value = false
  } finally {
    isCreating.value = false
  }
}
</script>

<template>
  <div
    class="relative flex flex-wrap items-center gap-1.5 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 transition-colors focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/30 cursor-pointer"
    @click="toggleMenu"
  >
    <span v-if="!selectedTags.length" class="text-sm text-white/30">Add tags to this post</span>
    <span
      v-for="tag in selectedTags"
      :key="tag.id"
      class="inline-flex items-center gap-1 rounded-md bg-primary/10 px-2 py-1 text-xs font-medium text-primary"
    >
      {{ tag.name }}
      <button type="button" class="cursor-pointer hover:text-white" @click.stop="removeTag(tag.id)">
        <X class="h-3 w-3" />
      </button>
    </span>

    <ChevronDown class="ml-auto h-4 w-4 shrink-0 text-white/40" />

    <div v-if="menuOpen" class="fixed inset-0 z-40" @click.stop="menuOpen = false" />

    <div
      v-if="menuOpen"
      class="absolute left-0 top-full z-50 mt-1 w-full overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
      @click.stop
    >
      <input
        v-model="search"
        type="text"
        placeholder="Search or create a tag..."
        class="w-full border-0 border-b border-white/[0.08] bg-transparent px-3 py-2 text-sm text-white placeholder-white/30 outline-none focus:ring-0"
        @keydown.enter="showCreateOption ? createTag() : filteredTags[0] && addTag(filteredTags[0])"
      />

      <div class="max-h-52 overflow-y-auto">
        <button
          v-for="tag in filteredTags"
          :key="tag.id"
          type="button"
          class="block w-full px-3 py-2 text-left text-sm text-white/80 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
          @click="addTag(tag)"
        >
          {{ tag.name }}
        </button>

        <button
          v-if="showCreateOption"
          type="button"
          class="flex w-full items-center gap-1.5 px-3 py-2 text-left text-sm text-primary transition-colors hover:bg-white/5 cursor-pointer disabled:opacity-50"
          :disabled="isCreating"
          @click="createTag"
        >
          <Plus class="h-3.5 w-3.5 shrink-0" />
          Create “{{ search.trim() }}”
        </button>

        <p v-if="!filteredTags.length && !showCreateOption" class="px-3 py-2 text-sm text-white/40">No more tags</p>
      </div>

      <p v-if="errorMessage" class="border-t border-white/[0.08] px-3 py-2 text-xs text-red-400">{{ errorMessage }}</p>
    </div>
  </div>
</template>
