<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'
import { mediaUrl } from '~/composables/useShopApi'

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
const currentImage = ref<string | null>(null)

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

function openEdit(product: any) {
  productId = product.id
  state.name = product.name
  state.unit = product.unit || '个'
  state.is_active = product.is_active
  state.category = product.category?.id ?? product.category
  state.image = undefined
  currentImage.value = product.image_url || mediaUrl(product.image)
  open.value = true
}

async function onSubmit(event: FormSubmitEvent<z.output<typeof schema>>) {
  if (!productId) return
  loading.value = true
  try {
    const url = `/api/tenant/${tenantSlug.value}/products/${productId}/`
    if (state.image) {
      // Multipart upload with image
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
    toast.add({ title: '商品已更新', color: 'success' })
    open.value = false
    emit('updated')
  } catch (e: any) {
    toast.add({ title: '更新失败', description: e?.data?.message || '请重试', color: 'error' })
  } finally {
    loading.value = false
  }
}

defineExpose({ openEdit })
</script>

<template>
  <UModal v-model:open="open" title="编辑商品" :ui="{ content: '!max-w-sm' }">
    <template #body>
      <UForm :schema="schema" :state="state" class="space-y-4" @submit="onSubmit">
        <!-- Image section: preview + upload side by side -->
        <div class="flex items-center gap-4">
          <div class="shrink-0">
            <img
              v-if="currentImage"
              :src="currentImage"
              alt="当前图片"
              class="size-20 rounded-lg object-cover border border-(--ui-border)"
            />
            <div v-else class="size-20 rounded-lg border border-dashed border-(--ui-border) flex items-center justify-center text-(--ui-text-muted) text-xs">无图片</div>
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

        <div class="flex justify-end gap-2">
          <UButton label="取消" color="neutral" variant="ghost" @click="open = false" />
          <UButton label="保存" color="primary" type="submit" :loading="loading" />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
