<script setup lang="ts">
definePageMeta({ layout: 'shop' })

const route = useRoute()
const router = useRouter()
const toast = useToast()
const slug = computed(() => route.params.slug as string)
const { fetchMemberProfile } = useShopApi()

// Auth check
const memberToken = useCookie('member-token')
const token = computed(() => memberToken.value || null)

onMounted(() => {
  if (!memberToken.value) {
    router.replace(`/${slug.value}/login`)
  }
})

const profile = ref<any>(null)
const isLoading = ref(false)
const errorMessage = ref('')

async function loadProfile() {
  if (!token.value) return

  isLoading.value = true
  errorMessage.value = ''
  try {
    const data = await fetchMemberProfile(slug.value, token.value)
    profile.value = data
  } catch (err: any) {
    errorMessage.value = err?.data?.detail || '加载会员信息失败'
  } finally {
    isLoading.value = false
  }
}

function handleLogout() {
  memberToken.value = null
  toast.add({ title: '已退出登录', color: 'info', duration: 2000 })
  router.push(`/${slug.value}`)
}

function formatPrice(price: string | number): string {
  const n = Number(price)
  return isNaN(n) ? String(price) : `${n.toFixed(2)}`
}

// Load on mount
watchEffect(() => {
  if (token.value) {
    loadProfile()
  }
})
</script>

<template>
  <div class="py-6 px-4 lg:px-6 max-w-2xl mx-auto">
    <div class="flex items-center gap-3 mb-6">
      <UButton
        icon="i-lucide-arrow-left"
        variant="ghost"
        color="neutral"
        square
        @click="router.back()"
      />
      <h1 class="text-2xl font-bold text-(--ui-text)">会员中心</h1>
    </div>

    <!-- Auth redirect -->
    <div
      v-if="!token"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-log-in" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-lg font-medium text-(--ui-text) mb-4">请先登录</p>
      <UButton
        :to="`/${slug}/login`"
        label="去登录"
        icon="i-lucide-user"
      />
    </div>

    <!-- Loading -->
    <div v-else-if="isLoading" class="space-y-4 animate-pulse">
      <div class="h-24 bg-(--ui-bg-muted) rounded-xl" />
      <div class="h-12 bg-(--ui-bg-muted) rounded-xl" />
      <div class="h-12 bg-(--ui-bg-muted) rounded-xl" />
    </div>

    <!-- Error -->
    <div
      v-else-if="errorMessage"
      class="flex flex-col items-center justify-center py-20"
    >
      <UIcon name="i-lucide-alert-circle" class="size-16 text-(--ui-text-muted) mb-4" />
      <p class="text-sm text-(--ui-text-muted) mb-4">{{ errorMessage }}</p>
      <UButton
        variant="outline"
        color="neutral"
        label="重试"
        @click="loadProfile"
      />
    </div>

    <!-- Profile -->
    <div v-else-if="profile" class="space-y-4">
      <!-- Avatar and name card -->
      <UCard>
        <div class="flex items-center gap-4">
          <div class="size-16 rounded-full bg-(--ui-primary)/10 flex items-center justify-center">
            <UIcon name="i-lucide-user" class="size-8 text-(--ui-primary)" />
          </div>
          <div>
            <p class="text-lg font-bold text-(--ui-text)">
              {{ profile.name || profile.phone || '会员' }}
            </p>
            <p class="text-sm text-(--ui-text-muted)">
              {{ profile.phone || '' }}
            </p>
          </div>
        </div>
      </UCard>

      <!-- Stats grid -->
      <div class="grid grid-cols-2 gap-3">
        <UCard>
          <div class="text-center">
            <UIcon name="i-lucide-credit-card" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
            <p class="text-xs text-(--ui-text-muted)">卡号</p>
            <p class="text-sm font-semibold text-(--ui-text) mt-0.5">
              {{ profile.card_no || '-' }}
            </p>
          </div>
        </UCard>

        <UCard>
          <div class="text-center">
            <UIcon name="i-lucide-coins" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
            <p class="text-xs text-(--ui-text-muted)">积分</p>
            <p class="text-sm font-semibold text-(--ui-text) mt-0.5 tabular-nums">
              {{ profile.points ?? 0 }}
            </p>
          </div>
        </UCard>

        <UCard>
          <div class="text-center">
            <UIcon name="i-lucide-wallet" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
            <p class="text-xs text-(--ui-text-muted)">储值余额</p>
            <p class="text-sm font-semibold text-(--ui-primary) mt-0.5 tabular-nums">
              {{ formatPrice(profile.balance ?? 0) }}
            </p>
          </div>
        </UCard>

        <UCard>
          <div class="text-center">
            <UIcon name="i-lucide-trending-up" class="size-5 text-(--ui-text-muted) mx-auto mb-1" />
            <p class="text-xs text-(--ui-text-muted)">累计消费</p>
            <p class="text-sm font-semibold text-(--ui-text) mt-0.5 tabular-nums">
              {{ formatPrice(profile.total_spent ?? 0) }}
            </p>
          </div>
        </UCard>
      </div>

      <!-- Quick links -->
      <UCard>
        <div class="space-y-1">
          <UButton
            :to="`/${slug}/orders`"
            variant="ghost"
            color="neutral"
            block
            class="justify-start"
            icon="i-lucide-receipt"
            label="我的订单"
          />
          <USeparator />
          <UButton
            variant="ghost"
            color="error"
            block
            class="justify-start"
            icon="i-lucide-log-out"
            label="退出登录"
            @click="handleLogout"
          />
        </div>
      </UCard>
    </div>
  </div>
</template>
