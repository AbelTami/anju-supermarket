/** Proxy login to Django backend. Sets JWT cookies. */
export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  // Validate required fields
  if (!body || typeof body.username !== 'string' || body.username.trim().length === 0) {
    throw createError({ statusCode: 400, message: '用户名不能为空' })
  }
  if (typeof body.password !== 'string' || body.password.trim().length === 0) {
    throw createError({ statusCode: 400, message: '密码不能为空' })
  }

  const config = useRuntimeConfig()

  const resp = await $fetch<{
    access: string
    refresh: string
    user: Record<string, unknown>
    tenants: Record<string, unknown>[]
  }>(`${config.apiBase}/api/auth/login/`, {
    method: 'POST',
    body,
    headers: { 'Content-Type': 'application/json' },
    ignoreResponseError: true,
  })

  // Set JWT as httpOnly cookies
  setCookie(event, 'access_token', resp.access, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 120, // 2 hours
  })
  setCookie(event, 'refresh_token', resp.refresh, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7, // 7 days
  })

  return { user: resp.user, tenants: resp.tenants }
})
