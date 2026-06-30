<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'

const emit = defineEmits<{ created: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const categoriesUrl = computed(() => `/api/tenant/${tenantSlug.value}/categories`)

const { data: catData } = useFetch(categoriesUrl, { lazy: true, watch: [tenantSlug] })
const categoryOptions = computed(() =>
  (catData.value as any)?.results?.map((c: any) => ({ label: c.name, value: c.id })) || []
)

const schema = z.object({
  name: z.string().min(1, '请输入商品名称'),
  category: z.number().optional(),
  unit: z.string().default('个'),
  is_weighted: z.boolean().default(false),
  is_active: z.boolean().default(true),
})

type Schema = z.output<typeof schema>

const state = reactive<Partial<Schema>>({ name: '', unit: '个', is_weighted: false, is_active: true })

// SKU management — ponytail: simple inline editing
interface SkuForm { barcode: string; spec_name: string; purchase_price: number; selling_price: number; stock_quantity: number; stock_alert: number }
const skus = ref<SkuForm[]>([{ barcode: '', spec_name: '默认', purchase_price: 0, selling_price: 0, stock_quantity: 0, stock_alert: 10 }])

function addSku() { skus.value.push({ barcode: '', spec_name: '', purchase_price: 0, selling_price: 0, stock_quantity: 0, stock_alert: 10 }) }
function removeSku(i: number) { if (skus.value.length > 1) skus.value.splice(i, 1) }

async function onSubmit(event: FormSubmitEvent<Schema>) {
  try {
    const body = {
      ...event.data,
      skus: skus.value.map(s => ({
        ...s,
        spec_attrs: {},
        purchase_price: String(s.purchase_price),
        selling_price: String(s.selling_price),
        stock_quantity: String(s.stock_quantity),
        stock_alert: String(s.stock_alert),
      })),
    }
    await $fetch(`/api/tenant/${tenantSlug.value}/products/`, { method: 'POST', body })
    toast.add({ title: `商品「${event.data.name}」添加成功`, color: 'success' })
    open.value = false
    emit('created')
    // Reset
    state.name = ''
    skus.value = [{ barcode: '', spec_name: '默认', purchase_price: 0, selling_price: 0, stock_quantity: 0, stock_alert: 10 }]
  } catch (e: any) {
    toast.add({ title: '添加失败', description: e?.message || '请重试', color: 'error' })
  }
}
</script>

<template>
  <UModal v-model:open="open" title="新增商品" description="添加商品及SKU规格">
    <UButton label="新增商品" icon="i-lucide-plus" color="primary" />

    <template #body>
      <UForm :schema="schema" :state="state" class="space-y-4" @submit="onSubmit">
        <div class="grid grid-cols-2 gap-3">
          <UFormField label="商品名称" name="name">
            <UInput v-model="state.name" placeholder="如：可口可乐" />
          </UFormField>
          <UFormField label="分类" name="category">
            <USelect v-model="state.category" :items="categoryOptions" placeholder="选择分类" />
          </UFormField>
          <UFormField label="单位" name="unit">
            <UInput v-model="state.unit" placeholder="个/瓶/袋/箱" />
          </UFormField>
          <div class="flex items-end gap-4 pb-1">
            <UCheckbox v-model="state.is_weighted" label="称重商品" />
            <UCheckbox v-model="state.is_active" label="上架" />
          </div>
        </div>

        <!-- SKU section -->
        <div class="border-t pt-3">
          <div class="flex items-center justify-between mb-2">
            <span class="text-sm font-medium">SKU 规格</span>
            <UButton icon="i-lucide-plus" size="xs" variant="outline" @click="addSku">添加规格</UButton>
          </div>
          <div v-for="(sku, i) in skus" :key="i" class="grid grid-cols-6 gap-2 mb-2 p-3 bg-elevated/50 rounded">
            <UInput v-model="sku.spec_name" placeholder="规格名" class="col-span-1" size="xs" />
            <UInput v-model="sku.barcode" placeholder="条码" class="col-span-1" size="xs" />
            <UInput v-model.number="sku.purchase_price" placeholder="进价" class="col-span-1" size="xs" type="number" />
            <UInput v-model.number="sku.selling_price" placeholder="售价" class="col-span-1" size="xs" type="number" />
            <UInput v-model.number="sku.stock_quantity" placeholder="库存" class="col-span-1" size="xs" type="number" />
            <UButton v-if="skus.length > 1" icon="i-lucide-x" size="xs" color="neutral" variant="ghost" class="col-span-1" @click="removeSku(i)" />
          </div>
        </div>

        <div class="flex justify-end gap-2">
          <UButton label="取消" color="neutral" variant="subtle" @click="open = false" />
          <UButton label="创建" color="primary" type="submit" />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
