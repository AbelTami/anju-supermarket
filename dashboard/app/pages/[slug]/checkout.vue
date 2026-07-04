<script setup lang="ts">
import { mediaUrl } from '~/composables/useShopApi'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { placeOrder } = useShopApi()
const { onImgError } = useImageFallback()

const cart = useState<any[]>('shop-cart', () => [])

// Redirect to cart if empty
if (cart.value.length === 0 && import.meta.client) {
  router.replace(`/${slug.value}/cart`)
}

// Selection state — use all cart items or pass from cart
const selectedItems = computed(() => cart.value)

const totalAmount = computed(() =>
  selectedItems.value.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 0), 0)
)

const itemCount = computed(() =>
  selectedItems.value.reduce((sum, item) => sum + (item.quantity || 0), 0)
)

// Step indicator
const currentStep = computed(() => {
  // Step 1: 确认商品 — 默认
  // Step 2: 填写信息 — 填了联系信息或选了支付方式或选了优惠券
  // Step 3: 提交订单 — 所有选项都用过了
  const hasContactInfo = customerName.value.length > 0 || customerPhone.value.length > 0 || pickupNote.value.length > 0
  const hasPaymentSelection = paymentMethod.value !== 'cash' || useBalanceMixed.value
  const hasCouponSelection = selectedCoupon.value !== null

  if (hasPaymentSelection || hasCouponSelection) return 3
  if (hasContactInfo) return 2
  return 1
})
const steps = [
  { id: 1, label: '确认商品' },
  { id: 2, label: '填写信息' },
  { id: 3, label: '提交订单' }
]

// Contact form
const customerName = ref('')
const customerPhone = ref('')
const pickupNote = ref('')

// Payment method
const paymentMethod = ref<string>('cash')
const paymentMethods = ref([
  { value: 'cash', label: '到店支付', icon: 'i-lucide-store', desc: '取货时在店内付款' },
  { value: 'wechat', label: '微信支付', icon: 'i-lucide-smartphone', desc: '在线微信支付' },
  { value: 'alipay', label: '支付宝', icon: 'i-lucide-smartphone', desc: '在线支付宝支付' },
])

// Member balance info (if logged in)
const memberAuth = useMemberAuth()
const memberBalance = ref(0)
const useBalanceMixed = ref(false)

onMounted(async () => {
  if (memberAuth.token.value) {
    try {
      const profile = await memberAuth.fetchProfile(slug.value)
      memberBalance.value = Number(profile.balance) || 0
    } catch { /* guest checkout — ignore */ }
  }
})

// Remaining amount to pay after balance deduction
const balanceDeduction = computed(() =>
  Math.min(memberBalance.value, paidAmount.value),
)
const remainingAmount = computed(() =>
  Math.max(0, paidAmount.value - balanceDeduction.value),
)
const finalPaymentMethod = computed(() =>
  useBalanceMixed.value && remainingAmount.value > 0
    ? `${paymentMethod.value}_after_balance`
    : paymentMethod.value,
)

// Coupon (mock)
const availableCoupons = ref([
  { id: 1, title: '满100减20', minAmount: 100, discount: 20, code: 'MAN100J20' },
  { id: 2, title: '满200减50', minAmount: 200, discount: 50, code: 'MAN200J50' }
])
const selectedCoupon = ref<number | null>(null)
const discountAmount = computed(() => {
  if (selectedCoupon.value === null) return 0
  const coupon = availableCoupons.value.find(c => c.id === selectedCoupon.value)
  if (!coupon) return 0
  if (totalAmount.value >= coupon.minAmount) return coupon.discount
  return 0
})
const paidAmount = computed(() => Math.max(0, totalAmount.value - discountAmount.value))

// Pre-fill from login token if available — already declared above
const isSubmitting = ref(false)
const errorMessage = ref('')

async function handlePlaceOrder() {
  errorMessage.value = ''

  isSubmitting.value = true
  try {
    const items = cart.value.map((item: any) => ({
      sku: item.skuId ?? item.productId,
      product_name: item.name,
      spec_name: item.specName || '',
      quantity: item.quantity,
      price: Number(item.price || 0),
      subtotal: Number(item.price || 0) * item.quantity
    }))

    // Mixed payment: calculate deducted amount + remaining
    let deductedAmount = 0
    if (useBalanceMixed.value && memberBalance.value > 0) {
      deductedAmount = balanceDeduction.value
    }

    const orderData = {
      total_amount: Number(totalAmount.value.toFixed(2)),
      discount_amount: Number(discountAmount.value.toFixed(2)),
      paid_amount: Number(paidAmount.value.toFixed(2)),
      payment_method: finalPaymentMethod.value,
      member: null,
      customerName: customerName.value || '',
      customerPhone: customerPhone.value || '',
      pickupNote: pickupNote.value || '',
      items
    }

    const token = memberAuth.token.value || undefined
    await placeOrder(slug.value, orderData, token)

    // Deduct balance (full or partial)
    if (deductedAmount > 0 && token) {
      try {
        await $fetch(`/api/shop/${slug.value}/members/deduct-balance/`, {
          method: 'POST',
          headers: { Authorization: `Token ${token}` },
          body: { amount: deductedAmount }
        })
      } catch { /* offline handling */ }
    }

    cart.value = []
    // step will auto-advance via computed
    toast.add({ title: '下单成功！可到店取货', color: 'success', duration: 3000, ui: { container: 'shop-toast' } })
    router.push(`/${slug.value}/orders`)
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || err?.data?.message || '下单失败，请稍后再试'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto pb-32 lg:pb-6">
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
          确认订单
        </h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">
          请核对商品信息并填写联系方式
        </p>
      </div>
    </div>

    <!-- Step indicator -->
    <div class="flex items-center justify-center mb-8">
      <template v-for="(step, idx) in steps" :key="step.id">
        <div class="shop-step-item" :class="currentStep >= step.id ? 'shop-step-active' : 'shop-step-pending'">
          <div
            class="size-7 rounded-full flex items-center justify-center text-xs font-bold"
            :class="currentStep > step.id
              ? 'bg-(--ui-success) text-white'
              : currentStep === step.id
                ? 'bg-(--ui-primary) text-white'
                : 'bg-(--ui-bg-muted) text-(--ui-text-muted)'"
          >
            <UIcon v-if="currentStep > step.id" name="i-lucide-check" class="size-3.5" />
            <span v-else>{{ step.id }}</span>
          </div>
          <span class="text-xs hidden sm:inline">{{ step.label }}</span>
        </div>
        <div
          v-if="idx < steps.length - 1"
          class="shop-step-line"
          :class="currentStep > step.id ? 'shop-step-line-active' : ''"
        />
      </template>
    </div>

    <!-- Error message -->
    <div
      v-if="errorMessage"
      class="p-3 rounded-xl bg-(--ui-error)/10 text-(--ui-error) text-sm mb-4 flex items-center gap-2"
    >
      <UIcon name="i-lucide-alert-circle" class="size-4 shrink-0" />
      {{ errorMessage }}
    </div>

    <!-- Order items summary -->
    <div class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-3">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-package" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">订单商品</h2>
        <span class="text-xs text-(--ui-text-muted) ml-auto">{{ itemCount }} 件</span>
      </div>

      <div class="space-y-0">
        <div
          v-for="(item, idx) in selectedItems"
          :key="item.id"
          class="flex gap-3"
          :class="idx < selectedItems.length - 1 ? 'border-b border-(--ui-border)/30 pb-3 mb-3' : ''"
        >
          <div class="size-16 shrink-0 rounded-xl overflow-hidden bg-(--ui-bg-muted) shadow-sm">
            <img
              v-if="item.image"
              :src="item.image"
              :alt="item.name"
              class="h-full w-full object-cover"
              @error="onImgError($event, item.name)"
            >
            <div v-else class="h-full w-full flex items-center justify-center">
              <span class="text-xl font-black text-(--ui-text-muted)/15">{{ item.name?.charAt(0) }}</span>
            </div>
          </div>
          <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
            <p class="text-sm font-medium text-(--ui-text) line-clamp-2 leading-snug">
              {{ item.name }}
            </p>
            <p v-if="item.specName" class="text-xs text-(--ui-text-muted) mt-0.5">{{ item.specName }}</p>
            <div class="flex justify-between items-baseline mt-1">
              <span class="text-xs text-(--ui-text-muted)">x{{ item.quantity }}</span>
              <span class="text-sm font-bold text-(--ui-text) tabular-nums">
                ¥{{ (item.price * item.quantity).toFixed(2) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Contact info -->
    <div class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-contact" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">联系信息</h2>
        <span class="text-[10px] text-(--ui-text-muted)/50 ml-auto">取货时联系用</span>
      </div>

      <!-- Name + Phone row -->
      <div class="grid grid-cols-2 gap-3 mb-3">
        <div class="relative">
          <div class="absolute left-3 top-1/2 -translate-y-1/2 size-4 flex items-center justify-center">
            <UIcon name="i-lucide-user" class="size-3.5 text-(--ui-text-muted)/40" />
          </div>
          <input
            v-model="customerName"
            placeholder="联系人姓名"
            class="w-full h-11 pl-9 pr-3 rounded-xl border border-(--ui-border) bg-(--ui-bg) text-sm text-(--ui-text) placeholder:text-(--ui-text-muted)/40 outline-none transition focus:border-(--ui-primary) focus:ring-1 focus:ring-(--ui-primary)/20"
            maxlength="20"
          />
        </div>
        <div class="relative">
          <div class="absolute left-3 top-1/2 -translate-y-1/2 size-4 flex items-center justify-center">
            <UIcon name="i-lucide-phone" class="size-3.5 text-(--ui-text-muted)/40" />
          </div>
          <input
            v-model="customerPhone"
            placeholder="手机号"
            class="w-full h-11 pl-9 pr-3 rounded-xl border border-(--ui-border) bg-(--ui-bg) text-sm text-(--ui-text) placeholder:text-(--ui-text-muted)/40 outline-none transition focus:border-(--ui-primary) focus:ring-1 focus:ring-(--ui-primary)/20"
            maxlength="11"
            @input="customerPhone = customerPhone.replace(/\D/g, '')"
          />
        </div>
      </div>

      <!-- Note -->
      <div class="relative">
        <div class="absolute left-3 top-3.5 size-4 flex items-center justify-center">
          <UIcon name="i-lucide-edit" class="size-3.5 text-(--ui-text-muted)/40" />
        </div>
        <textarea
          v-model="pickupNote"
          placeholder="取货备注（选填）· 如：请放门口、加冰袋等"
          class="w-full min-h-[44px] pl-9 pr-3 py-2.5 rounded-xl border border-(--ui-border) bg-(--ui-bg) text-sm text-(--ui-text) placeholder:text-(--ui-text-muted)/40 outline-none transition resize-none focus:border-(--ui-primary) focus:ring-1 focus:ring-(--ui-primary)/20"
          rows="2"
        />
      </div>
    </div>

    <!-- Payment method -->
    <div v-if="memberBalance > 0" class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-3">
        <div class="size-7 rounded-lg bg(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-wallet" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">储值余额抵扣</h2>
      </div>

      <label
        class="flex items-center justify-between cursor-pointer rounded-xl p-3 transition-all duration-150"
        :class="useBalanceMixed ? 'bg-(--ui-primary)/5 border border-(--ui-primary)/20' : 'bg-(--ui-bg-muted)/50'"
      >
        <div>
          <p class="text-sm font-medium text-(--ui-text)">
            使用储值余额
            <span class="font-bold tabular-nums" :class="useBalanceMixed ? 'text-(--ui-primary)' : ''">¥{{ memberBalance.toFixed(2) }}</span>
          </p>
          <p v-if="useBalanceMixed && remainingAmount > 0" class="text-xs text-(--ui-text-muted) mt-0.5">
            余额扣 <span class="font-medium text-(--ui-primary)">¥{{ balanceDeduction.toFixed(2) }}</span>，
            剩 <span class="font-medium">¥{{ remainingAmount.toFixed(2) }}</span> 用下方方式付
          </p>
          <p v-else-if="useBalanceMixed && remainingAmount === 0" class="text-xs text-(--ui-success) mt-0.5 flex items-center gap-1">
            <UIcon name="i-lucide-check-circle" class="size-3.5" />
            余额充足，全额抵扣
          </p>
          <p v-else class="text-xs text-(--ui-text-muted) mt-0.5">开启后先用余额付，不足的选下方方式补齐</p>
        </div>
        <USwitch v-model="useBalanceMixed" color="primary" />
      </label>
    </div>

    <!-- Payment method -->
    <div class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-credit-card" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">支付方式</h2>
        <span v-if="useBalanceMixed && remainingAmount > 0" class="text-xs text-(--ui-text-muted) ml-auto">
          付剩余 <span class="font-medium text-(--ui-primary) tabular-nums">¥{{ remainingAmount.toFixed(2) }}</span>
        </span>
        <span v-else-if="useBalanceMixed && remainingAmount === 0" class="text-xs text-(--ui-success) ml-auto flex items-center gap-1">
          <UIcon name="i-lucide-check" class="size-3" /> 无需额外支付
        </span>
      </div>

      <div class="space-y-2">
        <div
          v-for="pm in paymentMethods"
          :key="pm.value"
          class="shop-payment-card"
          :class="paymentMethod === pm.value ? 'shop-payment-active' : 'shop-payment-inactive'"
          @click="paymentMethod = pm.value"
        >
          <div
            class="size-10 rounded-lg flex items-center justify-center shrink-0"
            :class="paymentMethod === pm.value ? 'bg-(--ui-primary)/10' : 'bg-(--ui-bg-muted)'"
          >
            <UIcon :name="pm.icon" class="size-5" :class="paymentMethod === pm.value ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)'" />
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium" :class="paymentMethod === pm.value ? 'text-(--ui-primary)' : 'text-(--ui-text)'">
              {{ pm.label }}
            </p>
            <p class="text-xs text-(--ui-text-muted)">
              {{ pm.desc }}
            </p>
          </div>
          <div
            class="size-5 rounded-full border-2 flex items-center justify-center shrink-0"
            :class="paymentMethod === pm.value ? 'border-(--ui-primary)' : 'border-(--ui-border)'"
          >
            <div v-if="paymentMethod === pm.value" class="size-2.5 rounded-full bg-(--ui-primary)" />
          </div>
        </div>
      </div>
    </div>

    <!-- Coupon -->
    <div class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-ticket" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">优惠券</h2>
      </div>

      <div v-if="availableCoupons.length > 0" class="space-y-2">
        <div
          v-for="coupon in availableCoupons"
          :key="coupon.id"
          class="cursor-pointer relative overflow-hidden"
          @click="totalAmount >= coupon.minAmount ? selectedCoupon = selectedCoupon === coupon.id ? null : coupon.id : null"
        >
          <div
            class="rounded-xl p-3 transition-all duration-150"
            :class="totalAmount >= coupon.minAmount
              ? selectedCoupon === coupon.id
                ? 'bg-(--ui-primary)/10 ring-1 ring-(--ui-primary)/30'
                : 'bg-(--ui-bg-accented) hover:bg-(--ui-bg-muted)'
              : 'bg-(--ui-bg-muted)/50 opacity-40'"
          >
            <!-- Coupon left stripe -->
            <div
              v-if="selectedCoupon === coupon.id"
              class="absolute left-0 top-0 bottom-0 w-1 bg-(--ui-primary) rounded-l-xl"
            />
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-bold" :class="selectedCoupon === coupon.id ? 'text-(--ui-primary)' : 'text-(--ui-text)'">
                  {{ coupon.title }}
                  <span v-if="selectedCoupon === coupon.id" class="text-xs font-normal ml-1.5 px-1.5 py-0.5 rounded-full bg-(--ui-primary)/20 text-(--ui-primary)">已使用</span>
                </p>
                <p class="text-xs text-(--ui-text-muted) mt-0.5">
                  满 ¥{{ coupon.minAmount }} 可用 · 码: <span class="font-mono">{{ coupon.code }}</span>
                </p>
              </div>
              <div
                class="size-5 rounded-full border-2 flex items-center justify-center shrink-0"
                :class="selectedCoupon === coupon.id ? 'border-(--ui-primary) bg-(--ui-primary)/10' : 'border-(--ui-border)'"
              >
                <div v-if="selectedCoupon === coupon.id" class="size-2.5 rounded-full bg-(--ui-primary)" />
              </div>
            </div>
            <div v-if="totalAmount < coupon.minAmount" class="mt-2 text-xs text-(--ui-text-muted)/60 flex items-center gap-1">
              <UIcon name="i-lucide-alert-circle" class="size-3" />
              还差 ¥{{ (coupon.minAmount - totalAmount).toFixed(2) }} 即可使用
            </div>
          </div>
        </div>
      </div>
      <p v-else class="text-xs text-(--ui-text-muted)">
        暂无可用优惠券
      </p>
    </div>

    <!-- Price summary -->
    <div class="shop-card p-4 mb-4 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-calculator" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">费用明细</h2>
      </div>
      <div class="space-y-2.5 text-sm">
        <div class="flex justify-between text-(--ui-text-muted)">
          <span>商品总额</span>
          <span class="tabular-nums font-medium">¥{{ totalAmount.toFixed(2) }}</span>
        </div>
        <div v-if="discountAmount > 0" class="flex justify-between text-(--ui-success)">
          <span class="flex items-center gap-1">
            <UIcon name="i-lucide-tag" class="size-3.5" />
            优惠券减免
          </span>
          <span class="tabular-nums">-¥{{ discountAmount.toFixed(2) }}</span>
        </div>
        <div v-if="useBalanceMixed && balanceDeduction > 0" class="flex justify-between text-(--ui-primary)">
          <span class="flex items-center gap-1">
            <UIcon name="i-lucide-wallet" class="size-3.5" />
            储值余额抵扣
          </span>
          <span class="tabular-nums">-¥{{ balanceDeduction.toFixed(2) }}</span>
        </div>
        <div v-if="useBalanceMixed && remainingAmount > 0" class="flex justify-between">
          <span>还需支付</span>
          <span class="tabular-nums font-semibold text-(--ui-text)">¥{{ remainingAmount.toFixed(2) }}</span>
        </div>
        <div class="border-t border-(--ui-border)/40 pt-3 flex justify-between font-bold">
          <span class="text-sm">{{ useBalanceMixed && balanceDeduction > 0 ? '应付总额' : '实付金额' }}</span>
          <span class="tabular-nums text-xl tracking-tight text-(--ui-primary)">¥{{ paidAmount.toFixed(2) }}</span>
        </div>
      </div>
    </div>

    <!-- Submit -->
    <div class="shop-sticky-bottom -mx-4 lg:-mx-6">
      <div class="max-w-3xl mx-auto">
        <div class="flex items-center justify-between gap-3">
          <div class="flex-1 min-w-0">
            <p class="text-xs text-(--ui-text-muted) truncate">
              共 {{ itemCount }} 件商品
            </p>
            <p class="text-xl font-bold tabular-nums tracking-tight" :class="useBalanceMixed && remainingAmount > 0 ? 'text-(--ui-text)' : 'text-(--ui-primary)'">
              <template v-if="useBalanceMixed && balanceDeduction > 0">
                <span class="text-sm font-normal text-(--ui-text-muted)">余额 </span>
                <span class="text-(--ui-primary)">-¥{{ balanceDeduction.toFixed(2) }}</span>
                <span v-if="remainingAmount > 0" class="text-sm font-normal text-(--ui-text-muted)"> + </span>
                <span v-if="remainingAmount > 0" class="text-(--ui-primary)">¥{{ remainingAmount.toFixed(2) }}</span>
                <span v-else class="text-sm font-normal text-(--ui-success) ml-1">√ 已抵扣</span>
              </template>
              <template v-else>
                ¥{{ paidAmount.toFixed(2) }}
              </template>
            </p>
          </div>
          <UButton
            size="lg"
            class="h-12 rounded-xl text-sm font-bold px-6 shrink-0"
            :loading="isSubmitting"
            :disabled="selectedItems.length === 0 || isSubmitting"
            @click="handlePlaceOrder"
          >
            <template v-if="isSubmitting">
              <UIcon name="i-lucide-loader-circle" class="size-4 animate-spin" />
              提交中…
            </template>
            <template v-else>
              <UIcon name="i-lucide-check-circle" class="size-4" />
              <template v-if="useBalanceMixed && balanceDeduction > 0 && remainingAmount > 0">
                余额+付款
              </template>
              <template v-else-if="useBalanceMixed && balanceDeduction > 0 && remainingAmount === 0">
                全额余额抵扣
              </template>
              <template v-else>
                提交订单
              </template>
            </template>
          </UButton>
        </div>
      </div>
    </div>
  </div>

  <!-- Submitting overlay -->
  <div
    v-if="isSubmitting"
    class="fixed inset-0 z-[100] bg-black/20 backdrop-blur-sm flex items-center justify-center"
  >
    <div class="bg-white dark:bg-zinc-900 rounded-2xl p-8 shadow-2xl flex flex-col items-center gap-3">
      <UIcon name="i-lucide-loader-circle" class="size-10 animate-spin text-(--ui-primary)" />
      <p class="text-sm font-medium text-(--ui-text)">正在提交订单…</p>
      <p class="text-xs text-(--ui-text-muted)">请勿关闭页面</p>
    </div>
  </div>
</template>
