<script setup lang="ts">
import type { PaginatedResponse, CouponInfo } from '~/types'

definePageMeta({ layout: 'shop' })

useHead({ title: '我的优惠券' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)

const memberAuth = useMemberAuth()
const token = computed(() => memberAuth.token.value)

const availableCoupons = ref<CouponInfo[]>([])
const usedCoupons = ref<CouponInfo[]>([])
const expiredCoupons = ref<CouponInfo[]>([])
const isLoading = ref(true)
const loadError = ref(false)

async function loadCoupons() {
  if (!token.value) {
    isLoading.value = false
    return
  }
  isLoading.value = true
  loadError.value = false
  try {
    const data = await $fetch(`/api/shop/${slug.value}/members/coupons/`, {
      headers: { Authorization: `Token ${token.value}` },
    })
    const raw = Array.isArray(data) ? data : (data as any)?.results || []
    // Map API fields (snake_case) to frontend fields
    const all = raw.map((c: any) => ({
      id: c.id,
      title: c.coupon_title || c.title,
      discount: c.discount_value || c.discount,
      discountRate: c.discount_type === 'percent' ? Number(c.discount_value) / 100 : null,
      minAmount: Number(c.min_amount || 0),
      code: c.code,
      used: c.used || false,
      expired: c.valid_until ? new Date(c.valid_until) < new Date() : false,
      validUntil: c.valid_until || '',
      scopeLabel: c.scope_label || '全场通用',
    }))
    availableCoupons.value = all.filter(c => !c.used && !c.expired)
    usedCoupons.value = all.filter(c => c.used)
    expiredCoupons.value = all.filter(c => c.expired)
  } catch {
    loadError.value = true
  } finally {
    isLoading.value = false
  }
}

onMounted(() => loadCoupons())

async function copyCode(code: string) {
  try {
    await navigator.clipboard.writeText(code)
    toast.add({ title: '优惠码已复制', color: 'success', duration: 1500, ui: { container: 'shop-toast' } })
  } catch {
    toast.add({ title: '复制失败', color: 'error', duration: 1500, ui: { container: 'shop-toast' } })
  }
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function formatDate(dateStr: string): string {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

function daysLeft(dateStr: string): number {
  if (!dateStr) return Infinity
  return Math.ceil((new Date(dateStr).getTime() - Date.now()) / 86400000)
}

const activeTab = ref<'available' | 'used' | 'expired'>('available')

const tabLabel = computed(() => {
  if (activeTab.value === 'available') return `共 ${availableCoupons.value.length} 张可用`
  if (activeTab.value === 'used') return `已使用 ${usedCoupons.value.length} 张`
  return `已过期 ${expiredCoupons.value.length} 张`
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-2xl mx-auto shop-animate-in">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button
        class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition focus-visible:ring-2 focus-visible:ring-(--ui-primary)/50 focus-visible:outline-none"
        @click="router.back()"
      >
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">
          我的优惠券
        </h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">
          {{ tabLabel }}
        </p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 bg-(--ui-bg-muted) rounded-xl p-1 mb-5">
      <button
        v-for="tab in ([
          { key: 'available', label: '可用', count: availableCoupons.length },
          { key: 'used', label: '已使用', count: usedCoupons.length },
          { key: 'expired', label: '已过期', count: expiredCoupons.length },
        ] as const)"
        :key="tab.key"
        class="flex-1 py-2 rounded-lg text-sm font-medium transition focus-visible:ring-2 focus-visible:ring-(--ui-primary)/50 focus-visible:outline-none"
        :class="activeTab === tab.key
          ? 'bg-(--ui-bg) text-(--ui-text) shadow-sm'
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

    <!-- Error -->
    <div v-else-if="loadError" class="flex flex-col items-center justify-center py-16">
      <div class="size-16 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-3">
        <UIcon name="i-lucide-wifi-off" class="size-8 text-(--ui-text-muted)/40" />
      </div>
      <p class="font-semibold text-(--ui-text)">
        加载失败
      </p>
      <p class="text-sm text-(--ui-text-muted) mt-1 mb-4">
        请检查网络后重试
      </p>
      <UButton
        label="重新加载"
        icon="i-lucide-refresh-cw"
        variant="soft"
        @click="loadCoupons"
      />
    </div>

    <!-- Available -->
    <Transition name="tab-fade">
      <div v-if="activeTab === 'available' && availableCoupons.length > 0" class="space-y-3">
        <div
          v-for="coupon in availableCoupons"
          :key="coupon.id"
          class="relative overflow-hidden rounded-xl border border-(--ui-primary)/20 bg-gradient-to-r from-(--ui-primary)/8 to-(--ui-primary)/3 hover:shadow-md hover:-translate-y-0.5 transition-all duration-200"
        >
          <div class="flex">
            <!-- Left: discount -->
            <div class="w-24 shrink-0 flex flex-col items-center justify-center py-4 bg-(--ui-primary)/10">
              <span v-if="coupon.discountRate" class="text-2xl font-extrabold tabular-nums tracking-tighter text-(--ui-primary)">{{ (coupon.discountRate * 100).toFixed(0) }}%</span>
              <span v-else class="text-2xl font-extrabold tabular-nums tracking-tighter text-(--ui-primary)">¥{{ coupon.discount }}</span>
              <span class="text-[11px] font-medium mt-0.5 text-(--ui-primary)/70">{{ coupon.discountRate ? '折扣' : '减免' }}</span>
            </div>
            <!-- Right: info -->
            <div class="flex-1 p-3 pl-3 border-l-2 border-dashed border-(--ui-primary)/30">
              <div class="flex items-start justify-between">
                <div>
                  <p class="text-sm font-bold text-(--ui-text)">
                    {{ coupon.title }}
                  </p>
                  <p class="text-xs mt-0.5" :class="coupon.minAmount > 0 ? 'text-(--ui-text-muted)' : 'text-green-600 font-medium'">
                    {{ coupon.minAmount > 0 ? `满 ¥${coupon.minAmount} 可用` : '无门槛' }}
                    <span v-if="coupon.scopeLabel && coupon.scopeLabel !== '全场通用'" class="text-[10px] text-amber-600 flex items-center gap-1 mt-0.5"><UIcon name="i-lucide-info" class="size-3" />{{ coupon.scopeLabel }}</span>
                  </p>
                </div>
                <div class="text-right shrink-0">
                  <p class="text-[11px] text-(--ui-text-muted)/70">
                    有效期至
                  </p>
                  <p class="text-xs text-(--ui-text-muted)">
                    {{ formatDate(coupon.validUntil) }}
                  </p>
                  <p v-if="daysLeft(coupon.validUntil) <= 3 && daysLeft(coupon.validUntil) > 0" class="text-[10px] text-red-500 font-medium mt-0.5">
                    仅剩 {{ daysLeft(coupon.validUntil) }} 天
                  </p>
                </div>
              </div>
              <!-- Code row -->
              <div class="flex items-center justify-between mt-2">
                <button
                  class="flex items-center gap-1.5 text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition-colors font-mono"
                  @click="copyCode(coupon.code)"
                >
                  <UIcon name="i-lucide-copy" class="size-3" />
                  {{ coupon.code }}
                </button>
                <UButton
                  size="xs"
                  color="primary"
                  variant="soft"
                  class="rounded-full text-xs"
                  :to="`/${slug}`"
                >
                  立即使用
                </UButton>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Used -->
    <Transition name="tab-fade">
      <div v-if="activeTab === 'used' && usedCoupons.length > 0" class="space-y-3">
        <div
          v-for="coupon in usedCoupons"
          :key="coupon.id"
          class="rounded-xl bg-(--ui-bg-muted)/50 border border-(--ui-border) p-4 opacity-60 grayscale-[0.4]"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-(--ui-text) line-through">
                {{ coupon.title }}
              </p>
              <p class="text-xs text-(--ui-text-muted) mt-1 flex items-center gap-1.5">
                <UIcon name="i-lucide-copy" class="size-3" />{{ coupon.code }}
              </p>
            </div>
            <UBadge color="neutral" variant="soft" size="sm">
              已使用
            </UBadge>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Expired -->
    <Transition name="tab-fade">
      <div v-if="activeTab === 'expired' && expiredCoupons.length > 0" class="space-y-3">
        <div
          v-for="coupon in expiredCoupons"
          :key="coupon.id"
          class="rounded-xl bg-(--ui-bg-muted)/50 border border-(--ui-border) p-4 opacity-40 grayscale-[0.6]"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-(--ui-text-muted)">
                {{ coupon.title }}
              </p>
              <p class="text-xs text-(--ui-text-muted)/60 mt-1">
                已于 {{ formatDate(coupon.validUntil) }} 过期
              </p>
            </div>
            <UBadge color="neutral" variant="soft" size="sm">
              已过期
            </UBadge>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Empty -->
    <Transition name="tab-fade">
      <div v-if="activeTab === 'available' && availableCoupons.length === 0 && !isLoading && !loadError" class="flex flex-col items-center justify-center py-16">
        <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
          <UIcon name="i-lucide-ticket" class="size-10 text-(--ui-text-muted)/25" />
        </div>
        <p class="text-lg font-semibold text-(--ui-text)">
          暂无可用优惠券
        </p>
        <p class="text-sm text-(--ui-text-muted) mt-1 mb-4">
          逛逛商城，下单即可获取优惠券
        </p>
        <UButton
          label="去逛逛"
          icon="i-lucide-shopping-bag"
          variant="soft"
          :to="`/${slug}`"
        />
      </div>
      <div v-else-if="activeTab !== 'available' && !isLoading && !loadError" class="flex flex-col items-center justify-center py-16">
        <div class="size-16 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-3">
          <UIcon name="i-lucide-ticket" class="size-7 text-(--ui-text-muted)/25" />
        </div>
        <p class="text-sm font-medium text-(--ui-text)">
          暂无{{ activeTab === 'used' ? '已使用' : '已过期' }}优惠券
        </p>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.tab-fade-enter-active { transition: opacity 0.2s ease-out; }
.tab-fade-leave-active { transition: opacity 0.15s ease-in; }
.tab-fade-enter-from,
.tab-fade-leave-to { opacity: 0; }
</style>
