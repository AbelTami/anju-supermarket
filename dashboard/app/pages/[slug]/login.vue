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
      toast.add({ title: '登录成功', color: 'success', duration: 2000, ui: { container: 'shop-toast' } })
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
    <div class="w-full max-w-sm shop-animate-in">
      <!-- Logo -->
      <div class="text-center mb-8">
        <div class="size-16 rounded-2xl bg-gradient-to-br from-(--ui-primary) to-(--ui-primary)/60 text-white flex items-center justify-center mx-auto mb-4 shadow-lg shadow-(--ui-primary)/20">
          <UIcon name="i-lucide-store" class="size-8" />
        </div>
        <h1 class="text-xl font-bold text-(--ui-text) tracking-tight">
          会员登录
        </h1>
        <p class="text-sm text-(--ui-text-muted) mt-1">
          登录后可查看订单和会员信息
        </p>
      </div>

      <!-- Card -->
      <div class="shop-card p-6">
        <!-- Error message -->
        <div
          v-if="errorMessage"
          class="p-3 rounded-xl bg-(--ui-error)/10 text-(--ui-error) text-sm mb-4 flex items-center gap-2"
        >
          <UIcon name="i-lucide-alert-circle" class="size-4 shrink-0" />
          {{ errorMessage }}
        </div>

        <div class="space-y-4">
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
            class="h-12 rounded-xl text-base font-bold"
            :loading="isLoading"
            @click="handleLogin"
          >
            登录
          </UButton>
        </div>

        <div class="mt-6 pt-4 border-t border-(--ui-border)/50 text-center space-y-2">
          <p class="text-sm text-(--ui-text-muted)">
            还没有账号？
          </p>
          <p class="text-xs text-(--ui-primary) font-medium">
            请联系店主开通会员
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
