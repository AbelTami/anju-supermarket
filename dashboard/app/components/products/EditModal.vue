<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'
import { mediaUrl } from '~/composables/useShopApi'

const emit = defineEmits<{ updated: [] }>()
const tenantSlug = useCurrentTenantSlug()
const toast = useToast()
const open = ref(false)
const loading = ref(false)

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

interface Sku {
  id: number
  barcode: string
  spec_name: string
  purchase_price: string
  selling_price: string
  stock_quantity: string
  stock_alert: string
  /** snapshot of original values to detect what changed */
  _original?: string
}

let productId: number | null = null
const currentImage = ref<string | null>(null)
const skus = ref<Sku[]>([])

const state = reactive({
  name: '',
  category: undefined as number | undefined,
  unit: '个',
  is_active: true,
  image: undefined as File | undefined,
})

const schema = z.object({
  name: z.string().min(1),
  category: z.number().optional(),
  unit: z.string(),
  is_active: z.boolean(),
  image: z.any().optional(),
})

function snapshot(sku: Sku): string {
  return JSON.stringify({
    barcode: sku.barcode,
    spec_name: sku.spec_name,
    purchase_price: sku.purchase_price,
    selling_price: sku.selling_price,
    stock_quantity: sku.stock_quantity,
    stock_alert: sku.stock_alert,
  })
}

async function openEdit(product: { id: number, name: string, unit?: string, is_active: boolean, category?: number | { id: number }, image?: string, image_url?: string }) {
  productId = product.id
  state.name = product.name
  state.unit = product.unit || '个'
  state.is_active = product.is_active
  state.category = typeof product.category === 'object' ? product.category?.id : product.category
  state.image = undefined
  currentImage.value = product.image_url || (product.image ? mediaUrl(product.image) ?? null : null)
  skus.value = []
  open.value = true

  // Fetch full detail (with nested skus) so we can edit prices.
  try {
    const detail = await $fetch<{ skus?: Array<Record<string, unknown>> }>(
      `/api/tenant/${tenantSlug.value}/products/${product.id}/`,
    )
    skus.value = (detail.skus ?? []).map((s) => {
      const sku: Sku = {
        id: Number(s.id),
        barcode: String(s.barcode ?? ''),
        spec_name: String(s.spec_name ?? ''),
        purchase_price: String(s.purchase_price ?? '0'),
        selling_price: String(s.selling_price ?? '0'),
        stock_quantity: String(s.stock_quantity ?? '0'),
        stock_alert: String(s.stock_alert ?? '0'),
      }
      sku._original = snapshot(sku)
      return sku
    })
  } catch { /* leave empty — user can still edit product fields */ }
}

async function onSubmit(event: FormSubmitEvent<z.output<typeof schema>>) {
  if (!productId) return
  loading.value = true
  try {
    const url = `/api/tenant/${tenantSlug.value}/products/${productId}/`
    if (state.image) {
      const fd = new FormData()
      fd.append('name', event.data.name)
      fd.append('unit', event.data.unit)
      fd.append('is_active', String(event.data.is_active))
      if (event.data.category) fd.append('category', String(event.data.category))
      fd.append('image', state.image)
      await $fetch(url, { method: 'PATCH', body: fd })
    } else {
      await $fetch(url, { method: 'PATCH', body: event.data })
    }

    // PATCH only the SKUs that actually changed — minimizes writes, avoids
    // clobbering concurrent edits by another admin.
    const changed = skus.value.filter(s => snapshot(s) !== s._original)
    await Promise.all(changed.map(s => $fetch(
      `/api/tenant/${tenantSlug.value}/skus/${s.id}/`,
      {
        method: 'PATCH',
        body: {
          barcode: s.barcode,
          spec_name: s.spec_name,
          purchase_price: s.purchase_price,
          selling_price: s.selling_price,
          stock_quantity: s.stock_quantity,
          stock_alert: s.stock_alert,
        },
      },
    )))

    const changedCount = changed.length
    toast.add({
      title: changedCount > 0 ? `商品已更新（含 ${changedCount} 个 SKU）` : '商品已更新',
      color: 'success',
    })
    open.value = false
    emit('updated')
  } catch (e: unknown) {
    const err = e as { data?: { message?: string } }
    toast.add({ title: '更新失败', description: err?.data?.message || '请重试', color: 'error' })
  } finally {
    loading.value = false
  }
}

defineExpose({ openEdit })
</script>

<template>
  <UModal v-model:open="open" title="编辑商品" :ui="{ content: '!max-w-2xl' }">
    <template #body>
      <UForm
        :schema="schema"
        :state="state"
        class="space-y-4"
        @submit="onSubmit"
      >
        <!-- Image section -->
        <div class="flex items-center gap-4">
          <div class="shrink-0">
            <img
              v-if="currentImage"
              :src="currentImage"
              alt="当前图片"
              class="size-20 rounded-lg object-cover border border-(--ui-border)"
            >
            <div v-else class="size-20 rounded-lg border border-dashed border-(--ui-border) flex items-center justify-center text-(--ui-text-muted) text-xs">
              无图片
            </div>
          </div>
          <UFormField label="更新图片" class="flex-1">
            <UFileUpload
              v-model="state.image"
              accept="image/*"
              variant="button"
              size="sm"
              label="选择图片"
              color="neutral"
            />
          </UFormField>
        </div>

        <UFormField label="商品名称" name="name">
          <UInput v-model="state.name" />
        </UFormField>

        <div class="grid grid-cols-2 gap-3">
          <UFormField label="分类">
            <USelect v-model="state.category" :items="categoryOptions" placeholder="选择分类" />
          </UFormField>
          <UFormField label="单位">
            <UInput v-model="state.unit" />
          </UFormField>
        </div>

        <UCheckbox v-model="state.is_active" label="上架" />

        <!-- SKU section — editable prices / stock per spec -->
        <div v-if="skus.length > 0" class="border-t pt-3 space-y-2">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium">规格与价格</span>
            <span class="text-xs text-(--ui-text-muted)">共 {{ skus.length }} 个规格</span>
          </div>
          <div class="grid grid-cols-12 gap-2 text-[10px] uppercase tracking-wider text-(--ui-text-muted) px-1">
            <div class="col-span-3">
              规格名
            </div>
            <div class="col-span-2">
              条码
            </div>
            <div class="col-span-2 text-right">
              进价
            </div>
            <div class="col-span-2 text-right">
              售价
            </div>
            <div class="col-span-2 text-right">
              库存
            </div>
            <div class="col-span-1 text-right">
              预警
            </div>
          </div>
          <div
            v-for="sku in skus"
            :key="sku.id"
            class="grid grid-cols-12 gap-2 items-center p-2 bg-(--ui-bg-muted)/40 rounded"
          >
            <UInput v-model="sku.spec_name" class="col-span-3" size="xs" />
            <UInput v-model="sku.barcode" class="col-span-2" size="xs" />
            <UInput
              v-model="sku.purchase_price"
              class="col-span-2"
              size="xs"
              type="number"
            />
            <UInput
              v-model="sku.selling_price"
              class="col-span-2"
              size="xs"
              type="number"
            />
            <UInput
              v-model="sku.stock_quantity"
              class="col-span-2"
              size="xs"
              type="number"
            />
            <UInput
              v-model="sku.stock_alert"
              class="col-span-1"
              size="xs"
              type="number"
            />
          </div>
        </div>

        <div class="flex justify-end gap-2 pt-2">
          <UButton
            label="取消"
            color="neutral"
            variant="ghost"
            @click="open = false"
          />
          <UButton
            label="保存"
            color="primary"
            type="submit"
            :loading="loading"
          />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
