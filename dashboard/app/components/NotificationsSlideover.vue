<script setup lang="ts">
import { formatTimeAgo } from '@vueuse/core'
import { useAuth } from '~/composables/useAuth'

const { isNotificationsSlideoverOpen } = useDashboard()
const auth = useAuth()

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/orders?ordering=-paid_at&page_size=10` : ''

const { data } = useFetch(apiUrl, { lazy: true, watch: [tenantSlug] })

const notifications = computed(() => {
  const orders = (data.value as any)?.results || []
  return orders.map((o: any) => ({
    id: o.id,
    body: `订单 #${o.order_no} — ¥${o.total_amount} [${o.payment_method === 'cash' ? '现金' : o.payment_method === 'wechat' ? '微信' : o.payment_method === 'alipay' ? '支付宝' : '会员卡'}]`,
    date: o.paid_at,
    sender: { name: o.cashier_name, avatar: undefined },
    unread: false,
  }))
})
</script>

<template>
  <USlideover v-model:open="isNotificationsSlideoverOpen" title="最近交易">
    <template #body>
      <div v-if="notifications.length === 0" class="text-center text-dimmed py-8">暂无交易记录</div>
      <NuxtLink
        v-for="n in notifications"
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
