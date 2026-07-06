/** Role management composable - shared state and actions.
 *
 * Provides role definitions, member counts, and role management actions.
 * Follows antfu/skills: createSharedComposable, readonly refs, computed.
 */

import { createSharedComposable } from '@vueuse/core'

import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'
import type { Role, RoleMember } from '~/components/role/types'

export type { Role, RoleMember }

/** Predefined roles - matches backend Role enum */
const ROLES: Role[] = [
  {
    code: 'super_admin',
    name: '超级管理员',
    icon: 'i-lucide-shield-check',
    description: '拥有所有权限',
    level: 1,
    memberCount: 0,
    permissions: [
      { module: '全部', actions: ['view', 'create', 'update', 'delete'] },
    ],
  },
  {
    code: 'manager',
    name: '店长',
    icon: 'i-lucide-crown',
    description: '除系统配置外所有权限',
    level: 2,
    memberCount: 0,
    permissions: [
      { module: '商品管理', actions: ['view', 'create', 'update'] },
      { module: '库存管理', actions: ['view', 'create', 'update'] },
      { module: '收银管理', actions: ['view', 'create', 'update'] },
      { module: '会员管理', actions: ['view', 'create', 'update'] },
      { module: '财务管理', actions: ['view'] },
      { module: '员工管理', actions: ['view', 'update'] },
    ],
  },
  {
    code: 'accountant',
    name: '财务',
    icon: 'i-lucide-receipt-text',
    description: '财务报表查看',
    level: 3,
    memberCount: 0,
    permissions: [
      { module: '财务管理', actions: ['view'] },
    ],
  },
  {
    code: 'warehouse',
    name: '库管',
    icon: 'i-lucide-warehouse',
    description: '库存管理',
    level: 3,
    memberCount: 0,
    permissions: [
      { module: '商品管理', actions: ['view'] },
      { module: '库存管理', actions: ['view', 'create', 'update'] },
    ],
  },
  {
    code: 'cashier',
    name: '收银员',
    icon: 'i-lucide-scan-barcode',
    description: '收银和会员查询',
    level: 4,
    memberCount: 0,
    permissions: [
      { module: '收银管理', actions: ['view', 'create'] },
      { module: '会员管理', actions: ['view', 'create'] },
    ],
  },
]

export const useRoles = createSharedComposable(() => {
  const tenantSlug = useCurrentTenantSlug()
  const toast = useToast()

  const selectedRole = ref<Role | null>(null)
  const members = ref<RoleMember[]>([])
  const isLoading = ref(false)

  // Fetch employees and compute member counts
  const { data: employees, refresh } = useFetch<{ results: RoleMember[] }>(
    computed(() => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/employees` : ''),
    { lazy: true, server: false },
  )

  // Roles with dynamic member counts
  const roles = computed(() => {
    const memberCountByRole = (employees.value?.results || []).reduce((acc, emp) => {
      const role = emp.role || emp.role_label || 'cashier'
      acc[role] = (acc[role] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    return ROLES.map(role => ({
      ...role,
      memberCount: memberCountByRole[role.code] || 0,
    }))
  })

  // Select role and fetch members
  async function selectRole(role: Role) {
    selectedRole.value = role
    isLoading.value = true
    try {
      const data = await $fetch<{ results: RoleMember[] }>(
        `/api/tenant/${tenantSlug.value}/employees?role=${role.code}`,
      )
      members.value = data.results || []
    } catch {
      members.value = []
    } finally {
      isLoading.value = false
    }
  }

  // Change user role
  async function changeRole(userId: number, newRole: string) {
    try {
      await $fetch(`/api/tenant/${tenantSlug.value}/employees/${userId}/role/`, {
        method: 'PATCH',
        body: { role: newRole },
      })
      toast.add({ title: '角色已更新', color: 'success' })
      refresh()
      if (selectedRole.value) {
        selectRole(selectedRole.value)
      }
    } catch {
      toast.add({ title: '更新失败', color: 'error' })
    }
  }

  return {
    roles,
    selectedRole,
    members,
    isLoading,
    selectRole,
    changeRole,
    refresh,
  }
})
