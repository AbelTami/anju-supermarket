/** Product wishlist — persisted in localStorage via useLocalStorage */
import type { ProductInfo } from '~~/app/types'

const FAVORITE_STORAGE_KEY = 'shop-favorites'

export function useFavorite() {
  const favoriteIds = useLocalStorage<number[]>(FAVORITE_STORAGE_KEY, [])

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
