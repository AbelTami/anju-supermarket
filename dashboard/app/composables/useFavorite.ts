/** Product wishlist — persisted in localStorage via useLocalStorage */
import type { ProductInfo } from '~/types'

const FAVORITE_STORAGE_KEY = 'shop-favorites'

export function useFavorite() {
  const favoriteIds = useLocalStorage<number[]>(FAVORITE_STORAGE_KEY, [])

  function isFavorited(productId: number): boolean {
    return favoriteIds.value.includes(productId)
  }

  function toggle(productId: number) {
    const idx = favoriteIds.value.indexOf(productId)
    if (idx >= 0) {
      favoriteIds.value.splice(idx, 1)
    } else {
      // Limit to prevent localStorage bloat
      if (favoriteIds.value.length >= 200) {
        favoriteIds.value.shift()
      }
      favoriteIds.value.push(productId)
    }
  }

  function add(productId: number) {
    if (!favoriteIds.value.includes(productId)) {
      favoriteIds.value.push(productId)
    }
  }

  function remove(productId: number) {
    const idx = favoriteIds.value.indexOf(productId)
    if (idx >= 0) {
      favoriteIds.value.splice(idx, 1)
    }
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
