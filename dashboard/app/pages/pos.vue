<script setup lang="ts">
/** POS收银台 — real product search + order creation via BFF proxy */
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()

interface CartItem {
  skuId: number
  name: string
  spec: string
  barcode: string
  price: number
  quantity: number
}

const searchQuery = ref('')
const cart = ref<CartItem[]>([])
const settling = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const productApiUrl = computed(() =>
  searchQuery.value
    ? `/api/tenant/${tenantSlug.value}/products?skus=1&search=${encodeURIComponent(searchQuery.value)}`
    : `/api/tenant/${tenantSlug.value}/products?skus=1&page_size=50`
)
const orderApiUrl = computed(() => `/api/tenant/${tenantSlug.value}/orders`)

// Search products via real API
const { data: productData } = useFetch(productApiUrl, {
  lazy: true,
  server: false,
  watch: [productApiUrl],
  debounce: 300,
})

// Category → icon mapping
const iconMap: Record<string, string> = {
  '饮料': 'i-lucide-coffee', '食品': 'i-lucide-beef', '乳制品': 'i-lucide-milk',
  '零食': 'i-lucide-cookie', '酒类': 'i-lucide-beer', '调味品': 'i-lucide-salt',
  '日用品': 'i-lucide-spray-can', '冷冻': 'i-lucide-snowflake', '粮油': 'i-lucide-wheat',
  '个人护理': 'i-lucide-smile', '清洁': 'i-lucide-sparkles', '文具': 'i-lucide-pencil',
}
function getIcon(name: string, category: string): string {
  for (const [k, v] of Object.entries(iconMap)) { if (category?.includes(k) || name.includes(k)) return v }
  return 'i-lucide-package'
}

const products = computed(() => {
  const results = (productData.value as any)?.results || []
  return results.flatMap((p: any) => {
    const icon = getIcon(p.name, p.category?.name || '')
    return (p.skus || []).length > 0
      ? p.skus.map((sku: any) => ({ id: sku.id, name: p.name, spec: sku.spec_name, barcode: sku.barcode, price: Number(sku.selling_price), icon }))
      : [{ id: p.id, name: p.name, spec: '', barcode: '', price: 0, icon }]
  })
})

const totalAmount = computed(() =>
  cart.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
)

function addToCart(product: any) {
  const existing = cart.value.find(c => c.skuId === product.id)
  if (existing) {
    existing.quantity++
  } else {
    cart.value.push({ skuId: product.id, name: product.name, spec: product.spec, barcode: product.barcode, price: product.price, quantity: 1 })
  }
  searchQuery.value = ''
}

function removeFromCart(index: number) {
  cart.value.splice(index, 1)
}

function clearCart() {
  cart.value = []
}

async function settle(method: string) {
  if (cart.value.length === 0) return
  settling.value = true
  try {
    const body = {
      total_amount: totalAmount.value.toFixed(2),
      discount_amount: '0.00',
      paid_amount: totalAmount.value.toFixed(2),
      payment_method: method,
      items: cart.value.map(item => ({
        sku: item.skuId,
        product_name: item.name,
        spec_name: item.spec,
        quantity: item.quantity,
        price: item.price.toFixed(2),
        subtotal: (item.price * item.quantity).toFixed(2),
      })),
    }
    await useFetch(orderApiUrl.value, { method: 'POST', body })
    toast.add({ title: `${method === 'cash' ? '现金' : method === 'wechat' ? '微信' : method === 'alipay' ? '支付宝' : '会员卡'}收款 ¥${totalAmount.value.toFixed(2)}`, color: 'success' })
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

      <div class="flex h-[calc(100dvh-8rem)] gap-4 p-4">
        <!-- Left: Product search + grid -->
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
                <div class="text-sm font-medium truncate">{{ product.name }}</div>
                <div class="text-xs text-dimmed">{{ product.spec }}</div>
                <div class="text-sm font-bold text-primary mt-1">¥{{ product.price }}</div>
              </div>
            </UCard>
          </div>
        </div>

        <!-- Right: Cart + settlement -->
        <div class="w-96 flex flex-col">
          <UCard class="flex-1 flex flex-col">
            <template #header>
              <div class="flex items-center justify-between">
                <span class="font-semibold">购物车 ({{ cart.length }})</span>
                <UButton v-if="cart.length" icon="i-lucide-trash" size="xs" color="neutral" variant="ghost" @click="clearCart" />
              </div>
            </template>

            <div class="flex-1 overflow-auto space-y-2">
              <div v-if="cart.length === 0" class="text-center text-dimmed py-12">购物车为空</div>
              <div v-for="(item, i) in cart" :key="i" class="flex items-center justify-between p-2 rounded hover:bg-elevated">
                <div class="flex-1 min-w-0">
                  <div class="text-sm font-medium truncate">{{ item.name }}</div>
                  <div class="text-xs text-dimmed">¥{{ item.price }} × {{ item.quantity }}</div>
                </div>
                <div class="text-sm font-bold ml-2">¥{{ (item.price * item.quantity).toFixed(2) }}</div>
                <UButton icon="i-lucide-x" size="2xs" color="neutral" variant="ghost" class="ml-1" @click="removeFromCart(i)" />
              </div>
            </div>

            <template #footer>
              <div class="text-xl font-bold text-center mb-3">合计: ¥{{ totalAmount.toFixed(2) }}</div>
              <div class="grid grid-cols-4 gap-2">
                <UButton color="neutral" block :loading="settling" @click="settle('cash')">现金</UButton>
                <UButton color="primary" block :loading="settling" @click="settle('wechat')">微信</UButton>
                <UButton block :loading="settling" @click="settle('alipay')">支付宝</UButton>
                <UButton color="secondary" block :loading="settling" @click="settle('member_card')">会员</UButton>
              </div>
            </template>
          </UCard>
        </div>
      </div>
    </UDashboardPanel>
  
</template>
