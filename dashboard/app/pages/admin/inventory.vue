<script setup lang="ts">
/** 库存管理 — 库存流水 + 低库存预警 */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'

const tenantSlug = useCurrentTenantSlug()
const search = ref('')

const apiUrl = computed(() =>
  tenantSlug.value ? `/api/tenant/${tenantSlug.value}/inventory-records` : undefined,
)
const { data, status, refresh } = useFetch(apiUrl, {
  lazy: true,
  server: false,
  key: computed(() => `inventory-${tenantSlug.value}`),
})

const lowStockUrl = computed(() =>
  tenantSlug.value ? `/api/tenant/${tenantSlug.value}/inventory-records/low-stock/` : undefined,
)
const { data: lowStockData } = useFetch(lowStockUrl, {
  lazy: true,
  server: false,
  key: computed(() => `inventory-low-stock-${tenantSlug.value}`),
})
const lowStockCount = computed(() => (lowStockData.value as { count?: number } | undefined)?.count ?? 0)

interface InventoryRecord {
  type_label: string
  sku_name: string
  sku_spec: string
  quantity: string
  before_quantity: string
  after_quantity: string
  remark: string
  operator_name: string
  created_at: string
}

const columns: TableColumn<InventoryRecord>[] = [
  { accessorKey: 'type_label', header: '变动类型' },
  { accessorKey: 'sku_name', header: '商品' },
  { accessorKey: 'sku_spec', header: '规格' },
  { accessorKey: 'quantity', header: '数量' },
  { accessorKey: 'before_quantity', header: '变动前' },
  { accessorKey: 'after_quantity', header: '变动后' },
  { accessorKey: 'remark', header: '备注' },
  { accessorKey: 'operator_name', header: '操作人' },
  { accessorKey: 'created_at', header: '时间', cell: ({ row }) => row.original.created_at?.slice(0, 19) },
]

const paginationRowModel = getPaginationRowModel()
</script>

<template>
  <UDashboardPanel>
    <template #header>
      <UDashboardNavbar title="库存管理">
        <template #right>
          <UBadge
            v-if="lowStockCount > 0"
            color="error"
            variant="subtle"
            class="mr-2"
          >
            {{ lowStockCount }} 个库存预警
          </UBadge>
          <InventoryAddModal @created="refresh()" />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <ClientOnly>
        <div class="p-4">
          <!-- Low-stock alert banner -->
          <UAlert
            v-if="lowStockCount > 0"
            icon="i-lucide-triangle-alert"
            color="warning"
            variant="soft"
            class="mb-4"
          >
            <template #title>
              {{ lowStockCount }} 个商品库存低于预警值，需要补货
            </template>
          </UAlert>

          <UInput
            v-model="search"
            icon="i-lucide-search"
            placeholder="搜索商品名/条码..."
            class="flex-1 mb-4"
          />
          <UTable
            v-if="data?.results?.length"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="paginationRowModel"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">
            加载中...
          </div>
          <div v-else class="text-center py-12 text-dimmed">
            暂无库存记录
          </div>
        </div>
      </ClientOnly>
    </template>
  </UDashboardPanel>
</template>
