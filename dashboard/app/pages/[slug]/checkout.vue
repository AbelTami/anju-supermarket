<script setup lang="ts">
import { useShopCart } from '~/composables/useShopCart'
import { openReceiptPrint } from '~/composables/useReceiptPrint'
import type { TenantPublicInfo } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { placeOrder } = useShopApi()
const { onImgError } = useImageFallback()
const { items: cart, clear: clearCart } = useShopCart()

// Redirect on empty cart — run after hydration to avoid SSR mismatch.
onMounted(() => {
  if (cart.value.length === 0) {
    router.replace(`/${slug.value}/cart`)
  }
})

const selectedItems = computed(() => cart.value)

const totalAmount = computed(() =>
  selectedItems.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
)

const itemCount = computed(() =>
  selectedItems.value.reduce((sum, item) => sum + item.quantity, 0),
)

const customerName = ref('')
const customerPhone = ref('')
const pickupNote = ref('')

const paymentMethod = ref<string>('cash')
const paymentMethods = [
  { value: 'cash', label: '到店支付', icon: 'i-lucide-store', desc: '取货时在店内付款' },
  { value: 'wechat', label: '微信支付', icon: 'i-lucide-smartphone', desc: '在线微信支付' },
  { value: 'alipay', label: '支付宝', icon: 'i-lucide-smartphone', desc: '在线支付宝支付' },
]

const memberAuth = useMemberAuth()
const memberBalance = ref(0)
const useBalanceMixed = ref(false)

onMounted(async () => {
  if (!memberAuth.token.value) return
  try {
    const profile = await memberAuth.fetchProfile(slug.value)
    memberBalance.value = Number(profile?.balance ?? 0)
  } catch { /* guest checkout */ }
})

interface MemberCoupon {
  id: number
  couponId: number
  title: string
  minAmount: number
  discount: number
  code: string
  discount_type: string
  discount_value: string
  min_amount: string
  coupon_title: string
  category_ids: number[]
  first_order_only: boolean
  used: boolean
}

const availableCoupons = ref<MemberCoupon[]>([])
const isNewMember = ref(false)
const selectedCoupon = ref<number | null>(null)

async function loadCoupons(): Promise<void> {
  const token = memberAuth.token.value
  if (!token) return
  try {
    const resp = await $fetch<{ results: Array<Record<string, unknown>>, is_new_member?: boolean }>(
      `/api/shop/${slug.value}/members/coupons/`,
      { headers: { Authorization: `Token ${token}` } },
    )
    isNewMember.value = !!resp.is_new_member
    availableCoupons.value = (resp.results || []).map(c => ({
      id: Number(c.id),
      couponId: Number(c.coupon_id),
      title: String(c.coupon_title ?? ''),
      minAmount: Number(c.min_amount ?? 0),
      discount: Number(c.discount_value ?? 0),
      code: String(c.code ?? ''),
      discount_type: String(c.discount_type ?? 'fixed'),
      discount_value: String(c.discount_value ?? '0'),
      min_amount: String(c.min_amount ?? '0'),
      coupon_title: String(c.coupon_title ?? ''),
      category_ids: Array.isArray(c.category_ids) ? c.category_ids.map(Number) : [],
      first_order_only: !!c.first_order_only,
      used: !!c.used,
    }))
  } catch { /* keep empty */ }
}

onMounted(() => loadCoupons())

// Cart category set — used to check category-restricted coupons.
const cartCategoryIds = computed(() => {
  const set = new Set<number>()
  for (const item of cart.value) {
    if (item.categoryId) set.add(item.categoryId)
  }
  return set
})

interface CouponEligibility {
  allowed: boolean
  reason: string
}

function couponEligibility(c: MemberCoupon): CouponEligibility {
  if (c.used) return { allowed: false, reason: '已使用' }
  if (c.first_order_only && !isNewMember.value) {
    return { allowed: false, reason: '仅限首单' }
  }
  if (c.category_ids.length > 0) {
    const hasMatch = c.category_ids.some(id => cartCategoryIds.value.has(id))
    if (!hasMatch) return { allowed: false, reason: '购物车无适用商品' }
  }
  if (totalAmount.value < c.minAmount) {
    return { allowed: false, reason: `未满 ¥${c.minAmount}` }
  }
  return { allowed: true, reason: '' }
}

const eligibleCoupons = computed(() =>
  availableCoupons.value.map(c => ({ coupon: c, eligibility: couponEligibility(c) })),
)

const discountAmount = computed(() => {
  if (selectedCoupon.value === null) return 0
  const c = availableCoupons.value.find(x => x.id === selectedCoupon.value)
  if (!c) return 0
  const elig = couponEligibility(c)
  if (!elig.allowed) return 0
  if (c.discount_type === 'percent') {
    // Compute eligible subtotal for the percent basis.
    const basis = c.category_ids.length === 0
      ? totalAmount.value
      : cart.value
          .filter(item => item.categoryId && c.category_ids.includes(item.categoryId))
          .reduce((s, i) => s + i.price * i.quantity, 0)
    return Math.round(basis * Number(c.discount_value)) / 100
  }
  return c.discount
})

const isSubmitting = ref(false)
const errorMessage = ref('')
const orderResult = ref<Record<string, any> | null>(null)

// Tenant info for receipt printing
const { data: tenantInfo } = useFetch<TenantPublicInfo>(
  () => `/api/shop/${slug.value}/info/`,
  { lazy: true, server: false },
)

function printReceipt() {
  if (!orderResult.value) return
  const t = tenantInfo.value as Record<string, any> | null
  const ok = openReceiptPrint(orderResult.value, {
    name: t?.name ?? '',
    address: t?.address ?? '',
    phone: t?.phone ?? '',
    business_hours: t?.business_hours ?? '',
    paper_width: t?.paper_width ?? '58',
    print_logo: false,
    print_barcode: t?.print_barcode ?? true,
    footer_text: t?.footer_text ?? '',
  })
  if (!ok) toast.add({ title: '打印窗口被拦截，请允许弹窗后重试', color: 'warning', duration: 3000 })
}

function resetCheckout() {
  orderResult.value = null
}

async function handlePlaceOrder(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true
  try {
    // Server computes all amounts from SKU prices — we only send sku + quantity.
    const orderData = {
      payment_method: useBalanceMixed.value ? 'member_card' : paymentMethod.value,
      member: null,
      coupon_id: selectedCoupon.value,
      items: cart.value.map(item => ({
        sku: item.skuId ?? item.productId,
        quantity: item.quantity,
      })),
    }

    const token = memberAuth.token.value || undefined
    const result = await placeOrder(slug.value, orderData, token)

    clearCart()
    orderResult.value = result as Record<string, any>
    toast.add({ title: '下单成功！', color: 'success', duration: 3000, ui: { container: 'shop-toast' } })
  } catch (err: unknown) {
    const e = err as { data?: { detail?: string, message?: string } }
    errorMessage.value = e?.data?.detail || e?.data?.message || '下单失败，请稍后再试'
  } finally {
    isSubmitting.value = false
  }
}

const balanceDeduction = computed(() => Math.min(memberBalance.value, totalAmount.value))
const remainingAmount = computed(() => Math.max(0, totalAmount.value - balanceDeduction.value))
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto pb-32 lg:pb-6">
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

    <!-- Success state -->
    <div v-if="orderResult" class="py-8">
      <div class="shop-card p-8 text-center">
        <div class="flex size-16 mx-auto items-center justify-center rounded-2xl bg-(--ui-success)/10">
          <UIcon name="i-lucide-circle-check" class="size-8 text-(--ui-success)" />
        </div>
        <h2 class="mt-4 text-xl font-bold text-(--ui-text-highlighted)">
          下单成功！
        </h2>
        <p class="mt-1 text-sm text-(--ui-text-muted)">
          可到店取货或等待配送
        </p>

        <div class="mt-6 rounded-xl bg-(--ui-bg-elevated)/50 p-4 text-left space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-(--ui-text-muted)">订单号</span>
            <span class="font-mono font-semibold text-(--ui-text-highlighted)">{{ orderResult.order_no }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-(--ui-text-muted)">支付方式</span>
            <span class="font-medium text-(--ui-text)">{{ ({ cash: '现金', wechat: '微信', alipay: '支付宝', member_card: '会员卡' } as Record<string, string>)[orderResult.payment_method] || orderResult.payment_method }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-(--ui-text-muted)">件数</span>
            <span class="font-medium text-(--ui-text)">{{ orderResult.items?.length ?? 0 }} 件</span>
          </div>
          <div class="border-t border-(--ui-border)/40 pt-2 flex justify-between">
            <span class="text-sm font-semibold text-(--ui-text)">实付</span>
            <span class="text-lg font-bold text-(--ui-primary) tabular-nums">¥{{ Number(orderResult.paid_amount).toFixed(2) }}</span>
          </div>
        </div>

        <div class="mt-6 flex gap-3 justify-center">
          <UButton
            variant="outline"
            color="neutral"
            icon="i-lucide-printer"
            @click="printReceipt"
          >
            打印小票
          </UButton>
          <UButton
            icon="i-lucide-list"
            @click="router.push(`/${slug}/orders`)"
          >
            查看订单
          </UButton>
        </div>
      </div>
    </div>

    <!-- Error message -->
    <div
      v-if="errorMessage && !orderResult"
      class="p-3 rounded-xl bg-(--ui-error)/10 text-(--ui-error) text-sm mb-4 flex items-center gap-2"
    >
      <UIcon name="i-lucide-alert-circle" class="size-4 shrink-0" />
      {{ errorMessage }}
    </div>

    <div v-if="!orderResult" class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-3">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-package" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          订单商品
        </h2>
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
            <p v-if="item.specName" class="text-xs text-(--ui-text-muted) mt-0.5">
              {{ item.specName }}
            </p>
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

    <div v-if="!orderResult" class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-contact" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          联系信息
        </h2>
      </div>

      <div class="grid grid-cols-2 gap-3 mb-3">
        <UInput
          v-model="customerName"
          icon="i-lucide-user"
          placeholder="联系人姓名"
          class="h-11"
          maxlength="20"
        />
        <UInput
          v-model="customerPhone"
          icon="i-lucide-phone"
          placeholder="手机号"
          class="h-11"
          maxlength="11"
        />
      </div>

      <UTextarea
        v-model="pickupNote"
        icon="i-lucide-edit"
        placeholder="取货备注（选填）· 如：请放门口、加冰袋等"
        :rows="2"
      />
    </div>

    <div v-if="!orderResult && memberBalance > 0" class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-3">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-wallet" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          储值余额抵扣
        </h2>
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
            剩 <span class="font-medium">¥{{ remainingAmount.toFixed(2) }}</span>
          </p>
          <p v-else-if="useBalanceMixed && remainingAmount === 0" class="text-xs text-(--ui-success) mt-0.5 flex items-center gap-1">
            <UIcon name="i-lucide-check-circle" class="size-3.5" />
            余额充足，全额抵扣
          </p>
          <p v-else class="text-xs text-(--ui-text-muted) mt-0.5">开启后用余额支付</p>
        </div>
        <USwitch v-model="useBalanceMixed" />
      </label>
    </div>

    <div v-if="!orderResult && !(useBalanceMixed && remainingAmount === 0)" class="shop-card p-4 mb-5 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-credit-card" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          支付方式
        </h2>
      </div>

      <div class="space-y-2">
        <button
          v-for="pm in paymentMethods"
          :key="pm.value"
          type="button"
          class="shop-payment-card w-full"
          :class="paymentMethod === pm.value ? 'shop-payment-active' : 'shop-payment-inactive'"
          @click="paymentMethod = pm.value"
        >
          <div
            class="size-10 rounded-lg flex items-center justify-center shrink-0"
            :class="paymentMethod === pm.value ? 'bg-(--ui-primary)/10' : 'bg-(--ui-bg-muted)'"
          >
            <UIcon :name="pm.icon" class="size-5" :class="paymentMethod === pm.value ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)'" />
          </div>
          <div class="flex-1 text-left">
            <p class="text-sm font-medium" :class="paymentMethod === pm.value ? 'text-(--ui-primary)' : 'text-(--ui-text)'">
              {{ pm.label }}
            </p>
            <p class="text-xs text-(--ui-text-muted)">
              {{ pm.desc }}
            </p>
          </div>
        </button>
      </div>
    </div>

    <div v-if="!orderResult" class="shop-card p-4 mb-4 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-ticket" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          优惠券
        </h2>
      </div>

      <div v-if="eligibleCoupons.length > 0" class="space-y-2">
        <button
          v-for="{ coupon, eligibility } in eligibleCoupons"
          :key="coupon.id"
          type="button"
          class="block w-full text-left cursor-pointer relative overflow-hidden rounded-xl"
          :disabled="!eligibility.allowed"
          @click="eligibility.allowed && (selectedCoupon = selectedCoupon === coupon.id ? null : coupon.id)"
        >
          <div
            class="rounded-xl p-3 transition-all duration-150"
            :class="eligibility.allowed
              ? selectedCoupon === coupon.id
                ? 'bg-(--ui-primary)/10 ring-1 ring-(--ui-primary)/30'
                : 'bg-(--ui-bg-accented) hover:bg-(--ui-bg-muted)'
              : 'bg-(--ui-bg-muted)/50 opacity-60 cursor-not-allowed'"
          >
            <div
              v-if="selectedCoupon === coupon.id"
              class="absolute left-0 top-0 bottom-0 w-1 bg-(--ui-primary) rounded-l-xl"
            />
            <div class="flex items-center justify-between">
              <div class="min-w-0">
                <p class="text-sm font-bold flex items-center gap-1.5" :class="selectedCoupon === coupon.id ? 'text-(--ui-primary)' : 'text-(--ui-text)'">
                  {{ coupon.title }}
                  <span v-if="coupon.first_order_only" class="text-[10px] font-normal px-1.5 py-0.5 rounded-full bg-amber-500/15 text-amber-600">新人</span>
                  <span v-if="coupon.category_ids.length > 0" class="text-[10px] font-normal px-1.5 py-0.5 rounded-full bg-blue-500/15 text-blue-600">限品类</span>
                  <span v-if="selectedCoupon === coupon.id" class="text-xs font-normal ml-1 px-1.5 py-0.5 rounded-full bg-(--ui-primary)/20 text-(--ui-primary)">已使用</span>
                </p>
                <p class="text-xs mt-0.5" :class="eligibility.allowed ? 'text-(--ui-text-muted)' : 'text-(--ui-error)'">
                  满 ¥{{ coupon.minAmount }} 可用 · 码: <span class="font-mono">{{ coupon.code }}</span>
                  <span v-if="!eligibility.allowed"> · {{ eligibility.reason }}</span>
                </p>
              </div>
              <div
                class="size-5 rounded-full border-2 flex items-center justify-center shrink-0"
                :class="selectedCoupon === coupon.id ? 'border-(--ui-primary) bg-(--ui-primary)/10' : 'border-(--ui-border)'"
              >
                <div v-if="selectedCoupon === coupon.id" class="size-2.5 rounded-full bg-(--ui-primary)" />
              </div>
            </div>
          </div>
        </button>
      </div>
      <p v-else class="text-xs text-(--ui-text-muted)">
        暂无可用优惠券
      </p>
    </div>

    <div v-if="!orderResult" class="shop-card p-4 mb-4 overflow-hidden">
      <div class="flex items-center gap-2 mb-4">
        <div class="size-7 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
          <UIcon name="i-lucide-calculator" class="size-3.5 text-(--ui-primary)" />
        </div>
        <h2 class="font-semibold text-sm text-(--ui-text)">
          费用明细
        </h2>
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
        <div class="border-t border-(--ui-border)/40 pt-3 flex justify-between font-bold">
          <span class="text-sm">实付金额</span>
          <span class="tabular-nums text-xl tracking-tight text-(--ui-primary)">
            ¥{{ Math.max(0, totalAmount - discountAmount).toFixed(2) }}
          </span>
        </div>
      </div>
    </div>

    <div v-if="!orderResult" class="shop-sticky-bottom -mx-4 lg:-mx-6">
      <div class="max-w-3xl mx-auto">
        <div class="flex items-center justify-between gap-3">
          <div class="flex-1 min-w-0">
            <p class="text-xs text-(--ui-text-muted) truncate">
              共 {{ itemCount }} 件商品
            </p>
            <p class="text-xl font-bold tabular-nums tracking-tight text-(--ui-primary)">
              ¥{{ Math.max(0, totalAmount - discountAmount).toFixed(2) }}
            </p>
          </div>
          <UButton
            size="lg"
            class="h-12 rounded-xl text-sm font-bold px-6 shrink-0"
            :loading="isSubmitting"
            :disabled="selectedItems.length === 0 || isSubmitting"
            @click="handlePlaceOrder"
          >
            <UIcon name="i-lucide-check-circle" class="size-4" />
            提交订单
          </UButton>
        </div>
      </div>
    </div>
  </div>

  <div
    v-if="isSubmitting"
    class="fixed inset-0 z-[100] bg-black/20 backdrop-blur-sm flex items-center justify-center"
  >
    <div class="bg-white dark:bg-zinc-900 rounded-2xl p-8 shadow-2xl flex flex-col items-center gap-3">
      <UIcon name="i-lucide-loader-circle" class="size-10 animate-spin text-(--ui-primary)" />
      <p class="text-sm font-medium text-(--ui-text)">
        正在提交订单…
      </p>
      <p class="text-xs text-(--ui-text-muted)">
        请勿关闭页面
      </p>
    </div>
  </div>
</template>
