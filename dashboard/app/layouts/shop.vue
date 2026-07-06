<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'
import type { PaginatedResponse, CategoryInfo, ProductInfo, TenantPublicInfo } from '~/types'
import { useShopCart } from '~/composables/useShopCart'

const route = useRoute()
const router = useRouter()
const slug = computed(() => route.params.slug as string)

const searchQuery = ref('')
const showMobileSearch = ref(false)
const showMobileMenu = ref(false)
const searchSuggestions = ref<string[]>([])
const showSuggestions = ref(false)

const colorMode = useColorMode()
const isHydrated = ref(false)
onMounted(() => { isHydrated.value = true })
const isDark = computed(() => isHydrated.value && colorMode.value === 'dark')
function toggleDark() {
  colorMode.preference = isDark.value ? 'light' : 'dark'
}

const { count: cartCount } = useShopCart()

const { data: categories } = useFetch(() => `/api/shop/${slug.value}/categories/`, {
  lazy: true,
  server: false,
  key: computed(() => `shop-categories-${slug.value}`),
})

const { data: tenantInfo } = useFetch<TenantPublicInfo>(
  () => `/api/shop/${slug.value}/info/`,
  {
    key: computed(() => `tenant-info-${slug.value}`),
    default: () => null as any,
  },
)

const categoryItems = computed<NavigationMenuItem[]>(() => {
  const resp = categories.value as PaginatedResponse<CategoryInfo> | CategoryInfo[] | undefined
  const cats = Array.isArray(resp) ? resp : (resp?.results || [])
  return cats.map(c => ({
    label: c.name,
    to: `/${slug.value}?category=${c.id}`,
  }))
})

const memberAuth = useMemberAuth()
const isLoggedIn = computed(() => !!memberAuth.token.value)

// antfu: VueUse useScroll handles listener cleanup + returns reactive y.
const { y: scrollY } = useScroll(window, { throttle: 100 })
const showBackToTop = computed(() => scrollY.value > 400)

function scrollToTop(): void {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function handleSearch(): void {
  if (searchQuery.value.trim()) {
    router.push({ path: `/${slug.value}`, query: { q: searchQuery.value } })
    showMobileSearch.value = false
    showMobileMenu.value = false
    showSuggestions.value = false
  }
}

const debouncedSearch = refDebounced(searchQuery, 300)
watch(debouncedSearch, async (val) => {
  if (!val || val.trim().length < 1) {
    searchSuggestions.value = []
    showSuggestions.value = false
    return
  }
  try {
    const { fetchProducts } = useShopApi()
    const data = await fetchProducts(slug.value, { search: val.trim(), page_size: 5 })
    const products: ProductInfo[] = Array.isArray(data) ? data : (data?.results || [])
    searchSuggestions.value = products.map(p => p.name).filter(Boolean)
    showSuggestions.value = searchSuggestions.value.length > 0
  } catch {
    searchSuggestions.value = []
    showSuggestions.value = false
  }
})

function hideSuggestions(): void { showSuggestions.value = false }

function selectSuggestion(text: string): void {
  searchQuery.value = text
  showSuggestions.value = false
  handleSearch()
}

const activeCategoryId = computed(() => {
  const q = route.query.category
  return q ? Number(q) : undefined
})

const storeName = computed(() => slug.value)

const { isFavorited } = useFavorite()
</script>

<template>
  <div class="min-h-screen flex flex-col bg-gradient-to-b from-(--ui-bg) to-(--ui-bg-muted)/20">
    <!-- Header with glass effect -->
    <header class="shop-header sticky z-40 text-white shadow-lg">
      <div class="flex items-center justify-between h-14 px-4 lg:px-6 max-w-7xl mx-auto w-full">
        <!-- Mobile menu toggle -->
        <button
          class="lg:hidden size-9 flex items-center justify-center rounded-lg hover:bg-white/10 transition -ml-1"
          @click="showMobileMenu = !showMobileMenu"
        >
          <UIcon :name="showMobileMenu ? 'i-lucide-x' : 'i-lucide-menu'" class="size-5" />
        </button>

        <!-- Logo -->
        <NuxtLink
          :to="`/${slug}`"
          class="flex items-center gap-2.5 font-bold text-lg hover:opacity-90 transition shrink-0"
        >
          <div class="size-8 rounded-lg bg-white/20 backdrop-blur flex items-center justify-center">
            <UIcon name="i-lucide-store" class="size-5" />
          </div>
          <span class="hidden sm:inline tracking-tight">{{ storeName }}</span>
        </NuxtLink>

        <!-- Desktop categories -->
        <div class="hidden lg:flex items-center gap-1 flex-1 justify-center px-4">
          <NuxtLink
            v-for="item in categoryItems.slice(0, 8)"
            :key="item.label"
            :to="item.to"
            class="px-3 py-1.5 rounded-lg text-sm font-medium transition whitespace-nowrap"
            :class="Number(item.to?.split('=')[1]) === activeCategoryId
              ? 'text-white bg-white/20'
              : 'text-white/80 hover:text-white hover:bg-white/10'"
          >
            {{ item.label }}
          </NuxtLink>
        </div>

        <!-- Right section -->
        <div class="flex items-center gap-1.5">
          <!-- Desktop search with suggestions -->
          <div class="hidden sm:flex items-center relative">
            <div class="relative">
              <UIcon name="i-lucide-search" class="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-white/50" />
              <input
                v-model="searchQuery"
                placeholder="搜索商品…"
                class="h-9 w-48 lg:w-56 rounded-lg bg-white/15 border border-white/10 pl-9 pr-3 text-sm text-white placeholder:text-white/40 outline-none focus:bg-white/20 focus:border-white/30 transition"
                @keyup.enter="handleSearch"
                @focus="debouncedSearch.length > 0 && (showSuggestions = true)"
                @blur="setTimeout(hideSuggestions, 200)"
              >
            </div>
            <!-- Search suggestions dropdown -->
            <div
              v-if="showSuggestions && searchSuggestions.length > 0"
              class="absolute top-full left-0 right-0 mt-1 bg-white dark:bg-zinc-800 rounded-xl shadow-lg border border-(--ui-border) overflow-hidden z-50"
            >
              <div
                v-for="suggestion in searchSuggestions"
                :key="suggestion"
                class="px-3 py-2.5 text-sm text-(--ui-text) hover:bg-(--ui-bg-muted) cursor-pointer transition flex items-center gap-2"
                @mousedown.prevent="selectSuggestion(suggestion)"
              >
                <UIcon name="i-lucide-search" class="size-3.5 text-(--ui-text-muted)" />
                {{ suggestion }}
              </div>
            </div>
          </div>

          <!-- Mobile search toggle -->
          <button
            class="sm:hidden size-9 flex items-center justify-center rounded-lg hover:bg-white/10 transition"
            @click="showMobileSearch = !showMobileSearch"
          >
            <UIcon name="i-lucide-search" class="size-5" />
          </button>

          <!-- Color mode toggle -->
          <button
            class="hidden sm:flex size-9 items-center justify-center rounded-lg hover:bg-white/10 transition"
            @click="toggleDark"
          >
            <UIcon :name="isDark ? 'i-lucide-sun' : 'i-lucide-moon'" class="size-4" />
          </button>

          <!-- Cart -->
          <button
            class="relative size-9 flex items-center justify-center rounded-lg hover:bg-white/10 transition"
            @click="router.push(`/${slug}/cart`)"
          >
            <UIcon name="i-lucide-shopping-cart" class="size-5" />
            <span v-if="cartCount > 0" :key="cartCount" class="shop-cart-badge shop-cart-bounce">{{ cartCount > 99 ? '99+' : cartCount }}</span>
          </button>

          <!-- Member / Login — ClientOnly to avoid SSR hydration mismatch -->
          <ClientOnly>
            <NuxtLink
              v-if="!isLoggedIn"
              :to="`/${slug}/login`"
              class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg text-sm font-medium text-white/80 hover:text-white hover:bg-white/10 transition"
            >
              <UIcon name="i-lucide-user" class="size-4" />
              <span>登录</span>
            </NuxtLink>
            <button
              v-else
              class="hidden sm:flex size-9 items-center justify-center rounded-lg hover:bg-white/10 transition"
              @click="router.push(`/${slug}/member`)"
            >
              <UIcon name="i-lucide-user" class="size-5" />
            </button>
          </ClientOnly>
        </div>
      </div>

      <!-- Mobile search bar (expandable) -->
      <div
        v-if="showMobileSearch"
        class="sm:hidden px-4 pb-3"
      >
        <div class="relative">
          <UIcon name="i-lucide-search" class="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-white/50" />
          <input
            v-model="searchQuery"
            placeholder="搜索商品…"
            class="w-full h-10 rounded-lg bg-white/15 border border-white/10 pl-9 pr-3 text-sm text-white placeholder:text-white/40 outline-none focus:bg-white/20 focus:border-white/30 transition"
            @keyup.enter="handleSearch"
          >
        </div>
        <!-- Mobile search suggestions -->
        <div
          v-if="showSuggestions && searchSuggestions.length > 0"
          class="mt-1 bg-white/95 dark:bg-zinc-800/95 backdrop-blur rounded-xl shadow-lg border border-white/10 overflow-hidden"
        >
          <div
            v-for="suggestion in searchSuggestions"
            :key="suggestion"
            class="px-3 py-2.5 text-sm text-(--ui-text) hover:bg-(--ui-bg-muted) cursor-pointer transition flex items-center gap-2"
            @mousedown.prevent="selectSuggestion(suggestion)"
          >
            <UIcon name="i-lucide-search" class="size-3.5 text-(--ui-text-muted)" />
            {{ suggestion }}
          </div>
        </div>
      </div>

      <!-- Mobile menu panel -->
      <div
        v-if="showMobileMenu"
        class="lg:hidden border-t border-white/10 bg-(--ui-primary)/95 backdrop-blur-md"
      >
        <div class="px-4 py-3 space-y-1">
          <NuxtLink
            v-for="item in categoryItems"
            :key="item.label"
            :to="item.to"
            class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
            @click="showMobileMenu = false"
          >
            {{ item.label }}
          </NuxtLink>
          <div class="border-t border-white/10 my-2" />
          <NuxtLink
            :to="`/${slug}/orders`"
            class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
            @click="showMobileMenu = false"
          >
            📋 我的订单
          </NuxtLink>
          <NuxtLink
            :to="`/${slug}/favorites`"
            class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
            @click="showMobileMenu = false"
          >
            ❤️ 我的收藏
          </NuxtLink>
          <NuxtLink
            :to="`/${slug}/coupons`"
            class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
            @click="showMobileMenu = false"
          >
            🎫 优惠券
          </NuxtLink>
          <NuxtLink
            :to="`/${slug}/recharge`"
            class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
            @click="showMobileMenu = false"
          >
            💰 充值中心
          </NuxtLink>
          <ClientOnly>
            <NuxtLink
              v-if="!isLoggedIn"
              :to="`/${slug}/login`"
              class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
              @click="showMobileMenu = false"
            >
              👤 会员登录
            </NuxtLink>
            <NuxtLink
              v-else
              :to="`/${slug}/member`"
              class="block px-3 py-2 rounded-lg text-sm text-white/80 hover:text-white hover:bg-white/10 transition"
              @click="showMobileMenu = false"
            >
              👤 会员中心
            </NuxtLink>
          </ClientOnly>
        </div>
      </div>
    </header>

    <!-- Mobile category bar (below header) -->
    <div
      v-if="categoryItems.length"
      class="lg:hidden flex gap-2 overflow-x-auto px-4 py-2.5 bg-(--ui-bg-muted)/50 border-b border-(--ui-border)/50 no-scrollbar"
    >
      <NuxtLink
        v-for="item in categoryItems"
        :key="item.label"
        :to="item.to"
        class="shrink-0 px-3.5 py-1.5 rounded-full text-xs font-medium transition"
        :class="route.query.category === item.to?.split('=')[1] ? 'shop-category-pill-active' : 'shop-category-pill-inactive'"
      >
        {{ item.label }}
      </NuxtLink>
    </div>

    <!-- Operational broadcast banner (admin-controlled) -->
    <BroadcastBanner />

    <!-- Main content -->
    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="shop-footer py-10 mt-16">
      <div class="max-w-7xl mx-auto px-4 lg:px-6">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-8 mb-8">
          <!-- Brand -->
          <div>
            <div class="flex items-center gap-2 mb-3">
              <div class="size-8 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center">
                <UIcon name="i-lucide-store" class="size-4 text-(--ui-primary)" />
              </div>
              <span class="font-bold text-(--ui-text)">{{ storeName }}</span>
            </div>
            <p class="text-xs text-(--ui-text-muted)/70 leading-relaxed">
              在线选购商品，到店取货，便捷省心。
            </p>
          </div>

          <!-- Quick links -->
          <div>
            <p class="text-xs font-semibold text-(--ui-text) uppercase tracking-wider mb-3">
              快速链接
            </p>
            <div class="space-y-2">
              <NuxtLink :to="`/${slug}`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">首页</NuxtLink>
              <NuxtLink :to="`/${slug}/orders`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">我的订单</NuxtLink>
              <NuxtLink :to="`/${slug}/favorites`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">我的收藏</NuxtLink>
              <NuxtLink :to="`/${slug}/coupons`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">优惠券</NuxtLink>
              <NuxtLink :to="`/${slug}/recharge`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">充值中心</NuxtLink>
              <NuxtLink :to="`/${slug}/analytics`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">消费分析</NuxtLink>
              <NuxtLink :to="`/${slug}/member`" class="block text-xs text-(--ui-text-muted) hover:text-(--ui-primary) transition">会员中心</NuxtLink>
            </div>
          </div>

          <!-- Contact -->
          <div>
            <p class="text-xs font-semibold text-(--ui-text) uppercase tracking-wider mb-3">
              联系我们
            </p>
            <div class="space-y-2 text-xs text-(--ui-text-muted)">
              <p v-if="tenantInfo?.address" class="flex items-center gap-1.5">
                <span>地址:</span>
                <UIcon name="i-lucide-map-pin" class="size-3.5 shrink-0" />
                <span>{{ tenantInfo.address }}</span>
              </p>
              <p v-if="tenantInfo?.phone" class="flex items-center gap-1.5">
                <span>电话:</span>
                <UIcon name="i-lucide-phone" class="size-3.5 shrink-0" />
                <span>{{ tenantInfo.phone }}</span>
              </p>
              <p v-if="tenantInfo?.business_hours" class="flex items-center gap-1.5">
                <span>营业时间:</span>
                <UIcon name="i-lucide-clock" class="size-3.5 shrink-0" />
                <span>{{ tenantInfo.business_hours }}</span>
              </p>
            </div>
          </div>
        </div>

        <div class="border-t border-(--ui-border)/40 pt-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-(--ui-text-muted)">
          <span>&copy; {{ new Date().getFullYear() }} {{ storeName }} · 安居超市系统</span>
          <div class="flex gap-4">
            <NuxtLink :to="`/${slug}`" class="hover:text-(--ui-primary) transition">首页</NuxtLink>
            <span>·</span>
            <NuxtLink :to="`/${slug}/orders`" class="hover:text-(--ui-primary) transition">我的订单</NuxtLink>
          </div>
        </div>
      </div>
    </footer>

    <!-- Back to top button -->
    <Transition name="scale">
      <button
        v-if="showBackToTop"
        class="fixed bottom-6 right-6 z-40 size-10 rounded-full bg-(--ui-primary) text-white shadow-lg shadow-(--ui-primary)/30 flex items-center justify-center hover:bg-(--ui-primary)/90 transition active:scale-90"
        @click="scrollToTop"
      >
        <UIcon name="i-lucide-arrow-up" class="size-5" />
      </button>
    </Transition>
  </div>
</template>

<style scoped>
.scale-enter-active,
.scale-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.8);
}
</style>
