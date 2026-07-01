<script setup lang="ts">
import type { Period, Range, Stat } from '~/types'

const props = defineProps<{
  period: Period
  range: Range
}>()

import { useAuth } from '~/composables/useAuth'
const auth = useAuth()

const stats = ref<Stat[]>([
  { title: '今日营业额', icon: 'i-lucide-circle-dollar-sign', value: '—', variation: 0 },
  { title: '今日订单', icon: 'i-lucide-shopping-cart', value: '—', variation: 0 },
  { title: '扫码收款', icon: 'i-lucide-smartphone', value: '—', variation: 0 },
  { title: '会员收款', icon: 'i-lucide-credit-card', value: '—', variation: 0 },
])

async function fetchStats() {
  const slug = (auth.currentTenant.value as any)?.slug
  if (!slug) return
  const days = Math.ceil((props.range.end.getTime() - props.range.start.getTime()) / 86400000) || 2
  try {
    const d = await $fetch(`/api/tenant/${slug}/daily-summaries/overview/?days=${days}&period=${props.period}`)
    const daily: any[] = d.daily || []
    const yesterday = daily.length > 1 ? daily[daily.length - 2] : null
    const pct = (a: number, b: number) => b ? Math.round(((a - b) / b) * 100) : 0
    stats.value = [
      { title: '今日营业额', icon: 'i-lucide-circle-dollar-sign',
        value: `¥${(d.total_amount || 0).toLocaleString()}`, variation: pct(d.total_amount || 0, yesterday?.amount || 0) },
      { title: '今日订单', icon: 'i-lucide-shopping-cart',
        value: d.total_orders || 0, variation: pct(d.total_orders || 0, yesterday?.orders || 0) },
      { title: '扫码收款', icon: 'i-lucide-smartphone',
        value: `¥${((d.wechat_amount || 0) + (d.alipay_amount || 0)).toLocaleString()}`, variation: 0 },
      { title: '会员收款', icon: 'i-lucide-credit-card',
        value: `¥${(d.member_amount || 0).toLocaleString()}`, variation: 0 },
    ]
  } catch { /* keep defaults */ }
}

onMounted(fetchStats)
watch([() => (auth.currentTenant.value as any)?.slug, () => props.period, () => props.range], fetchStats)
</script>

<template>
  <UPageGrid class="lg:grid-cols-4 gap-4 sm:gap-6 lg:gap-px">
    <UPageCard
      v-for="(stat, index) in stats"
      :key="index"
      :icon="stat.icon"
      :title="stat.title"
      :to="['/admin/finance', '/admin/inbox', '/admin/pos', '/admin/customers'][index]"
      variant="subtle"
      :ui="{
        container: 'gap-y-1.5',
        wrapper: 'items-start',
        leading: 'p-2.5 rounded-full bg-primary/10 ring ring-inset ring-primary/25 flex-col',
        title: 'font-normal text-muted text-xs uppercase'
      }"
      class="lg:rounded-none first:rounded-l-lg last:rounded-r-lg hover:z-1"
    >
      <div class="flex items-center gap-2">
        <span class="text-2xl font-semibold text-highlighted">
          {{ stat.value }}
        </span>

        <UBadge
          :color="stat.variation > 0 ? 'success' : 'error'"
          variant="subtle"
          class="text-xs"
        >
          {{ stat.variation > 0 ? '+' : '' }}{{ stat.variation }}%
        </UBadge>
      </div>
    </UPageCard>
  </UPageGrid>
</template>
