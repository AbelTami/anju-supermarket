/** Handle image load errors — swap broken src with a fallback placeholder. */
import { productPlaceholder } from '~/composables/useShopApi'

export function useImageFallback() {
  function onImgError(event: Event, productName?: string) {
    const img = event.target as HTMLImageElement
    if (!img || img.dataset?.fallbackAttempted) return
    img.dataset.fallbackAttempted = 'true'
    img.src = productPlaceholder(productName || '商品')
    img.classList.add('opacity-80')
  }

  function imgSrc(src: string | null | undefined, name: string): string {
    return src || productPlaceholder(name)
  }

  return { onImgError, imgSrc }
}
