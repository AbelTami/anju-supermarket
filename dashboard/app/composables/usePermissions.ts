import { createSharedComposable } from '@vueuse/core'
import type { Role } from '~~/app/types'

const ROLE_PERMISSIONS = {
  super_admin: ['*'] as const,
  manager: ['products', 'inventory', 'pos', 'members', 'finance', 'employees', 'settings'] as const,
  cashier: ['pos', 'members'] as const,
  warehouse: ['inventory'] as const,
  accountant: ['finance'] as const,
} satisfies Record<Role, readonly string[]>

type Permission = typeof ROLE_PERMISSIONS[Role][number]

const _usePermissions = () => {
  const { currentTenant } = useAuth()

  const currentRole = computed(() => currentTenant.value?.role)

  function hasPermission(permission: Permission): boolean {
    const role = currentRole.value
    if (!role)
      return false
    if (role === 'super_admin')
      return true
    return ROLE_PERMISSIONS[role].includes(permission)
  }

  function hasAnyPermission(permissions: Permission[]): boolean {
    return permissions.some(p => hasPermission(p))
  }

  function hasAllPermissions(permissions: Permission[]): boolean {
    return permissions.every(p => hasPermission(p))
  }

  return {
    currentRole: readonly(currentRole),
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,
  }
}

export const usePermissions = createSharedComposable(_usePermissions)
