<script setup lang="ts">
import { mediaUrl } from '~/composables/useShopApi'
import type { PaginatedResponse, ProductInfo } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { fetchProducts } = useShopApi()
const { onImgError } = useImageFallback()
const { favoriteIds, isFavorited, toggle: toggleFavorite, count } = useFavorite()

// Fetch products by their IDs
const products = ref<ProductInfo[]>([])
const isLoading = ref(false)

async function loadFavorites() {
  if (favoriteIds.value.length === 0) {
    products.value = []
    return
  }
  isLoading.value = true
  try {
    // Fetch all products (page_size=100) and filter by fav IDs
    const data = await fetchProducts(slug.value, { page_size: 100 })
    const all = Array.isArray(data) ? data : (data as PaginatedResponse<ProductInfo>)?.results || []
    products.value = all.filter(p => favoriteIds.value.includes(p.id))
  } catch {
    toast.add({ title: '加载收藏失败', color: 'error', duration: 2000, ui: { container: 'shop-toast' } })
  } finally {
    isLoading.value = false
  }
}

// Watch for favorite changes — re-filter
watch(favoriteIds, () => {
  products.value = products.value.filter(p => favoriteIds.value.includes(p.id))
})

onMounted(() => loadFavorites())

function removeFav(product: ProductInfo, event: MouseEvent) {
  event.preventDefault()
  event.stopPropagation()
  toggleFavorite(product.id)
  toast.add({ title: '已取消收藏', color: 'neutral', duration: 1200, ui: { container: 'shop-toast' } })
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function renderStars(rating: number): string[] {
  const stars: string[] = []
  for (let i = 1; i <= 5; i++) {
    if (i <= Math.floor(rating)) stars.push('full')
    else if (i - rating < 1) stars.push('half')
    else stars.push('empty')
  }
  return stars
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto shop-animate-in">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button
        class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition"
        @click="router.back()"
      >
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">我的收藏</h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">
          共 <span class="font-medium">{{ count }}</span> 件收藏商品
        </p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="grid grid-cols-2 md:grid-cols-3 gap-4">
      <div v-for="i in 4" :key="i">
        <div class="shop-skeleton aspect-square rounded-xl" />
        <div class="mt-3 space-y-2 px-0.5">
          <div class="shop-skeleton h-4 rounded w-2/3" />
          <div class="shop-skeleton h-4 rounded w-1/3" />
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="products.length === 0"
      class="flex flex-col items-center justify-center py-20"
    >
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-heart" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">还没有收藏商品</p>
      <p class="shop-empty-desc">浏览商品时点击❤️即可收藏</p>
      <UButton
        :to="`/${slug}`"
        variant="soft"
        color="neutral"
        label="去逛逛"
        icon="i-lucide-shopping-bag"
      />
    </div>

    <!-- Favorites grid -->
    <div v-else class="grid grid-cols-2 md:grid-cols-3 gap-4">
      <NuxtLink
        v-for="product in products"
        :key="product.id"
        :to="`/${slug}/product/${product.id}`"
        class="shop-card group block relative"
      >
        <!-- Remove fav button -->
        <button
          class="absolute top-2 right-2 z-20 size-8 flex items-center justify-center rounded-full bg-white/70 dark:bg-zinc-800/70 backdrop-blur shadow-sm hover:scale-110 transition"
          @click="removeFav(product, $event)"
        >
          <UIcon name="i-lucide-heart" class="size-4 text-rose-500" />
        </button>

        <!-- Image -->
        <div class="overflow-hidden aspect-square rounded-t-xl bg-(--ui-bg-muted) relative">
          <img
            v-if="product.image || product.image_url"
            :src="mediaUrl(product.image || product.image_url)!"
            :alt="product.name"
            class="h-full w-full object-cover shop-img-zoom"
            loading="lazy"
            @error="onImgError($event, product.name)"
          />
          <div v-else class="absolute inset-0 flex items-center justify-center">
            <span class="text-4xl font-black text-(--ui-primary)/15">{{ product.name?.charAt(0) }}</span>
          </div>
          <div class="absolute bottom-2 left-2 shop-price-badge text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-lg">
            {{ formatPrice(product.price ?? 0) }}
          </div>
        </div>

        <!-- Info -->
        <div class="p-3">
          <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug min-h-[2.5em]">
            {{ product.name }}
          </p>
          <div v-if="product.rating" class="flex items-center gap-1 mt-1.5">
            <UIcon
              v-for="(star, sIdx) in renderStars(product.rating)"
              :key="sIdx"
              :name="star === 'full' ? 'i-lucide-star' : star === 'half' ? 'i-lucide-star-half' : 'i-lucide-star'"
              class="shop-star"
              :class="star !== 'empty' ? 'shop-star-filled' : 'shop-star-empty'"
            />
            <span class="text-[10px] text-(--ui-text-muted) ml-0.5">{{ product.rating.toFixed(1) }}</span>
          </div>
        </div>
      </NuxtLink>
    </div>
  </div>
</template>
