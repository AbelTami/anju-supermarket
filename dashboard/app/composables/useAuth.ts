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

  /** Fetch current user profile from the BFF. Uses $fetch to avoid Nuxt useFetch cache. */
  async function fetchProfile() {
    try {
      const profile = await $fetch('/api/auth/profile') as any
      if (profile) {
        user.value = { id: profile.id, username: profile.username, phone: profile.phone, email: profile.email, first_name: profile.first_name }
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
      const result = await $fetch('/api/auth/login', {
        method: 'POST',
        body: { username, password },
      }) as any
      user.value = result.user
      tenants.value = result.tenants || []
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
      const result = await $fetch('/api/auth/register', {
        method: 'POST',
        body: { tenant_name: tenantName, username, password, phone },
      }) as any
      user.value = result.user
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
    await navigateTo('/admin/auth/login')
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
