/** Shop API — calls Django REST backend via Nuxt BFF proxy (server/api/shop/[slug]/[...].ts).
 *  Customer auth uses Token header, not the admin JWT cookie.
 */

export function getDjangoBase() {
  return ''
}

/** Base URL for media files served by Django (images still load directly from Django, not BFF). */
export function getMediaBase() {
  return 'http://localhost:8000'
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

/** Fallback placeholder for products without images. */
export function productPlaceholder(name: string): string {
  return `https://placehold.co/400x400/eee/999?text=${encodeURIComponent(name.slice(0, 4))}`
}

export interface ProductParams {
  category?: string | number
  search?: string
  page?: number
  page_size?: number
}

export interface OrderItemData {
  sku: number
  product_name: string
  spec_name: string
  quantity: number
  price: number
  subtotal: number
}

export interface OrderData {
  total_amount: number
  discount_amount: number
  paid_amount: number
  payment_method: string
  member: number | null
  items: OrderItemData[]
}

export function useShopApi() {
  function buildUrl(slug: string, path: string) {
    return `/api/shop/${slug}${path}`
  }

  /** GET /{slug}/products/ */
  async function fetchProducts(slug: string, params?: ProductParams) {
    const url = buildUrl(slug, '/products/')
    return await $fetch<any>(url, { query: params as Record<string, any> })
  }

  /** GET /{slug}/products/{id}/ */
  async function fetchProduct(slug: string, id: string | number) {
    const url = buildUrl(slug, `/products/${id}/`)
    return await $fetch<any>(url)
  }

  /** GET /{slug}/categories/ */
  async function fetchCategories(slug: string) {
    const url = buildUrl(slug, '/categories/')
    return await $fetch<any>(url)
  }

  /** POST /{slug}/orders/ — optionally pass member token to link order to member */
  async function placeOrder(slug: string, orderData: OrderData, memberToken?: string) {
    const url = buildUrl(slug, '/orders/')
    const headers: Record<string, string> = {}
    if (memberToken) headers.Authorization = `Token ${memberToken}`
    return await $fetch<any>(url, { method: 'POST', body: orderData, headers })
  }

  /** GET /{slug}/orders/ — requires member token */
  async function fetchOrders(slug: string, memberToken: string) {
    const url = buildUrl(slug, '/orders/')
    return await $fetch<any>(url, { headers: { Authorization: `Token ${memberToken}` } })
  }

  /** POST /{slug}/members/login/ */
  async function memberLogin(slug: string, phone: string, password: string) {
    const url = buildUrl(slug, '/members/login/')
    return await $fetch<any>(url, { method: 'POST', body: { phone, password } })
  }

  /** GET /{slug}/members/profile/ */
  async function fetchMemberProfile(slug: string, token: string) {
    const url = buildUrl(slug, '/members/profile/')
    return await $fetch<any>(url, { headers: { Authorization: `Token ${token}` } })
  }

  return {
    fetchProducts,
    fetchProduct,
    fetchCategories,
    placeOrder,
    fetchOrders,
    memberLogin,
    fetchMemberProfile,
  }
}
