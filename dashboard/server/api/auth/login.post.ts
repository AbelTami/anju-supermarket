/** Proxy login to Django backend. Sets JWT cookies. */
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const config = useRuntimeConfig()

  const resp = await $fetch<{
    access: string
    refresh: string
    user: Record<string, unknown>
    tenants: Record<string, unknown>[]
  }>(`http://localhost:8000/api/auth/login/`, {
    method: 'POST',
    body,
    headers: { 'Content-Type': 'application/json' },
  })

  // Set JWT as httpOnly cookies
  setCookie(event, 'access_token', resp.access, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 120, // 2 hours
  })
  setCookie(event, 'refresh_token', resp.refresh, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7, // 7 days
  })

  return { user: resp.user, tenants: resp.tenants }
})
