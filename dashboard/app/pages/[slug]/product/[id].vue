<script setup lang="ts">
import { mediaUrl } from '~/composables/useShopApi'
import { useShopCart } from '~/composables/useShopCart'
import { formatPrice, renderStars } from '~/utils/format'
import type { ProductInfo, ProductSkuInfo, PaginatedResponse } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const productId = computed(() => route.params.id as string)
const { fetchProduct, fetchProducts } = useShopApi()
const { onImgError } = useImageFallback()
const { isFavorited, toggle: toggleFavorite } = useFavorite()
const { add: addToCartShared } = useShopCart()

const { data: productData, status } = useAsyncData(
  () => `shop-product-${slug.value}-${productId.value}`,
  () => fetchProduct(slug.value, productId.value),
)

const product = computed<ProductInfo | null>(() => productData.value ?? null)
const isLoading = computed(() => status.value === 'pending')

const selectedSku = ref<ProductSkuInfo | null>(null)

watchEffect(() => {
  if (product.value?.skus?.length && !selectedSku.value) {
    selectedSku.value = product.value.skus.find(s => Number(s.stock_quantity) > 0) || product.value.skus[0]
  }
})

const quantity = ref(1)
const addingToCart = ref(false)
const addedToCart = ref(false)

function addToCart(): void {
  if (!product.value) return
  const item: Parameters<typeof addToCartShared>[0] = {
    ...product.value,
    // override price with the chosen SKU's price
    price: String(selectedSku.value?.selling_price ?? product.value.price ?? '0'),
  }
  addToCartShared(item, selectedSku.value?.spec_name ?? '')
  addingToCart.value = true
  setTimeout(() => {
    addingToCart.value = false
    addedToCart.value = true
    toast.add({ title: '已加入购物车', color: 'success', duration: 2000, ui: { container: 'shop-toast' } })
    setTimeout(() => { addedToCart.value = false }, 1500)
  }, 200)
}

function incrementQty(): void {
  if (quantity.value < 99) quantity.value += 1
}
function decrementQty(): void {
  if (quantity.value > 1) quantity.value -= 1
}

function toggleFav(p: ProductInfo): void {
  toggleFavorite(p.id)
  const nowFav = isFavorited(p.id)
  toast.add({
    title: nowFav ? '已收藏' : '已取消收藏',
    color: nowFav ? 'success' : 'neutral',
    duration: 1200,
    ui: { container: 'shop-toast' },
  })
}

function productImage(p: ProductInfo): string | null {
  return p.image_url || mediaUrl(p.image) || null
}

function productImages(p: ProductInfo): string[] {
  const imgs: string[] = []
  if (p.image_url) imgs.push(p.image_url)
  if (p.image) imgs.push(mediaUrl(p.image)!)
  return [...new Set(imgs.filter(Boolean))]
}

const activeImageIndex = ref(0)
const allImages = computed(() => product.value ? productImages(product.value) : [])
const activeImage = computed(() => allImages.value[activeImageIndex.value] || '')

function selectImage(index: number): void { activeImageIndex.value = index }
function prevImage(): void { if (activeImageIndex.value > 0) activeImageIndex.value -= 1 }
function nextImage(): void { if (activeImageIndex.value < allImages.value.length - 1) activeImageIndex.value += 1 }

const touchStartX = ref(0)
function onTouchStart(e: TouchEvent): void { touchStartX.value = e.touches[0].clientX }
function onTouchEnd(e: TouchEvent): void {
  const diff = touchStartX.value - e.changedTouches[0].clientX
  if (Math.abs(diff) > 50) {
    if (diff > 0) nextImage()
    else prevImage()
  }
}

function currentPrice(): string {
  if (selectedSku.value?.selling_price) return selectedSku.value.selling_price
  if (product.value?.price) return product.value.price
  return '0'
}

function originalPrice(): string | null {
  if (product.value?.original_price) return product.value.original_price
  if (product.value?.discount && Number(product.value.discount) > 0 && product.value.price) {
    return (Number(product.value.price) / (1 - Number(product.value.discount) / 100)).toFixed(2)
  }
  return null
}

function discountPercent(): number {
  return product.value?.discount ? Number(product.value.discount) : 0
}
function productUnit(): string {
  return product.value?.unit || ''
}

// antfu: VueUse useScroll handles direction detection + listener cleanup.
const { y: scrollY } = useScroll(window, { throttle: 100 })
const showMobileBar = computed(() => {
  // Visible near top or when scrolling up — computed is pure, no side effects.
  return scrollY.value < 200
})

const relatedProducts = ref<ProductInfo[]>([])
onMounted(async () => {
  if (!product.value) return
  try {
    const categoryId = (product.value.category as { id?: number } | undefined)?.id
    if (categoryId) {
      const data = await fetchProducts(slug.value, { category: categoryId, page_size: 6 })
      const all = Array.isArray(data) ? data : (data as PaginatedResponse<ProductInfo>)?.results || []
      relatedProducts.value = all.filter(p => p.id !== product.value!.id).slice(0, 5)
    }
  } catch { /* ignore */ }
})

watch(() => productId.value, () => {
  selectedSku.value = null
  quantity.value = 1
  activeImageIndex.value = 0
  relatedProducts.value = []
})

const isOutOfStock = computed(() => {
  if (!product.value?.skus?.length) return false
  return product.value.skus.every(s => Number(s.stock_quantity) === 0)
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-7xl mx-auto shop-animate-in pb-24 lg:pb-6">
    <button
      class="inline-flex items-center gap-1.5 text-sm text-(--ui-text-muted) hover:text-(--ui-primary) transition mb-4"
      @click="router.back()"
    >
      <UIcon name="i-lucide-arrow-left" class="size-4" />
      返回
    </button>

    <div v-if="isLoading" class="flex flex-col lg:flex-row gap-8 lg:gap-12">
      <div class="w-full lg:w-1/2">
        <div class="shop-skeleton aspect-square rounded-2xl" />
      </div>
      <div class="w-full lg:w-1/2 space-y-4">
        <div class="shop-skeleton h-8 rounded w-3/4" />
        <div class="shop-skeleton h-6 rounded w-1/4" />
        <div class="shop-skeleton h-4 rounded w-full" />
        <div class="shop-skeleton h-4 rounded w-2/3" />
        <div class="shop-skeleton h-12 rounded w-1/3 mt-4" />
      </div>
    </div>

    <div v-else-if="!product" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-package-x" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">
        商品不存在
      </p>
      <p class="shop-empty-desc">
        该商品可能已下架或不存在
      </p>
      <UButton
        :to="`/${slug}`"
        variant="soft"
        color="neutral"
        label="返回首页"
      />
    </div>

    <div v-else class="flex flex-col lg:flex-row gap-8 lg:gap-12">
      <div class="w-full lg:w-1/2 lg:sticky lg:top-20 lg:self-start">
        <div
          class="overflow-hidden rounded-2xl bg-(--ui-bg-muted) aspect-square relative shadow-md group"
          @touchstart="onTouchStart"
          @touchend="onTouchEnd"
        >
          <img
            v-if="allImages.length > 0"
            :src="activeImage"
            :alt="product.name"
            class="h-full w-full object-cover transition-all duration-500"
            :class="allImages.length > 1 ? 'cursor-crosshair' : ''"
            @error="onImgError($event, product.name)"
          >
          <div
            v-else
            class="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-(--ui-primary)/5 to-(--ui-primary)/10"
          >
            <span class="text-7xl font-black text-(--ui-primary)/15 select-none">{{ product.name?.charAt(0) }}</span>
          </div>

          <button
            v-if="allImages.length > 1"
            class="absolute left-2 top-1/2 -translate-y-1/2 size-8 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 transition opacity-0 group-hover:opacity-100"
            @click="prevImage"
          >
            <UIcon name="i-lucide-chevron-left" class="size-4" />
          </button>
          <button
            v-if="allImages.length > 1"
            class="absolute right-2 top-1/2 -translate-y-1/2 size-8 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 transition opacity-0 group-hover:opacity-100"
            @click="nextImage"
          >
            <UIcon name="i-lucide-chevron-right" class="size-4" />
          </button>

          <div
            v-if="allImages.length > 1"
            class="absolute bottom-3 right-3 bg-black/50 text-white text-xs px-2 py-0.5 rounded-full"
          >
            {{ activeImageIndex + 1 }} / {{ allImages.length }}
          </div>
        </div>

        <div
          v-if="allImages.length > 1"
          class="flex gap-2 mt-3 overflow-x-auto no-scrollbar"
        >
          <button
            v-for="(img, idx) in allImages"
            :key="idx"
            class="shop-thumb"
            :class="idx === activeImageIndex ? 'shop-thumb-active' : 'shop-thumb-inactive'"
            @click="selectImage(idx)"
          >
            <img
              :src="img"
              :alt="`${product.name} ${idx + 1}`"
              class="h-full w-full object-cover"
              @error="onImgError($event, product.name)"
            >
          </button>
        </div>
      </div>

      <div class="w-full lg:w-1/2 flex flex-col gap-5">
        <div>
          <div class="flex items-start justify-between gap-2">
            <h1 class="text-2xl lg:text-3xl font-bold text-(--ui-text) tracking-tight flex-1">
              {{ product.name }}
            </h1>
            <button
              class="size-9 shrink-0 rounded-xl flex items-center justify-center hover:bg-(--ui-bg-muted) transition"
              @click="toggleFav(product)"
            >
              <UIcon
                :name="isFavorited(product.id) ? 'i-lucide-heart' : 'i-lucide-heart-off'"
                class="size-5"
                :class="isFavorited(product.id) ? 'text-rose-500' : 'text-(--ui-text-muted)'"
              />
            </button>
          </div>

          <div class="flex items-center gap-3 mt-2 flex-wrap">
            <div v-if="product.rating" class="flex items-center gap-1">
              <div class="flex items-center gap-0.5">
                <UIcon
                  v-for="(star, sIdx) in renderStars(product.rating)"
                  :key="sIdx"
                  :name="star === 'full' ? 'i-lucide-star' : star === 'half' ? 'i-lucide-star-half' : 'i-lucide-star'"
                  class="shop-star"
                  :class="star !== 'empty' ? 'shop-star-filled' : 'shop-star-empty'"
                />
              </div>
              <span class="text-sm font-medium text-(--ui-text)">{{ product.rating.toFixed(1) }}</span>
            </div>
            <span v-if="product.monthly_sales" class="text-xs text-(--ui-text-muted)">月销 {{ product.monthly_sales }}</span>
            <span v-if="productUnit()" class="text-xs text-(--ui-text-muted) flex items-center gap-1">
              <UIcon name="i-lucide-package" class="size-3.5" />
              单位: {{ productUnit() }}
            </span>
          </div>
        </div>

        <div class="border-b border-(--ui-border)/50 pb-5">
          <div class="flex items-baseline gap-3">
            <span class="text-3xl font-bold tabular-nums tracking-tight" :class="discountPercent() > 0 ? 'text-rose-500' : 'text-(--ui-primary)'">
              {{ formatPrice(currentPrice()) }}
            </span>
            <span v-if="originalPrice()" class="text-sm text-(--ui-text-muted) line-through">
              {{ formatPrice(originalPrice()!) }}
            </span>
            <UBadge
              v-if="discountPercent() > 0"
              color="error"
              variant="soft"
              size="sm"
              class="rounded-full"
            >
              -{{ discountPercent() }}%
            </UBadge>
          </div>
        </div>

        <div v-if="product.skus?.length" class="border-b border-(--ui-border)/50 pb-5">
          <p class="text-sm font-medium text-(--ui-text) mb-3 flex items-center gap-1.5">
            <UIcon name="i-lucide-grid-3x3" class="size-4 text-(--ui-text-muted)" />
            规格选择
          </p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="sku in product.skus"
              :key="sku.id"
              class="shop-spec-btn"
              :class="selectedSku?.id === sku.id
                ? 'shop-spec-btn-active'
                : Number(sku.stock_quantity) === 0
                  ? 'shop-spec-btn-disabled'
                  : 'shop-spec-btn-inactive'"
              :disabled="Number(sku.stock_quantity) === 0"
              @click="Number(sku.stock_quantity) !== 0 && (selectedSku = sku)"
            >
              {{ sku.spec_name }}
              <span v-if="sku.selling_price" class="ml-1 opacity-70">{{ formatPrice(sku.selling_price) }}</span>
            </button>
          </div>
          <p
            v-if="selectedSku?.stock_quantity !== undefined"
            class="text-xs mt-3 flex items-center gap-1"
            :class="Number(selectedSku.stock_quantity) > 0 ? 'text-(--ui-text-muted)' : 'text-(--ui-error)'"
          >
            <UIcon :name="Number(selectedSku.stock_quantity) > 0 ? 'i-lucide-check-circle' : 'i-lucide-alert-circle'" class="size-3.5" />
            {{ Number(selectedSku.stock_quantity) > 0 ? `库存: ${Number(selectedSku.stock_quantity)}` : '已售罄' }}
          </p>
        </div>

        <div class="flex items-center gap-4">
          <span class="text-sm font-medium text-(--ui-text)">数量</span>
          <div class="shop-qty">
            <button :disabled="quantity <= 1" @click="decrementQty">
              <UIcon name="i-lucide-minus" class="size-4" />
            </button>
            <span>{{ quantity }}</span>
            <button :disabled="quantity >= 99" @click="incrementQty">
              <UIcon name="i-lucide-plus" class="size-4" />
            </button>
          </div>
        </div>

        <UButton
          size="lg"
          class="hidden lg:flex w-full justify-center h-12 rounded-xl text-base font-bold"
          :disabled="addingToCart || isOutOfStock"
          :loading="addingToCart"
          @click="addToCart"
        >
          <template v-if="addedToCart">
            <UIcon name="i-lucide-check" class="size-5" />
            已加入购物车 ✓
          </template>
          <template v-else-if="isOutOfStock">
            <UIcon name="i-lucide-alert-circle" class="size-5" />
            暂时缺货
          </template>
          <template v-else>
            <UIcon name="i-lucide-shopping-cart" class="size-5" />
            加入购物车
          </template>
        </UButton>

        <!-- ponytail: strip HTML entirely and render as text — regex sanitizers
             have known bypasses; v-html on text just adds risk for no gain. -->
        <div v-if="product.description" class="border-t border-(--ui-border)/50 pt-5">
          <div class="flex items-center gap-2 mb-3">
            <UIcon name="i-lucide-file-text" class="size-4 text-(--ui-primary)" />
            <p class="text-sm font-medium text-(--ui-text)">
              商品详情
            </p>
          </div>
          <p class="text-sm text-(--ui-text-muted) leading-relaxed whitespace-pre-line">
            {{ product.description }}
          </p>
        </div>

        <div class="border-t border-(--ui-border)/50 pt-5">
          <div class="grid grid-cols-2 gap-3 text-sm">
            <div class="flex items-center gap-2 text-(--ui-text-muted)">
              <UIcon name="i-lucide-tag" class="size-3.5" />
              <span>分类: {{ (product.category as { name?: string } | undefined)?.name || product.category_name || '-' }}</span>
            </div>
            <div class="flex items-center gap-2 text-(--ui-text-muted)">
              <UIcon name="i-lucide-clock" class="size-3.5" />
              <span>上架: {{ product.created_at ? new Date(product.created_at).toLocaleDateString('zh-CN') : '-' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="relatedProducts.length > 0" class="mt-16">
      <div class="border-t border-(--ui-border)/50 pt-8">
        <h2 class="text-lg font-bold text-(--ui-text) mb-6 flex items-center gap-2">
          <UIcon name="i-lucide-tag" class="size-5 text-(--ui-primary)" />
          相关商品
        </h2>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          <NuxtLink
            v-for="(rel, idx) in relatedProducts"
            :key="rel.id"
            :to="`/${slug}/product/${rel.id}`"
            class="shop-card group block"
            :style="{ animation: `fade-in-up 0.3s ease-out ${idx * 60}ms both` }"
          >
            <div class="overflow-hidden aspect-square rounded-t-xl bg-(--ui-bg-muted) relative">
              <img
                v-if="rel.image"
                :src="mediaUrl(rel.image)!"
                :alt="rel.name"
                class="h-full w-full object-cover shop-img-zoom"
                loading="lazy"
                @error="onImgError($event, rel.name)"
              >
              <div v-else class="absolute inset-0 flex items-center justify-center">
                <span class="text-4xl font-black text-(--ui-text-muted)/15">{{ rel.name?.charAt(0) }}</span>
              </div>
              <div class="absolute bottom-2 left-2 shop-price-badge text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-lg">
                {{ formatPrice(rel.price ?? 0) }}
              </div>
            </div>
            <div class="p-3">
              <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug min-h-[2.5em]">{{ rel.name }}</p>
            </div>
          </NuxtLink>
        </div>
      </div>
    </div>

    <Transition name="slide-up">
      <div v-if="showMobileBar" class="lg:hidden shop-mobile-bar px-4 py-3">
        <div class="flex items-center gap-3">
          <button
            class="size-10 rounded-xl bg-(--ui-bg-muted) flex items-center justify-center shrink-0"
            @click="router.push(`/${slug}`)"
          >
            <UIcon name="i-lucide-home" class="size-5 text-(--ui-text-muted)" />
          </button>
          <button
            class="size-10 rounded-xl bg-(--ui-bg-muted) flex items-center justify-center shrink-0 relative"
            @click="router.push(`/${slug}/cart`)"
          >
            <UIcon name="i-lucide-shopping-cart" class="size-5 text-(--ui-text-muted)" />
          </button>
          <UButton
            class="flex-1 h-10 rounded-xl text-sm font-bold"
            :disabled="addingToCart || isOutOfStock"
            :loading="addingToCart"
            @click="addToCart"
          >
            <template v-if="addedToCart">
              <UIcon name="i-lucide-check" class="size-4" />
              已加入 ✓
            </template>
            <template v-else-if="isOutOfStock">
              <UIcon name="i-lucide-alert-circle" class="size-4" />
              暂时缺货
            </template>
            <template v-else>
              {{ formatPrice(currentPrice()) }} · 加入购物车
            </template>
          </UButton>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.2s ease, opacity 0.2s ease;
}
.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
</style>
