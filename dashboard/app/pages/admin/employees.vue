<script setup lang="ts">
/** 员工管理 */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useAuth } from '~/composables/useAuth'

const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const auth = useAuth()
const toast = useToast()

const search = ref('')
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/employees` : ''

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

async function deleteEmployee(id: number, name: string) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/employees/${id}/`, { method: 'DELETE' })
    toast.add({ title: `员工「${name}」已删除`, color: 'success' })
    refresh()
  } catch {
    toast.add({ title: '删除失败', color: 'error' })
  }
}

const columns: TableColumn<any>[] = [
  { accessorKey: 'username', header: '用户名' },
  { accessorKey: 'name', header: '姓名' },
  { accessorKey: 'role_label', header: '角色' },
  { accessorKey: 'phone', header: '手机号' },
  { accessorKey: 'is_active', header: '状态',
    cell: ({ row }: any) => row.original.is_active
      ? h(UBadge, { color: 'success', variant: 'subtle' }, () => '在职')
      : h(UBadge, { color: 'neutral', variant: 'subtle' }, () => '离职'),
  },
  {
    accessorKey: 'actions', header: '',
    cell: ({ row }: any) => h(UDropdownMenu, {
      items: [[{ label: '删除', icon: 'i-lucide-trash', color: 'error', onSelect: () => deleteEmployee(row.original.id, row.original.username || row.original.name) }]],
    }, () => h(UButton, { icon: 'i-lucide-ellipsis-vertical', color: 'neutral', variant: 'ghost', size: 'xs' })),
  },
]
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="员工管理">
          <template #right>
            <EmployeesAddModal @created="refresh()" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div class="p-4">
          <UInput v-model="search" icon="i-lucide-search" placeholder="搜索员工..." class="flex-1 mb-4" />
          <UTable
            v-if="data?.results"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="getPaginationRowModel()"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">加载中...</div>
          <div v-else class="text-center py-12 text-dimmed">暂无员工数据</div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
