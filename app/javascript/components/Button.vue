<script setup lang="ts">
import { computed } from 'vue'
import { Link } from '@inertiajs/vue3'

const props = withDefaults(defineProps<{
  type?: 'button' | 'submit' | 'reset'
  href?: string
  method?: 'get' | 'post' | 'put' | 'patch' | 'delete'
  variant?: 'primary' | 'secondary' | 'danger'
}>(), { type: 'button', variant: 'primary' })

const variantClasses = {
  primary: 'bg-primary text-white shadow-sm hover:bg-primary-hover',
  secondary: 'border border-white/[0.08] bg-surface-raised text-white/80 hover:bg-white/[0.08] hover:text-white',
  danger: 'bg-red-500 text-white shadow-sm hover:bg-red-400',
}

const classes = computed(() =>
  `rounded-lg px-4 py-2 text-sm font-semibold transition-colors active:scale-[0.98] cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed ${variantClasses[props.variant]}`
)
</script>

<template>
  <Link v-if="href" :href="href" :method="method" :class="classes">
    <slot />
  </Link>
  <button v-else :type="type" :class="classes">
    <slot />
  </button>
</template>
