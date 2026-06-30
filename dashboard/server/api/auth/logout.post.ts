/** Clear auth cookies on logout. */
export default defineEventHandler(async (event) => {
  deleteCookie(event, 'access_token', { path: '/' })
  deleteCookie(event, 'refresh_token', { path: '/' })
  return { success: true }
})
