<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent, AuthFormField } from '@nuxt/ui'

definePageMeta({ layout: 'auth' })

const auth = useAuth()
const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')

const fields: AuthFormField[] = [
  { name: 'tenant_name', type: 'text', label: '超市名称', placeholder: '请输入超市名称', required: true },
  { name: 'username', type: 'text', label: '用户名', placeholder: '登录用户名', required: true },
  { name: 'phone', type: 'text', label: '手机号', placeholder: '管理员手机号（选填）' },
  { name: 'password', label: '密码', type: 'password', placeholder: '至少6位密码', required: true },
]

const schema = z.object({
  tenant_name: z.string().catch('').pipe(z.string().min(1, '请输入超市名称')),
  username: z.string().catch('').pipe(z.string().min(1, '请输入用户名')),
  phone: z.string().catch(''),
  password: z.string().catch('').pipe(z.string().min(6, '密码至少6位')),
})

type Schema = z.output<typeof schema>

async function onSubmit(event: FormSubmitEvent<Schema>) {
  errorMsg.value = ''
  loading.value = true
  try {
    await auth.register(event.data.tenant_name, event.data.username, event.data.password, event.data.phone || '')
    await router.push('/admin')
  } catch (e: any) {
    errorMsg.value = e?.data?.message || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex min-h-dvh items-center justify-center">
    <UPageCard class="w-full max-w-md">
      <UAuthForm
        :schema="schema"
        :fields="fields"
        title="注册超市"
        description="创建你的超市管理系统账号"
        icon="i-lucide-circle-plus"
        :submit="{ label: '注册', block: true, loading }"
        @submit="onSubmit"
      >
        <template #validation>
          <UAlert v-if="errorMsg" icon="i-lucide-triangle-alert" color="error" variant="soft" :title="errorMsg" class="mb-4" />
        </template>
        <template #footer>
          已有账号？<ULink to="/admin/auth/login" class="text-primary font-medium">返回登录</ULink>
        </template>
      </UAuthForm>
    </UPageCard>
  </div>
</template>
