<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { memberLogin } = useShopApi()

const memberToken = useCookie('member-token', { maxAge: 60 * 60 * 24 * 7, sameSite: 'lax', secure: false })

const phone = ref('')
const password = ref('')
const isLoading = ref(false)
const errorMessage = ref('')

async function handleLogin() {
  errorMessage.value = ''

  if (!phone.value.trim()) {
    errorMessage.value = '请输入手机号'
    return
  }
  if (!password.value) {
    errorMessage.value = '请输入密码'
    return
  }

  isLoading.value = true
  try {
    const result = await memberLogin(slug.value, phone.value.trim(), password.value)
    const token = result.token || result.key
    if (token) {
      memberToken.value = token
      toast.add({ title: '登录成功', color: 'success', duration: 2000 })
      router.push(`/${slug.value}`)
    } else {
      errorMessage.value = '登录失败，请检查手机号和密码'
    }
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || err?.data?.message || '登录失败，请稍后再试'
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center py-12 px-4">
    <UCard class="w-full max-w-md">
      <template #header>
        <div class="text-center">
          <UIcon name="i-lucide-user-circle" class="size-12 text-(--ui-primary) mx-auto mb-2" />
          <h1 class="text-xl font-bold text-(--ui-text)">会员登录</h1>
          <p class="text-sm text-(--ui-text-muted) mt-1">登录后可查看订单和会员信息</p>
        </div>
      </template>

      <div class="space-y-4">
        <!-- Error message -->
        <div
          v-if="errorMessage"
          class="p-3 rounded-lg bg-(--ui-error)/10 text-(--ui-error) text-sm"
        >
          {{ errorMessage }}
        </div>

        <UFormField label="手机号" required>
          <UInput
            v-model="phone"
            icon="i-lucide-phone"
            placeholder="请输入手机号"
            size="lg"
            class="w-full"
            autocomplete="tel"
            @keyup.enter="handleLogin"
          />
        </UFormField>

        <UFormField label="密码" required>
          <UInput
            v-model="password"
            icon="i-lucide-lock"
            type="password"
            placeholder="请输入密码"
            size="lg"
            class="w-full"
            autocomplete="current-password"
            @keyup.enter="handleLogin"
          />
        </UFormField>

        <UButton
          block
          size="lg"
          :loading="isLoading"
          @click="handleLogin"
        >
          登录
        </UButton>
      </div>

      <template #footer>
        <p class="text-center text-sm text-(--ui-text-muted)">
          还没有账号？
          <NuxtLink
            :to="`/${slug}/login`"
            class="text-(--ui-primary) hover:underline font-medium"
          >
            请联系店主开通会员
          </NuxtLink>
        </p>
      </template>
    </UCard>
  </div>
</template>
