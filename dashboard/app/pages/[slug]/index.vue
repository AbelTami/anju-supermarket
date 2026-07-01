<script setup lang="ts">
definePageMeta({ layout: 'shop' })

import { mediaUrl } from '~/composables/useShopApi'

const route = useRoute()
const slug = computed(() => route.params.slug as string)
const { fetchProducts, fetchCategories } = useShopApi()

const activeCategory = computed(() => {
  const q = route.query.category
  return q ? Number(q) : undefined
})
const searchQuery = computed(() => route.query.q ? String(route.query.q) : undefined)

// SEO
useHead(() => ({
  title: searchQuery.value
    ? `搜索: ${searchQuery.value} - ${slug.value}`
    : `${slug.value} - 网上超市`,
}))

// Fetch products — SSR-friendly via useAsyncData
const { data: productsData, status } = useAsyncData(
  () => `shop-products-${slug.value}-${activeCategory.value ?? 'all'}-${searchQuery.value ?? ''}`,
  () => fetchProducts(slug.value, {
    category: activeCategory.value,
    search: searchQuery.value,
  }),
  { watch: [activeCategory, searchQuery] }
)

const products = computed<any[]>(() => {
  const data = productsData.value as any
  if (!data) return []
  // Handle both array and paginated response
  if (Array.isArray(data)) return data
  if (data.results) return data.results
  return []
})

const isLoading = computed(() => status.value === 'pending')

// Fetch categories client-side
const categoriesList = ref<any[]>([])
onMounted(async () => {
  try {
    const catData = await fetchCategories(slug.value)
    categoriesList.value = Array.isArray(catData)
      ? catData
      : ((catData as any)?.results || [])
  } catch { /* ignore */ }
})

// Helper: build product image URL with Django media base
function productImage(product: any): string | null {
  return product.image_url || mediaUrl(product.image)
}

// Helper: format price
function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}

function productPrice(product: any): string {
  return product.price ?? '0'
}

function productUnit(product: any): string {
  return product.unit || ''
}
</script>

<template>
  <div class="py-6">
    <!-- Category filter bar -->
    <div
      v-if="categoriesList.length > 0"
      class="mb-6"
    >
      <div class="flex gap-2 overflow-x-auto px-4 lg:px-6 no-scrollbar">
        <UButton
          :to="`/${slug}`"
          :variant="!activeCategory ? 'solid' : 'outline'"
          color="neutral"
          size="sm"
          label="全部"
          class="shrink-0 rounded-full"
        />
        <UButton
          v-for="cat in categoriesList"
          :key="cat.id"
          :to="`/${slug}?category=${cat.id}`"
          :variant="activeCategory === cat.id ? 'solid' : 'outline'"
          color="neutral"
          size="sm"
          :label="cat.name"
          class="shrink-0 rounded-full"
        />
      </div>
    </div>

    <!-- Search result banner -->
    <div v-if="searchQuery" class="px-4 lg:px-6 mb-6">
      <p class="text-sm text-(--ui-text-muted)">
        搜索 "<span class="font-medium text-(--ui-text)">{{ searchQuery }}</span>"
        的结果
        <span v-if="!isLoading && products.length">（共 {{ products.length }} 件商品）</span>
      </p>
    </div>

    <!-- Loading skeleton -->
    <div v-if="isLoading" class="px-4 lg:px-6">
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
        <div
          v-for="i in 10"
          :key="i"
          class="animate-pulse"
        >
          <div class="aspect-square bg-(--ui-bg-muted) rounded-xl" />
          <div class="mt-3 space-y-2">
            <div class="h-4 bg-(--ui-bg-muted) rounded w-1/3" />
            <div class="h-4 bg-(--ui-bg-muted) rounded w-2/3" />
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="products.length === 0"
      class="flex flex-col items-center justify-center py-20 px-4"
    >
      <UIcon name="i-lucide-package-search" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-1">暂无商品</p>
      <p class="text-sm text-(--ui-text-muted)">
        {{ searchQuery ? '未找到匹配的商品，试试其他关键词' : '该分类下暂无商品' }}
      </p>
      <UButton
        v-if="searchQuery || activeCategory"
        :to="`/${slug}`"
        variant="outline"
        color="neutral"
        size="sm"
        label="查看全部商品"
        class="mt-4"
      />
    </div>

    <!-- Product grid -->
    <div v-else class="px-4 lg:px-6">
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
        <NuxtLink
          v-for="product in products"
          :key="product.id"
          :to="`/${slug}/product/${product.id}`"
          class="group block"
        >
          <div
            class="overflow-hidden rounded-xl aspect-square relative"
            :class="productImage(product) ? 'bg-(--ui-bg-muted)' : 'bg-(--ui-bg-accented)'"
          >
            <img
              v-if="productImage(product)"
              :src="productImage(product)!"
              :alt="product.name"
              class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
              loading="lazy"
            />
            <span
              v-else
              class="absolute inset-0 flex items-center justify-center text-5xl font-black text-white/70 select-none bg-gradient-to-br from-(--ui-primary) to-(--ui-primary)/40"
            >{{ product.name?.charAt(0) }}</span>
          </div>

          <div class="mt-3 space-y-1 px-0.5">
            <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug">
              {{ product.name }}
            </p>
            <div class="flex items-baseline gap-1.5">
              <span class="text-sm font-bold text-(--ui-primary)">
                {{ formatPrice(productPrice(product)) }}
              </span>
              <span
                v-if="productUnit(product)"
                class="text-xs text-(--ui-text-muted)"
              >
                / {{ productUnit(product) }}
              </span>
            </div>
          </div>
        </NuxtLink>
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
