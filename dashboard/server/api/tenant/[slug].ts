/** Exact-match proxy for /api/tenant/{slug} — handles the base tenant endpoint
 *  (PATCH for settings, GET for tenant info) that the catch-all [...].ts misses
 *  because it requires at least one extra path segment.
 */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  const slug = getRouterParam(event, 'slug')

  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }

  if (!slug || !/^[a-z0-9_-]+$/i.test(slug)) {
    throw createError({ statusCode: 400, message: 'Invalid tenant' })
  }

  const backendUrl = useRuntimeConfig().apiBase
  const djangoUrl = `${backendUrl}/api/${slug}/`
  const method = event.method

  let body: any = null
  if (method !== 'GET') {
    body = await readBody(event).catch(() => null)
  }

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
  } catch (err: unknown) {
    const e = err as { statusCode?: number, data?: unknown, message?: string }
    throw createError({
      statusCode: e.statusCode || 500,
      message: e.message || '请求处理失败',
      data: e.data,
    })
  }
})
