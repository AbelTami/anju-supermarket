/** Product wishlist — persisted in cookie via useCookie (SSR-safe) */
import type { ProductInfo } from '~~/app/types'

const FAVORITE_STORAGE_KEY = 'shop-favorites'
const MAX_AGE_DAYS = 365

export function useFavorite() {
  const favoriteIds = useCookie<number[]>(FAVORITE_STORAGE_KEY, {
    default: () => [],
    maxAge: MAX_AGE_DAYS * 24 * 60 * 60,
    sameSite: 'lax',
  })

  function isFavorited(productId: number): boolean {
    return favoriteIds.value.includes(productId)
  }

  function toggle(productId: number) {
    // ponytail: replace entire array to trigger reactivity for watchers
    if (favoriteIds.value.includes(productId)) {
      favoriteIds.value = favoriteIds.value.filter(id => id !== productId)
    } else {
      if (favoriteIds.value.length >= 200) {
        favoriteIds.value = [...favoriteIds.value.slice(1), productId]
      } else {
        favoriteIds.value = [...favoriteIds.value, productId]
      }
    }
  }

  function add(productId: number) {
    if (!favoriteIds.value.includes(productId)) {
      if (favoriteIds.value.length >= 200) {
        favoriteIds.value = [...favoriteIds.value.slice(1), productId]
      } else {
        favoriteIds.value = [...favoriteIds.value, productId]
      }
    }
  }

  function remove(productId: number) {
    favoriteIds.value = favoriteIds.value.filter(id => id !== productId)
  }

  function clear() {
    favoriteIds.value = []
  }

  const count = computed(() => favoriteIds.value.length)

  return {
    favoriteIds,
    isFavorited,
    toggle,
    add,
    remove,
    clear,
    count,
  }
}
