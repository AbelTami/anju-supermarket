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
  // Path traversal protection: normalize and reject any path that escapes
  let safeRest = (rest || '').replace(/\\/g, '/')
  // Normalize ../ sequences
  while (safeRest.includes('/./') || safeRest.includes('//') || safeRest.startsWith('./')) {
    safeRest = safeRest.replace('/./', '/').replace('//', '/')
    if (safeRest.startsWith('./')) safeRest = safeRest.slice(2)
  }
  // Reject path traversal attempts
  if (safeRest.includes('..')) {
    throw createError({ statusCode: 403, message: 'Forbidden' })
  }
  // Only allow alphanumeric, slash, hyphen, underscore, query params
  safeRest = safeRest.replace(/[^a-zA-Z0-9/_.?=&-]/g, '')
  const pathSuffix = safeRest ? `${safeRest}/` : ''

  const backendUrl = useRuntimeConfig().apiBase
  const djangoUrl = `${backendUrl}/api/${slug}/${pathSuffix}`
  const method = event.method

  // Handle multipart file uploads
  const contentType = getHeader(event, 'content-type') || ''
  const isMultipart = contentType.startsWith('multipart/')

  let body: any = null
  if (method !== 'GET') {
    if (isMultipart) {
      body = await readRawBody(event, false)
      if (!body) throw createError({ statusCode: 400, message: 'Empty body' })
    } else {
      body = await readBody(event).catch(() => null)
    }
  }

  try {
    const headers: Record<string, string> = {
      Authorization: `Bearer ${accessToken}`,
    }
    if (isMultipart) {
      headers['Content-Type'] = contentType
    } else {
      headers['Content-Type'] = 'application/json'
    }

    const resp = await $fetch(djangoUrl, {
      method,
      body,
      headers,
      query: getQuery(event),
    })
    return resp
  } catch (err: unknown) {
    const e = err as { statusCode?: number, data?: unknown, message?: string }
    // Forward Django's status + body verbatim — the frontend needs the
    // original validation messages ("该用户名已存在", {field: [...]}, etc).
    throw createError({
      statusCode: e.statusCode || 500,
      message: e.message || '请求处理失败',
      data: e.data,
    })
  }
})
