/** Global auth guard — protects admin routes, leaves public routes alone. */
export default defineNuxtRouteMiddleware(async (to) => {
  // Only protect /admin/* routes
  if (!to.path.startsWith('/admin')) return

  // Allow auth pages within admin
  if (to.path.startsWith('/admin/auth/')) return

  const auth = useAuth()
  try {
    await auth.fetchProfile()
    if (!auth.user.value) throw new Error('Not authenticated')
  } catch {
    return navigateTo('/admin/auth/login')
  }
})
