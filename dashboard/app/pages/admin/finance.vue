<script setup lang="ts">
/** 财务/报表 */
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'

const tenantSlug = useCurrentTenantSlug()
const apiUrl = computed(() =>
  tenantSlug.value ? `/api/tenant/${tenantSlug.value}/daily-summaries/overview/?days=7` : undefined,
)

const { data, status } = useFetch(apiUrl, {
  lazy: true,
  server: false,
  key: computed(() => `finance-overview-${tenantSlug.value}`),
})

interface OverviewResponse {
  total_amount?: number
  total_orders?: number
  cash_amount?: number
  wechat_amount?: number
  alipay_amount?: number
  daily?: Array<{ date: string, amount: number, orders: number }>
}

const summaryCards = computed(() => {
  const d = (data.value as OverviewResponse | undefined) ?? {}
  return [
    { label: '7日营业额', value: `¥${(d.total_amount ?? 0).toLocaleString()}` },
    { label: '7日订单数', value: String(d.total_orders ?? 0) },
    { label: '现金收款', value: `¥${(d.cash_amount ?? 0).toLocaleString()}` },
    { label: '扫码收款', value: `¥${((d.wechat_amount ?? 0) + (d.alipay_amount ?? 0)).toLocaleString()}` },
  ]
})

const dailyData = computed(() => (data.value as OverviewResponse | undefined)?.daily ?? [])
</script>

<template>
  <UDashboardPanel>
    <template #header>
      <UDashboardNavbar title="财务/报表" />
    </template>

    <template #body>
      <div class="p-4 space-y-6">
        <div v-if="status === 'pending'" class="text-center py-12 text-dimmed">
          加载中...
        </div>
        <template v-else>
          <!-- 统计卡片 -->
          <div class="grid grid-cols-4 gap-4">
            <UCard v-for="stat in summaryCards" :key="stat.label">
              <div class="text-sm text-dimmed">
                {{ stat.label }}
              </div>
              <div class="text-2xl font-bold mt-1">
                {{ stat.value }}
              </div>
            </UCard>
          </div>

          <!-- 每日趋势 -->
          <UCard>
            <template #header>
              <span class="font-semibold">近7天销售趋势</span>
            </template>
            <div class="space-y-2">
              <div v-if="dailyData.length === 0" class="text-center text-dimmed py-8">
                暂无数据
              </div>
              <div v-for="day in dailyData" :key="day.date" class="flex items-center gap-4">
                <span class="text-sm text-dimmed w-24">{{ day.date }}</span>
                <div class="flex-1 bg-primary/20 rounded-full h-6 relative overflow-hidden">
                  <div
                    class="bg-primary h-full rounded-full transition-all"
                    :style="{ width: `${dailyData.length ? (day.amount / Math.max(...dailyData.map((d: any) => d.amount))) * 100 : 0}%` }"
                  />
                </div>
                <span class="text-sm font-medium w-28 text-right">¥{{ day.amount.toLocaleString() }}</span>
                <span class="text-xs text-dimmed w-14 text-right">{{ day.orders }}笔</span>
              </div>
            </div>
          </UCard>
        </template>
      </div>
    </template>
  </UDashboardPanel>
</template>
