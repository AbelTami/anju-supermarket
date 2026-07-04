/** Auth state — shared across the app via VueUse createSharedComposable. */
import { createSharedComposable } from '@vueuse/core'
import type { TenantInfo, UserInfo } from '~~/app/types'

interface LoginResponse {
  user: UserInfo
  tenants: TenantInfo[]
  accessToken: string
}

interface RegisterResponse {
  user: UserInfo
  tenant: TenantInfo
  accessToken: string
}

const _useAuth = () => {
  const user = ref<UserInfo | null>(null)
  const tenants = ref<TenantInfo[]>([])
  const currentTenant = ref<TenantInfo | null>(null)
  const isLoading = ref(false)
  const accessToken = ref<string | null>(null)

  /** Fetch current user profile from the BFF. */
  async function fetchProfile() {
    try {
      const profile = await $fetch<UserInfo & { tenants?: TenantInfo[] }>('/api/auth/profile')
      if (profile) {
        user.value = { ...profile }
        if (profile.tenants) {
          tenants.value = profile.tenants
          if (!currentTenant.value && profile.tenants.length > 0) {
            currentTenant.value = profile.tenants[0]
          }
        }
      }
    } catch {
      if (!user.value) {
        tenants.value = []
      }
    }
  }

  async function login(username: string, password: string) {
    isLoading.value = true
    try {
      const result = await $fetch<LoginResponse>('/api/auth/login', {
        method: 'POST',
        body: { username, password },
        ignoreResponseError: true,
      })
      if (!result?.user) return false
      user.value = result.user
      tenants.value = result.tenants || []
      accessToken.value = result.accessToken || null
      if (tenants.value.length > 0) {
        currentTenant.value = tenants.value[0]
      }
      return true
    } catch {
      return false
    } finally {
      isLoading.value = false
    }
  }

  async function register(tenantName: string, username: string, password: string, phone: string) {
    isLoading.value = true
    try {
      const result = await $fetch<RegisterResponse>('/api/auth/register', {
        method: 'POST',
        body: { tenant_name: tenantName, username, password, phone },
        ignoreResponseError: true,
      })
      if (!result?.user) return false
      user.value = result.user
      accessToken.value = result.accessToken || null
      if (result.tenant) {
        tenants.value = [result.tenant]
        currentTenant.value = result.tenant
      }
      return true
    } catch {
      return false
    } finally {
      isLoading.value = false
    }
  }

  async function logout() {
    await $fetch('/api/auth/logout', { method: 'POST' }).catch(() => {})
    user.value = null
    tenants.value = []
    currentTenant.value = null
    accessToken.value = null
    try {
      await navigateTo('/admin/auth/login')
    } catch { /* navigation failed — ignore */ }
  }

  function switchTenant(tenant: TenantInfo) {
    currentTenant.value = tenant
  }

  return {
    user: readonly(user),
    tenants: readonly(tenants),
    currentTenant: readonly(currentTenant),
    isLoading: readonly(isLoading),
    accessToken: readonly(accessToken),
    fetchProfile,
    login,
    register,
    logout,
    switchTenant,
  }
}

export const useAuth = createSharedComposable(_useAuth)
