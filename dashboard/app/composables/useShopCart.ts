/** Shared shop cart — single source of truth for the customer-facing storefront.

Why this exists: cart state was duplicated across 5 pages with inconsistent
types (some `any[]`, some `CartItemState[]`) and every page mutated the array
in place. Centralizing here gives one typed API and forces immutable updates,
which keeps Vue's reactivity predictable.
*/
import { mediaUrl } from '~/composables/useShopApi'
import type { ProductInfo } from '~/types'

export interface CartItem {
  id: string
  productId: number
  skuId: number | null
  name: string
  specName: string
  price: number
  originalPrice: number
  quantity: number
  image?: string
  categoryId?: number
  stockQuantity: number
  unitName: string
}

function newId(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID()
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`
}

function imageOf(product: ProductInfo): string | undefined {
  return product.image_url || mediaUrl(product.image) || undefined
}

/** Extract a numeric category id from the polymorphic ProductInfo.category field. */
function categoryIdOf(product: ProductInfo): number | undefined {
  const c = product.category
  if (typeof c === 'number') return c
  if (c && typeof c === 'object' && typeof c.id === 'number') return c.id
  return undefined
}

export function useShopCart() {
  const items = useState<CartItem[]>('shop-cart', () => [])

  const count = computed(() => items.value.reduce((sum, i) => sum + i.quantity, 0))

  function add(product: ProductInfo, specName = '', skuStock = 999, skuSellingPrice?: string): void {
    const existing = items.value.find(i => i.productId === product.id && i.specName === specName)
    const price = Number(skuSellingPrice ?? product.price ?? 0)
    const stock = skuStock !== 999 ? skuStock : 999
    if (existing) {
      items.value = items.value.map(i =>
        i === existing ? { ...i, quantity: i.quantity + 1, stockQuantity: stock, price } : i,
      )
    } else {
      items.value = [
        ...items.value,
        {
          id: newId(),
          productId: product.id,
          skuId: null,
          name: product.name,
          specName,
          price,
          originalPrice: Number(product.original_price ?? 0),
          quantity: 1,
          image: imageOf(product),
          categoryId: categoryIdOf(product),
          stockQuantity: stock,
          unitName: product.unit || '',
        },
      ]
    }
  }

  function setQuantity(id: string, quantity: number): void {
    const q = Math.max(0, Math.min(99, Math.floor(quantity)))
    if (q <= 0) {
      items.value = items.value.filter(i => i.id !== id)
      return
    }
    items.value = items.value.map(i => (i.id === id ? { ...i, quantity: q } : i))
  }

  function increment(id: string): void {
    const item = items.value.find(i => i.id === id)
    if (item && item.quantity < 99) setQuantity(id, item.quantity + 1)
  }

  function decrement(id: string): void {
    const item = items.value.find(i => i.id === id)
    if (item && item.quantity > 1) setQuantity(id, item.quantity - 1)
  }

  function remove(id: string): void {
    items.value = items.value.filter(i => i.id !== id)
  }

  function removeAll(ids: Iterable<string>): void {
    const set = new Set(ids)
    items.value = items.value.filter(i => !set.has(i.id))
  }

  function clear(): void {
    items.value = []
  }

  return {
    items: readonly(items),
    count,
    add,
    setQuantity,
    increment,
    decrement,
    remove,
    removeAll,
    clear,
  }
}
