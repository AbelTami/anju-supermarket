<script setup lang="ts">
import type { PaginatedResponse, OrderInfo } from '~/types'

definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
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

const orders = ref<OrderInfo[]>([])
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
      orders.value = data as OrderInfo[]
    } else {
      orders.value = (data as PaginatedResponse<OrderInfo>).results || []
    }
  } catch (err: unknown) {
    const apiErr = err as { data?: { detail?: string }, message?: string }
    errorMessage.value = apiErr?.data?.detail || '加载订单失败'
  } finally {
    isLoading.value = false
  }
}

function toggleExpand(orderId: number) {
  const next = new Set(expandedOrders.value)
  if (next.has(orderId)) next.delete(orderId)
  else next.add(orderId)
  expandedOrders.value = next
}

function isExpanded(orderId: number): boolean {
  return expandedOrders.value.has(orderId)
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `¥${n.toFixed(2)}`
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
      minute: '2-digit'
    })
  } catch {
    return dateStr
  }
}

const statusConfig: Record<string, { label: string, color: string, icon: string }> = {
  pending: { label: '待处理', color: 'warning', icon: 'i-lucide-clock' },
  confirmed: { label: '已确认', color: 'info', icon: 'i-lucide-check-circle' },
  preparing: { label: '备货中', color: 'info', icon: 'i-lucide-package' },
  ready: { label: '待取货', color: 'primary', icon: 'i-lucide-shopping-bag' },
  completed: { label: '已完成', color: 'success', icon: 'i-lucide-check-circle' },
  cancelled: { label: '已取消', color: 'neutral', icon: 'i-lucide-x-circle' }
}

function statusLabel(status: string): string {
  return statusConfig[status]?.label || status || '未知'
}

function statusColor(status: string): string {
  return statusConfig[status]?.color || 'neutral'
}

function statusIcon(status: string): string {
  return statusConfig[status]?.icon || 'i-lucide-circle'
}

// Cancel order
const cancellingOrderId = ref<number | null>(null)

async function cancelOrder(orderId: number) {
  cancellingOrderId.value = orderId
  try {
    await $fetch(`/api/shop/${slug.value}/orders/${orderId}/cancel/`, {
      method: 'POST',
      headers: token.value ? { Authorization: `Token ${token.value}` } : {},
    })
    const order = orders.value.find(o => o.id === orderId)
    if (order) order.status = 'cancelled'
    toast.add({ title: '订单已取消', color: 'success', duration: 2000, ui: { container: 'shop-toast' } })
  } catch (err: any) {
    toast.add({ title: err?.data?.detail || '取消失败', color: 'error', duration: 2000, ui: { container: 'shop-toast' } })
  } finally {
    cancellingOrderId.value = null
  }
}

// Load on mount
watchEffect(() => {
  if (token.value) loadOrders()
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-3xl mx-auto shop-animate-in pb-24 lg:pb-6">
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
          我的订单
        </h1>
        <p class="text-xs text-(--ui-text-muted) mt-0.5">
          查看和管理您的订单
        </p>
      </div>
    </div>

    <!-- Auth redirect -->
    <div v-if="!token" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-log-in" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">
        请先登录查看订单
      </p>
      <p class="shop-empty-desc">
        登录后可查看您的所有订单
      </p>
      <UButton
        :to="`/${slug}/login`"
        label="去登录"
        icon="i-lucide-user"
        variant="soft"
      />
    </div>

    <!-- Loading -->
    <div v-else-if="isLoading" class="space-y-3">
      <div v-for="i in 3" :key="i" class="shop-skeleton h-28 rounded-xl" />
    </div>

    <!-- Error -->
    <div v-else-if="errorMessage" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-alert-circle" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-desc">
        {{ errorMessage }}
      </p>
      <UButton
        variant="soft"
        color="neutral"
        label="重试"
        size="sm"
        @click="loadOrders"
      />
    </div>

    <!-- Empty state -->
    <div v-else-if="orders.length === 0" class="flex flex-col items-center justify-center py-20">
      <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center mb-4">
        <UIcon name="i-lucide-receipt" class="shop-empty-icon" />
      </div>
      <p class="shop-empty-text">
        暂无订单
      </p>
      <p class="shop-empty-desc">
        您还没有下过订单
      </p>
      <UButton
        :to="`/${slug}`"
        label="去逛逛"
        icon="i-lucide-shopping-bag"
        variant="soft"
      />
    </div>

    <!-- Orders list -->
    <div v-else class="space-y-3">
      <div
        v-for="order in orders"
        :key="order.id"
        class="shop-card overflow-hidden"
      >
        <!-- Order header -->
        <button
          class="w-full text-left p-4 flex items-center justify-between hover:bg-(--ui-bg-muted)/30 transition"
          @click="toggleExpand(order.id)"
        >
          <div class="flex items-center gap-3">
            <div
              class="size-10 rounded-xl flex items-center justify-center"
              :class="`bg-(${statusColor(order.status)})/10`"
            >
              <UIcon :name="statusIcon(order.status)" class="size-5" :class="`text-(${statusColor(order.status)})`" />
            </div>
            <div>
              <p class="font-medium text-sm text-(--ui-text)">
                {{ formatDate(order.paid_at) }}
              </p>
              <p class="text-xs text-(--ui-text-muted) mt-0.5">
                #{{ String(order.order_no || order.id) }}
              </p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <UBadge :color="statusColor(order.status) as any" variant="soft" size="sm">
              {{ statusLabel(order.status) }}
            </UBadge>
            <div class="text-right">
              <p class="text-sm font-bold text-(--ui-text) tabular-nums">
                {{ formatPrice(order.paid_amount) }}
              </p>
              <p v-if="order.items_count" class="text-[10px] text-(--ui-text-muted)">
                {{ order.items_count }} 件
              </p>
            </div>
            <UIcon
              :name="isExpanded(order.id) ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
              class="size-4 text-(--ui-text-muted) transition-transform"
            />
          </div>
        </button>

        <!-- Expanded details -->
        <div
          v-if="isExpanded(order.id)"
          class="border-t border-(--ui-border)/50 px-4 py-3 space-y-2 text-xs text-(--ui-text-muted) shop-animate-scale"
        >
          <div class="flex justify-between">
            <span>订单编号</span>
            <span class="text-(--ui-text) font-mono">{{ order.order_no || `#${order.id}` }}</span>
          </div>
          <div class="flex justify-between">
            <span>下单时间</span>
            <span class="text-(--ui-text)">{{ formatDate(order.paid_at) }}</span>
          </div>
          <div class="flex justify-between">
            <span>支付方式</span>
            <span class="text-(--ui-text)">{{ order.payment_method || '到店支付' }}</span>
          </div>
          <div v-if="order.cashier_name" class="flex justify-between">
            <span>收银员</span>
            <span class="text-(--ui-text)">{{ order.cashier_name }}</span>
          </div>
          <div v-if="Number(order.discount_amount) > 0" class="flex justify-between text-(--ui-success)">
            <span>优惠</span>
            <span class="tabular-nums">-{{ formatPrice(order.discount_amount) }}</span>
          </div>
          <div class="border-t border-(--ui-border)/50 pt-2 flex justify-between font-medium">
            <span>实付金额</span>
            <span class="text-(--ui-text) tabular-nums">{{ formatPrice(order.paid_amount) }}</span>
          </div>
          <!-- Cancel button — only for cancellable statuses -->
          <div v-if="order.status === 'pending'" class="pt-3 flex justify-end">
            <UButton
              size="sm"
              color="error"
              variant="soft"
              :loading="cancellingOrderId === order.id"
              :disabled="cancellingOrderId !== null"
              @click="cancelOrder(order.id)"
            >
              <UIcon name="i-lucide-x-circle" class="size-3.5" />
              取消订单
            </UButton>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
