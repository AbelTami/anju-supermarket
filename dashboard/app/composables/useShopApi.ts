/** Shop API — calls Django REST backend via Nuxt BFF proxy (server/api/shop/[slug]/[...].ts).
 *  Customer auth uses Token header, not the admin JWT cookie.
 */
import type { PaginatedResponse, ProductInfo, CategoryInfo, OrderInfo, OrderData, OrderItemData } from '~/types'

/** Base URL for media files served by Django (images still load directly from Django, not BFF). */
export function getMediaBase() {
  const config = useRuntimeConfig()
  return config.public.apiBase || 'http://localhost:8000'
}

/**
 * Prepend the Django media base to a relative media path.
 * Returns null for empty/undefined input. Passes through absolute URLs unchanged.
 */
export function mediaUrl(path: string | null | undefined): string | null {
  if (!path) return null
  if (path.startsWith('http')) return path
  return `${getMediaBase()}${path}`
}

/** Fallback placeholder for products without images — stable per product name. */
export function productPlaceholder(name: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(name.replace(/\s+/g, '').slice(0, 30))}/400/400`
}

export interface ProductParams {
  category?: string | number
  search?: string
  page?: number
  page_size?: number
}

export type { OrderData, OrderItemData }

export function useShopApi() {
  function buildUrl(slug: string, path: string) {
    return `/api/shop/${slug}${path}`
  }

  /** GET /{slug}/products/ */
  async function fetchProducts(slug: string, params?: ProductParams) {
    const url = buildUrl(slug, '/products/')
    return await $fetch<PaginatedResponse<ProductInfo> | ProductInfo[]>(url, { query: params as Record<string, any> })
  }

  /** GET /{slug}/products/{id}/ */
  async function fetchProduct(slug: string, id: string | number) {
    const url = buildUrl(slug, `/products/${id}/`)
    return await $fetch<ProductInfo>(url)
  }

  /** GET /{slug}/categories/ */
  async function fetchCategories(slug: string) {
    const url = buildUrl(slug, '/categories/')
    return await $fetch<PaginatedResponse<CategoryInfo> | CategoryInfo[]>(url)
  }

  /** POST /{slug}/orders/ — optionally pass member token to link order to member */
  async function placeOrder(slug: string, orderData: OrderData, memberToken?: string) {
    const url = buildUrl(slug, '/orders/')
    const headers: Record<string, string> = {}
    if (memberToken) headers.Authorization = `Token ${memberToken}`
    return await $fetch<OrderInfo>(url, { method: 'POST', body: orderData, headers })
  }

  /** GET /{slug}/orders/ — requires member token */
  async function fetchOrders(slug: string, memberToken: string) {
    const url = buildUrl(slug, '/orders/')
    return await $fetch<PaginatedResponse<OrderInfo>>(url, { headers: { Authorization: `Token ${memberToken}` } })
  }

  /** POST /{slug}/members/login/ */
  async function memberLogin(slug: string, phone: string, password: string) {
    const url = buildUrl(slug, '/members/login/')
    return await $fetch<{ token: string, member: { id: number, name: string, phone: string } }>(url, { method: 'POST', body: { phone, password } })
  }

  /** GET /{slug}/members/profile/ */
  async function fetchMemberProfile(slug: string, token: string) {
    const url = buildUrl(slug, '/members/profile/')
    return await $fetch<{ id: number, name: string, phone: string, points: number, balance: string, total_spent: string }>(url, { headers: { Authorization: `Token ${token}` } })
  }

  return {
    fetchProducts,
    fetchProduct,
    fetchCategories,
    placeOrder,
    fetchOrders,
    memberLogin,
    fetchMemberProfile
  }
}
