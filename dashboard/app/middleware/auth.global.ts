/** Global auth guard — protects admin routes, leaves public routes alone. */
export default defineNuxtRouteMiddleware(async (to) => {
  // Only protect /admin/* routes
  if (!to.path.startsWith('/admin')) return

  // Allow auth pages within admin
  if (to.path.startsWith('/admin/auth/')) return

  const auth = useAuth()
  // Skip profile fetch if already authenticated (e.g. just logged in)
  if (auth.user.value) return
  try {
    await auth.fetchProfile()
    if (!auth.user.value) throw new Error('Not authenticated')
  } catch (err: any) {
    // Only redirect to login on auth errors (401/403), not on network errors
    if (err?.statusCode === 401 || err?.statusCode === 403 || err?.response?.status === 401 || err?.response?.status === 403) {
      return navigateTo('/admin/auth/login')
    }
    return
  }
})
