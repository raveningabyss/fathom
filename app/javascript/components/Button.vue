<script setup lang="ts">
withDefaults(defineProps<{ type?: 'button' | 'submit' | 'reset' }>(), { type: 'button' })
</script>

<template>
  <button
    :type="type"
    class="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-primary-hover active:scale-[0.98] cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
  >
    <slot />
  </button>
</template>
