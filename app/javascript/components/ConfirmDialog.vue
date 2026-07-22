<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import Button from '@/components/Button.vue'

withDefaults(defineProps<{
  open: boolean
  title: string
  message: string
  confirmLabel?: string
  cancelLabel?: string
  danger?: boolean
}>(), { confirmLabel: 'Confirm', cancelLabel: 'Cancel', danger: true })

const emit = defineEmits<{ confirm: [], cancel: [] }>()

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') emit('cancel')
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
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
        <div class="w-full max-w-sm rounded-xl border border-white/[0.08] bg-surface-raised p-5 shadow-2xl">
          <h2 class="text-base font-semibold text-white">{{ title }}</h2>
          <p class="mt-1.5 text-sm text-white/60">{{ message }}</p>

          <div class="mt-5 flex justify-end gap-2">
            <Button type="button" variant="secondary" @click="emit('cancel')">{{ cancelLabel }}</Button>
            <Button type="button" :variant="danger ? 'danger' : 'primary'" @click="emit('confirm')">{{ confirmLabel }}</Button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
