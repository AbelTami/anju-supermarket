<script setup lang="ts">
/** POS收银台 — product search + immutable cart. Amounts are NOT sent to the
 * backend (server recomputes from SKU prices) — see backend/apps/pos/serializers.py.
 */
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'
import { openReceiptPrint } from '~/composables/useReceiptPrint'

interface CartItem {
  skuId: number
  name: string
  spec: string
  barcode: string
  price: number
  quantity: number
}

interface ProductSku {
  id: number
  spec_name: string
  barcode: string
  selling_price: string | number
}
interface Product {
  id: number
  name: string
  category?: { name: string } | null
  skus?: ProductSku[]
}

const tenantSlug = useCurrentTenantSlug()
const toast = useToast()

const searchQuery = ref('')
const cart = ref<CartItem[]>([])
const settling = ref(false)

// Last settled order for print reminder
const lastOrder = ref<Record<string, any> | null>(null)
const auth = useAuth()

function printReceipt() {
  if (!lastOrder.value) return
  const tenant = auth.currentTenant.value as Record<string, any>
  const ok = openReceiptPrint(lastOrder.value, {
    name: tenant?.name ?? '',
    address: tenant?.address ?? '',
    phone: tenant?.phone ?? '',
    business_hours: tenant?.business_hours ?? '',
    paper_width: tenant?.paper_width ?? '58',
    print_logo: tenant?.print_logo ?? true,
    print_barcode: tenant?.print_barcode ?? true,
    footer_text: tenant?.footer_text ?? '',
  })
  if (!ok) toast.add({ title: '打印窗口被拦截，请允许弹窗后重试', color: 'warning' })
}

function dismissPrint() {
  lastOrder.value = null
}

const productApiUrl = computed(() =>
  searchQuery.value
    ? `/api/tenant/${tenantSlug.value}/products?skus=1&search=${encodeURIComponent(searchQuery.value)}`
    : `/api/tenant/${tenantSlug.value}/products?skus=1&page_size=50`,
)

const orderApiUrl = computed(() => `/api/tenant/${tenantSlug.value}/orders`)

const { data: productData } = useFetch(productApiUrl, {
  lazy: true,
  server: false,
  key: computed(() => `pos-products-${tenantSlug.value}-${searchQuery.value}`),
  debounce: 300,
})

const iconMap: Record<string, string> = {
  饮料: 'i-lucide-coffee',
  食品: 'i-lucide-beef',
  乳制品: 'i-lucide-milk',
  零食: 'i-lucide-cookie',
  酒类: 'i-lucide-beer',
  调味品: 'i-lucide-flask-conical',
  日用品: 'i-lucide-spray-can',
  冷冻: 'i-lucide-snowflake',
  粮油: 'i-lucide-wheat',
  个人护理: 'i-lucide-smile',
  清洁: 'i-lucide-sparkles',
  文具: 'i-lucide-pencil',
}

function getIcon(name: string, category: string): string {
  for (const [key, value] of Object.entries(iconMap)) {
    if (category.includes(key) || name.includes(key)) return value
  }
  return 'i-lucide-package'
}

interface PosProduct {
  id: number
  name: string
  spec: string
  barcode: string
  price: number
  icon: string
}

const products = computed<PosProduct[]>(() => {
  const results = (productData.value as { results?: Product[] } | undefined)?.results ?? []
  return results.flatMap((p: Product): PosProduct[] => {
    const icon = getIcon(p.name, p.category?.name ?? '')
    if ((p.skus?.length ?? 0) > 0) {
      return (p.skus ?? []).map(sku => ({
        id: sku.id,
        name: p.name,
        spec: sku.spec_name,
        barcode: sku.barcode,
        price: Number(sku.selling_price),
        icon,
      }))
    }
    return [{ id: p.id, name: p.name, spec: '', barcode: '', price: 0, icon }]
  })
})

const totalAmount = computed(() =>
  cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
)

function addToCart(product: PosProduct): void {
  dismissPrint() // dismiss print bar when starting new order
  const existing = cart.value.find(c => c.skuId === product.id)
  if (existing) {
    cart.value = cart.value.map(c =>
      c.skuId === product.id ? { ...c, quantity: c.quantity + 1 } : c,
    )
  } else {
    cart.value = [
      ...cart.value,
      {
        skuId: product.id,
        name: product.name,
        spec: product.spec,
        barcode: product.barcode,
        price: product.price,
        quantity: 1,
      },
    ]
  }
  searchQuery.value = ''
}

function incrementQty(skuId: number): void {
  cart.value = cart.value.map(c => (c.skuId === skuId ? { ...c, quantity: c.quantity + 1 } : c))
}

function decrementQty(skuId: number): void {
  cart.value = cart.value
    .map(c => (c.skuId === skuId ? { ...c, quantity: c.quantity - 1 } : c))
    .filter(c => c.quantity > 0)
}

function removeFromCart(skuId: number): void {
  cart.value = cart.value.filter(c => c.skuId !== skuId)
}

function clearCart(): void {
  cart.value = []
}

const paymentLabels: Record<string, string> = {
  cash: '现金',
  wechat: '微信',
  alipay: '支付宝',
  member_card: '会员卡',
}

async function settle(method: string): Promise<void> {
  if (cart.value.length === 0) return
  settling.value = true
  try {
    const body = {
      payment_method: method,
      items: cart.value.map(item => ({
        sku: item.skuId,
        quantity: item.quantity,
      })),
    }
    const order = await $fetch(orderApiUrl.value, { method: 'POST', body }) as Record<string, any>
    toast.add({
      title: `${paymentLabels[method] ?? method}收款 ¥${totalAmount.value.toFixed(2)}`,
      color: 'success',
    })
    lastOrder.value = order
    clearCart()
  } catch {
    toast.add({ title: '结算失败，请重试', color: 'error' })
  } finally {
    settling.value = false
  }
}
</script>

<template>
  <UDashboardPanel>
    <template #header>
      <UDashboardNavbar title="收银/POS" />
    </template>

    <!-- Print reminder bar -->
    <div
      v-if="lastOrder"
      class="mx-4 mt-2 flex items-center justify-between rounded-lg border border-(--ui-primary)/30 bg-(--ui-primary)/5 px-4 py-2.5"
    >
      <div class="flex items-center gap-2.5 min-w-0">
        <UIcon name="i-lucide-receipt-text" class="size-4 shrink-0 text-(--ui-primary)" />
        <span class="text-sm text-(--ui-text-highlighted) truncate">
          订单 <span class="font-mono font-semibold">{{ lastOrder.order_no }}</span> 已完成
        </span>
      </div>
      <div class="flex items-center gap-2 shrink-0">
        <UButton
          size="xs"
          icon="i-lucide-printer"
          @click="printReceipt"
        >
          打印小票
        </UButton>
        <UButton
          size="xs"
          icon="i-lucide-x"
          color="neutral"
          variant="ghost"
          @click="dismissPrint"
        />
      </div>
    </div>

    <div class="flex h-[calc(100dvh-8rem)] gap-4 px-4 pb-4" :class="lastOrder ? 'pt-2' : 'pt-4'">
      <div class="flex-1 flex flex-col gap-4">
        <UInput
          v-model="searchQuery"
          icon="i-lucide-search"
          placeholder="扫码或输入商品名称/条码..."
          size="xl"
          class="w-full"
        />

        <div class="grid grid-cols-4 gap-3 overflow-auto flex-1 content-start">
          <UCard
            v-for="product in products"
            :key="product.id"
            class="cursor-pointer hover:ring-2 hover:ring-primary transition-all"
            @click="addToCart(product)"
          >
            <div class="text-center">
              <UIcon :name="product.icon" class="size-8 text-primary mb-1" />
              <div class="text-sm font-medium truncate">
                {{ product.name }}
              </div>
              <div class="text-xs text-dimmed">
                {{ product.spec }}
              </div>
              <div class="text-sm font-bold text-primary mt-1">
                ¥{{ product.price }}
              </div>
            </div>
          </UCard>
        </div>
      </div>

      <div class="w-96 flex flex-col">
        <UCard class="flex-1 flex flex-col">
          <template #header>
            <div class="flex items-center justify-between">
              <span class="font-semibold">购物车 ({{ cart.length }})</span>
              <UButton
                v-if="cart.length"
                icon="i-lucide-trash"
                size="xs"
                color="neutral"
                variant="ghost"
                @click="clearCart"
              />
            </div>
          </template>

          <div class="flex-1 overflow-auto space-y-2">
            <div v-if="cart.length === 0" class="text-center text-dimmed py-12">
              购物车为空
            </div>
            <div
              v-for="item in cart"
              :key="item.skuId"
              class="flex items-center justify-between p-2 rounded hover:bg-elevated"
            >
              <div class="flex-1 min-w-0">
                <div class="text-sm font-medium truncate">
                  {{ item.name }}
                </div>
                <div class="text-xs text-dimmed">
                  ¥{{ item.price }} × {{ item.quantity }}
                </div>
              </div>
              <div class="flex items-center gap-1">
                <UButton
                  icon="i-lucide-minus"
                  size="2xs"
                  color="neutral"
                  variant="ghost"
                  @click="decrementQty(item.skuId)"
                />
                <UButton
                  icon="i-lucide-plus"
                  size="2xs"
                  color="neutral"
                  variant="ghost"
                  @click="incrementQty(item.skuId)"
                />
              </div>
              <div class="text-sm font-bold ml-2">
                ¥{{ (item.price * item.quantity).toFixed(2) }}
              </div>
              <UButton
                icon="i-lucide-x"
                size="2xs"
                color="neutral"
                variant="ghost"
                class="ml-1"
                @click="removeFromCart(item.skuId)"
              />
            </div>
          </div>

          <template #footer>
            <div class="text-xl font-bold text-center mb-3">
              合计: ¥{{ totalAmount.toFixed(2) }}
            </div>
            <div class="grid grid-cols-4 gap-2">
              <UButton
                color="neutral"
                block
                :loading="settling"
                @click="settle('cash')"
              >
                现金
              </UButton>
              <UButton
                color="primary"
                block
                :loading="settling"
                @click="settle('wechat')"
              >
                微信
              </UButton>
              <UButton block :loading="settling" @click="settle('alipay')">
                支付宝
              </UButton>
              <UButton
                color="secondary"
                block
                :loading="settling"
                @click="settle('member_card')"
              >
                会员
              </UButton>
            </div>
          </template>
        </UCard>
      </div>
    </div>
  </UDashboardPanel>
</template>
