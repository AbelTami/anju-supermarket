<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const slug = computed(() => route.params.slug as string)
const { fetchOrders } = useShopApi()

// Auth check
const memberToken = useCookie('member-token')
const token = computed(() => memberToken.value || null)

onMounted(() => {
  if (!memberToken.value) {
    router.replace(`/${slug.value}/login`)
  }
})

const orders = ref<any[]>([])
const isLoading = ref(false)
const errorMessage = ref('')

const expandedOrders = ref<Set<number>>(new Set())

async function loadOrders() {
  if (!token.value) return

  isLoading.value = true
  errorMessage.value = ''
  try {
    const data = await fetchOrders(slug.value, token.value)
    if (Array.isArray(data)) {
      orders.value = data
    } else if ((data as any)?.results) {
      orders.value = (data as any).results
    } else {
      orders.value = []
    }
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || '加载订单失败'
  } finally {
    isLoading.value = false
  }
}

function toggleExpand(orderId: number) {
  const next = new Set(expandedOrders.value)
  if (next.has(orderId)) {
    next.delete(orderId)
  } else {
    next.add(orderId)
  }
  expandedOrders.value = next
}

function isExpanded(orderId: number): boolean {
  return expandedOrders.value.has(orderId)
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
}
function formatPriceRaw(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : n.toFixed(2)
}

function formatDate(dateStr: string): string {
  if (!dateStr) return ''
  try {
    const d = new Date(dateStr)
    return d.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    })
  } catch {
    return dateStr
  }
}

function statusLabel(status: string): string {
  const map: Record<string, string> = {
    pending: '待处理',
    confirmed: '已确认',
    preparing: '备货中',
    ready: '待取货',
    completed: '已完成',
    cancelled: '已取消',
  }
  return map[status] || status || '未知'
}

function statusColor(status: string): string {
  const map: Record<string, string> = {
    pending: 'warning',
    confirmed: 'info',
    preparing: 'info',
    ready: 'primary',
    completed: 'success',
    cancelled: 'neutral',
  }
  return map[status] || 'neutral'
}

// Load on mount if token is available
watchEffect(() => {
  if (token.value) {
    loadOrders()
  }
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto">
    <div class="flex items-center gap-3 mb-6">
      <UButton
        icon="i-lucide-arrow-left"
        variant="ghost"
        color="neutral"
        square
        @click="router.back()"
      />
      <h1 class="text-2xl font-bold text-(--ui-text)">我的订单</h1>
    </div>

    <!-- Auth redirect -->
    <div
      v-if="!token"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-log-in" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-4">请先登录查看订单</p>
      <UButton
        :to="`/${slug}/login`"
        label="去登录"
        icon="i-lucide-user"
      />
    </div>

    <!-- Loading -->
    <div v-else-if="isLoading" class="space-y-4">
      <div
        v-for="i in 3"
        :key="i"
        class="animate-pulse rounded-xl bg-(--ui-bg-muted) h-24"
      />
    </div>

    <!-- Error -->
    <div
      v-else-if="errorMessage"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-alert-circle" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-sm text-(--ui-text-muted) mb-4">{{ errorMessage }}</p>
      <UButton
        variant="outline"
        color="neutral"
        label="重试"
        @click="loadOrders"
      />
    </div>

    <!-- Empty state -->
    <div
      v-else-if="orders.length === 0"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-receipt" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-1">暂无订单</p>
      <p class="text-sm text-(--ui-text-muted) mb-6">您还没有下过订单</p>
      <UButton
        :to="`/${slug}`"
        label="去逛逛"
        icon="i-lucide-shopping-bag"
      />
    </div>

    <!-- Orders list -->
    <div v-else class="space-y-4">
      <UCard v-for="order in orders" :key="order.id">
        <!-- Order header -->
        <button
          class="w-full text-left flex items-center justify-between"
          @click="toggleExpand(order.id)"
        >
          <div class="flex items-center gap-3">
            <UIcon
              name="i-lucide-receipt-text"
              class="size-5 text-(--ui-text-muted)"
            />
            <div>
              <p class="text-sm font-medium text-(--ui-text)">
                订单 #{{ order.order_no || order.id }}
              </p>
              <p class="text-xs text-(--ui-text-muted)">{{ formatDate(order.paid_at) }}</p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <UBadge
              v-if="order.status"
              :color="statusColor(order.status)"
              variant="soft"
              size="sm"
            >
              {{ statusLabel(order.status) }}
            </UBadge>
            <span class="text-sm font-bold text-(--ui-primary) tabular-nums">
              {{ formatPrice(order.total_amount || 0) }}
            </span>
            <UIcon
              :name="isExpanded(order.id) ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="size-4 text-(--ui-text-muted) shrink-0"
            />
          </div>
        </button>

        <!-- Expandable items -->
        <div v-if="isExpanded(order.id)" class="mt-4 pt-4 border-t border-(--ui-border)">
          <!-- Order items -->
          <div class="space-y-3">
            <div
              v-for="item in (order.items || [])"
              :key="item.id"
              class="flex gap-3"
            >
              <div class="flex-1 min-w-0">
                <p class="text-sm text-(--ui-text) line-clamp-1">{{ item.product_name }}</p>
                <p v-if="item.spec_name" class="text-xs text-(--ui-text-muted)">
                  {{ item.spec_name }}
                </p>
                <div class="flex justify-between text-xs text-(--ui-text-muted) mt-1">
                  <span>数量 x{{ item.quantity }}</span>
                  <span class="tabular-nums">{{ formatPrice(item.price || 0) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </UCard>
    </div>
  </div>
</template>
