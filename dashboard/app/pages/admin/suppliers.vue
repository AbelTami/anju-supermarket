<script setup lang="ts">
/** 供应商管理 */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useAuth } from '~/composables/useAuth'

const UButton = resolveComponent('UButton')
const UDropdownMenu = resolveComponent('UDropdownMenu')
const auth = useAuth()
const toast = useToast()

const search = ref('')
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/suppliers` : ''

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

async function deleteSupplier(id: number, name: string) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/suppliers/${id}/`, { method: 'DELETE' })
    toast.add({ title: `供应商「${name}」已删除`, color: 'success' })
    refresh()
  } catch {
    toast.add({ title: '删除失败', color: 'error' })
  }
}

const columns: TableColumn<any>[] = [
  { accessorKey: 'name', header: '供应商名称' },
  { accessorKey: 'contact', header: '联系人' },
  { accessorKey: 'phone', header: '联系电话' },
  { accessorKey: 'address', header: '地址' },
  { accessorKey: 'remark', header: '备注' },
  {
    accessorKey: 'actions', header: '',
    cell: ({ row }: any) => h(UDropdownMenu, {
      items: [[{ label: '删除', icon: 'i-lucide-trash', color: 'error', onSelect: () => deleteSupplier(row.original.id, row.original.name) }]],
    }, () => h(UButton, { icon: 'i-lucide-ellipsis-vertical', color: 'neutral', variant: 'ghost', size: 'xs' })),
  },
]
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="供应商管理">
          <template #right>
            <SuppliersAddModal @created="refresh()" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div class="p-4">
          <UInput v-model="search" icon="i-lucide-search" placeholder="搜索供应商..." class="flex-1 mb-4" />
          <UTable
            v-if="data?.results"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="getPaginationRowModel()"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">加载中...</div>
          <div v-else class="text-center py-12 text-dimmed">暂无供应商</div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
