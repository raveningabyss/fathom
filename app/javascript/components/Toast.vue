<script setup lang="ts">
import { watch } from 'vue'
import { CircleAlert } from '@lucide/vue'

const props = withDefaults(defineProps<{ message: string | null, duration?: number }>(), { duration: 3000 })
const emit = defineEmits<{ dismissed: [] }>()

watch(() => props.message, (message, _oldMessage, onCleanup) => {
  if (!message) return

  const timer = setTimeout(() => emit('dismissed'), props.duration)
  onCleanup(() => clearTimeout(timer))
}, { immediate: true })
</script>

<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 translate-y-2"
    >
      <div
        v-if="message"
        class="fixed bottom-4 right-4 z-50 flex max-w-sm items-start gap-2 rounded-lg border border-red-500/20 bg-surface-raised px-4 py-3 text-sm text-white shadow-xl"
      >
        <CircleAlert class="mt-0.5 h-4 w-4 shrink-0 text-red-400" />
        <p>{{ message }}</p>
      </div>
    </Transition>
  </Teleport>
</template>
