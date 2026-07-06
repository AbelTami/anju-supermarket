<script setup lang="ts">
const colorMode = useColorMode()
const toast = useToast()

// antfu: VueUse useEventListener auto-cleans on unmount — no manual
// removeEventListener needed, no leak across HMR / route changes.
useEventListener(window, 'api-error', (event: Event) => {
  const e = event as CustomEvent<{ title: string, description: string }>
  toast.add({
    title: e.detail.title,
    description: e.detail.description,
    color: 'error',
  })
})

const color = computed(() => colorMode.value === 'dark' ? '#1b1718' : 'white')

useHead({
  meta: [
    { charset: 'utf-8' },
    { name: 'viewport', content: 'width=device-width, initial-scale=1' },
    { key: 'theme-color', name: 'theme-color', content: color },
  ],
  link: [
    { rel: 'icon', href: '/favicon.ico' },
  ],
  htmlAttrs: {
    lang: 'zh-CN',
  },
})

const title = '安居超市管理系统'
const description = '安居超市SAAS管理平台 — 商品管理、库存管理、POS收银、会员管理、财务报表一站式解决方案。'

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
  ogImage: 'https://ui.nuxt.com/assets/templates/nuxt/dashboard-light.png',
  twitterCard: 'summary_large_image',
})
</script>

<template>
  <UApp :toaster="{ position: 'top-center' }">
    <NuxtLoadingIndicator />

    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </UApp>
</template>
