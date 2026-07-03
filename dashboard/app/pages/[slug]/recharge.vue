<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)

const memberToken = useCookie('member-token')
const token = computed(() => memberToken.value || null)

const profile = ref<any>(null)
const isLoading = ref(false)

const rechargeAmount = ref<number>(100)
const customAmount = ref<string>('')
const useCustom = ref(false)

const presets = [50, 100, 200, 500, 1000]

// Mock recharge bonuses
const bonuses: Record<number, number> = { 50: 0, 100: 10, 200: 30, 500: 100, 1000: 300 }

const effectiveAmount = computed(() => useCustom.value ? Number(customAmount.value) || 0 : rechargeAmount.value)
const bonusAmount = computed(() => useCustom.value ? 0 : (bonuses[rechargeAmount.value] || 0))
const totalAmount = computed(() => effectiveAmount.value + bonusAmount.value)

async function loadProfile() {
  if (!token.value) return
  try {
    const { fetchMemberProfile } = useShopApi()
    profile.value = await fetchMemberProfile(slug.value, token.value)
  } catch { /* ignore */ }
}

onMounted(loadProfile)

function selectPreset(amount: number) {
  useCustom.value = false
  rechargeAmount.value = amount
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function handleRecharge() {
  if (effectiveAmount.value <= 0) {
    toast.add({ title: '请输入充值金额', color: 'error', duration: 2000, ui: { container: 'shop-toast' } })
    return
  }

  if (!token.value) {
    toast.add({ title: '请先登录', color: 'error', duration: 2000, ui: { container: 'shop-toast' } })
    return
  }

  $fetch(`/api/shop/${slug.value}/members/recharge/`, {
    method: 'POST',
    headers: { Authorization: `Token ${token.value}` },
    body: {
      amount: effectiveAmount.value,
      bonus: bonusAmount.value,
    },
  })
    .then(() => {
      toast.add({
        title: `充值 ¥${effectiveAmount.value} 成功`,
        description: bonusAmount.value > 0 ? `赠送 ¥${bonusAmount.value}，到账 ¥${totalAmount.value}` : `到账 ¥${totalAmount.value}`,
        color: 'success',
        duration: 3000,
        ui: { container: 'shop-toast' },
      })
      // Refresh profile to show updated balance
      loadProfile()
    })
    .catch((err: any) => {
      toast.add({
        title: err?.data?.detail || '充值失败',
        color: 'error',
        duration: 2000,
        ui: { container: 'shop-toast' },
      })
    })
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-md mx-auto shop-animate-in">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition" @click="router.back()">
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">充值中心</h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">选择金额快速充值</p>
      </div>
    </div>

    <!-- Current balance -->
    <div class="shop-card p-5 mb-5 text-center">
      <p class="text-xs text-(--ui-text-muted) mb-1">当前余额</p>
      <p class="text-3xl font-bold text-(--ui-primary) tabular-nums tracking-tight">
        {{ formatPrice(profile?.balance ?? 0) }}
      </p>
    </div>

    <!-- Preset amounts -->
    <div class="shop-card p-5 mb-4">
      <h2 class="text-sm font-semibold text-(--ui-text) mb-4">选择金额</h2>
      <div class="grid grid-cols-3 gap-3">
        <button
          v-for="amount in presets"
          :key="amount"
          class="rounded-xl border-2 py-3 text-center transition-all duration-150"
          :class="!useCustom && rechargeAmount === amount
            ? 'border-(--ui-primary) bg-(--ui-primary)/5 text-(--ui-primary) shadow-sm'
            : 'border-(--ui-border) text-(--ui-text) hover:border-(--ui-border-hover)'"
          @click="selectPreset(amount)"
        >
          <p class="text-lg font-bold tabular-nums">¥{{ amount }}</p>
          <p v-if="bonuses[amount] > 0" class="text-[10px] mt-0.5 text-(--ui-success) font-medium">送 ¥{{ bonuses[amount] }}</p>
        </button>
      </div>

      <!-- Custom amount -->
      <div class="mt-3">
        <button
          class="w-full py-2.5 rounded-xl border text-sm font-medium transition"
          :class="useCustom
            ? 'border-(--ui-primary) bg-(--ui-primary)/5 text-(--ui-primary)'
            : 'border-(--ui-border) text-(--ui-text-muted) hover:border-(--ui-border-hover)'"
          @click="useCustom = true"
        >
          <template v-if="useCustom">
            自定义金额
          </template>
          <template v-else>
            其他金额
          </template>
        </button>
        <div v-if="useCustom" class="relative mt-2">
          <span class="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-bold text-(--ui-text-muted)">¥</span>
          <input
            v-model="customAmount"
            type="number"
            min="1"
            step="1"
            placeholder="输入金额"
            class="w-full h-11 pl-7 pr-3 rounded-xl border border-(--ui-primary) bg-(--ui-bg) text-lg font-bold text-(--ui-text) tabular-nums outline-none"
            @input="customAmount = customAmount.replace(/\D/g, '')"
          />
        </div>
      </div>
    </div>

    <!-- Summary -->
    <div class="shop-card p-5 mb-6">
      <div class="space-y-2 text-sm">
        <div class="flex justify-between text-(--ui-text-muted)">
          <span>充值金额</span>
          <span class="tabular-nums font-medium text-(--ui-text)">¥{{ effectiveAmount }}</span>
        </div>
        <div v-if="bonusAmount > 0" class="flex justify-between text-(--ui-success)">
          <span class="flex items-center gap-1">
            <UIcon name="i-lucide-gift" class="size-3.5" />
            赠送
          </span>
          <span class="tabular-nums">+¥{{ bonusAmount }}</span>
        </div>
        <div class="border-t border-(--ui-border)/40 pt-2 flex justify-between font-bold">
          <span>到账金额</span>
          <span class="tabular-nums text-lg text-(--ui-primary)">¥{{ totalAmount }}</span>
        </div>
      </div>
    </div>

    <!-- Submit -->
    <UButton
      block
      size="lg"
      class="h-12 rounded-xl text-base font-bold"
      icon="i-lucide-wallet"
      :disabled="effectiveAmount <= 0 || isLoading"
      @click="handleRecharge"
    >
      立即充值 ¥{{ effectiveAmount }}
      <template v-if="bonusAmount > 0"> (送 ¥{{ bonusAmount }})</template>
    </UButton>

    <!-- Footer note -->
    <p class="text-center text-[10px] text-(--ui-text-muted)/50 mt-4">
      充值金额将存入储值余额，可在结算时使用
    </p>
  </div>
</template>
