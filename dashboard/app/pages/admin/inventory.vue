<script setup lang="ts">
/** 库存管理 */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useAuth } from '~/composables/useAuth'

const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const auth = useAuth()

const search = ref('')
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/inventory-records` : ''

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

const columns: TableColumn<any>[] = [
  { accessorKey: 'type_label', header: '变动类型' },
  { accessorKey: 'quantity', header: '数量' },
  { accessorKey: 'before_quantity', header: '变动前' },
  { accessorKey: 'after_quantity', header: '变动后' },
  { accessorKey: 'remark', header: '备注' },
  { accessorKey: 'operator_name', header: '操作人' },
  { accessorKey: 'created_at', header: '时间', cell: ({ row }: any) => row.original.created_at?.slice(0, 19) },
]
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="库存管理">
          <template #right>
            <InventoryAddModal @created="refresh()" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div class="p-4">
          <UInput v-model="search" icon="i-lucide-search" placeholder="搜索库存记录..." class="flex-1 mb-4" />
          <UTable
            v-if="data?.results"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="getPaginationRowModel()"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">加载中...</div>
          <div v-else class="text-center py-12 text-dimmed">暂无库存记录</div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
