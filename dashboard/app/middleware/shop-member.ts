/** Route middleware: shop pages that require a logged-in member.

 * Usage: `definePageMeta({ middleware: ['shop-member'] })`.
 * Replaces the per-page `onMounted(() => if (!token) router.replace('/login'))`
 * pattern duplicated across orders/analytics/favorites/member.
 */
export default defineNuxtRouteMiddleware((to) => {
  const memberAuth = useMemberAuth()
  const slug = to.params.slug
  if (memberAuth.token.value) return
  return navigateTo(`/${slug}/login`)
})
