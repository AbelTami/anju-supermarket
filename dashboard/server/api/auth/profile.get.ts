/** Proxy profile request to Django, forwarding the JWT cookie. */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }

  return $fetch(`http://localhost:8000/api/auth/profile/`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  })
})
