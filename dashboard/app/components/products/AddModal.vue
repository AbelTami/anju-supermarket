<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'

const emit = defineEmits<{ created: [] }>()
const tenantSlug = useCurrentTenantSlug()
const toast = useToast()
const open = ref(false)

const categoriesUrl = computed(() => `/api/tenant/${tenantSlug.value}/categories`)

const { data: catData } = useFetch(categoriesUrl, {
  lazy: true,
  key: computed(() => `categories-${tenantSlug.value}`),
})

interface CategoryOption { label: string, value: number }
const categoryOptions = computed<CategoryOption[]>(() => {
  const results = (catData.value as { results?: Array<{ id: number, name: string }> } | undefined)?.results
  return (results ?? []).map(c => ({ label: c.name, value: c.id }))
})

const schema = z.object({
  name: z.string().min(1, '请输入商品名称'),
  category: z.number().optional(),
  unit: z.string().default('个'),
  is_weighted: z.boolean().default(false),
  is_active: z.boolean().default(true),
  image: z.any().optional(),
})

type Schema = z.output<typeof schema>

const state = reactive<Partial<Schema>>({ name: '', unit: '个', is_weighted: false, is_active: true, image: undefined })

interface SkuForm {
  barcode: string
  spec_name: string
  purchase_price: number
  selling_price: number
  stock_quantity: number
  stock_alert: number
}

const EMPTY_SKU = (): SkuForm => ({
  barcode: '',
  spec_name: '默认',
  purchase_price: 0,
  selling_price: 0,
  stock_quantity: 0,
  stock_alert: 10,
})

const skus = ref<SkuForm[]>([EMPTY_SKU()])

function addSku(): void {
  skus.value = [...skus.value, EMPTY_SKU()]
}

function removeSku(index: number): void {
  if (skus.value.length <= 1) return
  skus.value = skus.value.filter((_, i) => i !== index)
}

const lookupLoading = ref(false)
async function barcodeLookup(barcode: string): Promise<void> {
  if (!barcode) return
  lookupLoading.value = true
  try {
    const data = await $fetch<{ found: boolean, name?: string, image_url?: string, brands?: string }>(
      `/api/tenant/${tenantSlug.value}/products/barcode-lookup/?barcode=${barcode}`,
    )
    if (data.found) {
      if (!state.name) state.name = data.name || ''
      if (data.image_url && !state.image) {
        state.image = data.image_url
      }
      toast.add({ title: `已识别：${data.name || data.brands || '未知商品'}`, color: 'success', duration: 3000 })
    } else {
      toast.add({ title: '未找到该条码的商品信息', color: 'warning' })
    }
  } catch {
    toast.add({ title: '条码查询失败', color: 'error' })
  } finally {
    lookupLoading.value = false
  }
}

function resetForm(): void {
  state.name = ''
  state.unit = '个'
  state.is_weighted = false
  state.is_active = true
  state.image = undefined
  skus.value = [EMPTY_SKU()]
}

async function onSubmit(event: FormSubmitEvent<Schema>): Promise<void> {
  try {
    // If image is a File, use FormData; otherwise use JSON
    if (state.image instanceof File) {
      const fd = new FormData()
      fd.append('name', event.data.name)
      fd.append('unit', event.data.unit)
      fd.append('is_weighted', String(event.data.is_weighted))
      fd.append('is_active', String(event.data.is_active))
      if (event.data.category) fd.append('category', String(event.data.category))
      fd.append('image', state.image)

      // Add SKUs as JSON string
      fd.append('skus', JSON.stringify(skus.value.map(s => ({
        ...s,
        spec_attrs: {},
        purchase_price: String(s.purchase_price),
        selling_price: String(s.selling_price),
        stock_quantity: String(s.stock_quantity),
        stock_alert: String(s.stock_alert),
      }))))

      await $fetch(`/api/tenant/${tenantSlug.value}/products/`, { method: 'POST', body: fd })
    } else {
      const body = {
        ...event.data,
        image_url: typeof state.image === 'string' ? state.image : undefined,
        image: undefined,
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
    }
    toast.add({ title: `商品「${event.data.name}」添加成功`, color: 'success' })
    open.value = false
    emit('created')
    resetForm()
  } catch (err: unknown) {
    const e = err as { message?: string }
    toast.add({ title: '添加失败', description: e?.message || '请重试', color: 'error' })
  }
}
</script>

<template>
  <UModal v-model:open="open" title="新增商品" description="添加商品及SKU规格">
    <UButton label="新增商品" icon="i-lucide-plus" color="primary" />

    <template #body>
      <UForm
        :schema="schema"
        :state="state"
        class="space-y-4"
        @submit="onSubmit"
      >
        <!-- Image upload -->
        <UFormField name="image" label="商品图片">
          <UFileUpload
            v-model="state.image"
            accept="image/*"
            variant="button"
            size="sm"
            label="选择图片"
            color="neutral"
            description="支持 JPG、PNG、WebP 格式，建议尺寸 400×400"
          />
        </UFormField>

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
            <UButton
              icon="i-lucide-plus"
              size="xs"
              variant="outline"
              @click="addSku"
            >
              添加规格
            </UButton>
          </div>
          <div v-for="(sku, i) in skus" :key="i" class="grid grid-cols-8 gap-2 mb-2 p-3 bg-elevated/50 rounded">
            <UInput
              v-model="sku.spec_name"
              placeholder="规格名"
              class="col-span-1"
              size="xs"
            />
            <div class="col-span-2 flex gap-1">
              <UInput
                v-model="sku.barcode"
                placeholder="条码"
                class="flex-1"
                size="xs"
              />
              <UButton
                icon="i-lucide-scan"
                size="xs"
                color="primary"
                variant="soft"
                :loading="lookupLoading"
                @click="barcodeLookup(sku.barcode)"
              />
            </div>
            <UInput
              v-model.number="sku.purchase_price"
              placeholder="进价"
              class="col-span-1"
              size="xs"
              type="number"
            />
            <UInput
              v-model.number="sku.selling_price"
              placeholder="售价"
              class="col-span-1"
              size="xs"
              type="number"
            />
            <UInput
              v-model.number="sku.stock_quantity"
              placeholder="库存"
              class="col-span-1"
              size="xs"
              type="number"
            />
            <UInput
              v-model.number="sku.stock_alert"
              placeholder="预警"
              class="col-span-1"
              size="xs"
              type="number"
            />
            <UButton
              v-if="skus.length > 1"
              icon="i-lucide-x"
              size="xs"
              color="neutral"
              variant="ghost"
              class="col-span-1"
              @click="removeSku(i)"
            />
          </div>
        </div>

        <div class="flex justify-end gap-2">
          <UButton
            label="取消"
            color="neutral"
            variant="subtle"
            @click="open = false"
          />
          <UButton label="创建" color="primary" type="submit" />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
