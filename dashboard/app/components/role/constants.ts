import type { SelectItem } from '@nuxt/ui'

/** Permission action display metadata */
export const ACTION_META: Record<string, { label: string, icon: string }> = {
  view: { label: '查看', icon: 'i-lucide-eye' },
  create: { label: '新增', icon: 'i-lucide-file-plus' },
  update: { label: '编辑', icon: 'i-lucide-pencil-line' },
  delete: { label: '删除', icon: 'i-lucide-trash-2' },
}

export const ACTION_KEYS = ['view', 'create', 'update', 'delete'] as const

/** Role level display metadata */
export const LEVEL_META: Record<number, { label: string, color: 'primary' | 'success' | 'warning' | 'neutral' }> = {
  1: { label: 'Lv.1', color: 'primary' },
  2: { label: 'Lv.2', color: 'success' },
  3: { label: 'Lv.3', color: 'warning' },
  4: { label: 'Lv.4', color: 'neutral' },
}

/** Available role options for assignment */
export const ROLE_OPTIONS: SelectItem[] = [
  { label: '收银员', value: 'cashier', icon: 'i-lucide-scan-barcode' },
  { label: '库管', value: 'warehouse', icon: 'i-lucide-warehouse' },
  { label: '财务', value: 'accountant', icon: 'i-lucide-receipt-text' },
  { label: '店长', value: 'manager', icon: 'i-lucide-crown' },
  { label: '超级管理员', value: 'super_admin', icon: 'i-lucide-shield-check' },
]

/** Lookup helpers */
export function getRoleLabel(code: string): string {
  const option = (ROLE_OPTIONS as { label?: string, value?: string }[]).find(r => r.value === code)
  return option?.label ?? code
}

export function getLevelMeta(level: number) {
  return LEVEL_META[level] || { label: `Lv.${level}`, color: 'neutral' as const }
}
