<script setup lang="ts">
definePageMeta({ layout: 'auth' })

const auth = useAuth()
const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')
const tenantName = ref('')
const username = ref('')
const phone = ref('')
const password = ref('')

async function onSubmit(e: Event) {
  e.preventDefault()
  errorMsg.value = ''

  if (!tenantName.value.trim()) { errorMsg.value = '请输入超市名称'; return }
  if (!username.value.trim()) { errorMsg.value = '请输入用户名'; return }
  if (password.value.length < 6) { errorMsg.value = '密码至少6位'; return }

  loading.value = true
  try {
    await auth.register(tenantName.value, username.value, password.value, phone.value)
    await router.push('/')
  } catch (e: any) {
    errorMsg.value = e?.data?.error || '注册失败，请重试'
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
          <UIcon name="i-lucide-circle-plus" class="size-10 text-primary mx-auto mb-3" />
          <h1 class="text-xl font-semibold text-highlighted">注册超市</h1>
          <p class="mt-1 text-sm text-muted">创建你的超市管理系统账号</p>
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

        <UFormField label="超市名称">
          <UInput v-model="tenantName" placeholder="请输入超市名称" autofocus />
        </UFormField>

        <UFormField label="用户名">
          <UInput v-model="username" placeholder="登录用户名" />
        </UFormField>

        <UFormField label="手机号">
          <UInput v-model="phone" placeholder="管理员手机号（选填）" />
        </UFormField>

        <UFormField label="密码">
          <UInput v-model="password" type="password" placeholder="至少6位密码" />
        </UFormField>

        <UButton type="submit" label="注册" block :loading="loading" />
      </UForm>

      <template #footer>
        <p class="text-center text-sm text-muted">
          已有账号？
          <ULink to="/auth/login" class="text-primary font-medium">返回登录</ULink>
        </p>
      </template>
    </UCard>
  </div>
</template>
