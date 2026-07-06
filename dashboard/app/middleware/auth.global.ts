/** Global auth guard — protects admin routes, leaves public routes alone. */
export default defineNuxtRouteMiddleware(async (to) => {
  // Only protect /admin/* routes
  if (!to.path.startsWith('/admin')) return

  // Allow auth pages within admin
  if (to.path.startsWith('/admin/auth/')) return

  const auth = useAuth()
  const permissions = usePermissions()

  // Skip profile fetch if already authenticated (e.g. just logged in)
  if (auth.user.value) return
  try {
    await auth.fetchProfile()
  } catch {
    // fetchProfile swallows errors internally — we handle the result below
  }
  // If still not authenticated after fetch, redirect to login
  if (!auth.user.value) {
    return navigateTo('/admin/auth/login')
  }

  // Route-based permission check
  const routePermissions: Record<string, string[]> = {
    '/admin/products': ['products'],
    '/admin/inventory': ['inventory'],
    '/admin/pos': ['pos'],
    '/admin/customers': ['members'],
    '/admin/employees': ['employees'],
    '/admin/finance': ['finance'],
  }

  for (const [route, requiredPerms] of Object.entries(routePermissions)) {
    if (to.path.startsWith(route)) {
      if (!permissions.hasAnyPermission(requiredPerms as any)) {
        return navigateTo('/admin')
      }
    }
  }
})
