<script setup lang="ts">
import { ref, watch } from 'vue'
import { Image as ImageIcon, X } from '@lucide/vue'
import type { Medium } from '@/types/medium'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ select: [medium: Medium], cancel: [] }>()

const media = ref<Medium[]>([])
const isLoading = ref(false)
const errorMessage = ref<string | null>(null)

async function loadMedia() {
  isLoading.value = true
  errorMessage.value = null

  try {
    const response = await fetch('/admin/media', { headers: { Accept: 'application/json' } })
    if (!response.ok) throw new Error('Failed to load media library')

    const data = await response.json()
    media.value = data.media
  } catch {
    errorMessage.value = 'Failed to load media library.'
  } finally {
    isLoading.value = false
  }
}

watch(() => props.open, (open) => {
  if (open) loadMedia()
})
</script>

<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="open"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
        @click.self="emit('cancel')"
      >
        <div class="flex max-h-[80vh] w-full max-w-3xl flex-col gap-4 rounded-xl border border-white/[0.08] bg-surface-raised p-5 shadow-2xl">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold text-white">Pick from library</h2>
            <button type="button" class="text-white/40 transition-colors hover:text-white cursor-pointer" @click="emit('cancel')">
              <X class="h-5 w-5" />
            </button>
          </div>

          <div class="min-h-0 flex-1 overflow-y-auto">
            <div v-if="isLoading" class="flex h-40 items-center justify-center text-sm text-white/40">
              Loading...
            </div>

            <div v-else-if="errorMessage" class="flex h-40 items-center justify-center text-sm text-red-400">
              {{ errorMessage }}
            </div>

            <div v-else-if="media.length" class="grid grid-cols-3 gap-3 sm:grid-cols-4 md:grid-cols-5">
              <button
                v-for="item in media"
                :key="item.id"
                type="button"
                class="group flex aspect-square items-center justify-center overflow-hidden rounded-lg border border-white/[0.08] bg-surface transition-colors hover:border-primary/40 cursor-pointer"
                @click="emit('select', item)"
              >
                <img :src="item.media_url" :alt="`Media ${item.id}`" class="max-h-full max-w-full object-contain transition-transform group-hover:scale-105" />
              </button>
            </div>

            <div v-else class="flex h-40 flex-col items-center justify-center gap-2 text-white/40">
              <ImageIcon class="h-8 w-8" />
              <p class="text-sm">No media in your library yet</p>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
