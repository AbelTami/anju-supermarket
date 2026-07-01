/** Proxy profile request to Django, forwarding the JWT cookie. */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }
  const config = useRuntimeConfig()

  return $fetch(`${config.apiBase}/api/auth/profile/`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  })
})
