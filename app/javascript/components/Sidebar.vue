<script setup lang="ts">
import { computed, ref } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'
import { ChartColumn, FileText, Images, LayoutDashboard, LogOut, Settings } from '@lucide/vue'

const navItems = [
  { label: 'Dashboard', href: '/admin', icon: LayoutDashboard },
  { label: 'Posts', href: '/admin/posts', icon: FileText },
  { label: 'Media', href: '/admin/media', icon: Images },
  { label: 'Analytics', href: '/admin/analytics', icon: ChartColumn },
]

const page = usePage()
const username = computed(() => page.props.current_user.username)
const initials = computed(() => username.value.slice(0, 2).toUpperCase())

const currentPath = computed(() => page.url.split('?')[0])
const isActive = (href: string) => href === '/admin' ? currentPath.value === '/admin' : currentPath.value.startsWith(href)

const menuOpen = ref(false)
</script>

<template>
  <aside class="flex h-full flex-col px-4 py-4">
    <span class="font-logo text-primary text-5xl block text-center">Fathom</span>

    <ul class="mt-6 flex flex-col gap-1">
      <li v-for="item in navItems" :key="item.href">
        <Link
          :href="item.href"
          class="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
          :class="isActive(item.href) ? 'bg-primary/15 text-primary' : 'text-white/70 hover:bg-surface-raised hover:text-white'"
        >
          <component :is="item.icon" class="h-4 w-4 shrink-0" />
          {{ item.label }}
        </Link>
      </li>
    </ul>

    <div class="mt-auto flex flex-col gap-1">
      <Link
        href="/admin/settings"
        class="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
        :class="isActive('/admin/settings') ? 'bg-primary/15 text-primary' : 'text-white/70 hover:bg-surface-raised hover:text-white'"
      >
        <Settings class="h-4 w-4 shrink-0" />
        Settings
      </Link>

      <div class="relative">
        <button
          type="button"
          class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left transition-colors hover:bg-surface-raised cursor-pointer"
          @click="menuOpen = !menuOpen"
        >
          <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-primary text-sm font-semibold text-white">
            {{ initials }}
          </span>
          <span class="min-w-0 flex-1 truncate text-sm font-medium text-white/90">{{ username }}</span>
        </button>

        <div v-if="menuOpen" class="fixed inset-0 z-40" @click="menuOpen = false" />

        <div
          v-if="menuOpen"
          class="absolute left-full bottom-0 z-50 ml-2 w-36 overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
        >
          <Link
            href="/admin/sign_out"
            method="delete"
            as="button"
            class="flex w-full items-center gap-2 px-4 py-2.5 text-left text-sm text-red-400 transition-colors hover:bg-white/5 cursor-pointer"
            @click="menuOpen = false"
          >
            <LogOut class="h-4 w-4" />
            Log out
          </Link>
        </div>
      </div>
    </div>
  </aside>
</template>
