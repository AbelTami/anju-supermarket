/** BFF proxy for SSE order stream.

 * Why: EventSource cannot set Authorization headers, and putting the JWT in the
 * URL query string leaks it via access logs, browser history, and Referer.
 * This proxy reads the httpOnly access_token cookie (set on login) and
 * forwards the request to Django with a proper Authorization header.
 *
 * Streams chunked text/event-stream straight through.
 */
export default defineEventHandler(async (event) => {
  const accessToken = getCookie(event, 'access_token')
  if (!accessToken) {
    throw createError({ statusCode: 401, message: 'Not authenticated' })
  }

  const slug = getRouterParam(event, 'slug')
  if (!slug) {
    throw createError({ statusCode: 400, message: 'Missing tenant slug' })
  }

  const config = useRuntimeConfig()
  const upstream = `${config.apiBase}/api/${slug}/orders/stream/`

  // Forward to Django and stream the response body back unchanged.
  const upstreamResp = await fetch(upstream, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
      Accept: 'text/event-stream',
    },
  })

  if (!upstreamResp.ok || !upstreamResp.body) {
    throw createError({ statusCode: upstreamResp.status || 502, message: 'Upstream stream failed' })
  }

  setHeader(event, 'Content-Type', 'text/event-stream')
  setHeader(event, 'Cache-Control', 'no-cache, no-transform')
  setHeader(event, 'Connection', 'keep-alive')
  setHeader(event, 'X-Accel-Buffering', 'no') // disable proxy buffering (nginx)

  return sendStream(event, upstreamResp.body)
})
