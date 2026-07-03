<script setup lang="ts">
import { mediaUrl } from '~/composables/useShopApi'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const { onImgError } = useImageFallback()
const slug = computed(() => route.params.slug as string)

const cart = useState<any[]>('shop-cart', () => [])
const cartNote = ref('')

// Selection state
const selectedIds = ref<Set<string>>(new Set())
const selectAll = computed({
  get: () => cart.value.length > 0 && selectedIds.value.size === cart.value.length,
  set: (val: boolean) => {
    if (val) {
      selectedIds.value = new Set(cart.value.map((i: any) => i.id))
    } else {
      selectedIds.value = new Set()
    }
  }
})

const selectedItems = computed(() =>
  cart.value.filter((i: any) => selectedIds.value.has(i.id))
)

const totalAmount = computed(() =>
  selectedItems.value.reduce((sum, item: any) => sum + (item.price || 0) * (item.quantity || 0), 0)
)

const itemCount = computed(() =>
  selectedItems.value.reduce((sum, item: any) => sum + (item.quantity || 0), 0)
)

const totalCount = computed(() =>
  cart.value.reduce((sum: number, item: any) => sum + (item.quantity || 0), 0)
)

function formatPrice(price: number): string {
  return `¥${price.toFixed(2)}`
}

function toggleSelect(itemId: string) {
  const next = new Set(selectedIds.value)
  if (next.has(itemId)) {
    next.delete(itemId)
  } else {
    next.add(itemId)
  }
  selectedIds.value = next
}

function incrementQty(item: any) {
  if (item.quantity < 99) item.quantity++
}

function decrementQty(item: any) {
  if (item.quantity > 1) item.quantity--
}

function removeItem(itemId: string) {
  const idx = cart.value.findIndex((i: any) => i.id === itemId)
  if (idx !== -1) {
    cart.value.splice(idx, 1)
    const next = new Set(selectedIds.value)
    next.delete(itemId)
    selectedIds.value = next
  }
}

function removeSelected() {
  const idsToRemove = selectedIds.value
  cart.value = cart.value.filter((i: any) => !idsToRemove.has(i.id))
  selectedIds.value = new Set()
}

function goToProduct(item: any) {
  router.push(`/${slug.value}/product/${item.productId}`)
}

function goCheckout() {
  if (selectedItems.value.length === 0) return
  router.push(`/${slug.value}/checkout`)
}
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
      <div>
        <h1 class="text-2xl font-bold text-(--ui-text) tracking-tight">
          购物车
        </h1>
        <p v-if="cart.length" class="text-xs text-(--ui-text-muted) mt-0.5">
          {{ totalCount }} 件商品
        </p>
      </div>
    </div>

    <!-- Empty state -->
    <div
      v-if="cart.length === 0"
      class="flex flex-col items-center justify-center py-20"
    >
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-shopping-bag" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">
        购物车是空的
      </p>
      <p class="shop-empty-desc">
        快去挑选心仪的商品吧
      </p>
      <UButton
        :to="`/${slug}`"
        variant="soft"
        color="neutral"
        label="去逛逛"
        icon="i-lucide-shopping-bag"
      />
    </div>

    <!-- Cart items -->
    <div v-else class="space-y-3">
      <!-- Select all bar -->
      <div class="flex items-center justify-between px-1">
        <label class="flex items-center gap-2 cursor-pointer">
          <UCheckbox v-model="selectAll" />
          <span class="text-sm text-(--ui-text-muted)">全选</span>
        </label>
        <button
          v-if="selectedIds.size > 0"
          class="text-xs text-(--ui-error) hover:text-(--ui-error)/80 transition flex items-center gap-1"
          @click="removeSelected"
        >
          <UIcon name="i-lucide-trash-2" class="size-3.5" />
          删除所选 ({{ selectedIds.size }})
        </button>
      </div>

      <div
        v-for="item in cart"
        :key="item.id"
        class="shop-card-compact p-3 flex gap-3 shop-animate-in"
        :class="selectedIds.has(item.id) ? 'ring-1 ring-(--ui-primary)/30' : ''"
      >
        <!-- Checkbox -->
        <div class="flex items-center shrink-0">
          <UCheckbox
            :checked="selectedIds.has(item.id)"
            @change="toggleSelect(item.id)"
          />
        </div>

        <!-- Image -->
        <button
          class="size-20 shrink-0 rounded-xl overflow-hidden bg-(--ui-bg-muted) cursor-pointer hover:opacity-90 transition"
          @click="goToProduct(item)"
        >
          <img
            v-if="item.image"
            :src="item.image"
            :alt="item.name"
            class="h-full w-full object-cover"
            @error="onImgError($event, item.name)"
          >
          <div v-else class="h-full w-full flex items-center justify-center">
            <span class="text-2xl font-black text-(--ui-text-muted)/15">{{ item.name?.charAt(0) }}</span>
          </div>
        </button>

        <!-- Info -->
        <div class="flex-1 min-w-0 flex flex-col justify-between">
          <div class="flex items-start justify-between gap-1">
            <button
              class="text-left hover:text-(--ui-primary) transition block flex-1"
              @click="goToProduct(item)"
            >
              <p class="font-medium text-sm text-(--ui-text) line-clamp-2 leading-snug">
                {{ item.name }}
              </p>
            </button>
            <button
              class="size-7 flex items-center justify-center rounded-lg hover:bg-(--ui-error)/10 text-(--ui-text-muted) hover:text-(--ui-error) transition shrink-0 -mr-1 -mt-0.5"
              @click="removeItem(item.id)"
            >
              <UIcon name="i-lucide-x" class="size-3.5" />
            </button>
          </div>
          <p v-if="item.specName" class="text-xs text-(--ui-text-muted) mt-0.5">
            {{ item.specName }}
          </p>

          <div class="flex items-center justify-between mt-2">
            <!-- Quantity -->
            <div class="shop-qty">
              <button :disabled="item.quantity <= 1" @click="decrementQty(item)">
                <UIcon name="i-lucide-minus" class="size-3.5" />
              </button>
              <span class="text-sm w-8">{{ item.quantity }}</span>
              <button :disabled="item.quantity >= 99" @click="incrementQty(item)">
                <UIcon name="i-lucide-plus" class="size-3.5" />
              </button>
            </div>

            <div class="text-right">
              <span class="text-sm font-bold tabular-nums" :class="selectedIds.has(item.id) ? 'text-(--ui-primary)' : 'text-(--ui-text)'">
                {{ formatPrice(item.price * item.quantity) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Note -->
      <div class="flex items-center gap-2 px-1 pt-1">
        <UIcon name="i-lucide-edit" class="size-3.5 text-(--ui-text-muted)" />
        <input
          v-model="cartNote"
          placeholder="添加备注（选填）"
          class="flex-1 text-xs bg-transparent border-none outline-none text-(--ui-text-muted) placeholder:text-(--ui-text-muted)/40"
        >
      </div>

      <!-- Sticky bottom bar -->
      <div class="shop-sticky-bottom left-0 right-0 -mx-4 lg:-mx-6">
        <div class="max-w-3xl mx-auto">
          <div class="flex items-center justify-between gap-3">
            <label class="flex items-center gap-2 cursor-pointer shrink-0">
              <UCheckbox v-model="selectAll" />
              <span class="text-xs text-(--ui-text-muted)">全选</span>
            </label>

            <div class="flex items-center gap-3 flex-1 justify-end">
              <div class="text-right">
                <p class="text-xs text-(--ui-text-muted)">
                  合计
                  <span v-if="selectedIds.size < cart.length" class="text-(--ui-text-muted)/60">
                    (已选 {{ selectedIds.size }} 件)
                  </span>
                </p>
                <p class="text-xl font-bold tabular-nums tracking-tight" :class="selectedItems.length > 0 ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)'">
                  {{ formatPrice(totalAmount) }}
                </p>
              </div>
              <UButton
                :disabled="selectedItems.length === 0"
                size="lg"
                class="h-11 rounded-xl text-sm font-bold px-6"
                icon="i-lucide-credit-card"
                @click="goCheckout"
              >
                去结算
                <span v-if="selectedItems.length > 0">({{ itemCount }})</span>
              </UButton>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
