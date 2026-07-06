<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'

const emit = defineEmits<{ created: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')

const schema = z.object({
  name: z.string().min(1, '请输入供应商名称'),
  contact: z.string().optional(),
  phone: z.string().optional(),
  address: z.string().optional(),
  remark: z.string().optional(),
})

type Schema = z.output<typeof schema>
const state = reactive<Partial<Schema>>({ name: '', contact: '', phone: '', address: '', remark: '' })

async function onSubmit(event: FormSubmitEvent<Schema>) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/suppliers/`, { method: 'POST', body: event.data })
    toast.add({ title: `供应商「${event.data.name}」添加成功`, color: 'success' })
    open.value = false
    emit('created')
    state.name = ''; state.contact = ''; state.phone = ''; state.address = ''; state.remark = ''
  } catch (e: any) {
    toast.add({ title: '添加失败', color: 'error' })
  }
}
</script>

<template>
  <UModal v-model:open="open" title="新增供应商">
    <UButton label="新增供应商" icon="i-lucide-plus" color="primary" />

    <template #body>
      <UForm
        :schema="schema"
        :state="state"
        class="space-y-4"
        @submit="onSubmit"
      >
        <UFormField label="供应商名称" name="name">
          <UInput v-model="state.name" placeholder="供应商名称" />
        </UFormField>
        <div class="grid grid-cols-2 gap-3">
          <UFormField label="联系人" name="contact">
            <UInput v-model="state.contact" placeholder="联系人" />
          </UFormField>
          <UFormField label="电话" name="phone">
            <UInput v-model="state.phone" placeholder="联系电话" />
          </UFormField>
        </div>
        <UFormField label="地址" name="address">
          <UInput v-model="state.address" placeholder="地址" />
        </UFormField>
        <UFormField label="备注" name="remark">
          <UInput v-model="state.remark" placeholder="选填" />
        </UFormField>
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
