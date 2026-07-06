<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useAuth } from '~/composables/useAuth'

const props = defineProps<{ member: any }>()
const emit = defineEmits<{ updated: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')

const schema = z.object({
  name: z.string().min(1, '请输入姓名'),
  phone: z.string().min(1, '请输入手机号'),
  card_no: z.string().optional(),
  remark: z.string().optional(),
})

type Schema = z.output<typeof schema>
const state = reactive<Partial<Schema>>({
  name: props.member.name || '',
  phone: props.member.phone || '',
  card_no: props.member.card_no || '',
  remark: props.member.remark || '',
})

async function onSubmit(event: FormSubmitEvent<Schema>) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/members/${props.member.id}/`, {
      method: 'PATCH',
      body: event.data,
    })
    toast.add({ title: `会员「${event.data.name}」已更新`, color: 'success' })
    open.value = false
    emit('updated')
  } catch {
    toast.add({ title: '更新失败', color: 'error' })
  }
}
</script>

<template>
  <UModal v-model:open="open" title="编辑会员" :ui="{ body: 'flex flex-col items-center gap-4', content: '!max-w-sm' }">
    <UButton
      icon="i-lucide-pencil"
      size="xs"
      color="neutral"
      variant="ghost"
    />

    <template #body>
      <UForm
        :schema="schema"
        :state="state"
        class="space-y-4 w-56"
        @submit="onSubmit"
      >
        <UFormField label="姓名" name="name">
          <UInput v-model="state.name" placeholder="会员姓名" />
        </UFormField>
        <UFormField label="手机号" name="phone">
          <UInput v-model="state.phone" placeholder="手机号" />
        </UFormField>
        <UFormField label="会员卡号" name="card_no">
          <UInput v-model="state.card_no" placeholder="选填" />
        </UFormField>
        <UFormField label="备注" name="remark">
          <UInput v-model="state.remark" placeholder="选填" />
        </UFormField>
        <div class="flex justify-center gap-2 pt-2">
          <UButton
            label="取消"
            color="neutral"
            variant="ghost"
            @click="open = false"
          />
          <UButton label="保存" color="primary" type="submit" />
        </div>
      </UForm>
    </template>
  </UModal>
</template>
