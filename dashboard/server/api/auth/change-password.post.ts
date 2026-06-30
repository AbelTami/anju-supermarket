export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  if (!accessToken) throw createError({ statusCode: 401 })

  const body = await readBody(event)
  return $fetch('http://localhost:8000/api/auth/change-password/', {
    method: 'POST',
    body,
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
  })
})
