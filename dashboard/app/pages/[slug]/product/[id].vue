<script setup lang="ts">
definePageMeta({ layout: 'shop' })

import { mediaUrl } from '~/composables/useShopApi'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const productId = computed(() => route.params.id as string)
const { fetchProduct, fetchProducts } = useShopApi()

// Shared cart state
const cart = useState<any[]>('shop-cart', () => [])

// Product data
const { data: productData, status } = useAsyncData(
  () => `shop-product-${slug.value}-${productId.value}`,
  () => fetchProduct(slug.value, productId.value),
)

const product = computed<any>(() => {
  const data = productData.value as any
  if (!data) return null
  return data
})

const isLoading = computed(() => status.value === 'pending')

// Selected SKU/variant
const selectedSku = ref<any>(null)

// Auto-select first SKU when product loads
watchEffect(() => {
  if (product.value?.skus?.length && !selectedSku.value) {
    selectedSku.value = product.value.skus.find((s: any) => s.stock_quantity > 0 || s.stock_quantity === undefined) || product.value.skus[0]
  }
})

// Quantity
const quantity = ref(1)

// Add to cart state
const addingToCart = ref(false)
const addedToCart = ref(false)

function addToCart() {
  if (!product.value) return

  const item = {
    id: crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    productId: product.value.id,
    skuId: selectedSku.value?.id ?? null,
    name: product.value.name,
    specName: selectedSku.value?.spec_name ?? '',
    image: mediaUrl(productImage(product.value)),
    price: Number(selectedSku.value?.selling_price || 0),
    quantity: quantity.value,
  }

  addingToCart.value = true
  // Brief loading animation
  setTimeout(() => {
    const existing = cart.value.find(
      (i: any) => i.productId === item.productId && i.skuId === item.skuId,
    )
    if (existing) {
      existing.quantity += item.quantity
    } else {
      cart.value.push(item)
    }
    addingToCart.value = false
    addedToCart.value = true
    toast.add({ title: '已加入购物车', color: 'success', duration: 2000 })
    setTimeout(() => { addedToCart.value = false }, 1500)
  }, 400)
}

function incrementQty() {
  if (quantity.value < 99) quantity.value++
}

function decrementQty() {
  if (quantity.value > 1) quantity.value--
}

// Image helpers
function productImage(p: any): string | null {
  return p?.image_url || mediaUrl(p?.image) || null
}

function productImages(p: any): string[] {
  const imgs: string[] = []
  if (p?.image_url) imgs.push(p.image_url)
  if (p?.image) imgs.push(mediaUrl(p.image)!)
  return [...new Set(imgs.filter(Boolean))]
}

const activeImageIndex = ref(0)
const allImages = computed(() => product.value ? productImages(product.value) : [])

function selectImage(index: number) {
  activeImageIndex.value = index
}

// Price helpers
function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function currentPrice(): string {
  if (selectedSku.value?.selling_price) return selectedSku.value.selling_price
  if (product.value?.price) return product.value.price
  return '0'
}

function currentOriginalPrice(): string | null {
  // Django does not return original_price; only selling_price is available.
  return null
}

function discountPercent(): number {
  return 0
}

function productUnit(): string {
  return product.value?.unit || ''
}

// Related products — fetch client-side
const relatedProducts = ref<any[]>([])
onMounted(async () => {
  if (!product.value) return
  try {
    // category is a nested object in ProductDetailSerializer, extract its id
    const categoryId = product.value.category?.id
    if (categoryId) {
      const data = await fetchProducts(slug.value, { category: categoryId, page_size: 6 })
      const all = Array.isArray(data) ? data : (data as any)?.results || []
      relatedProducts.value = all.filter((p: any) => p.id !== product.value.id).slice(0, 5)
    }
  } catch { /* ignore */ }
})

// Watch for product changes to reset state
watch(() => productId.value, () => {
  selectedSku.value = null
  quantity.value = 1
  activeImageIndex.value = 0
  relatedProducts.value = []
})</script>

<template>
  <div>
    <!-- Loading skeleton -->
    <div v-if="isLoading" class="py-8 px-4 lg:px-6">
      <div class="flex flex-col lg:flex-row gap-8 max-w-6xl mx-auto animate-pulse">
        <div class="w-full lg:w-1/2 aspect-square bg-(--ui-bg-muted) rounded-2xl" />
        <div class="w-full lg:w-1/2 space-y-4">
          <div class="h-8 bg-(--ui-bg-muted) rounded w-3/4" />
          <div class="h-6 bg-(--ui-bg-muted) rounded w-1/4" />
          <div class="h-4 bg-(--ui-bg-muted) rounded w-full" />
          <div class="h-4 bg-(--ui-bg-muted) rounded w-2/3" />
          <div class="h-12 bg-(--ui-bg-muted) rounded w-1/3 mt-4" />
        </div>
      </div>
    </div>

    <!-- Product not found -->
    <div
      v-else-if="!product"
      class="flex flex-col items-center justify-center py-20 px-4"
    >
      <UIcon name="i-lucide-package-x" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-1">商品不存在</p>
      <p class="text-sm text-(--ui-text-muted) mb-4">该商品可能已下架或不存在</p>
      <UButton
        :to="`/${slug}`"
        variant="outline"
        color="neutral"
        label="返回首页"
      />
    </div>

    <!-- Product detail -->
    <div v-else class="max-w-6xl mx-auto py-8 px-4 lg:px-6">
      <!-- Back button -->
      <div class="mb-6">
        <UButton
          icon="i-lucide-arrow-left"
          variant="ghost"
          color="neutral"
          size="sm"
          label="返回"
          @click="router.back()"
        />
      </div>

      <div class="flex flex-col lg:flex-row gap-8 lg:gap-12">
        <!-- Image gallery -->
        <div class="w-full lg:w-1/2">
          <!-- Main image -->
          <div class="overflow-hidden rounded-2xl bg-(--ui-bg-muted) aspect-square relative">
            <img
              v-if="allImages.length > 0"
              :src="allImages[activeImageIndex] || ''"
              :alt="product.name"
              class="h-full w-full object-cover"
            />
            <span
              v-else
              class="absolute inset-0 flex items-center justify-center text-6xl font-bold text-(--ui-text-muted)/20 select-none bg-(--ui-bg-accented)"
            >{{ product.name?.charAt(0) }}</span>
          </div>

          <!-- Thumbnails -->
          <div
            v-if="allImages.length > 1"
            class="flex gap-2 mt-3 overflow-x-auto no-scrollbar"
          >
            <button
              v-for="(img, idx) in allImages"
              :key="idx"
              class="size-16 lg:size-20 shrink-0 rounded-lg overflow-hidden border-2 transition"
              :class="idx === activeImageIndex ? 'border-(--ui-primary)' : 'border-transparent hover:border-(--ui-border)'"
              @click="selectImage(idx)"
            >
              <img :src="img" :alt="`${product.name} ${idx + 1}`" class="h-full w-full object-cover" />
            </button>
          </div>
        </div>

        <!-- Product info -->
        <div class="w-full lg:w-1/2 flex flex-col gap-5">
          <!-- Name -->
          <div>
            <h1 class="text-2xl font-bold text-(--ui-text)">{{ product.name }}</h1>
            <p v-if="productUnit()" class="text-sm text-(--ui-text-muted) mt-1">
              {{ productUnit() }}
            </p>
          </div>

          <!-- Price -->
          <div class="border-b border-(--ui-border) pb-5">
            <div class="flex items-baseline gap-2">
              <span class="text-2xl font-bold text-(--ui-primary)">
                {{ formatPrice(currentPrice()) }}
              </span>
              <span
                v-if="currentOriginalPrice()"
                class="text-sm text-(--ui-text-muted) line-through"
              >
                {{ formatPrice(currentOriginalPrice()!) }}
              </span>
              <UBadge
                v-if="discountPercent() > 0"
                color="error"
                variant="soft"
                size="sm"
              >
                -{{ discountPercent() }}%
              </UBadge>
            </div>
          </div>

          <!-- SKU / Variant selector -->
          <div v-if="product.skus?.length" class="border-b border-(--ui-border) pb-5">
            <p class="text-sm font-medium text-(--ui-text) mb-3">规格选择</p>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="sku in product.skus"
                :key="sku.id"
                class="px-4 py-2 rounded-lg border-2 text-sm font-medium transition-all cursor-pointer"
                :class="selectedSku?.id === sku.id
                  ? 'border-(--ui-primary) bg-(--ui-primary)/10 text-(--ui-primary)'
                  : sku.stock_quantity === 0
                    ? 'border-(--ui-border) text-(--ui-text-muted) opacity-50 cursor-not-allowed'
                    : 'border-(--ui-border) hover:border-(--ui-border-hover) text-(--ui-text)'"
                :disabled="sku.stock_quantity === 0"
                @click="sku.stock_quantity !== 0 && (selectedSku = sku)"
              >
                {{ sku.spec_name }}
                <span
                  v-if="sku.selling_price"
                  class="ml-1"
                >
                  {{ formatPrice(sku.selling_price) }}
                </span>
              </button>
            </div>
            <!-- Selected SKU stock info -->
            <p
              v-if="selectedSku?.stock_quantity !== undefined && selectedSku?.stock_quantity >= 0"
              class="text-xs mt-2"
              :class="selectedSku?.stock_quantity > 0 ? 'text-(--ui-text-muted)' : 'text-(--ui-error)'"
            >
              {{ selectedSku.stock_quantity > 0 ? `库存: ${selectedSku.stock_quantity}` : '已售罄' }}
            </p>
          </div>

          <!-- Quantity selector -->
          <div class="flex items-center gap-4">
            <span class="text-sm font-medium text-(--ui-text)">数量</span>
            <div class="flex items-center border border-(--ui-border) rounded-lg">
              <UButton
                icon="i-lucide-minus"
                variant="ghost"
                color="neutral"
                square
                size="sm"
                :disabled="quantity <= 1"
                @click="decrementQty"
              />
              <span class="w-12 text-center text-sm font-medium tabular-nums">{{ quantity }}</span>
              <UButton
                icon="i-lucide-plus"
                variant="ghost"
                color="neutral"
                square
                size="sm"
                :disabled="quantity >= 99"
                @click="incrementQty"
              />
            </div>
          </div>

          <!-- Add to cart -->
          <UButton
            size="lg"
            class="w-full justify-center"
            :disabled="addingToCart || (selectedSku?.stock_quantity === 0)"
            :loading="addingToCart"
            @click="addToCart"
          >
            <template v-if="addedToCart">
              <UIcon name="i-lucide-check" class="size-5" />
              <span class="ml-2">已加入购物车</span>
            </template>
            <template v-else>
              <UIcon name="i-lucide-shopping-cart" class="size-5" />
              <span class="ml-2">加入购物车</span>
            </template>
          </UButton>

          <!-- Description -->
          <div v-if="product.description" class="border-t border-(--ui-border) pt-5">
            <p class="text-sm font-medium text-(--ui-text) mb-2">商品详情</p>
            <div
              class="prose prose-sm text-(--ui-text-muted) max-w-none"
              v-html="product.description"
            />
          </div>
        </div>
      </div>

      <!-- Related products -->
      <div v-if="relatedProducts.length > 0" class="mt-16">
        <div class="border-t border-(--ui-border) pt-8">
          <h2 class="text-lg font-bold text-(--ui-text) mb-6">相关商品</h2>
          <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
            <NuxtLink
              v-for="rel in relatedProducts"
              :key="rel.id"
              :to="`/${slug}/product/${rel.id}`"
              class="group block"
            >
              <div class="overflow-hidden rounded-xl bg-(--ui-bg-muted) aspect-square relative">
                <img
                  v-if="rel.image"
                  :src="mediaUrl(rel.image)!"
                  :alt="rel.name"
                  class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  loading="lazy"
                />
                <UIcon
                  v-else
                  name="i-lucide-package"
                  class="absolute inset-0 m-auto size-10 text-(--ui-text-muted)"
                />
              </div>
              <div class="mt-3 space-y-1">
                <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug">
                  {{ rel.name }}
                </p>
              </div>
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
