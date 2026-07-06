<script setup lang="ts">
import { mediaUrl } from '~/composables/useShopApi'
import { useShopCart } from '~/composables/useShopCart'
import { formatPrice, renderStars } from '~/utils/format'
import type { PaginatedResponse, ProductInfo, CategoryInfo, BannerInfo } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { fetchProducts, fetchCategories } = useShopApi()
const { onImgError } = useImageFallback()
const { isFavorited, toggle: toggleFavorite } = useFavorite()
const { add: addToCart } = useShopCart()

const activeCategory = computed(() => {
  const q = route.query.category
  return q ? Number(q) : undefined
})
const searchQuery = computed(() => route.query.q ? String(route.query.q) : undefined)
const sortBy = ref<string>(route.query.sort as string || 'default')

const currentPage = ref(1)
const pageSize = 20
const totalCount = ref(0)
const totalPages = computed(() => Math.max(1, Math.ceil(totalCount.value / pageSize)))

useHead(() => ({
  title: searchQuery.value
    ? `搜索: ${searchQuery.value} - ${slug.value}`
    : `${slug.value} - 网上超市`,
}))

// Product list — sortBy is purely client-side, so it stays out of the cache key
// and the watch list to avoid a wasted refetch on every sort change.
const { data: productsData, status } = useAsyncData(
  () => `shop-products-${slug.value}-${activeCategory.value ?? 'all'}-${searchQuery.value ?? ''}-${currentPage.value}`,
  () => fetchProducts(slug.value, {
    category: activeCategory.value,
    search: searchQuery.value,
    page: currentPage.value,
    page_size: pageSize,
  }),
  { watch: [activeCategory, searchQuery, currentPage] },
)

// Pull pagination total out via watch — never inside the computed, which must
// be pure (no side effects).
const allProducts = computed<ProductInfo[]>(() => {
  const data = productsData.value
  if (!data) return []
  if (Array.isArray(data)) return data
  return (data as PaginatedResponse<ProductInfo>).results ?? []
})

watch(productsData, (data) => {
  if (data && !Array.isArray(data)) {
    totalCount.value = (data as PaginatedResponse<ProductInfo>).count ?? 0
  } else {
    totalCount.value = Array.isArray(data) ? data.length : 0
  }
}, { immediate: true })

const products = computed<ProductInfo[]>(() => {
  const list = [...allProducts.value]
  switch (sortBy.value) {
    case 'price-asc':
      return list.sort((a, b) => Number(a.price || 0) - Number(b.price || 0))
    case 'price-desc':
      return list.sort((a, b) => Number(b.price || 0) - Number(a.price || 0))
    case 'sales':
      return list.sort((a, b) => Number(b.monthly_sales || 0) - Number(a.monthly_sales || 0))
    default:
      return list
  }
})

const isLoading = computed(() => status.value === 'pending')

watch([activeCategory, searchQuery], () => {
  currentPage.value = 1
})

const categoriesList = ref<CategoryInfo[]>([])
onMounted(async () => {
  try {
    const catData = await fetchCategories(slug.value)
    categoriesList.value = Array.isArray(catData)
      ? catData
      : ((catData as PaginatedResponse<CategoryInfo>)?.results || [])
  } catch { /* ignore */ }
})

const banners = ref<BannerInfo[]>([
  { id: 1, title: '新鲜果蔬', subtitle: '每日新鲜直达，品质保证', image: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=1200&h=400&fit=crop', link: `/${slug.value}?category=1` },
  { id: 2, title: '夏日特惠', subtitle: '精选商品低至5折', image: 'https://images.unsplash.com/photo-1608686207856-001b95cf60ca?w=1200&h=400&fit=crop', link: `/${slug.value}` },
  { id: 3, title: '新用户专享', subtitle: '注册即送10元优惠券', image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&h=400&fit=crop', link: `/${slug.value}` },
])
const currentBanner = ref(0)

// antfu: useIntervalFn auto-cleans on unmount, no manual clearInterval.
const { pause, resume } = useIntervalFn(() => {
  currentBanner.value = (currentBanner.value + 1) % banners.value.length
}, 4000)
onMounted(() => banners.value.length > 1 ? resume() : pause())

const addingProductId = ref<number | null>(null)
const addedProductIds = ref<Set<number>>(new Set())

function quickAdd(product: ProductInfo) {
  addToCart(product)
  addingProductId.value = product.id
  setTimeout(() => {
    addingProductId.value = null
    addedProductIds.value = new Set([...addedProductIds.value, product.id])
    toast.add({ title: '已加入购物车', color: 'success', duration: 1500, ui: { container: 'shop-toast' } })
    setTimeout(() => {
      const next = new Set(addedProductIds.value)
      next.delete(product.id)
      addedProductIds.value = next
    }, 1500)
  }, 200)
}

function toggleFav(product: ProductInfo, event: MouseEvent) {
  event.preventDefault()
  event.stopPropagation()
  toggleFavorite(product.id)
  const nowFav = isFavorited(product.id)
  toast.add({
    title: nowFav ? '已收藏' : '已取消收藏',
    color: nowFav ? 'success' : 'neutral',
    duration: 1200,
    ui: { container: 'shop-toast' },
  })
}

function productImage(product: ProductInfo): string | null {
  return product.image_url || mediaUrl(product.image) || null
}

function productPrice(product: ProductInfo): string {
  return product.price ?? '0'
}

function productUnit(product: ProductInfo): string {
  return product.unit || ''
}

function productTag(product: ProductInfo): { text: string, type: string } | null {
  if (product.discount && Number(product.discount) > 0) return { text: `-${product.discount}%`, type: 'discount' }
  if (product.is_new) return { text: '新品', type: 'new' }
  if (product.is_hot || (product.monthly_sales || 0) > 1000) return { text: '热卖', type: 'hot' }
  return null
}

const sortOptions = [
  { value: 'default', label: '综合排序' },
  { value: 'sales', label: '销量优先' },
  { value: 'price-asc', label: '价格从低到高' },
  { value: 'price-desc', label: '价格从高到低' },
]
</script>

<template>
  <div class="pb-16 lg:pb-0">
    <!-- Hero Banner Carousel -->
    <div v-if="!searchQuery && !activeCategory && banners.length > 0" class="relative overflow-hidden group">
      <div class="relative h-44 sm:h-56 lg:h-64">
        <div
          v-for="(banner, idx) in banners"
          :key="banner.id"
          class="absolute inset-0 transition-all duration-500"
          :class="idx === currentBanner ? 'opacity-100' : 'opacity-0 pointer-events-none'"
        >
          <NuxtLink :to="banner.link || `/${slug}`" class="block h-full">
            <!-- Background image with overlay -->
            <div
              class="absolute inset-0 bg-cover bg-center"
              :class="[
                idx % 3 === 0 ? 'bg-gradient-to-r from-violet-600/90 via-violet-500/90 to-fuchsia-500/90' : '',
                idx % 3 === 1 ? 'bg-gradient-to-r from-amber-500/90 via-orange-500/90 to-red-500/90' : '',
                idx % 3 === 2 ? 'bg-gradient-to-r from-emerald-500/90 via-teal-500/90 to-cyan-500/90' : '',
              ]"
              :style="banner.image ? { backgroundImage: `url(${banner.image})` } : {}"
            >
              <!-- Dark overlay for text readability -->
              <div class="absolute inset-0 bg-black/20" />
            </div>

            <!-- Content -->
            <div class="relative h-full flex items-center px-6 lg:px-10">
              <div class="text-white">
                <h2 class="text-2xl sm:text-3xl lg:text-4xl font-bold tracking-tight drop-shadow-md">{{ banner.title }}</h2>
                <p class="mt-1.5 text-sm sm:text-base text-white/90 max-w-md drop-shadow-sm">{{ banner.subtitle }}</p>
                <span class="inline-block mt-3 text-xs font-medium bg-white/20 rounded-full px-3 py-1 backdrop-blur-sm">立即查看 →</span>
              </div>
            </div>
          </NuxtLink>
        </div>
      </div>

      <!-- Banner dots -->
      <div class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5">
        <button
          v-for="(banner, idx) in banners"
          :key="banner.id"
          class="shop-hero-dot"
          :class="idx === currentBanner ? 'shop-hero-dot-active' : 'shop-hero-dot-inactive'"
          @click="currentBanner = idx"
        />
      </div>

      <!-- Arrow buttons -->
      <button
        class="absolute left-2 top-1/2 -translate-y-1/2 size-8 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 transition opacity-0 group-hover:opacity-100"
        @click="currentBanner = currentBanner > 0 ? currentBanner - 1 : banners.length - 1"
      >
        <UIcon name="i-lucide-chevron-left" class="size-4" />
      </button>
      <button
        class="absolute right-2 top-1/2 -translate-y-1/2 size-8 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 transition opacity-0 group-hover:opacity-100"
        @click="currentBanner = (currentBanner + 1) % banners.length"
      >
        <UIcon name="i-lucide-chevron-right" class="size-4" />
      </button>
    </div>

    <div class="py-6 px-4 lg:px-6 max-w-7xl mx-auto">
      <!-- Search result banner -->
      <div v-if="searchQuery" class="mb-6">
        <div class="flex items-center gap-3">
          <div class="size-10 rounded-xl bg-(--ui-primary)/10 flex items-center justify-center">
            <UIcon name="i-lucide-search" class="size-5 text-(--ui-primary)" />
          </div>
          <div>
            <p class="text-sm text-(--ui-text-muted)">
              搜索 "<span class="font-medium text-(--ui-text)">{{ searchQuery }}</span>"
            </p>
            <p v-if="!isLoading" class="text-xs text-(--ui-text-muted)/60">
              {{ totalCount > 0 ? `找到 ${totalCount} 件商品` : '未找到匹配商品' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Category pills + Sort bar -->
      <div v-if="categoriesList.length > 0 && !searchQuery" class="mb-6">
        <div class="flex items-center justify-between gap-4">
          <div class="flex gap-2 overflow-x-auto no-scrollbar flex-1">
            <NuxtLink
              :to="`/${slug}`"
              class="shop-category-pill shrink-0 px-4 py-1.5 rounded-full text-sm font-medium transition"
              :class="!activeCategory ? 'shop-category-pill-active' : 'shop-category-pill-inactive'"
            >
              全部
            </NuxtLink>
            <NuxtLink
              v-for="cat in categoriesList"
              :key="cat.id"
              :to="`/${slug}?category=${cat.id}`"
              class="shop-category-pill shrink-0 px-4 py-1.5 rounded-full text-sm font-medium transition"
              :class="activeCategory === cat.id ? 'shop-category-pill-active' : 'shop-category-pill-inactive'"
            >
              {{ cat.name }}
            </NuxtLink>
          </div>

          <!-- Sort dropdown (desktop) -->
          <div class="hidden sm:flex items-center gap-2 shrink-0">
            <UIcon name="i-lucide-arrow-up-down" class="size-3.5 text-(--ui-text-muted)" />
            <select
              v-model="sortBy"
              class="text-xs border border-(--ui-border) rounded-lg px-2 py-1.5 bg-transparent text-(--ui-text-muted) outline-none focus:border-(--ui-primary) transition"
            >
              <option v-for="opt in sortOptions" :key="opt.value" :value="opt.value">
                {{ opt.label }}
              </option>
            </select>
          </div>
        </div>

        <!-- Sort chips (mobile) -->
        <div class="sm:hidden flex gap-2 mt-3 overflow-x-auto no-scrollbar">
          <button
            v-for="opt in sortOptions"
            :key="opt.value"
            class="shrink-0 px-3 py-1 rounded-full text-xs font-medium transition border"
            :class="sortBy === opt.value
              ? 'border-(--ui-primary) bg-(--ui-primary)/10 text-(--ui-primary)'
              : 'border-(--ui-border) text-(--ui-text-muted) hover:border-(--ui-border-hover)'"
            @click="sortBy = opt.value"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- Loading shimmer -->
      <div v-if="isLoading" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
        <div v-for="i in 10" :key="i">
          <div class="shop-skeleton aspect-square rounded-xl" />
          <div class="mt-3 space-y-2 px-0.5">
            <div class="shop-skeleton h-4 rounded w-1/3" />
            <div class="shop-skeleton h-4 rounded w-2/3" />
            <div class="shop-skeleton h-3 rounded w-1/4 mt-2" />
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div
        v-else-if="products.length === 0"
        class="flex flex-col items-center justify-center py-20"
      >
        <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
          <UIcon :name="searchQuery ? 'i-lucide-search-x' : 'i-lucide-package-open'" class="shop-empty-icon" />
        </div>
        <p class="shop-empty-text">
          {{ searchQuery ? '未找到商品' : '暂无商品' }}
        </p>
        <p class="shop-empty-desc">
          {{ searchQuery ? '试试其他关键词吧' : '该分类下还没有商品' }}
        </p>
        <UButton
          v-if="searchQuery || activeCategory"
          :to="`/${slug}`"
          variant="soft"
          color="neutral"
          size="sm"
          label="查看全部商品"
          icon="i-lucide-arrow-left"
        />
      </div>

      <!-- Product grid -->
      <div v-else>
        <p v-if="searchQuery" class="text-xs text-(--ui-text-muted)/60 mb-3">
          共 {{ totalCount }} 件商品
        </p>

        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4 lg:gap-5">
          <NuxtLink
            v-for="(product, idx) in products"
            :key="product.id"
            :to="`/${slug}/product/${product.id}`"
            class="shop-card group block shop-stagger-enter relative"
            :style="{ animation: `fade-in-up 0.3s ease-out ${idx * 40}ms both` }"
          >
            <!-- Favorite button — ClientOnly to avoid SSR hydration mismatch -->
            <ClientOnly>
              <button
                class="absolute top-2 right-2 z-20 size-8 flex items-center justify-center rounded-full bg-white/70 dark:bg-zinc-800/70 backdrop-blur shadow-sm hover:scale-110 transition"
                @click="toggleFav(product, $event)"
              >
                <UIcon
                  :name="isFavorited(product.id) ? 'i-lucide-heart' : 'i-lucide-heart-off'"
                  class="size-4"
                  :class="isFavorited(product.id) ? 'text-rose-500' : 'text-(--ui-text-muted)'"
                />
              </button>
            </ClientOnly>

            <!-- Image container -->
            <div
              class="relative overflow-hidden aspect-square rounded-t-xl"
              :class="productImage(product) ? 'bg-(--ui-bg-muted)' : 'bg-gradient-to-br from-(--ui-primary)/10 to-(--ui-primary)/5'"
            >
              <img
                v-if="productImage(product)"
                :src="productImage(product)!"
                :alt="product.name"
                class="h-full w-full object-cover shop-img-zoom"
                loading="lazy"
                @error="onImgError($event, product.name)"
              >
              <div
                v-else
                class="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-(--ui-primary)/20 to-(--ui-primary)/5"
              >
                <span class="text-6xl font-bold text-(--ui-primary)/20 select-none">{{ product.name?.charAt(0) }}</span>
              </div>

              <!-- Tag badge -->
              <span
                v-if="productTag(product)"
                class="shop-tag"
                :class="`shop-tag-${productTag(product)!.type}`"
              >
                {{ productTag(product)!.text }}
              </span>

              <!-- Price badge -->
              <div class="absolute bottom-2 left-2 shop-price-badge text-white text-xs font-bold px-2.5 py-1 rounded-full shadow-lg">
                {{ formatPrice(productPrice(product)) }}
              </div>

              <!-- Out of stock overlay -->
              <div
                v-if="product.skus?.length && product.skus.every((s: any) => Number(s.stock_quantity) === 0)"
                class="absolute inset-0 bg-black/40 flex items-center justify-center backdrop-blur-[2px]"
              >
                <span class="text-white text-sm font-bold px-3 py-1 bg-black/50 rounded-full">暂时缺货</span>
              </div>
            </div>

            <!-- Product info -->
            <div class="p-3">
              <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug min-h-[2.5em]">
                {{ product.name }}
              </p>

              <!-- Rating & sales -->
              <div class="flex items-center gap-2 mt-1.5">
                <div v-if="product.rating" class="flex items-center gap-0.5">
                  <UIcon
                    v-for="(star, sIdx) in renderStars(product.rating)"
                    :key="sIdx"
                    :name="star === 'full' ? 'i-lucide-star' : star === 'half' ? 'i-lucide-star-half' : 'i-lucide-star'"
                    class="shop-star"
                    :class="star !== 'empty' ? 'shop-star-filled' : 'shop-star-empty'"
                  />
                  <span class="text-[10px] text-(--ui-text-muted) ml-0.5">{{ product.rating.toFixed(1) }}</span>
                </div>
                <span v-if="product.monthly_sales" class="text-[10px] text-(--ui-text-muted)/60">
                  月销 {{ product.monthly_sales > 999 ? `${(product.monthly_sales / 1000).toFixed(1)}k` : product.monthly_sales }}
                </span>
              </div>

              <div class="flex items-center gap-1.5 mt-0.5">
                <span v-if="productUnit(product)" class="text-xs text-(--ui-text-muted)/60">
                  / {{ productUnit(product) }}
                </span>
              </div>

              <!-- Quick add button -->
              <div class="mt-2.5" @click.prevent>
                <button
                  class="shop-quick-add min-h-[36px]"
                  :class="addedProductIds.has(product.id)
                    ? 'shop-quick-add-added'
                    : product.skus?.length && product.skus.every((s: any) => Number(s.stock_quantity) === 0)
                      ? 'shop-quick-add-disabled'
                      : 'shop-quick-add-default'"
                  :disabled="addingProductId === product.id || (product.skus?.length && product.skus.every((s: any) => Number(s.stock_quantity) === 0))"
                  @click="quickAdd(product)"
                >
                  <template v-if="addingProductId === product.id">
                    <UIcon name="i-lucide-loader-circle" class="size-3.5 animate-spin" />
                    加入中…
                  </template>
                  <template v-else-if="addedProductIds.has(product.id)">
                    <UIcon name="i-lucide-check" class="size-3.5" />
                    已加入 ✓
                  </template>
                  <template v-else>
                    <UIcon name="i-lucide-plus" class="size-3.5" />
                    加入购物车
                  </template>
                </button>
              </div>
            </div>
          </NuxtLink>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex items-center justify-center gap-2 mt-10">
          <button
            class="size-9 rounded-xl border border-(--ui-border) flex items-center justify-center text-sm text-(--ui-text-muted) hover:bg-(--ui-bg-muted) transition disabled:opacity-30"
            :disabled="currentPage <= 1"
            @click="currentPage = currentPage - 1"
          >
            <UIcon name="i-lucide-chevron-left" class="size-4" />
          </button>

          <template v-for="p in totalPages" :key="p">
            <button
              v-if="p === 1 || p === totalPages || Math.abs(p - currentPage) <= 2"
              class="min-w-9 h-9 rounded-xl text-sm font-medium transition"
              :class="p === currentPage
                ? 'bg-(--ui-primary) text-white shadow-sm'
                : 'border border-(--ui-border) text-(--ui-text-muted) hover:bg-(--ui-bg-muted)'"
              @click="currentPage = p"
            >
              {{ p }}
            </button>
            <span
              v-else-if="p === currentPage - 3 || p === currentPage + 3"
              class="text-(--ui-text-muted) text-sm"
            >…</span>
          </template>

          <button
            class="size-9 rounded-xl border border-(--ui-border) flex items-center justify-center text-sm text-(--ui-text-muted) hover:bg-(--ui-bg-muted) transition disabled:opacity-30"
            :disabled="currentPage >= totalPages"
            @click="currentPage = currentPage + 1"
          >
            <UIcon name="i-lucide-chevron-right" class="size-4" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
