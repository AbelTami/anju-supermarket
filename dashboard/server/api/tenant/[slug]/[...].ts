/** Catch-all proxy for tenant-scoped Django API calls. Auth routes have their own handlers and take precedence. */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  const slug = getRouterParam(event, 'slug')
  const rest = getRouterParam(event, '_')

  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }

  // SSRF protection: validate slug format (alphanumeric + hyphen + underscore only)
  if (!slug || !/^[a-z0-9_-]+$/i.test(slug)) {
    throw createError({ statusCode: 400, message: 'Invalid tenant' })
  }
  // Sanitize rest path: only allow alphanumeric, slash, hyphen, underscore, dot, query params
  const safeRest = rest ? rest.replace(/[^a-zA-Z0-9/_.?=&%-]/g, '') : ''
  const pathSuffix = safeRest ? `${safeRest}/` : ''

  const backendUrl = useRuntimeConfig().apiBase || 'http://localhost:8000'
  const djangoUrl = `${backendUrl}/api/${slug}/${pathSuffix}`
  const method = event.method

  // Limit body size for write requests
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
    const errBody = err.data || err.message
    throw createError({
      statusCode,
      statusMessage: typeof errBody === 'string' ? errBody : JSON.stringify(errBody),
      message: typeof errBody === 'string' ? errBody : JSON.stringify(errBody),
    })
  }
})
