<script setup lang="ts">
/** 系统设置 → 超市信息 */
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const tenantName = computed(() => (auth.currentTenant.value as any)?.name || '')

const schema = z.object({
  name: z.string().min(1, '请输入超市名称'),
  phone: z.string().optional(),
  address: z.string().optional(),
  business_hours: z.string().optional(),
})

type Schema = z.output<typeof schema>
const state = reactive<Partial<Schema>>({ name: tenantName.value, phone: '', address: '', business_hours: '' })

async function onSubmit(event: FormSubmitEvent<Schema>) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}`, {
      method: 'PATCH',
      body: event.data,
    })
    toast.add({ title: '超市信息已更新', color: 'success' })
  } catch {
    toast.add({ title: '更新失败', color: 'error' })
  }
}

watchEffect(() => { state.name = tenantName.value })
</script>

<template>
  <UForm :schema="schema" :state="state" @submit="onSubmit" class="space-y-6">
    <UPageCard title="超市信息" description="管理超市基本信息" variant="naked" orientation="horizontal">
      <UButton label="保存" color="neutral" type="submit" class="w-fit lg:ms-auto" />
    </UPageCard>

    <UPageCard variant="subtle" class="space-y-4">
      <UFormField name="name" label="超市名称" required class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="state.name" class="max-w-sm" />
      </UFormField>
      <USeparator />
      <UFormField name="phone" label="联系电话" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="state.phone" class="max-w-sm" placeholder="超市联系电话" />
      </UFormField>
      <USeparator />
      <UFormField name="address" label="超市地址" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="state.address" class="max-w-sm" placeholder="详细地址" />
      </UFormField>
      <USeparator />
      <UFormField name="business_hours" label="营业时间" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="state.business_hours" class="max-w-sm" placeholder="如：08:00-22:00" />
      </UFormField>
    </UPageCard>
  </UForm>
</template>
