<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const links = [[{
  label: '超市信息',
  icon: 'i-lucide-store',
  to: '/admin/settings',
  exact: true
}, {
  label: '员工账号',
  icon: 'i-lucide-users',
  to: '/admin/settings/members'
}, {
  label: '角色权限',
  icon: 'i-lucide-shield',
  to: '/admin/settings/notifications'
}, {
  label: '打印模板',
  icon: 'i-lucide-printer',
  to: '/admin/settings/security'
}]] satisfies NavigationMenuItem[][]
</script>

<template>
  <UDashboardPanel id="settings" :ui="{ body: 'lg:py-12' }">
    <template #header>
      <UDashboardNavbar title="系统设置">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>
      </UDashboardNavbar>

      <UDashboardToolbar>
        <!-- NOTE: The `-mx-1` class is used to align with the `DashboardSidebarCollapse` button here. -->
        <UNavigationMenu :items="links[0]" highlight class="-mx-1 flex-1" />
      </UDashboardToolbar>
    </template>

    <template #body>
      <div class="flex flex-col gap-4 sm:gap-6 lg:gap-12 w-full lg:max-w-2xl mx-auto">
        <NuxtPage />
      </div>
    </template>
  </UDashboardPanel>
</template>
