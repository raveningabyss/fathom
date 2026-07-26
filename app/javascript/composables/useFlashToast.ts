import { ref, watch } from 'vue'
import { usePage } from '@inertiajs/vue3'

export function useFlashToast() {
  const page = usePage()
  const toastMessage = ref<string | null>(null)

  watch(() => page.flash, (flash) => {
    const message = flash?.notice ?? flash?.alert
    if (message) toastMessage.value = message
  }, { immediate: true, deep: true })

  return toastMessage
}
