<script setup lang="ts">
import { useAuth } from '~/composables/useAuth'

const emit = defineEmits<{ created: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')

const type = ref('purchase_in')
const skuId = ref<number | null>(null)
const quantity = ref(0)
const remark = ref('')

// Search products to find SKU
const searchQuery = ref('')
const searchUrl = computed(() =>
  searchQuery.value
    ? `/api/tenant/${tenantSlug.value}/products?search=${encodeURIComponent(searchQuery.value)}`
    : null
)
const { data: searchData } = useFetch(searchUrl, { lazy: true, watch: [searchUrl], debounce: 300 })

const skuOptions = computed(() => {
  const results = (searchData.value as any)?.results || []
  return results.flatMap((p: any) =>
    (p.skus || []).map((s: any) => ({
      label: `${p.name} - ${s.spec_name} (库存: ${s.stock_quantity})`,
      value: s.id,
    }))
  )
})

const typeOptions = [
  { label: '采购入库', value: 'purchase_in' },
  { label: '退货入库', value: 'return_in' },
  { label: '盘盈入库', value: 'check_in' },
  { label: '销售出库', value: 'sale_out' },
  { label: '报损出库', value: 'damage_out' },
  { label: '盘亏出库', value: 'check_out' },
]

async function submit() {
  if (!skuId.value || quantity.value <= 0) return
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/inventory-records/`, {
      method: 'POST',
      body: { sku: skuId.value, type: type.value, quantity: String(quantity.value), remark: remark.value },
    })
    toast.add({ title: '库存操作成功', color: 'success' })
    open.value = false
    emit('created')
    skuId.value = null; quantity.value = 0; remark.value = ''; searchQuery.value = ''
  } catch (e: any) {
    toast.add({ title: '操作失败', description: e?.message, color: 'error' })
  }
}
</script>

<template>
  <UModal v-model:open="open" title="库存操作">
    <UButton label="入库/出库" icon="i-lucide-package-plus" color="primary" />

    <template #body>
      <div class="space-y-4">
        <UFormField label="操作类型">
          <USelect v-model="type" :items="typeOptions" />
        </UFormField>

        <UFormField label="搜索商品">
          <UInput v-model="searchQuery" placeholder="输入商品名称搜索..." />
        </UFormField>

        <UFormField v-if="skuOptions.length" label="选择SKU">
          <USelect v-model="skuId" :items="skuOptions" placeholder="选择规格" />
        </UFormField>

        <UFormField label="数量">
          <UInput v-model.number="quantity" type="number" placeholder="变动数量" />
        </UFormField>

        <UFormField label="备注">
          <UInput v-model="remark" placeholder="备注（选填）" />
        </UFormField>

        <div class="flex justify-end gap-2">
          <UButton label="取消" color="neutral" variant="subtle" @click="open = false" />
          <UButton label="确认" color="primary" @click="submit" />
        </div>
      </div>
    </template>
  </UModal>
</template>
