<script setup lang="ts">
/** 系统设置 → 员工账号 */
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/employees` : undefined

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })
const q = ref('')

const filtered = computed(() => {
  if (!data.value?.results) return []
  return data.value.results.filter((e: any) =>
    !q.value || (e.name || e.username).includes(q.value)
  )
})

const editOpen = ref(false)
const editTarget = ref<any>(null)
const editRole = ref('')

function openEditModal(emp: any) {
  editTarget.value = emp
  editRole.value = emp.role || 'cashier'
  editOpen.value = true
}

async function updateRole() {
  if (!editTarget.value) return
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/employees/${editTarget.value.id}/`, {
      method: 'PATCH',
      body: { role: editRole.value },
    })
    toast.add({ title: '角色更新成功', color: 'success' })
    editOpen.value = false
    refresh()
  } catch (e: any) {
    toast.add({ title: '更新失败', color: 'error' })
  }
}

async function toggleEmployee(emp: any) {
  if (emp.id === auth.user.value?.id) {
    toast.add({ title: '不能停用自己的账号', color: 'warning' })
    return
  }
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/employees/${emp.id}/`, {
      method: 'PATCH',
      body: { is_active: !emp.is_active },
    })
    toast.add({ title: emp.is_active ? '已停用' : '已启用', color: 'success' })
    refresh()
  } catch (e: any) {
    toast.add({ title: '操作失败', color: 'error' })
  }
}
</script>

<template>
  <div class="space-y-6">
    <UPageCard title="员工账号" description="管理超市员工及角色分配" variant="naked" orientation="horizontal">
      <EmployeesAddModal @created="refresh()" />
    </UPageCard>

    <UPageCard variant="subtle" :ui="{ container: 'p-0 sm:p-0 gap-y-0', header: 'p-4 mb-0 border-b border-default' }">
      <template #header>
        <UInput v-model="q" icon="i-lucide-search" placeholder="搜索员工..." class="w-full" />
      </template>

      <div v-if="status === 'pending'" class="text-center py-8 text-dimmed">加载中...</div>
      <div v-else class="divide-y divide-default">
        <div v-for="emp in filtered" :key="emp.id" class="flex items-center justify-between p-4 hover:bg-elevated/50">
          <div>
            <div class="font-medium">{{ emp.name || emp.username }}</div>
            <div class="text-sm text-dimmed">{{ emp.username }} · {{ emp.role_label || '无角色' }} · {{ emp.phone }}</div>
          </div>
          <div class="flex items-center gap-2">
            <UBadge :color="emp.is_active ? 'success' : 'neutral'" variant="subtle">
              {{ emp.is_active ? '在职' : '离职' }}
            </UBadge>
            <UDropdownMenu :items="[
              [{ label: '编辑角色', icon: 'i-lucide-pencil', onSelect: () => openEditModal(emp) }],
              [{ label: emp.is_active ? '停用账号' : '启用账号', icon: emp.is_active ? 'i-lucide-user-x' : 'i-lucide-user-check', onSelect: () => toggleEmployee(emp) }],
            ]">
              <UButton icon="i-lucide-ellipsis-vertical" size="xs" color="neutral" variant="ghost" />
            </UDropdownMenu>
          </div>
        </div>
      </div>
    </UPageCard>

    <!-- Edit role modal -->
    <UModal v-model:open="editOpen" title="编辑员工角色">
      <template #body>
        <div v-if="editTarget" class="space-y-4">
          <p class="text-sm text-dimmed">{{ editTarget.name || editTarget.username }}</p>
          <USelect v-model="editRole" :items="[
            { label: '超级管理员', value: 'super_admin' },
            { label: '店长', value: 'manager' },
            { label: '收银员', value: 'cashier' },
            { label: '库管', value: 'warehouse' },
            { label: '财务', value: 'accountant' },
          ]" />
          <div class="flex justify-end gap-2">
            <UButton label="取消" color="neutral" variant="subtle" @click="editOpen = false" />
            <UButton label="保存" color="primary" @click="updateRole" />
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>
