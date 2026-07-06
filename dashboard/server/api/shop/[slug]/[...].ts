/** Catch-all proxy for customer-facing shop API calls.
 *  Does NOT require admin JWT — passes through customer member tokens as-is.
 *  SSRF protection, request size limits, and path sanitization included.
 */
export default defineEventHandler(async (event) => {
  const slug = getRouterParam(event, 'slug')
  const rest = getRouterParam(event, '_')

  // SSRF protection: validate slug format (alphanumeric + hyphen + underscore only)
  if (!slug || !/^[a-z0-9_-]+$/i.test(slug)) {
    throw createError({ statusCode: 400, message: 'Invalid tenant' })
  }
  // Reject path traversal attempts
  if (rest && rest.includes('..')) {
    throw createError({ statusCode: 400, message: 'Invalid path' })
  }
  // Sanitize rest path: only allow alphanumeric, slash, hyphen, underscore, dot, query params
  const safeRest = rest ? rest.replace(/[^a-zA-Z0-9/_.?=&-]/g, '') : ''
  const pathSuffix = safeRest ? `${safeRest}/` : ''

  const backendUrl = useRuntimeConfig().apiBase
  const djangoUrl = `${backendUrl}/api/${slug}/${pathSuffix}`
  const method = event.method

  // Request size limit: 2 MB
  const contentLength = parseInt(getHeader(event, 'content-length') || '0', 10)
  if (contentLength > 2 * 1024 * 1024) {
    throw createError({ statusCode: 413, message: 'Request too large' })
  }

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
    const headers: Record<string, string> = {}

    // Pass through customer member token if present (Authorization: Token xxx)
    const memberAuth = getHeader(event, 'authorization')
    if (memberAuth && memberAuth.startsWith('Token ')) {
      headers['Authorization'] = memberAuth
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
