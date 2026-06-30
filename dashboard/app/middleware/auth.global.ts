/** Global auth guard — populates auth state, redirects unauthenticated users to login. */
export default defineNuxtRouteMiddleware(async (to) => {
  if (to.path.startsWith('/auth/')) return

  const auth = useAuth()
  try {
    await auth.fetchProfile()
    if (!auth.user.value) throw new Error('Not authenticated')
  } catch {
    return navigateTo('/auth/login')
  }
})
