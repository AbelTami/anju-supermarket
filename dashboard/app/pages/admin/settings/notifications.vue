<script setup lang="ts">
/** 系统设置 → 角色权限 */
const roles = [
  { name: '超级管理员', key: 'super_admin', desc: '全部权限：商品、库存、POS、会员、供应商、员工、财务、系统设置' },
  { name: '店长', key: 'manager', desc: '除系统设置外全部权限 + 报表查看' },
  { name: '收银员', key: 'cashier', desc: '仅POS收银 + 查会员 + 查库存' },
  { name: '库管', key: 'warehouse', desc: '商品管理 + 库存管理 + 供应商管理' },
  { name: '财务', key: 'accountant', desc: '仅财务报表 + 供应商应付' },
]

const moduleLabels = ['商品管理', '库存管理', 'POS收银', '会员管理', '供应商', '员工管理', '财务报表', '系统设置']

// ponytail: display-only matrix until role CRUD API is built
const permissions: Record<string, boolean[]> = {
  super_admin: [true, true, true, true, true, true, true, true],
  manager: [true, true, true, true, true, true, true, false],
  cashier: [false, false, true, true, false, false, false, false],
  warehouse: [true, true, false, false, true, false, false, false],
  accountant: [false, false, false, false, true, false, true, false],
}
</script>

<template>
  <div class="space-y-6">
    <UPageCard title="角色权限" description="管理系统预定义角色及对应权限" variant="naked" />

    <UPageCard v-for="role in roles" :key="role.key" variant="subtle" class="mb-4">
      <div class="flex items-start justify-between mb-3">
        <div>
          <div class="font-semibold">{{ role.name }}</div>
          <div class="text-sm text-dimmed">{{ role.desc }}</div>
        </div>
      </div>
      <div class="flex flex-wrap gap-2">
        <UBadge
          v-for="(label, i) in moduleLabels"
          :key="label"
          :color="permissions[role.key][i] ? 'success' : 'neutral'"
          variant="subtle"
        >
          {{ label }}
        </UBadge>
      </div>
    </UPageCard>
  </div>
</template>
