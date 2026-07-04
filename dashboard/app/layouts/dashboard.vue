<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const route = useRoute()
const toast = useToast()
const { unreadCount } = useRealtimeOrders()

const open = ref(false)

// 安居超市管理系统导航
const links = computed(() => [[{
  label: '首页仪表盘',
  icon: 'i-lucide-house',
  to: '/admin',
  exact: true,
  onSelect: () => { open.value = false }
}, {
  label: '收银/POS',
  icon: 'i-lucide-shopping-cart',
  to: '/admin/pos',
  onSelect: () => { open.value = false }
}, {
  label: '商品管理',
  icon: 'i-lucide-package',
  to: '/admin/products',
  onSelect: () => { open.value = false }
}, {
  label: '库存管理',
  icon: 'i-lucide-warehouse',
  to: '/admin/inventory',
  onSelect: () => { open.value = false }
}, {
  label: '会员管理',
  icon: 'i-lucide-users',
  to: '/admin/customers',
  onSelect: () => { open.value = false }
}, {
  label: '供应商管理',
  icon: 'i-lucide-truck',
  to: '/admin/suppliers',
  onSelect: () => { open.value = false }
}, {
  label: '员工管理',
  icon: 'i-lucide-user-round-check',
  to: '/admin/employees',
  onSelect: () => { open.value = false }
}, {
  label: '财务/报表',
  icon: 'i-lucide-chart-pie',
  to: '/admin/finance',
  onSelect: () => { open.value = false }
}, {
  label: '订单记录',
  icon: 'i-lucide-bell',
  to: '/admin/inbox',
  badge: String(unreadCount.value),
  onSelect: () => { open.value = false }
}], [{
  label: '系统设置',
  icon: 'i-lucide-settings',
  to: '/admin/settings',
  defaultOpen: false,
  type: 'trigger',
  children: [{
    label: '超市信息',
    to: '/admin/settings',
    exact: true,
    onSelect: () => { open.value = false }
  }, {
    label: '员工账号',
    to: '/admin/settings/members',
    onSelect: () => { open.value = false }
  }, {
    label: '角色权限',
    to: '/admin/settings/notifications',
    onSelect: () => { open.value = false }
  }, {
    label: '优惠券管理',
    to: '/admin/settings/coupons',
    onSelect: () => { open.value = false }
  }, {
    label: '打印模板',
    to: '/admin/settings/security',
    onSelect: () => { open.value = false }
  }]
}]]) as NavigationMenuItem[][]

const groups = computed(() => [{
  id: 'links',
  label: '页面导航',
  items: links.value.flat()
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
      variant: 'ghost',
      onClick: () => {
        cookie.value = 'opted-out'
      }
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
