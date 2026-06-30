<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const route = useRoute()
const toast = useToast()

const open = ref(false)

// 安居超市管理系统导航
const links = [[{
  label: '首页仪表盘',
  icon: 'i-lucide-house',
  to: '/',
  onSelect: () => { open.value = false }
}, {
  label: '收银/POS',
  icon: 'i-lucide-shopping-cart',
  to: '/pos',
  onSelect: () => { open.value = false }
}, {
  label: '商品管理',
  icon: 'i-lucide-package',
  to: '/products',
  onSelect: () => { open.value = false }
}, {
  label: '库存管理',
  icon: 'i-lucide-warehouse',
  to: '/inventory',
  onSelect: () => { open.value = false }
}, {
  label: '会员管理',
  icon: 'i-lucide-users',
  to: '/customers',
  onSelect: () => { open.value = false }
}, {
  label: '供应商管理',
  icon: 'i-lucide-truck',
  to: '/suppliers',
  onSelect: () => { open.value = false }
}, {
  label: '员工管理',
  icon: 'i-lucide-user-round-check',
  to: '/employees',
  onSelect: () => { open.value = false }
}, {
  label: '财务/报表',
  icon: 'i-lucide-chart-pie',
  to: '/finance',
  onSelect: () => { open.value = false }
}, {
  label: '消息通知',
  icon: 'i-lucide-bell',
  to: '/inbox',
  badge: '0',
  onSelect: () => { open.value = false }
}], [{
  label: '系统设置',
  icon: 'i-lucide-settings',
  to: '/settings',
  defaultOpen: false,
  type: 'trigger',
  children: [{
    label: '超市信息',
    to: '/settings',
    exact: true,
    onSelect: () => { open.value = false }
  }, {
    label: '员工账号',
    to: '/settings/members',
    onSelect: () => { open.value = false }
  }, {
    label: '角色权限',
    to: '/settings/notifications',
    onSelect: () => { open.value = false }
  }, {
    label: '打印模板',
    to: '/settings/security',
    onSelect: () => { open.value = false }
  }]
}]] satisfies NavigationMenuItem[][]

const groups = computed(() => [{
  id: 'links',
  label: '页面导航',
  items: links.flat()
}])

onMounted(async () => {
  const cookie = useCookie('cookie-consent')
  if (cookie.value === 'accepted') {
    return
  }

  toast.add({
    title: '安居超市管理系统使用 Cookie 来提升你的使用体验。',
    duration: 0,
    close: false,
    actions: [{
      label: 'Accept',
      color: 'neutral',
      variant: 'outline',
      onClick: () => {
        cookie.value = 'accepted'
      }
    }, {
      label: 'Opt out',
      color: 'neutral',
      variant: 'ghost'
    }]
  })
})
</script>

<template>
  <UDashboardGroup unit="rem">
    <UDashboardSidebar
      id="default"
      v-model:open="open"
      collapsible
      resizable
      class="bg-elevated/25"
      :ui="{ footer: 'lg:border-t lg:border-default' }"
    >
      <template #header="{ collapsed }">
        <TeamsMenu :collapsed="collapsed" />
      </template>

      <template #default="{ collapsed }">
        <UDashboardSearchButton :collapsed="collapsed" class="bg-transparent ring-default" />

        <UNavigationMenu
          :collapsed="collapsed"
          :items="links[0]"
          orientation="vertical"
          tooltip
          popover
        />

        <UNavigationMenu
          :collapsed="collapsed"
          :items="links[1]"
          orientation="vertical"
          tooltip
          class="mt-auto"
        />
      </template>

      <template #footer="{ collapsed }">
        <UserMenu :collapsed="collapsed" />
      </template>
    </UDashboardSidebar>

    <UDashboardSearch :groups="groups" />

    <slot />

    <NotificationsSlideover />
  </UDashboardGroup>
</template>
