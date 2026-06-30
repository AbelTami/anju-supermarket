<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { Period, Range, Sale } from '~/types'
import { getPaginationRowModel } from '@tanstack/table-core'

const props = defineProps<{ period: Period; range: Range }>()
const UBadge = resolveComponent('UBadge')

import { useAuth } from '~/composables/useAuth'
const auth = useAuth()
const table = useTemplateRef('salesTable')
const data = ref<Sale[]>([])
const pagination = ref({ pageIndex: 0, pageSize: 8 })

async function fetchSales() {
  const slug = (auth.currentTenant.value as any)?.slug
  if (!slug) return
  try {
    const d = await $fetch(`/api/tenant/${slug}/orders?ordering=-paid_at&page_size=50`)
    data.value = ((d as any).results || []).map((o: any) => ({
      id: o.order_no, date: o.paid_at, status: 'paid' as const,
      email: o.cashier_name, amount: Number(o.total_amount),
    }))
  } catch { /* keep empty */ }
}

onMounted(fetchSales)
watch([() => (auth.currentTenant.value as any)?.slug, () => props.period, () => props.range], fetchSales)

const columns: TableColumn<Sale>[] = [
  {
    accessorKey: 'id',
    header: '订单号',
    cell: ({ row }) => `#${row.getValue('id')}`
  },
  {
    accessorKey: 'date',
    header: '时间',
    cell: ({ row }) => {
      return new Date(row.getValue('date')).toLocaleString('zh-CN', {
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
      })
    }
  },
  {
    accessorKey: 'status',
    header: '状态',
    cell: ({ row }) => {
      const s = row.getValue('status') as string
      const labels: Record<string, string> = { paid: '已完成', failed: '失败', refunded: '已退款' }
      const color = { paid: 'success' as const, failed: 'error' as const, refunded: 'neutral' as const }[s]
      return h(UBadge, { variant: 'subtle', color }, () => labels[s] || s)
    }
  },
  {
    accessorKey: 'email',
    header: '收银员'
  },
  {
    accessorKey: 'amount',
    header: () => h('div', { class: 'text-right' }, '金额'),
    cell: ({ row }) => {
      const amount = Number.parseFloat(row.getValue('amount'))
      return h('div', { class: 'text-right font-medium' }, `¥${amount.toLocaleString()}`)
    }
  }
]
</script>

<template>
  <UTable
    ref="salesTable"
    :data="data"
    :columns="columns"
    v-model:pagination="pagination"
    :pagination-options="{ getPaginationRowModel: getPaginationRowModel() }"
    class="shrink-0"
    :ui="{
      base: 'table-fixed border-separate border-spacing-0',
      thead: '[&>tr]:bg-elevated/50 [&>tr]:after:content-none',
      tbody: '[&>tr]:last:[&>td]:border-b-0',
      th: 'py-2 first:rounded-l-lg last:rounded-r-lg border-y border-default first:border-l last:border-r',
      td: 'border-b border-default'
    }"
  />
  <div class="flex items-center justify-between gap-3 border-t border-default pt-4 mt-auto">
    <div class="text-sm text-muted">共 {{ table?.tableApi?.getFilteredRowModel().rows.length || data.length }} 条</div>
    <UPagination
      :default-page="(table?.tableApi?.getState().pagination.pageIndex || 0) + 1"
      :items-per-page="table?.tableApi?.getState().pagination.pageSize"
      :total="table?.tableApi?.getFilteredRowModel().rows.length"
      @update:page="(p: number) => table?.tableApi?.setPageIndex(p - 1)"
    />
  </div>
</template>
