<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const auth = useAuth()
const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')
const username = ref('')
const password = ref('')

async function onSubmit(e: Event) {
  e.preventDefault()
  errorMsg.value = ''

  if (!username.value.trim()) { errorMsg.value = '请输入用户名'; return }
  if (!password.value) { errorMsg.value = '请输入密码'; return }

  loading.value = true
  try {
    const ok = await auth.login(username.value, password.value)
    if (ok) await router.push('/')
  } catch {
    errorMsg.value = '账号或密码不正确，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex min-h-dvh items-center justify-center">
    <UCard class="w-full max-w-sm">
      <template #header>
        <div class="text-center">
          <UIcon name="i-lucide-store" class="size-10 text-primary mx-auto mb-3" />
          <h1 class="text-xl font-semibold text-highlighted">安居超市管理系统</h1>
          <p class="mt-1 text-sm text-muted">登录你的超市账号</p>
        </div>
      </template>

      <UForm class="space-y-4" @submit="onSubmit">
        <UAlert
          v-if="errorMsg"
          icon="i-lucide-triangle-alert"
          color="error"
          variant="soft"
          :title="errorMsg"
        />

        <UFormField label="用户名">
          <UInput v-model="username" placeholder="请输入用户名" autofocus />
        </UFormField>

        <UFormField label="密码">
          <UInput v-model="password" type="password" placeholder="请输入密码" />
        </UFormField>

        <UButton type="submit" label="登录" block :loading="loading" />
      </UForm>

      <template #footer>
        <p class="text-center text-sm text-muted">
          还没有账号？
          <ULink to="/auth/register" class="text-primary font-medium">注册超市</ULink>
        </p>
      </template>
    </UCard>
  </div>
</template>
