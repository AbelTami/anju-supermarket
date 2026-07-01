<script setup lang="ts">
/** 商品管理 — Real API via BFF proxy */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useAuth } from '~/composables/useAuth'

const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const auth = useAuth()

const search = ref('')
const editModal = useTemplateRef('editModal')
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')

const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/products` : ''

const { data, status, refresh } = useFetch(apiUrl, {
  lazy: true,
  server: false,
  watch: [tenantSlug],
})

const columns: TableColumn<any>[] = [
  { accessorKey: 'name', header: '商品名称' },
  { accessorKey: 'sku_count', header: 'SKU数' },
  { accessorKey: 'category_name', header: '分类' },
  { accessorKey: 'is_weighted', header: '称重', cell: ({ row }: any) => row.original.is_weighted ? '是' : '否' },
  { accessorKey: 'is_active', header: '状态',
    cell: ({ row }: any) => row.original.is_active
      ? h(UBadge, { color: 'success', variant: 'subtle' }, () => '上架')
      : h(UBadge, { color: 'neutral', variant: 'subtle' }, () => '下架'),
  },
  {
    accessorKey: 'actions', header: '',
    cell: ({ row }: any) =>
      h(UButton, {
        icon: 'i-lucide-pencil', color: 'neutral', variant: 'ghost', size: 'xs',
        onClick: () => editModal.value?.openEdit(row.original),
      }),
  },
]
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="商品管理">
          <template #right>
            <ProductsAddModal @created="refresh()" />
            <ProductsEditModal ref="editModal" @updated="refresh()" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div class="p-4">
          <div class="flex gap-4 mb-4">
            <UInput v-model="search" icon="i-lucide-search" placeholder="搜索商品名称/条码..." class="flex-1" />
          </div>

          <UTable
            v-if="data?.results"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="getPaginationRowModel()"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">加载中...</div>
          <div v-else class="text-center py-12 text-dimmed">暂无商品，请先添加</div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
