<script setup lang="ts">
import { computed, ref } from 'vue'
import { ChevronDown, X } from '@lucide/vue'

const props = withDefaults(defineProps<{ options?: string[] }>(), {
  options: () => ['Health', 'Gym', 'High-Converting', 'Marketing', 'Lifestyle', 'Technology'],
})

const selected = defineModel<string[]>({ default: () => [] })

const menuOpen = ref(false)
const unselectedOptions = computed(() => props.options.filter(option => !selected.value.includes(option)))

function addCategory(category: string) {
  selected.value = [...selected.value, category]
  menuOpen.value = false
}

function removeCategory(category: string) {
  selected.value = selected.value.filter(c => c !== category)
}
</script>

<template>
  <div class="relative flex flex-wrap items-center gap-1.5 rounded-lg border border-white/[0.08] bg-surface-raised px-3 py-2 transition-colors focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/30">
    <span v-if="!selected.length" class="text-sm text-white/30">Select a category your blog belongs to</span>
    <span
      v-for="category in selected"
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
      @click="menuOpen = !menuOpen"
    >
      <ChevronDown class="h-4 w-4" />
    </button>

    <div v-if="menuOpen" class="fixed inset-0 z-40" @click="menuOpen = false" />

    <div
      v-if="menuOpen"
      class="absolute left-0 top-full z-50 mt-1 w-full overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
    >
      <button
        v-for="category in unselectedOptions"
        :key="category"
        type="button"
        class="block w-full px-3 py-2 text-left text-sm text-white/80 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
        @click="addCategory(category)"
      >
        {{ category }}
      </button>
      <p v-if="!unselectedOptions.length" class="px-3 py-2 text-sm text-white/40">No more categories</p>
    </div>
  </div>
</template>
