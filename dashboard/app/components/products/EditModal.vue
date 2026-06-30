<script setup lang="ts">
/** Edit product basic info — name, unit, category, active status. */
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'

const emit = defineEmits<{ updated: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)
const loading = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const categoriesUrl = computed(() => `/api/tenant/${tenantSlug.value}/categories`)
const { data: catData } = useFetch(categoriesUrl, { lazy: true })

const categoryOptions = computed(() =>
  (catData.value as any)?.results?.map((c: any) => ({ label: c.name, value: c.id })) || []
)

let productId: number | null = null

const state = reactive({ name: '', category: undefined as number | undefined, unit: '个', is_active: true })

const schema = z.object({
  name: z.string().min(1),
  category: z.number().optional(),
  unit: z.string(),
  is_active: z.boolean(),
})

function openEdit(product: any) {
  productId = product.id
  state.name = product.name
  state.unit = product.unit || '个'
  state.is_active = product.is_active
  open.value = true
}

async function onSubmit(event: FormSubmitEvent<z.output<typeof schema>>) {
  if (!productId) return
  loading.value = true
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/products/${productId}/`, {
      method: 'PATCH',
      body: event.data,
    })
    toast.add({ title: '商品已更新', color: 'success' })
    open.value = false
    emit('updated')
  } catch {
    toast.add({ title: '更新失败', color: 'error' })
  } finally {
    loading.value = false
  }
}

defineExpose({ openEdit })
</script>

<template>
  <UModal v-model:open="open" title="编辑商品">
    <template #body>
      <UForm :schema="schema" :state="state" class="space-y-4" @submit="onSubmit">
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
        <div class="flex justify-end gap-2">
          <UButton label="取消" color="neutral" variant="subtle" @click="open = false" />
          <UButton label="保存" color="primary" type="submit" :loading="loading" />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
