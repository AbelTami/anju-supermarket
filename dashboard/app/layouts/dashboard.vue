<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const toast = useToast()
const { unreadCount } = useRealtimeOrders()
const permissions = usePermissions()

const open = ref(false)

const allLinks = [{
  label: '首页仪表盘',
  icon: 'i-lucide-house',
  to: '/admin',
  exact: true,
  permission: '*' as const,
}, {
  label: '收银/POS',
  icon: 'i-lucide-shopping-cart',
  to: '/admin/pos',
  permission: 'pos' as const,
}, {
  label: '商品管理',
  icon: 'i-lucide-package',
  to: '/admin/products',
  permission: 'products' as const,
}, {
  label: '库存管理',
  icon: 'i-lucide-warehouse',
  to: '/admin/inventory',
  permission: 'inventory' as const,
}, {
  label: '会员管理',
  icon: 'i-lucide-users',
  to: '/admin/customers',
  permission: 'members' as const,
}, {
  label: '供应商管理',
  icon: 'i-lucide-truck',
  to: '/admin/suppliers',
  permission: 'products' as const,
}, {
  label: '员工管理',
  icon: 'i-lucide-user-round-check',
  to: '/admin/employees',
  permission: 'employees' as const,
}, {
  label: '财务/报表',
  icon: 'i-lucide-chart-pie',
  to: '/admin/finance',
  permission: 'finance' as const,
}, {
  label: '订单记录',
  icon: 'i-lucide-bell',
  to: '/admin/inbox',
  badge: String(unreadCount.value),
  permission: '*' as const,
}]

const settingsLinks = [{
  label: '超市信息',
  to: '/admin/settings',
  exact: true,
  permission: '*' as const,
}, {
  label: '角色权限',
  to: '/admin/settings/roles',
  permission: '*' as const,
}, {
  label: '员工账号',
  to: '/admin/settings/members',
  permission: 'employees' as const,
}, {
  label: '优惠券管理',
  to: '/admin/settings/coupons',
  permission: 'products' as const,
}, {
  label: '打印模板',
  to: '/admin/settings/printer',
  permission: '*' as const,
}]

// 安居超市管理系统导航
const links = computed(() => {
  const filtered = allLinks.filter(link =>
    link.permission === '*' || permissions.hasPermission(link.permission),
  ).map(link => ({
    ...link,
    onSelect: () => { open.value = false },
  }))

  const filteredSettings = settingsLinks.filter(link =>
    link.permission === '*' || permissions.hasPermission(link.permission),
  ).map(link => ({
    ...link,
    onSelect: () => {
      navigateTo(link.to)
    },
  }))

  return [[
    ...filtered,
  ], [{
    label: '系统设置',
    icon: 'i-lucide-settings',
    defaultOpen: false,
    type: 'trigger',
    permission: '*' as const,
    children: filteredSettings,
  }]] as NavigationMenuItem[][]
})

const groups = computed(() => [{
  id: 'links',
  label: '页面导航',
  items: links.value.flat(),
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
      },
    }, {
      label: 'Opt out',
      color: 'neutral',
      variant: 'ghost',
      onClick: () => {
        cookie.value = 'opted-out'
      },
    }],
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
