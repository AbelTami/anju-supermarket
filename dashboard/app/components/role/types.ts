/** Shared types for role management components. */
export interface Permission {
  module: string
  actions: ('view' | 'create' | 'update' | 'delete')[]
}

export interface Role {
  code: string
  name: string
  icon: string
  description: string
  level: number
  memberCount: number
  permissions: Permission[]
}

export interface RoleMember {
  id: number
  username: string
  name?: string
  phone?: string
  is_active?: boolean
  role?: string
  role_label?: string
}
