/** Shared member auth state — survives page navigation + refresh. */
import { createSharedComposable, useLocalStorage } from '@vueuse/core'

export const useMemberAuth = createSharedComposable(() => {
  const token = useLocalStorage<string | null>('member-token', null)
  const member = ref<any>(null)

  async function fetchProfile(slug: string) {
    if (!token.value) return null
    try {
      const { fetchMemberProfile } = useShopApi()
      const profile = await fetchMemberProfile(slug, token.value)
      member.value = profile
      return profile
    } catch {
      // Token invalid or expired — clear it so user gets redirected to login
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
