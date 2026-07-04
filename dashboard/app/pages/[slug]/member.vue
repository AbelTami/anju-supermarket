<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
// Auth check
const memberAuth = useMemberAuth()
const token = computed(() => memberAuth.token.value)

onMounted(() => {
  if (!token.value) {
    router.replace(`/${slug.value}/login`)
  }
})

const profile = ref<any>(null)
const isLoading = ref(false)
const errorMessage = ref('')

async function loadProfile() {
  if (!token.value) return
  isLoading.value = true
  errorMessage.value = ''
  try {
    const data = await memberAuth.fetchProfile(slug.value)
    profile.value = data
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || '加载会员信息失败'
  } finally {
    isLoading.value = false
  }
}

function handleLogout() {
  memberAuth.logout()
  toast.add({ title: '已退出登录', color: 'info', duration: 2000, ui: { container: 'shop-toast' } })
  router.push(`/${slug.value}`)
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

// Mock level system — in production, read from profile
const memberLevel = computed(() => {
  if (!profile.value) return { name: '普通会员', color: 'text-(--ui-text-muted)', progress: 0, nextLevel: '白银会员', remaining: 0 }
  const spent = Number(profile.value.total_spent) || 0
  if (spent >= 5000) return { name: '钻石会员', color: 'text-violet-500', progress: 100, nextLevel: null, remaining: 0 }
  if (spent >= 2000) return { name: '黄金会员', color: 'text-amber-500', progress: ((spent - 2000) / 3000) * 100, nextLevel: '钻石会员', remaining: Math.max(0, 5000 - spent) }
  if (spent >= 500) return { name: '白银会员', color: 'text-sky-500', progress: ((spent - 500) / 1500) * 100, nextLevel: '黄金会员', remaining: Math.max(0, 2000 - spent) }
  return { name: '普通会员', color: 'text-(--ui-text-muted)', progress: (spent / 500) * 100, nextLevel: '白银会员', remaining: Math.max(0, 500 - spent) }
})

// Quick links config
const quickLinks = [
  { label: '我的订单', icon: 'i-lucide-receipt', to: 'orders', color: '' },
  { label: '我的收藏', icon: 'i-lucide-heart', to: 'favorites', color: 'text-rose-500' },
  { label: '优惠券', icon: 'i-lucide-ticket', to: 'coupons', color: 'text-amber-500' },
  { label: '充值中心', icon: 'i-lucide-wallet', to: 'recharge', color: 'text-(--ui-primary)' },
  { label: '消费分析', icon: 'i-lucide-bar-chart-3', to: 'analytics', color: 'text-violet-500' },
]

// Load on mount
watchEffect(() => {
  if (token.value) loadProfile()
})
</script>

<template>
  <ClientOnly>
  <div class="py-6 px-4 lg:px-6 max-w-2xl mx-auto shop-animate-in pb-24 lg:pb-6">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button
        class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition"
        @click="router.back()"
      >
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">
          会员中心
        </h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">
          查看您的会员信息和消费记录
        </p>
      </div>
    </div>

    <!-- Auth redirect -->
    <div v-if="!token" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-log-in" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">
        请先登录
      </p>
      <p class="shop-empty-desc">
        登录后可查看会员信息和订单
      </p>
      <UButton
        :to="`/${slug}/login`"
        label="去登录"
        icon="i-lucide-user"
        variant="soft"
      />
    </div>

    <!-- Loading -->
    <div v-else-if="isLoading" class="space-y-4 animate-pulse">
      <div class="shop-skeleton h-36 rounded-xl" />
      <div class="shop-skeleton h-24 rounded-xl" />
      <div class="shop-skeleton h-40 rounded-xl" />
    </div>

    <!-- Error -->
    <div v-else-if="errorMessage" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-alert-circle" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-desc">
        {{ errorMessage }}
      </p>
      <UButton
        variant="soft"
        color="neutral"
        label="重试"
        size="sm"
        @click="loadProfile"
      />
    </div>

    <!-- Profile -->
    <div v-else-if="profile" class="space-y-4">
      <!-- Member card (upgraded) -->
      <div class="shop-member-card rounded-xl p-5 text-white shadow-lg shadow-(--ui-primary)/20">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <div class="size-14 rounded-full bg-white/20 backdrop-blur flex items-center justify-center text-white">
              <UIcon name="i-lucide-user" class="size-7" />
            </div>
            <div>
              <p class="text-lg font-bold">
                {{ profile.name || profile.phone || '会员' }}
              </p>
              <p class="text-xs text-white/70">
                {{ profile.phone || '' }}
              </p>
            </div>
          </div>
          <div class="text-right">
            <p class="text-xs text-white/70">
              会员等级
            </p>
            <p class="text-sm font-bold" :class="memberLevel.color">
              {{ memberLevel.name }}
            </p>
          </div>
        </div>

        <!-- Progress to next level -->
        <div v-if="memberLevel.nextLevel" class="mb-4">
          <div class="flex justify-between text-xs text-white/70 mb-1">
            <span>距{{ memberLevel.nextLevel }}还差 ¥{{ memberLevel.remaining.toFixed(0) }}</span>
            <span>{{ Math.min(100, Math.round(memberLevel.progress)) }}%</span>
          </div>
          <div class="h-1.5 rounded-full bg-white/20 overflow-hidden">
            <div
              class="h-full rounded-full bg-white/60 transition-all duration-500"
              :style="{ width: `${Math.min(100, memberLevel.progress)}%` }"
            />
          </div>
        </div>

        <!-- Stats row -->
        <div class="grid grid-cols-3 gap-3">
          <div class="text-center">
            <p class="text-xl font-bold tabular-nums">
              {{ profile.points ?? 0 }}
            </p>
            <p class="text-xs text-white/70">
              积分
            </p>
          </div>
          <div class="text-center border-x border-white/10">
            <p class="text-xl font-bold tabular-nums">
              {{ formatPrice(profile.balance ?? 0) }}
            </p>
            <p class="text-xs text-white/70">
              储值余额
            </p>
          </div>
          <div class="text-center">
            <p class="text-xl font-bold tabular-nums">
              {{ formatPrice(profile.total_spent ?? 0) }}
            </p>
            <p class="text-xs text-white/70">
              累计消费
            </p>
          </div>
        </div>

        <!-- Card No -->
        <div v-if="profile.card_no" class="mt-4 pt-3 border-t border-white/10 text-center">
          <p class="text-xs text-white/50 font-mono tracking-widest">
            {{ profile.card_no }}
          </p>
        </div>
      </div>

      <!-- Stats grid (alternative layout) -->
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div class="shop-card p-3 text-center">
          <UIcon name="i-lucide-credit-card" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
          <p class="text-xs text-(--ui-text-muted)">
            卡号
          </p>
          <p class="text-sm font-semibold text-(--ui-text) mt-0.5 truncate">
            {{ profile.card_no || '-' }}
          </p>
        </div>
        <div class="shop-card p-3 text-center">
          <UIcon name="i-lucide-coins" class="size-5 text-amber-500 mx-auto mb-1" />
          <p class="text-xs text-(--ui-text-muted)">
            积分
          </p>
          <p class="text-sm font-semibold text-(--ui-text) mt-0.5 tabular-nums">
            {{ profile.points ?? 0 }}
          </p>
        </div>
        <div class="shop-card p-3 text-center">
          <UIcon name="i-lucide-wallet" class="size-5 text-(--ui-primary) mx-auto mb-1" />
          <p class="text-xs text-(--ui-text-muted)">
            储值余额
          </p>
          <p class="text-sm font-bold text-(--ui-primary) mt-0.5 tabular-nums">
            {{ formatPrice(profile.balance ?? 0) }}
          </p>
        </div>
        <div class="shop-card p-3 text-center">
          <UIcon name="i-lucide-trending-up" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
          <p class="text-xs text-(--ui-text-muted)">
            累计消费
          </p>
          <p class="text-sm font-semibold text-(--ui-text) mt-0.5 tabular-nums">
            {{ formatPrice(profile.total_spent ?? 0) }}
          </p>
        </div>
      </div>

      <!-- Quick links -->
      <div class="shop-card overflow-hidden">
        <NuxtLink
          v-for="link in quickLinks"
          :key="link.label"
          :to="link.to ? `/${slug}/${link.to}` : ''"
          class="flex items-center gap-3 p-4 hover:bg-(--ui-bg-muted)/50 transition border-b border-(--ui-border)/30 last:border-0"
          :class="link.disabled ? 'pointer-events-none' : ''"
        >
          <div class="size-9 rounded-lg bg-(--ui-bg-muted) flex items-center justify-center">
            <UIcon :name="link.icon" class="size-4" :class="link.color || 'text-(--ui-text-muted)'" />
          </div>
          <span class="flex-1 text-sm font-medium" :class="link.disabled ? 'text-(--ui-text-muted)' : 'text-(--ui-text)'">
            {{ link.label }}
          </span>
          <span v-if="link.disabled" class="text-[10px] text-(--ui-text-muted)/50 bg-(--ui-bg-muted) px-1.5 py-0.5 rounded">即将开放</span>
          <UIcon v-else name="i-lucide-chevron-right" class="size-4 text-(--ui-text-muted)" />
        </NuxtLink>
      </div>

      <!-- Logout -->
      <button
        class="w-full shop-card p-4 flex items-center gap-3 hover:bg-(--ui-error)/5 transition text-left"
        @click="handleLogout"
      >
        <div class="size-9 rounded-lg bg-(--ui-error)/10 flex items-center justify-center">
          <UIcon name="i-lucide-log-out" class="size-4 text-(--ui-error)" />
        </div>
        <span class="flex-1 text-sm font-medium text-(--ui-error)">退出登录</span>
        <UIcon name="i-lucide-chevron-right" class="size-4 text-(--ui-text-muted)" />
      </button>
    </div>
  </div>
  </ClientOnly>
</template>
