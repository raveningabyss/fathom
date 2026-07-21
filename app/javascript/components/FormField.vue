<script setup lang="ts">
defineProps<{ label: string }>()
</script>

<template>
  <div>
    <label class="mb-1.5 block text-sm font-semibold text-white">{{ label }}</label>
    <slot />
  </div>
</template>
