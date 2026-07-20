<script setup lang="ts">
import Sidebar from "@/components/Sidebar.vue"
</script>

<template>
  <div class="flex w-screen h-screen bg-base">
    <nav class="w-52">
      <Sidebar />
    </nav>
    <main class="flex-1 bg-surface">
      <slot />
    </main>
  </div>
</template>
