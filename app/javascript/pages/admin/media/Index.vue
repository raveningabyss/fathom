<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
import { Image as ImageIcon } from '@lucide/vue'
import AppLayout from '@/AppLayout.vue'
import Toast from '@/components/Toast.vue'
import { useFlashToast } from '@/composables/useFlashToast'
import type { Medium } from '@/types/medium'

defineProps<{ media: Medium[] }>()

const toastMessage = useFlashToast()
</script>

<template>
  <AppLayout>
    <div class="flex h-full flex-col gap-4 p-6">
      <h1 class="text-lg font-semibold text-white">Media Library</h1>

      <div class="flex-1 overflow-hidden rounded-xl border border-white/[0.08] bg-surface-raised">
        <div class="h-full overflow-auto p-4">
          <div v-if="media.length" class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
            <Link
              v-for="item in media"
              :key="item.id"
              :href="`/admin/media/${item.id}`"
              class="group flex aspect-square items-center justify-center overflow-hidden rounded-lg border border-white/[0.08] bg-surface transition-colors hover:border-primary/40"
            >
              <img :src="item.media_url" :alt="`Media ${item.id}`" class="max-h-full max-w-full object-contain transition-transform group-hover:scale-105" />
            </Link>
          </div>

          <div v-else class="flex h-full flex-col items-center justify-center gap-3 text-white/40">
            <ImageIcon class="h-10 w-10" />
            <p class="text-sm">No media yet</p>
          </div>
        </div>
      </div>
    </div>

    <Toast :message="toastMessage" @dismissed="toastMessage = null" />
  </AppLayout>
</template>
