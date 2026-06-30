<script setup lang="ts">
/** 会员管理 — Real Members API */
import type { TableColumn } from '@nuxt/ui'
import { getPaginationRowModel } from '@tanstack/table-core'
import { useAuth } from '~/composables/useAuth'

const UButton = resolveComponent('UButton')
const UBadge = resolveComponent('UBadge')
const auth = useAuth()
const toast = useToast()

const search = ref('')
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/members` : ''

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

async function deleteMember(id: number, name: string) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/members/${id}/`, { method: 'DELETE' })
    toast.add({ title: `会员「${name}」已删除`, color: 'success' })
    refresh()
  } catch {
    toast.add({ title: '删除失败', color: 'error' })
  }
}

const columns: TableColumn<any>[] = [
  { accessorKey: 'name', header: '姓名' },
  { accessorKey: 'phone', header: '手机号' },
  { accessorKey: 'card_no', header: '会员卡号' },
  { accessorKey: 'points', header: '积分' },
  { accessorKey: 'balance', header: '储值余额', cell: ({ row }: any) => `¥${row.original.balance}` },
  { accessorKey: 'total_spent', header: '累计消费', cell: ({ row }: any) => `¥${row.original.total_spent}` },
  {
    accessorKey: 'actions', header: '',
    cell: ({ row }: any) =>
      h('div', { class: 'flex gap-1' }, [
        h(UButton, { icon: 'i-lucide-pencil', size: 'xs', color: 'neutral', variant: 'ghost' }),
        h(UButton, {
          icon: 'i-lucide-trash', size: 'xs', color: 'error', variant: 'ghost',
          onClick: () => deleteMember(row.original.id, row.original.name),
        }),
      ]),
  },
]
</script>

<template>
  
    <UDashboardPanel>
      <template #header>
        <UDashboardNavbar title="会员管理">
          <template #right>
            <MembersAddModal @created="refresh()" />
          </template>
        </UDashboardNavbar>
      </template>

      <template #body>
        <div class="p-4">
          <UInput v-model="search" icon="i-lucide-search" placeholder="搜索姓名/手机号/卡号..." class="flex-1 mb-4" />
          <UTable
            v-if="data?.results"
            :data="data.results"
            :columns="columns"
            :pagination="{ pageSize: 15 }"
            :get-pagination-row-model="getPaginationRowModel()"
            sticky-top
          />
          <div v-else-if="status === 'pending'" class="text-center py-12 text-dimmed">加载中...</div>
          <div v-else class="text-center py-12 text-dimmed">暂无会员</div>
        </div>
      </template>
    </UDashboardPanel>
  
</template>
