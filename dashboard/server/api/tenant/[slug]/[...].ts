/** Catch-all proxy for tenant-scoped Django API calls. Auth routes have their own handlers and take precedence. */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  const slug = getRouterParam(event, 'slug')
  const rest = getRouterParam(event, '_') // [...].ts capture is _ by default

  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }

  const pathSuffix = rest ? `${rest}/` : ''
  const djangoUrl = `http://localhost:8000/api/${slug}/${pathSuffix}`
  const method = event.method
  const body = method !== 'GET' ? await readBody(event).catch(() => null) : null

  try {
    const resp = await $fetch(djangoUrl, {
      method,
      body,
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      query: getQuery(event),
    })
    return resp
  } catch (err: any) {
    const statusCode = err.statusCode || 500
    // Forward Django validation errors to the frontend
    const body = err.data || err.message
    throw createError({ statusCode, statusMessage: typeof body === 'string' ? body : JSON.stringify(body), message: typeof body === 'string' ? body : JSON.stringify(body) })
  }
})
