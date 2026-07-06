/** One-liner access to the active tenant slug — used by every page/composable
 * that builds a tenant-scoped URL. Stops the 13+ `(auth.currentTenant.value as
 * any)?.slug || ''` repetitions dead. */
import { useAuth } from './useAuth'

export function useCurrentTenantSlug() {
  const auth = useAuth()
  return computed(() => auth.currentTenant.value?.slug ?? '')
}
