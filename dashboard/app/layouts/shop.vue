<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const route = useRoute()
const router = useRouter()
const slug = computed(() => route.params.slug as string)

const searchQuery = ref('')

// Shared cart state — wired up later
const cart = useState<any[]>('shop-cart', () => [])
const cartCount = computed(() => cart.value.reduce((sum, item) => sum + (item.quantity || 0), 0))

// Fetch categories for nav — via BFF proxy (no auth needed for read)
const { data: categories } = useFetch(() => `/api/shop/${slug.value}/categories/`, {
  lazy: true,
  server: false,
})

const categoryItems = computed<NavigationMenuItem[]>(() => {
  const cats = (categories.value as any)?.results || (categories.value as any[]) || []
  return cats.map((c: any) => ({
    label: c.name,
    to: `/${slug.value}?category=${c.id}`,
  }))
})

function scrollToTop() {
  if (typeof window !== 'undefined') {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

function handleSearch() {
  if (searchQuery.value.trim()) {
    router.push({ path: `/${slug.value}`, query: { q: searchQuery.value } })
  }
}

// Tenant store name from the slug
const storeName = computed(() => slug.value)
</script>

<template>
  <div class="min-h-screen flex flex-col bg-white dark:bg-zinc-950">
    <!-- Header -->
    <UHeader
      :ui="{ wrapper: 'lg:px-5', body: 'h-16' }"
    >
      <template #logo>
        <NuxtLink
          :to="`/${slug}`"
          class="flex items-center gap-2 font-bold text-lg text-(--ui-primary) hover:opacity-80 transition"
        >
          <UIcon name="i-lucide-store" class="size-5" />
          <span class="hidden sm:inline">{{ storeName }}</span>
        </NuxtLink>
      </template>

      <template #left>
        <div class="hidden lg:flex items-center gap-1">
          <UButton
            v-for="item in categoryItems.slice(0, 6)"
            :key="item.label"
            :to="item.to"
            variant="ghost"
            color="neutral"
            size="sm"
            :label="item.label"
          />
        </div>
      </template>

      <template #right>
        <div class="flex items-center gap-2">
          <!-- Search -->
          <div class="hidden sm:flex items-center gap-2">
            <UInput
              v-model="searchQuery"
              icon="i-lucide-search"
              placeholder="搜索商品..."
              size="sm"
              class="w-48 lg:w-64"
              @keyup.enter="handleSearch"
            />
          </div>

          <!-- Mobile search button -->
          <UButton
            icon="i-lucide-search"
            variant="ghost"
            color="neutral"
            square
            class="sm:hidden"
            @click="handleSearch"
          />

          <!-- Cart button -->
          <div class="relative">
            <UButton
              icon="i-lucide-shopping-cart"
              variant="ghost"
              color="neutral"
              square
              :badge="cartCount || undefined"
              @click="router.push(`/${slug}/cart`)"
            />
            <span v-if="cartCount > 0" class="absolute top-0 -right-0.5 min-w-3.5 h-3.5 rounded-full bg-(--ui-primary) text-white text-[10px] flex items-center justify-center leading-none px-0.5 font-bold">{{ cartCount }}</span>
          </div>
        </div>
      </template>
    </UHeader>

    <!-- Mobile category bar -->
    <div
      v-if="categoryItems.length"
      class="lg:hidden flex gap-2 overflow-x-auto px-4 py-2 border-b border-(--ui-border) no-scrollbar"
    >
      <UButton
        v-for="item in categoryItems"
        :key="item.label"
        :to="item.to"
        variant="outline"
        color="neutral"
        size="xs"
        :label="item.label"
        class="shrink-0 rounded-full"
      />
    </div>

    <!-- Main content -->
    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="border-t border-(--ui-border) py-8 mt-12">
      <UContainer>
        <div class="flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-(--ui-text-muted)">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-store" class="size-4" />
            <span>{{ storeName }}</span>
          </div>
          <div class="flex gap-6">
            <NuxtLink :to="`/${slug}`" class="hover:text-(--ui-text) transition">首页</NuxtLink>
            <button class="hover:text-(--ui-text) transition cursor-pointer" @click="router.push(`/${slug}`).then(scrollToTop)">全部商品</button>
          </div>
          <span>&copy; {{ new Date().getFullYear() }} {{ storeName }}</span>
        </div>
      </UContainer>
    </footer>
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
