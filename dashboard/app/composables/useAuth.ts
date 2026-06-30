/** Auth state — shared across the app via VueUse createSharedComposable. */
import { createSharedComposable } from '@vueuse/core'

export interface TenantInfo {
  id: number
  name: string
  slug: string
}

export interface UserInfo {
  id: number
  username: string
  phone: string
  email: string
  first_name?: string
}

const _useAuth = () => {
  const user = ref<UserInfo | null>(null)
  const tenants = ref<TenantInfo[]>([])
  const currentTenant = ref<TenantInfo | null>(null)
  const isLoading = ref(false)

  /** Fetch current user profile from the BFF. */
  async function fetchProfile() {
    try {
      const { data } = await useFetch('/api/auth/profile')
      if (data.value) {
        user.value = data.value as UserInfo
        // profile endpoint returns tenants list
        const profile = data.value as any
        if (profile.tenants) {
          tenants.value = profile.tenants
          if (!currentTenant.value && profile.tenants.length > 0) {
            currentTenant.value = profile.tenants[0]
          }
        }
      }
    } catch {
      user.value = null
      tenants.value = []
    }
  }

  async function login(username: string, password: string) {
    isLoading.value = true
    try {
      const { data, error } = await useFetch('/api/auth/login', {
        method: 'POST',
        body: { username, password },
      })
      if (error.value) throw new Error('Login failed')
      const result = data.value as any
      user.value = result.user
      tenants.value = result.tenants || []
      if (tenants.value.length > 0) {
        currentTenant.value = tenants.value[0]
      }
      return true
    } finally {
      isLoading.value = false
    }
  }

  async function register(tenantName: string, username: string, password: string, phone: string) {
    isLoading.value = true
    try {
      const { data, error } = await useFetch('/api/auth/register', {
        method: 'POST',
        body: { tenant_name: tenantName, username, password, phone },
      })
      if (error.value) throw new Error('Register failed')
      const result = data.value as any
      user.value = result.user
      if (result.tenant) {
        tenants.value = [result.tenant]
        currentTenant.value = result.tenant
      }
      return true
    } finally {
      isLoading.value = false
    }
  }

  async function logout() {
    await useFetch('/api/auth/logout', { method: 'POST' })
    user.value = null
    tenants.value = []
    currentTenant.value = null
    await navigateTo('/auth/login')
  }

  function switchTenant(tenant: TenantInfo) {
    currentTenant.value = tenant
  }

  return {
    user: readonly(user),
    tenants: readonly(tenants),
    currentTenant: readonly(currentTenant),
    isLoading: readonly(isLoading),
    fetchProfile,
    login,
    register,
    logout,
    switchTenant,
  }
}

export const useAuth = createSharedComposable(_useAuth)
