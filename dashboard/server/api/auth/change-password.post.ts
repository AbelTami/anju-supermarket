export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  if (!accessToken) throw createError({ statusCode: 401 })
  const config = useRuntimeConfig()

  const body = await readBody(event)
  return $fetch(`${config.apiBase}/api/auth/change-password/`, {
    method: 'POST',
    body,
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
  })
})
