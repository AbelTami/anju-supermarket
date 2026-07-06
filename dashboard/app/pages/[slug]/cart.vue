<script setup lang="ts">
import type { ProductInfo, PaginatedResponse } from '~/types'
import { useShopCart } from '~/composables/useShopCart'
import { formatPrice } from '~/utils/format'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const { onImgError } = useImageFallback()
const slug = computed(() => route.params.slug as string)

const {
  items: cart, count: totalCount,
  increment, decrement, remove, removeAll,
} = useShopCart()
const cartNote = ref('')

// ── Selection (array for reliable v-model with UCheckbox) ─────────
const selectedIds = ref<string[]>([])
const selectAllModel = computed({
  get: () => cart.value.length > 0 && selectedIds.value.length === cart.value.length,
  set: (val: boolean) => {
    selectedIds.value = val ? cart.value.map(i => i.id) : []
  },
})
const hasSelection = computed(() => selectedIds.value.length > 0)
const selectedItems = computed(() => cart.value.filter(i => selectedIds.value.includes(i.id)))
const totalAmount = computed(() => selectedItems.value.reduce((s, i) => s + i.price * i.quantity, 0))
const itemCount = computed(() => selectedItems.value.reduce((s, i) => s + i.quantity, 0))

function itemChecked(id: string): boolean {
  return selectedIds.value.includes(id)
}
function setItemChecked(id: string, checked: boolean) {
  selectedIds.value = checked
    ? [...selectedIds.value, id]
    : selectedIds.value.filter(i => i !== id)
}

function removeItem(id: string): void {
  remove(id)
  selectedIds.value = selectedIds.value.filter(i => i !== id)
}
function removeSelected(): void {
  removeAll(selectedIds.value)
  selectedIds.value = []
}

// ── Swipe-to-delete ────────────────────────────────────────────────
const swipedId = ref<string | null>(null)
let touchStartX = 0
function onTouchStart(id: string, e: TouchEvent) {
  touchStartX = e.touches[0].clientX
  if (swipedId.value && swipedId.value !== id) swipedId.value = null
}
function onTouchMove(id: string, e: TouchEvent) {
  const dx = e.touches[0].clientX - touchStartX
  if (dx < -50) swipedId.value = id
  else if (dx > 50) swipedId.value = null
}

// ── Navigation ─────────────────────────────────────────────────────
function goToProduct(item: { productId: number }): void {
  router.push(`/${slug.value}/product/${item.productId}`)
}
function goCheckout(): void {
  if (!hasSelection.value) return
  router.push(`/${slug.value}/checkout`)
}

// ── Recommendations ────────────────────────────────────────────────
const recCatIds = computed(() => {
  const ids = new Set(cart.value.map(i => i.categoryId).filter(Boolean) as number[])
  return [...ids].slice(0, 3)
})
// Fetch all products; sort by category match relevance client-side
const { data: recData } = useFetch<PaginatedResponse<ProductInfo>>(
  () => `/api/shop/${slug.value}/products?page_size=50`,
  { lazy: true, server: false },
)
const recommendations = computed(() => {
  const results = (recData.value as any)?.results as ProductInfo[] | undefined
  if (!results || results.length === 0) return []
  const cartIds = new Set(cart.value.map(i => i.productId))
  const catSet = new Set(recCatIds.value)
  return results
    .filter(p => !cartIds.has(p.id))
    .map(p => {
      const cid = typeof p.category === 'object' ? (p.category as any)?.id : p.category
      return { ...p, _score: catSet.has(cid as number) ? 1 : 0 }
    })
    .sort((a, b) => (b as any)._score - (a as any)._score)
    .slice(0, 8)
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto pb-32 lg:pb-6">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button
        class="size-9 flex items-center justify-center rounded-lg hover:bg-(--ui-bg-muted) transition"
        @click="router.back()"
      >
        <UIcon name="i-lucide-arrow-left" class="size-5 text-(--ui-text-muted)" />
      </button>
      <div class="flex-1">
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">购物车</h1>
        <p v-if="cart.length" class="text-xs text-(--ui-text-muted) mt-0.5">共 {{ totalCount }} 件</p>
      </div>
      <UButton
        v-if="hasSelection"
        size="xs"
        variant="ghost"
        color="error"
        icon="i-lucide-trash-2"
        @click="removeSelected"
      >
        删除 ({{ selectedIds.length }})
      </UButton>
    </div>

    <!-- Empty -->
    <div v-if="cart.length === 0" class="flex flex-col items-center justify-center py-24">
      <div class="flex size-20 items-center justify-center rounded-2xl bg-(--ui-bg-elevated) mb-5">
        <UIcon name="i-lucide-shopping-cart" class="size-10 text-(--ui-text-muted)/25" />
      </div>
      <p class="text-base font-semibold text-(--ui-text-muted)">购物车是空的</p>
      <p class="text-sm text-(--ui-text-muted)/50 mt-1 mb-6">快去挑选心仪的商品吧</p>
      <UButton :to="`/${slug}`" color="neutral" icon="i-lucide-shopping-bag">去逛逛</UButton>
    </div>

    <!-- Cart items -->
    <div v-else class="space-y-3">
      <!-- Select all -->
      <div class="flex items-center px-1">
        <UCheckbox v-model="selectAllModel">
          <template #label>
            <span class="text-sm text-(--ui-text-muted)">全选</span>
          </template>
        </UCheckbox>
      </div>

      <!-- Items -->
      <TransitionGroup name="cart-item" tag="div" class="space-y-3">
        <div
          v-for="item in cart"
          :key="item.id"
          class="shop-card-compact relative overflow-hidden"
          :class="[
            selectedIds.includes(item.id) ? 'ring-1 ring-(--ui-primary)/30 bg-(--ui-primary)/[0.02]' : '',
            swipedId === item.id ? '-translate-x-20' : 'translate-x-0',
          ]"
          style="transition: transform 0.2s ease"
          @touchstart.passive="onTouchStart(item.id, $event)"
          @touchmove.passive="onTouchMove(item.id, $event)"
        >
          <!-- Swipe delete button -->
          <button
            class="absolute top-0 right-0 bottom-0 w-20 flex items-center justify-center bg-(--ui-error) text-white text-xs font-bold"
            @click="removeItem(item.id)"
          >
            <UIcon name="i-lucide-trash-2" class="size-5" />
          </button>

          <div class="relative p-3 flex gap-3 bg-white dark:bg-zinc-900">
            <!-- Checkbox -->
            <div class="flex items-center shrink-0">
              <UCheckbox
                :model-value="selectedIds.includes(item.id)"
                @update:model-value="(v: boolean) => setItemChecked(item.id, v)"
              />
            </div>

            <!-- Image -->
            <button
              class="relative size-20 shrink-0 rounded-xl overflow-hidden bg-(--ui-bg-elevated) cursor-pointer group"
              @click="goToProduct(item)"
            >
              <img
                v-if="item.image"
                :src="item.image"
                :alt="item.name"
                class="h-full w-full object-cover transition duration-300 group-hover:scale-105"
                @error="onImgError($event, item.name)"
              >
              <div v-else class="h-full w-full flex items-center justify-center bg-(--ui-bg-elevated)">
                <span class="text-xl font-bold text-(--ui-text-muted)/15">{{ item.name?.charAt(0) }}</span>
              </div>
            </button>

            <!-- Info -->
            <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
              <div class="flex items-start justify-between gap-2">
                <button
                  class="text-left hover:text-(--ui-primary) transition-colors min-w-0 flex-1"
                  @click="goToProduct(item)"
                >
                  <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug">{{ item.name }}</p>
                  <p v-if="item.specName" class="text-xs text-(--ui-text-muted) mt-0.5">{{ item.specName }}</p>
                </button>
                <button
                  class="hidden sm:flex size-7 shrink-0 items-center justify-center rounded-lg text-(--ui-text-muted)/40 hover:text-(--ui-error) hover:bg-(--ui-error)/10 transition -mr-1"
                  @click="removeItem(item.id)"
                  aria-label="删除"
                >
                  <UIcon name="i-lucide-x" class="size-4" />
                </button>
              </div>

              <!-- Price + qty -->
              <div class="flex items-end justify-between mt-1.5">
                <div class="min-w-0">
                  <span
                    class="text-sm font-bold tabular-nums"
                    :class="selectedIds.includes(item.id) ? 'text-(--ui-primary)' : 'text-(--ui-text)'"
                  >
                    {{ formatPrice(item.price * item.quantity) }}
                  </span>
                  <span
                    v-if="item.originalPrice && item.originalPrice > item.price"
                    class="ml-1.5 text-xs text-(--ui-text-muted)/50 line-through tabular-nums"
                  >
                    ¥{{ item.originalPrice.toFixed(2) }}
                  </span>
                  <span
                    v-if="item.unitName"
                    class="ml-1 text-xs text-(--ui-text-muted)/50"
                  >
                    /{{ item.unitName }}
                  </span>
                  <span
                    v-if="item.stockQuantity > 0 && item.stockQuantity <= 5"
                    class="ml-1.5 inline-flex items-center gap-0.5 text-[10px] font-medium text-amber-500"
                  >
                    <UIcon name="i-lucide-alert-triangle" class="size-2.5" />
                    仅剩 {{ item.stockQuantity }} 件
                  </span>
                </div>

                <!-- Qty -->
                <div class="flex items-center rounded-lg bg-(--ui-bg-elevated) border border-(--ui-border)/50 shrink-0">
                  <button
                    class="flex size-7 items-center justify-center rounded-l-lg text-(--ui-text-muted) hover:text-(--ui-text) hover:bg-(--ui-bg-accented) transition disabled:opacity-25 disabled:cursor-not-allowed"
                    :disabled="item.quantity <= 1"
                    @click="decrement(item.id)"
                  >
                    <UIcon name="i-lucide-minus" class="size-3" />
                  </button>
                  <span class="w-8 text-center text-xs font-medium tabular-nums text-(--ui-text)">{{ item.quantity }}</span>
                  <button
                    class="flex size-7 items-center justify-center rounded-r-lg text-(--ui-text-muted) hover:text-(--ui-text) hover:bg-(--ui-bg-accented) transition disabled:opacity-25 disabled:cursor-not-allowed"
                    :disabled="item.quantity >= 99"
                    @click="increment(item.id)"
                  >
                    <UIcon name="i-lucide-plus" class="size-3" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </TransitionGroup>

      <!-- Note -->
      <div class="px-1 pt-2">
        <UInput
          v-model="cartNote"
          icon="i-lucide-pencil-line"
          placeholder="添加备注（选填）…"
          size="sm"
          color="neutral"
          variant="none"
          class="w-full text-xs"
        />
      </div>

      <!-- Recommendations (full-width breakout for proper horizontal scroll) -->
      <div v-if="recommendations.length > 0" class="pt-4">
        <div class="flex items-center gap-2 mb-3 px-1 max-w-3xl mx-auto">
          <UIcon name="i-lucide-sparkles" class="size-4 text-(--ui-primary)" />
          <span class="text-sm font-semibold text-(--ui-text)">为你推荐</span>
          <span class="text-xs text-(--ui-text-muted)">← 滑动查看更多 →</span>
        </div>
        <div class="w-full overflow-x-auto pb-2 snap-x snap-mandatory">
          <div class="flex gap-3 px-4 lg:px-6 w-max">
            <button
            v-for="rec in recommendations"
            :key="rec.id"
            class="shop-card shrink-0 w-32 cursor-pointer text-left overflow-hidden group snap-start"
            @click="router.push(`/${slug}/product/${rec.id}`)"
          >
            <div class="aspect-square overflow-hidden bg-(--ui-bg-elevated)">
              <img
                v-if="rec.image_url || rec.image"
                :src="rec.image_url || rec.image"
                :alt="rec.name"
                class="h-full w-full object-cover transition duration-300 group-hover:scale-105"
                @error="onImgError($event, rec.name)"
              >
              <div v-else class="h-full w-full flex items-center justify-center">
                <span class="text-2xl font-bold text-(--ui-text-muted)/15">{{ rec.name?.charAt(0) }}</span>
              </div>
            </div>
            <div class="p-2.5">
              <p class="text-xs text-(--ui-text) line-clamp-2 leading-snug">{{ rec.name }}</p>
              <p class="mt-1 text-sm font-bold text-(--ui-primary) tabular-nums">¥{{ Number(rec.price || 0).toFixed(2) }}</p>
              <p v-if="rec.original_price && Number(rec.original_price) > Number(rec.price || 0)" class="text-[10px] text-(--ui-text-muted)/50 line-through">¥{{ Number(rec.original_price).toFixed(2) }}</p>
            </div>
          </button>
        </div>
      </div>
      </div>

      <!-- Bottom bar -->
      <div class="shop-sticky-bottom left-0 right-0 -mx-4 lg:-mx-6">
        <div class="max-w-3xl mx-auto flex items-center gap-3">
          <UCheckbox v-model="selectAllModel">
            <template #label>
              <span class="text-xs text-(--ui-text-muted)">全选</span>
            </template>
          </UCheckbox>

          <div class="flex-1 text-right min-w-0">
            <p class="text-xs text-(--ui-text-muted) truncate">
              合计
              <span v-if="hasSelection && selectedIds.length < cart.length">· 已选 {{ itemCount }} 件</span>
            </p>
            <p
              class="text-xl font-bold tabular-nums tracking-tight"
              :class="hasSelection ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)/60'"
            >
              {{ formatPrice(totalAmount) }}
            </p>
          </div>

          <UButton
            :disabled="!hasSelection"
            size="lg"
            class="h-12 rounded-xl text-sm font-bold px-6 shrink-0"
            @click="goCheckout"
          >
            去结算
            <span v-if="hasSelection" class="ml-1 opacity-80">({{ itemCount }})</span>
          </UButton>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.cart-item-enter-active { transition: opacity 0.25s ease-out, transform 0.25s ease-out; }
.cart-item-leave-active { transition: opacity 0.15s ease-in, transform 0.15s ease-in; }
.cart-item-enter-from { opacity: 0; transform: translateY(12px); }
.cart-item-leave-to { opacity: 0; transform: translateX(-12px); }
</style>
