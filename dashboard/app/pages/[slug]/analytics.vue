<script setup lang="ts">
import type { OrderInfo, PaginatedResponse } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const slug = computed(() => route.params.slug as string)
const { fetchOrders } = useShopApi()

const memberToken = useCookie('member-token')
const token = computed(() => memberToken.value || null)

const profile = ref<any>(null)
const orders = ref<OrderInfo[]>([])
const isLoading = ref(true)

async function loadData() {
  isLoading.value = true
  try {
    const { fetchMemberProfile } = useShopApi()
    const [prof, ords] = await Promise.all([
      fetchMemberProfile(slug.value, token.value!),
      fetchOrders(slug.value, token.value!),
    ])
    profile.value = prof
    orders.value = Array.isArray(ords) ? ords as OrderInfo[] : (ords as PaginatedResponse<OrderInfo>).results || []
  } catch { /* ignore */ }
  finally { isLoading.value = false }
}

onMounted(() => {
  if (!token.value) router.replace(`/${slug.value}/login`)
  else loadData()
})

const totalSpent = computed(() => Number(profile.value?.total_spent ?? 0))
const totalOrders = computed(() => orders.value.length)
const avgPerOrder = computed(() => totalOrders.value > 0 ? totalSpent.value / totalOrders.value : 0)
const points = computed(() => Number(profile.value?.points ?? 0))
const balance = computed(() => Number(profile.value?.balance ?? 0))

// Monthly breakdown (mock — in prod group by month from backend)
const monthlyData = computed(() => {
  const months: Record<string, number> = {}
  orders.value.forEach((o) => {
    if (o.paid_at) {
      const m = o.paid_at.slice(0, 7) // "2026-07"
      months[m] = (months[m] || 0) + Number(o.paid_amount || 0)
    }
  })
  return Object.entries(months).sort(([a], [b]) => a.localeCompare(b)).slice(-6)
})

const maxMonthly = computed(() => Math.max(...monthlyData.value.map(([, v]) => v), 1))

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function formatDate(d: string): string {
  if (!d) return ''
  return new Date(d).toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}

function monthLabel(m: string): string {
  const [y, mo] = m.split('-')
  return `${y.slice(2)}/${mo}`
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-2xl mx-auto shop-animate-in pb-24 lg:pb-6">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition" @click="router.back()">
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">消费分析</h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">了解您的消费习惯</p>
      </div>
    </div>

    <!-- Auth guard -->
    <div v-if="!token" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-log-in" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">请先登录</p>
      <p class="shop-empty-desc">登录后可查看消费分析</p>
      <UButton :to="`/${slug}/login`" label="去登录" variant="soft" />
    </div>

    <!-- Loading -->
    <div v-else-if="isLoading" class="space-y-4 animate-pulse">
      <div class="shop-skeleton h-28 rounded-xl" />
      <div class="shop-skeleton h-40 rounded-xl" />
      <div class="shop-skeleton h-32 rounded-xl" />
    </div>

    <!-- Stats cards -->
    <div v-else class="space-y-5">
      <!-- Summary -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div class="shop-card p-4 text-center">
          <p class="text-2xl font-bold tabular-nums text-(--ui-primary)">{{ formatPrice(totalSpent) }}</p>
          <p class="text-xs text-(--ui-text-muted) mt-1">累计消费</p>
        </div>
        <div class="shop-card p-4 text-center">
          <p class="text-2xl font-bold tabular-nums text-(--ui-text)">{{ totalOrders }}</p>
          <p class="text-xs text-(--ui-text-muted) mt-1">总订单</p>
        </div>
        <div class="shop-card p-4 text-center">
          <p class="text-2xl font-bold tabular-nums text-(--ui-text)">{{ formatPrice(avgPerOrder) }}</p>
          <p class="text-xs text-(--ui-text-muted) mt-1">客单价</p>
        </div>
        <div class="shop-card p-4 text-center">
          <p class="text-2xl font-bold tabular-nums text-amber-500">{{ points }}</p>
          <p class="text-xs text-(--ui-text-muted) mt-1">积分</p>
        </div>
      </div>

      <!-- Monthly bar chart -->
      <div class="shop-card p-5">
        <div class="flex items-center gap-2 mb-5">
          <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
            <UIcon name="i-lucide-bar-chart-3" class="size-3.5 text-(--ui-primary)" />
          </div>
          <h2 class="text-sm font-semibold text-(--ui-text)">月度消费趋势</h2>
        </div>

        <div v-if="monthlyData.length === 0" class="text-center py-8 text-xs text-(--ui-text-muted)">
          暂无消费数据
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="[month, amount] in monthlyData"
            :key="month"
            class="flex items-center gap-3"
          >
            <span class="text-[10px] text-(--ui-text-muted) w-12 shrink-0 text-right">{{ monthLabel(month) }}</span>
            <div class="flex-1 h-6 rounded-full bg-(--ui-bg-muted) overflow-hidden relative">
              <div
                class="h-full rounded-full transition-all duration-500"
                :class="amount >= maxMonthly * 0.8 ? 'bg-gradient-to-r from-(--ui-primary) to-violet-500' : amount >= maxMonthly * 0.5 ? 'bg-(--ui-primary)' : 'bg-(--ui-primary)/60'"
                :style="{ width: `${(amount / maxMonthly) * 100}%` }"
              />
            </div>
            <span class="text-xs font-medium tabular-nums text-(--ui-text) w-20 shrink-0 text-right">{{ formatPrice(amount) }}</span>
          </div>
        </div>
      </div>

      <!-- Member info -->
      <div class="shop-card p-5">
        <div class="flex items-center gap-2 mb-4">
          <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
            <UIcon name="i-lucide-info" class="size-3.5 text-(--ui-primary)" />
          </div>
          <h2 class="text-sm font-semibold text-(--ui-text)">会员概览</h2>
        </div>
        <div class="grid grid-cols-2 gap-y-3 gap-x-6 text-sm">
          <div class="flex justify-between">
            <span class="text-(--ui-text-muted)">注册时间</span>
            <span class="text-(--ui-text) font-medium">{{ profile?.created_at ? new Date(profile.created_at).toLocaleDateString('zh-CN') : '-' }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-(--ui-text-muted)">储值余额</span>
            <span class="text-(--ui-text) font-medium tabular-nums">{{ formatPrice(balance) }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-(--ui-text-muted)">总订单数</span>
            <span class="text-(--ui-text) font-medium">{{ totalOrders }}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-(--ui-text-muted)">积分</span>
            <span class="text-(--ui-text) font-medium tabular-nums">{{ points }}</span>
          </div>
        </div>
      </div>

      <!-- Recent orders -->
      <div class="shop-card p-5">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-2">
            <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
              <UIcon name="i-lucide-receipt" class="size-3.5 text-(--ui-primary)" />
            </div>
            <h2 class="text-sm font-semibold text-(--ui-text)">最近订单</h2>
          </div>
          <NuxtLink :to="`/${slug}/orders`" class="text-xs text-(--ui-primary) hover:underline">查看全部</NuxtLink>
        </div>

        <div v-if="orders.length === 0" class="text-center py-6 text-xs text-(--ui-text-muted)">
          暂无订单
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="order in orders.slice(0, 5)"
            :key="order.id"
            class="flex items-center justify-between py-2 border-b border-(--ui-border)/20 last:border-0"
          >
            <div class="flex items-center gap-2 min-w-0">
              <div class="size-2 rounded-full shrink-0" :class="order.status === 'completed' || order.status === 'paid' ? 'bg-(--ui-success)' : 'bg-(--ui-text-muted)/30'" />
              <span class="text-xs text-(--ui-text-muted) truncate">{{ formatDate(order.paid_at) }}</span>
            </div>
            <span class="text-sm font-medium tabular-nums text-(--ui-text)">{{ formatPrice(order.paid_amount) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
