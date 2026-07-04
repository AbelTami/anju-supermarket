<script setup lang="ts">
import type { PaginatedResponse, CouponInfo } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)

const memberAuth = useMemberAuth()
const token = computed(() => memberAuth.token.value)

// Coupon data from API
const availableCoupons = ref<CouponInfo[]>([])
const usedCoupons = ref<CouponInfo[]>([])
const expiredCoupons = ref<CouponInfo[]>([])
const isLoading = ref(true)

async function loadCoupons() {
  if (!token.value) {
    isLoading.value = false
    return
  }
  try {
    const data = await $fetch(`/api/shop/${slug.value}/members/coupons/`, {
      headers: { Authorization: `Token ${token.value}` },
    })
    const all: CouponInfo[] = Array.isArray(data) ? data : (data as PaginatedResponse<CouponInfo>)?.results || []
    availableCoupons.value = all.filter(c => !c.used && !c.expired)
    usedCoupons.value = all.filter(c => c.used)
    expiredCoupons.value = all.filter(c => c.expired)
  } catch { /* fallback to empty */ }
  finally { isLoading.value = false }
}

onMounted(() => {
  loadCoupons()
})

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

// Simple tabs
const activeTab = ref<'available' | 'used' | 'expired'>('available')
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-2xl mx-auto shop-animate-in">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition" @click="router.back()">
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">我的优惠券</h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">共 {{ availableCoupons.length }} 张可用</p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 bg-(--ui-bg-muted)/50 rounded-xl p-1 mb-5">
      <button
        v-for="tab in ([
          { key: 'available', label: '可用', count: availableCoupons.length },
          { key: 'used', label: '已使用', count: usedCoupons.length },
          { key: 'expired', label: '已过期', count: expiredCoupons.length },
        ] as const)"
        :key="tab.key"
        class="flex-1 py-2 rounded-lg text-sm font-medium transition"
        :class="activeTab === tab.key
          ? 'bg-white dark:bg-zinc-800 text-(--ui-text) shadow-sm'
          : 'text-(--ui-text-muted) hover:text-(--ui-text)'"
        @click="activeTab = tab.key"
      >
        {{ tab.label }} ({{ tab.count }})
      </button>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="space-y-3">
      <div v-for="i in 3" :key="i" class="shop-skeleton h-24 rounded-xl" />
    </div>

    <!-- Coupon list -->
    <div v-if="activeTab === 'available' && availableCoupons.length > 0" class="space-y-3">
      <div
        v-for="coupon in availableCoupons"
        :key="coupon.id"
        class="relative overflow-hidden rounded-xl bg-gradient-to-r from-(--ui-primary)/5 to-(--ui-primary)/2 border border-(--ui-primary)/20 p-0"
      >
        <div class="flex">
          <!-- Left: discount amount -->
          <div class="w-24 shrink-0 flex flex-col items-center justify-center py-4 text-(--ui-primary)">
            <span v-if="coupon.discountRate" class="text-2xl font-black tabular-nums">{{ (coupon.discountRate * 100).toFixed(0) }}%</span>
            <span v-else class="text-2xl font-black tabular-nums">{{ coupon.discount }}</span>
            <span class="text-[10px] font-medium mt-0.5 opacity-70">{{ coupon.discountRate ? '折扣' : '减免' }}</span>
          </div>
          <!-- Right: info -->
          <div class="flex-1 p-3 pl-0 border-l border-dashed border-(--ui-primary)/20">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-sm font-bold text-(--ui-text)">{{ coupon.title }}</p>
                <p v-if="coupon.minAmount > 0" class="text-xs text-(--ui-text-muted) mt-0.5">满 ¥{{ coupon.minAmount }} 可用</p>
                <p v-else class="text-xs text-(--ui-text-muted) mt-0.5">无门槛</p>
              </div>
              <div class="text-right shrink-0">
                <p class="text-[10px] text-(--ui-text-muted)/60">有效期至</p>
                <p class="text-xs text-(--ui-text-muted)">{{ coupon.validUntil }}</p>
              </div>
            </div>
            <div class="flex items-center justify-between mt-2">
              <p class="text-[10px] text-(--ui-text-muted)/50 font-mono">码: {{ coupon.code }}</p>
              <UButton size="2xs" color="primary" variant="soft" class="rounded-full text-[10px]">立即使用</UButton>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="activeTab === 'used' && usedCoupons.length > 0" class="space-y-3">
      <div
        v-for="coupon in usedCoupons"
        :key="coupon.id"
        class="rounded-xl bg-(--ui-bg-muted)/50 border border-(--ui-border) p-4 opacity-60"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-(--ui-text) line-through">{{ coupon.title }}</p>
            <p class="text-xs text-(--ui-text-muted) mt-0.5">码: {{ coupon.code }}</p>
          </div>
          <UBadge color="neutral" variant="soft" size="sm">已使用</UBadge>
        </div>
      </div>
    </div>

    <div v-else-if="activeTab === 'expired' && expiredCoupons.length > 0" class="space-y-3">
      <div
        v-for="coupon in expiredCoupons"
        :key="coupon.id"
        class="rounded-xl bg-(--ui-bg-muted)/50 border border-(--ui-border) p-4 opacity-50"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-(--ui-text-muted)">{{ coupon.title }}</p>
            <p class="text-xs text-(--ui-text-muted)/60 mt-0.5">已于 {{ coupon.validUntil }} 过期</p>
          </div>
          <UBadge color="neutral" variant="outline" size="sm">已过期</UBadge>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div
      v-else
      class="flex flex-col items-center justify-center py-16"
    >
      <div class="size-16 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-3">
        <UIcon name="i-lucide-ticket" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">暂无{{ activeTab === 'available' ? '可用' : activeTab === 'used' ? '已使用' : '已过期' }}优惠券</p>
      <p class="shop-empty-desc">{{ activeTab === 'available' ? '多消费可获取更多优惠券' : '' }}</p>
    </div>
  </div>
</template>
