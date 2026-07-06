<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent, AuthFormField } from '@nuxt/ui'

definePageMeta({ layout: 'auth' })

const auth = useAuth()
const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')

const fields: AuthFormField[] = [
  { name: 'username', type: 'text', label: '用户名', placeholder: '请输入用户名', required: true },
  { name: 'password', label: '密码', type: 'password', placeholder: '请输入密码', required: true },
]

const schema = z.object({
  username: z.string().catch('').pipe(z.string().min(1, '请输入用户名')),
  password: z.string().catch('').pipe(z.string().min(1, '请输入密码')),
})

type Schema = z.output<typeof schema>

async function onSubmit(event: FormSubmitEvent<Schema>) {
  errorMsg.value = ''
  loading.value = true
  try {
    const ok = await auth.login(event.data.username, event.data.password)
    if (ok) {
      await router.push('/admin')
    } else {
      errorMsg.value = '账号或密码不正确，请重试'
    }
  } catch {
    errorMsg.value = '账号或密码不正确，请重试'
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
        title="安居超市管理系统"
        description="登录你的超市账号"
        icon="i-lucide-store"
        :submit="{ label: '登录', block: true, loading }"
        @submit="onSubmit"
      >
        <template #validation>
          <UAlert
            v-if="errorMsg"
            icon="i-lucide-triangle-alert"
            color="error"
            variant="soft"
            :title="errorMsg"
            class="mb-4"
          />
        </template>
        <template #footer>
          还没有账号？<ULink to="/admin/auth/register" class="text-primary font-medium">注册超市</ULink>
        </template>
      </UAuthForm>
    </UPageCard>
  </div>
</template>
