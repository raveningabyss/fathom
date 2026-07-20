<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'

const form = useForm<{ identity: string, password: string }>({ identity: '', password: '' })

const submit = () => form.post('/admin/sign_in')
</script>

<template>
  <div class="flex h-screen items-center justify-center bg-base p-6">
    <div class="flex w-full md:w-[90%] lg:w-3/4 xl:w-2/3 max-w-6xl min-h-[550px] lg:min-h-[650px] xl:min-h-[700px] rounded-2xl bg-surface shadow-2xl overflow-hidden border border-white/[0.06]">
      <div class="flex flex-1 items-center justify-center p-6 md:p-10 lg:p-12">
        <div class="w-full max-w-sm">
          <div class="mb-4">
            <h1 class="text-3xl font-bold text-white tracking-tight">Welcome back</h1>
            <p class="mt-1.5 text-base text-primary-subtle">Good to see you again!</p>
          </div>

          <p v-if="form.errors.identity" class="rounded-lg border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-400 mb-1.5">
            {{ form.errors.identity }}
          </p>

          <form @submit.prevent="submit" class="flex flex-col gap-5">
            <div class="flex flex-col gap-1.5">
              <label for="identity" class="text-base font-medium text-white/70">Username or email</label>
              <input
                id="identity"
                v-model="form.identity"
                type="text"
                placeholder="you@example.com"
                autocomplete="username"
                class="w-full rounded-lg border border-white/[0.08] bg-surface-raised px-4 py-3 text-base text-white placeholder-white/20 outline-none transition-all duration-150 focus:border-primary-hover focus:ring-2 focus:ring-primary/20"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <label for="password" class="text-base font-medium text-white/70">Password</label>
              <input
                id="password"
                v-model="form.password"
                type="password"
                placeholder="••••••••"
                autocomplete="current-password"
                class="w-full rounded-lg border border-white/[0.08] bg-surface-raised px-4 py-3 text-base text-white placeholder-white/20 outline-none transition-all duration-150 focus:border-primary-hover focus:ring-2 focus:ring-primary/20"
              />
            </div>

            <button
              type="submit"
              :disabled="form.processing || (!form.identity || !form.password)"
              class="mt-1 w-full rounded-lg bg-primary px-4 py-3 text-base font-semibold text-white shadow-sm transition-all duration-150 hover:bg-primary-hover active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-surface cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ form.processing ? 'Signing in…' : 'Sign in' }}
            </button>
          </form>
        </div>
      </div>
      <div class="hidden md:block w-2/5 shrink-0">
        <!-- Photo by Francesco Ungaro from Pexels: https://www.pexels.com/photo/underwater-photo-of-fish-and-coral-reef-17681782/ -->
        <img
          :src="`/images/illustration.jpg`"
          alt="Ocean illustration"
          class="h-full w-full object-cover"
        />
      </div>
    </div>
  </div>
</template>
