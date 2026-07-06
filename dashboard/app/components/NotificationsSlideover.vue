<script setup lang="ts">
import { formatTimeAgo } from '@vueuse/core'
import { useAuth } from '~/composables/useAuth'

const { isNotificationsSlideoverOpen } = useDashboard()
const { latestOrder, recentOrders, connected, markAllRead } = useRealtimeOrders()
const auth = useAuth()
const toast = useToast()

// Mark all as read when slideover opens
watch(isNotificationsSlideoverOpen, (open) => {
  if (open) markAllRead()
})

// Load recent orders from API as baseline (SSE only covers new orders during this session)
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = computed(() => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/orders?ordering=-paid_at&page_size=10` : '')
const { data } = useFetch(apiUrl, { lazy: true, server: false, immediate: true, watch: [tenantSlug] })

// Merge API orders with SSE real-time orders
const apiOrders = computed(() => {
  const orders = (data.value as any)?.results || []
  return orders.map((o: any) => ({
    id: o.id,
    body: `#${o.order_no} — ¥${o.total_amount} [${o.payment_method === 'cash' ? '现金' : o.payment_method === 'wechat' ? '微信' : o.payment_method === 'alipay' ? '支付宝' : '会员卡'}]`,
    date: o.paid_at,
    sender: { name: o.cashier_name, avatar: undefined },
  }))
})

const notifications = computed(() =>
  recentOrders.value.map(o => ({
    id: o.id,
    body: `#${o.order_no} — ¥${o.total_amount} [${o.payment_method === 'cash' ? '现金' : o.payment_method === 'wechat' ? '微信' : o.payment_method === 'alipay' ? '支付宝' : '会员卡'}]`,
    date: o.paid_at,
    sender: { name: o.cashier_name, avatar: undefined },
  })),
)

// Merge API orders with SSE real-time orders, dedup by id
const allNotifications = computed(() => {
  const sseIds = new Set(notifications.value.map(n => n.id))
  const merged = [...notifications.value]
  for (const n of apiOrders.value) {
    if (!sseIds.has(n.id)) merged.push(n)
  }
  return merged
})

// Toast on new order
watch(latestOrder, (order) => {
  if (!order) return
  const method = order.payment_method === 'cash' ? '现金' : order.payment_method === 'wechat' ? '微信' : order.payment_method === 'alipay' ? '支付宝' : '会员卡'
  toast.add({
    title: `新订单 #${order.order_no}`,
    description: `¥${order.total_amount} — ${method}`,
    color: 'success',
    icon: 'i-lucide-shopping-cart',
    duration: 5000,
  })
})
</script>

<template>
  <USlideover v-model:open="isNotificationsSlideoverOpen" title="实时交易">
    <template #body>
      <div class="flex items-center gap-2 mb-3">
        <UBadge :color="connected ? 'success' : 'neutral'" variant="subtle" size="xs">
          {{ connected ? '实时连接中' : '未连接' }}
        </UBadge>
      </div>
      <div v-if="allNotifications.length === 0" class="text-center text-dimmed py-8">
        暂无交易记录
      </div>
      <NuxtLink
        v-for="n in allNotifications"
        :key="n.id"
        :to="`/admin/finance`"
        class="px-3 py-2.5 rounded-md hover:bg-elevated/50 flex items-center gap-3 relative -mx-3 first:-mt-3 last:-mb-3"
      >
        <UChip color="primary" inset>
          <UAvatar :text="n.sender.name?.charAt(0) || '?'" size="md" />
        </UChip>
        <div class="text-sm flex-1">
          <p class="flex items-center justify-between">
            <span class="text-highlighted font-medium">{{ n.sender.name }}</span>
            <time :datetime="n.date" class="text-muted text-xs" v-text="formatTimeAgo(new Date(n.date))" />
          </p>
          <p class="text-dimmed">{{ n.body }}</p>
        </div>
      </NuxtLink>
    </template>
  </USlideover>
</template>
