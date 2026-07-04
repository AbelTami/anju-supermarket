/** Real-time SSE connection for live order push notifications. */
import { createSharedComposable } from '@vueuse/core'
import { useAuth } from './useAuth'

export interface OrderEvent {
  id: number
  order_no: string
  total_amount: string
  paid_amount: string
  payment_method: string
  cashier_name: string
  paid_at: string
}

export const useRealtimeOrders = createSharedComposable(() => {
  const auth = useAuth()
  const latestOrder = ref<OrderEvent | null>(null)
  const recentOrders = ref<OrderEvent[]>([])
  const connected = ref(false)
  const unreadCount = ref(0)
  let eventSource: EventSource | null = null
  let reconnectTimer: ReturnType<typeof setTimeout> | null = null

  const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')

  function connect() {
    const slug = tenantSlug.value
    const token = (auth.accessToken as any)?.value
    if (!slug || !token) return
    if (eventSource) disconnect()

    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase || 'http://localhost:8000'
    const url = `${baseUrl}/api/${slug}/orders/stream/?token=${encodeURIComponent(token)}`
    eventSource = new EventSource(url)

    eventSource.onopen = () => {
      connected.value = true
    }

    eventSource.onmessage = (event) => {
      try {
        const payload = JSON.parse(event.data)
        if (payload.type === 'new_order') {
          const order = payload.data as OrderEvent
          latestOrder.value = order
          recentOrders.value = [order, ...recentOrders.value].slice(0, 20)
          if (!isSlideoverOpen()) unreadCount.value++
        }
      } catch { /* skip malformed events */ }
    }

    eventSource.onerror = () => {
      connected.value = false
      eventSource?.close()
      eventSource = null
      if (reconnectTimer) clearTimeout(reconnectTimer)
      reconnectTimer = setTimeout(() => {
        if (tenantSlug.value) connect()
      }, 5000)
    }
  }

  function disconnect() {
    eventSource?.close()
    eventSource = null
    connected.value = false
  }

  function markAllRead() {
    unreadCount.value = 0
  }

  // Cache useDashboard reference — only called once, not per-event
  const dashboard = useDashboard()
  function isSlideoverOpen(): boolean {
    try {
      return (dashboard.isNotificationsSlideoverOpen as any)?.value ?? false
    } catch { return false }
  }

  watch([tenantSlug, () => (auth.accessToken as any)?.value], ([slug, token]) => {
    if (slug && token) connect()
    else disconnect()
  }, { immediate: true })

  tryOnUnmounted(() => disconnect())

  return {
    latestOrder: readonly(latestOrder),
    recentOrders: readonly(recentOrders),
    connected: readonly(connected),
    unreadCount: readonly(unreadCount),
    connect,
    disconnect,
    markAllRead,
  }
})
