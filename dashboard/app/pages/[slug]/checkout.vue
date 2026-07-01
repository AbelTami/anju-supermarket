<script setup lang="ts">
definePageMeta({ layout: 'shop' })

import { mediaUrl } from '~/composables/useShopApi'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { placeOrder } = useShopApi()

const cart = useState<any[]>('shop-cart', () => [])

// Redirect to cart if empty
if (cart.value.length === 0 && import.meta.client) {
  router.replace(`/${slug.value}/cart`)
}

const cartItems = computed(() => cart.value)

const totalAmount = computed(() =>
  cartItems.value.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 0), 0),
)

const itemCount = computed(() =>
  cartItems.value.reduce((sum, item) => sum + (item.quantity || 0), 0),
)

// Contact form
const customerName = ref('')
const customerPhone = ref('')
const pickupNote = ref('')

// Pre-fill from login token if available
const memberToken = useCookie('member-token')
onMounted(() => {
  if (memberToken.value) {
    // Token is available — member info will be sent with the order
  }
})

const isSubmitting = ref(false)
const errorMessage = ref('')

async function handlePlaceOrder() {
  errorMessage.value = ''

  isSubmitting.value = true
  try {
    const items = cart.value.map(item => ({
      sku: item.skuId ?? item.productId,
      product_name: item.name,
      spec_name: item.specName || '',
      quantity: item.quantity,
      price: Number(item.price || 0),
      subtotal: Number(item.price || 0) * item.quantity,
    }))

    const orderData = {
      total_amount: Number(totalAmount.value.toFixed(2)),
      discount_amount: 0,
      paid_amount: Number(totalAmount.value.toFixed(2)),
      payment_method: 'cash',
      member: null,
      customerName: customerName.value || '',
      customerPhone: customerPhone.value || '',
      pickupNote: pickupNote.value || '',
      items,
    }

    const token = memberToken.value || undefined
    await placeOrder(slug.value, orderData as any, token)

    cart.value = []
    toast.add({ title: '下单成功！可到店取货', color: 'success', duration: 3000 })
    router.push(`/${slug.value}/orders`)
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || err?.data?.message || '下单失败，请稍后再试'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto">
    <div class="flex items-center gap-3 mb-6">
      <UButton
        icon="i-lucide-arrow-left"
        variant="ghost"
        color="neutral"
        square
        @click="router.back()"
      />
      <h1 class="text-2xl font-bold text-(--ui-text)">确认订单</h1>
    </div>

    <!-- Error message -->
    <div
      v-if="errorMessage"
      class="p-3 rounded-lg bg-(--ui-error)/10 text-(--ui-error) text-sm mb-4"
    >
      {{ errorMessage }}
    </div>

    <!-- Order items summary -->
    <UCard class="mb-4">
      <template #header>
        <h2 class="font-semibold text-(--ui-text)">订单商品</h2>
      </template>

      <div class="space-y-3">
        <div
          v-for="item in cartItems"
          :key="item.id"
          class="flex gap-3"
        >
          <div class="size-14 shrink-0 rounded-lg overflow-hidden bg-(--ui-bg-muted)">
            <img
              v-if="item.image"
              :src="item.image"
              :alt="item.name"
              class="h-full w-full object-cover"
            />
            <UIcon
              v-else
              name="i-lucide-package"
              class="size-6 m-auto mt-4 text-(--ui-text-muted)"
            />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-(--ui-text) line-clamp-1">{{ item.name }}</p>
            <p v-if="item.specName" class="text-xs text-(--ui-text-muted)">{{ item.specName }}</p>
            <div class="flex justify-between items-baseline mt-1">
              <span class="text-xs text-(--ui-text-muted)">x{{ item.quantity }}</span>
              <span class="text-sm font-medium text-(--ui-text) tabular-nums">
                ¥{{ (item.price * item.quantity).toFixed(2) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </UCard>

    <!-- Contact info -->
    <UCard class="mb-4">
      <template #header>
        <h2 class="font-semibold text-(--ui-text)">联系信息</h2>
      </template>

      <div class="space-y-4">
        <UFormField label="联系人">
          <UInput
            v-model="customerName"
            icon="i-lucide-user"
            placeholder="请输入姓名（选填）"
          />
        </UFormField>

        <UFormField label="联系电话">
          <UInput
            v-model="customerPhone"
            icon="i-lucide-phone"
            placeholder="请输入手机号（选填）"
          />
        </UFormField>

        <UFormField label="取货备注">
          <UTextarea
            v-model="pickupNote"
            placeholder="如有特殊要求请在此备注..."
            :rows="3"
          />
        </UFormField>
      </div>
    </UCard>

    <!-- Payment info -->
    <UCard class="mb-4">
      <template #header>
        <h2 class="font-semibold text-(--ui-text)">支付方式</h2>
      </template>

      <div class="flex items-center gap-3 p-3 rounded-lg bg-(--ui-bg-muted)">
        <UIcon name="i-lucide-store" class="size-5 text-(--ui-text-muted)" />
        <div>
          <p class="text-sm font-medium text-(--ui-text)">到店支付</p>
          <p class="text-xs text-(--ui-text-muted)">取货时在店内付款</p>
        </div>
      </div>
    </UCard>

    <!-- Total and submit -->
    <div class="bg-(--ui-bg-muted) rounded-xl p-4 space-y-2">
      <div class="flex justify-between text-sm">
        <span class="text-(--ui-text-muted)">共 {{ itemCount }} 件商品</span>
        <span class="text-(--ui-text-muted)">小计: ¥{{ totalAmount.toFixed(2) }}</span>
      </div>
      <div class="flex justify-between items-baseline">
        <span class="text-sm text-(--ui-text-muted)">合计</span>
        <span class="text-xl font-bold text-(--ui-primary) tabular-nums">
          ¥{{ totalAmount.toFixed(2) }}
        </span>
      </div>
    </div>

    <UButton
      block
      size="lg"
      class="mt-4"
      :loading="isSubmitting"
      :disabled="cartItems.length === 0"
      @click="handlePlaceOrder"
    >
      提交订单
    </UButton>
  </div>
</template>
