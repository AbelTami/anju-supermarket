/** Real-time SSE connection for live order push notifications.

Routes through the BFF at `/api/tenant/{slug}/orders/stream` so the JWT
stays in the httpOnly cookie — never in the URL or client memory.
*/
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
  let reconnectAttempt = 0

  const tenantSlug = computed(() => auth.currentTenant.value?.slug ?? '')

  function connect() {
    if (!import.meta.client) return
    const slug = tenantSlug.value
    if (!slug || !auth.user.value) return
    if (eventSource) disconnect()

    // BFF endpoint reads the httpOnly cookie server-side.
    const url = `/api/tenant/${slug}/orders/stream`
    eventSource = new EventSource(url)

    eventSource.onopen = () => {
      connected.value = true
      reconnectAttempt = 0
    }

    eventSource.onmessage = (event) => {
      try {
        const payload = JSON.parse(event.data) as { type: string, data: unknown }
        if (payload.type === 'new_order') {
          const order = payload.data as OrderEvent
          latestOrder.value = order
          recentOrders.value = [order, ...recentOrders.value].slice(0, 20)
          // Don't bump the bell count if the slideover is open — user is looking.
          if (!isSlideoverOpen()) unreadCount.value++
        }
      } catch { /* skip malformed events */ }
    }

    eventSource.onerror = () => {
      connected.value = false
      eventSource?.close()
      eventSource = null
      if (reconnectTimer) clearTimeout(reconnectTimer)
      // Exponential backoff capped at 60s — protects backend during outages.
      const delay = Math.min(1000 * 2 ** reconnectAttempt, 60_000)
      reconnectAttempt += 1
      reconnectTimer = setTimeout(() => {
        if (tenantSlug.value) connect()
      }, delay)
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

  const dashboard = useDashboard()
  function isSlideoverOpen(): boolean {
    try {
      return (dashboard.isNotificationsSlideoverOpen as any)?.value ?? false
    } catch { return false }
  }

  watch(tenantSlug, (slug) => {
    if (slug) connect()
    else disconnect()
  }, { immediate: true })

  // NOTE: no tryOnUnmounted here. createSharedComposable binds lifecycle to
  // the FIRST caller — if that's a page (not the layout), navigating away
  // would disconnect SSE for everyone. The watch above already handles
  // cleanup: empty slug (logout / no tenant) → disconnect.

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
