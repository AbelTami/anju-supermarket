<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const slug = computed(() => route.params.slug as string)

const cart = useState<any[]>('shop-cart', () => [])

const cartItems = computed(() => cart.value)

const totalAmount = computed(() =>
  cartItems.value.reduce((sum, item) => sum + (item.price || 0) * (item.quantity || 0), 0),
)

const itemCount = computed(() =>
  cartItems.value.reduce((sum, item) => sum + (item.quantity || 0), 0),
)

function formatPrice(price: number): string {
  return `¥${price.toFixed(2)}`
}

function incrementQty(item: any) {
  if (item.quantity < 99) {
    item.quantity++
  }
}

function decrementQty(item: any) {
  if (item.quantity > 1) {
    item.quantity--
  }
}

function removeItem(itemId: string) {
  const idx = cart.value.findIndex((i: any) => i.id === itemId)
  if (idx !== -1) {
    cart.value.splice(idx, 1)
  }
}

function goToProduct(item: any) {
  router.push(`/${slug.value}/product/${item.productId}`)
}
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto">
    <h1 class="text-2xl font-bold text-(--ui-text) mb-6">购物车</h1>

    <!-- Empty state -->
    <div
      v-if="cartItems.length === 0"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-shopping-cart" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-1">购物车是空的</p>
      <p class="text-sm text-(--ui-text-muted) mb-6">快去挑选心仪的商品吧</p>
      <UButton
        :to="`/${slug}`"
        variant="solid"
        label="开始购物"
        icon="i-lucide-shopping-bag"
      />
    </div>

    <!-- Cart items -->
    <div v-else class="space-y-4">
      <UCard v-for="item in cartItems" :key="item.id">
        <div class="flex gap-4">
          <!-- Image -->
          <button
            class="size-20 shrink-0 rounded-lg overflow-hidden bg-(--ui-bg-muted) cursor-pointer hover:opacity-80 transition"
            @click="goToProduct(item)"
          >
            <img
              v-if="item.image"
              :src="item.image"
              :alt="item.name"
              class="h-full w-full object-cover"
            />
            <UIcon
              v-else
              name="i-lucide-package"
              class="size-8 m-auto mt-6 text-(--ui-text-muted)"
            />
          </button>

          <!-- Info -->
          <div class="flex-1 min-w-0">
            <button
              class="text-left hover:text-(--ui-primary) transition block"
              @click="goToProduct(item)"
            >
              <p class="font-medium text-sm text-(--ui-text) line-clamp-2">{{ item.name }}</p>
            </button>
            <p
              v-if="item.specName"
              class="text-xs text-(--ui-text-muted) mt-0.5"
            >
              {{ item.specName }}
            </p>

            <div class="flex items-center justify-between mt-3">
              <!-- Quantity controls -->
              <div class="flex items-center border border-(--ui-border) rounded-lg">
                <UButton
                  icon="i-lucide-minus"
                  variant="ghost"
                  color="neutral"
                  square
                  size="xs"
                  :disabled="item.quantity <= 1"
                  @click="decrementQty(item)"
                />
                <span class="w-10 text-center text-sm font-medium tabular-nums">{{ item.quantity }}</span>
                <UButton
                  icon="i-lucide-plus"
                  variant="ghost"
                  color="neutral"
                  square
                  size="xs"
                  :disabled="item.quantity >= 99"
                  @click="incrementQty(item)"
                />
              </div>

              <div class="flex items-center gap-3">
                <span class="text-sm font-bold text-(--ui-primary) tabular-nums">
                  {{ formatPrice(item.price * item.quantity) }}
                </span>
                <UButton
                  icon="i-lucide-trash-2"
                  variant="ghost"
                  color="error"
                  square
                  size="xs"
                  @click="removeItem(item.id)"
                />
              </div>
            </div>
          </div>
        </div>
      </UCard>

      <!-- Cart summary -->
      <USeparator />

      <div class="bg-(--ui-bg-muted) rounded-xl p-4 space-y-2">
        <div class="flex justify-between text-sm">
          <span class="text-(--ui-text-muted)">共 {{ itemCount }} 件商品</span>
          <span class="text-(--ui-text-muted)">小计: {{ formatPrice(totalAmount) }}</span>
        </div>
        <div class="flex justify-between items-baseline">
          <span class="text-sm text-(--ui-text-muted)">合计</span>
          <span class="text-xl font-bold text-(--ui-primary) tabular-nums">
            {{ formatPrice(totalAmount) }}
          </span>
        </div>
      </div>

      <UButton
        block
        size="lg"
        icon="i-lucide-credit-card"
        @click="router.push(`/${slug}/checkout`)"
      >
        去结算
      </UButton>
    </div>
  </div>
</template>
