<script setup lang="ts">
// Dynamic redirect: logged-in admin → first tenant's dashboard, otherwise the
// admin login page. Falls back to the shop front if a default tenant exists.
const auth = useAuth()

await useAsyncData('bootstrap', async () => {
  await auth.fetchProfile()
  return true
})

const target = computed(() => {
  const slug = auth.currentTenant.value?.slug
  if (slug) return navigateTo(`/${slug}`, { replace: true })
  if (auth.tenants.value.length > 0) {
    return navigateTo(`/${auth.tenants.value[0].slug}`, { replace: true })
  }
  return navigateTo('/admin/auth/login', { replace: true })
})

watchEffect(() => target.value)
</script>

<template>
  <div class="flex h-screen items-center justify-center text-dimmed">
    <UIcon name="i-lucide-loader-circle" class="animate-spin size-6" />
  </div>
</template>
