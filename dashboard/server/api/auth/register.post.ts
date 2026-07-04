/** Proxy register to Django backend. */
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const config = useRuntimeConfig()

  const resp = await $fetch<{
    access: string
    refresh: string
    user: Record<string, unknown>
    tenant: Record<string, unknown>
  }>(`${config.apiBase}/api/auth/register/`, {
    method: 'POST',
    body,
    headers: { 'Content-Type': 'application/json' },
    ignoreResponseError: true,
  })

  setCookie(event, 'access_token', resp.access, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 120,
  })
  setCookie(event, 'refresh_token', resp.refresh, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  })

  return { user: resp.user, tenant: resp.tenant }
})
