/** Proxy register to Django backend. */
export default defineEventHandler(async (event) => {
  const body = await readBody(event)

  const resp = await $fetch<{
    access: string
    refresh: string
    user: Record<string, unknown>
    tenant: Record<string, unknown>
  }>(`http://localhost:8000/api/auth/register/`, {
    method: 'POST',
    body,
    headers: { 'Content-Type': 'application/json' },
  })

  setCookie(event, 'access_token', resp.access, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 120,
  })
  setCookie(event, 'refresh_token', resp.refresh, {
    httpOnly: true,
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  })

  return resp
})
