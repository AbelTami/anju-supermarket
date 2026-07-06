/** Shared member auth state.

Why cookie-only (not localStorage + cookie): useLocalStorage is not available
during SSR, which causes hydration mismatches and means the server-rendered
HTML thinks the user is logged out. useCookie is SSR-safe — Nuxt serializes
the cookie on the server and hydrates identically on the client.
*/
import { createSharedComposable } from '@vueuse/core'
import type { MemberInfo } from '~/types'

export const useMemberAuth = createSharedComposable(() => {
  const token = useCookie<string | null>('member-token', {
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 30, // 30 days, matches backend token lifetime
  })
  const member = ref<MemberInfo | null>(null)

  async function fetchProfile(slug: string) {
    if (!token.value) return null
    try {
      const { fetchMemberProfile } = useShopApi()
      const profile = await fetchMemberProfile(slug, token.value)
      member.value = profile
      return profile
    } catch {
      token.value = null
      member.value = null
      return null
    }
  }

  function login(rawToken: string) {
    token.value = rawToken
  }

  function logout() {
    token.value = null
    member.value = null
  }

  return {
    token: readonly(token),
    member: readonly(member),
    login,
    logout,
    fetchProfile,
  }
})
