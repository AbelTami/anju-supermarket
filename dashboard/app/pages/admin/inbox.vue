<script setup lang="ts">
/** 消息通知 — Recent orders + alerts */
import { formatTimeAgo } from '@vueuse/core'
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const ordersUrl = computed(() => `/api/tenant/${tenantSlug.value}/orders?ordering=-paid_at&page_size=30`)

const { data: ordersData, refresh } = useFetch(ordersUrl, { lazy: true, server: false, immediate: true, watch: [tenantSlug] })

const items = computed(() => {
  const orders = (ordersData.value as any)?.results || []
  return orders.map((o: any) => ({
    id: o.id,
    title: `订单 #${o.order_no}`,
    subtitle: `${o.cashier_name} · ${o.payment_method === 'cash' ? '现金' : o.payment_method === 'wechat' ? '微信' : o.payment_method === 'alipay' ? '支付宝' : '会员卡'}`,
    amount: `¥${o.total_amount}`,
    time: formatTimeAgo(new Date(o.paid_at)),
    date: o.paid_at,
    items_count: o.items_count,
  }))
})
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="消息通知">
          <template #leading>
            <UDashboardSidebarCollapse />
          </template>
          <template #trailing>
            <UBadge :label="items.length" variant="subtle" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div v-if="items.length === 0" class="flex flex-col items-center justify-center py-16 text-dimmed">
          <UIcon name="i-lucide-inbox" class="size-16 mb-4" />
          <p>暂无交易记录</p>
        </div>
        <div v-else class="divide-y divide-default">
          <div
            v-for="item in items"
            :key="item.id"
            class="flex items-center gap-4 px-4 py-3 hover:bg-elevated/50 transition-colors"
          >
            <div class="size-10 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
              <UIcon name="i-lucide-receipt" class="size-5 text-primary" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between">
                <span class="font-medium text-sm truncate">{{ item.title }}</span>
                <span class="text-xs text-muted ml-2 shrink-0">{{ item.time }}</span>
              </div>
              <div class="flex items-center justify-between mt-0.5">
                <span class="text-xs text-dimmed">{{ item.subtitle }} · {{ item.items_count }}件商品</span>
                <span class="text-sm font-semibold ml-2">{{ item.amount }}</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
