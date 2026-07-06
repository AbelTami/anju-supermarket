<script setup lang="ts">
import type { DropdownMenuItem } from '@nuxt/ui'

defineProps<{
  collapsed?: boolean
}>()

const colorMode = useColorMode()
const appConfig = useAppConfig()
const toast = useToast()

const colors = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
const neutrals = ['slate', 'gray', 'zinc', 'neutral', 'stone']

const auth = useAuth()
// Password change
const pwdOpen = ref(false)
const currentPwd = ref('')
const newPwd = ref('')
const pwdLoading = ref(false)

async function changePassword() {
  if (!currentPwd.value || !newPwd.value) return
  pwdLoading.value = true
  try {
    await $fetch('/api/auth/change-password', {
      method: 'POST',
      body: { current_password: currentPwd.value, new_password: newPwd.value },
    })
    toast.add({ title: '密码修改成功', color: 'success' })
    currentPwd.value = ''
    newPwd.value = ''
    pwdOpen.value = false
  } catch (e: any) {
    toast.add({ title: e?.data?.error || '修改失败', color: 'error' })
  } finally {
    pwdLoading.value = false
  }
}

const user = computed(() => {
  const u = auth.user.value as any
  const name = u?.username || '用户'
  const seed = u?.id || name
  return {
    name,
    avatar: { src: `https://api.dicebear.com/9.x/lorelei/svg?seed=${seed}` },
  }
})

const items = computed<DropdownMenuItem[][]>(() => ([[{
  type: 'label',
  label: user.value.name,
  avatar: user.value.avatar,
}], [{
  label: '个人资料',
  icon: 'i-lucide-user',
  to: '/admin/settings',
}, {
  label: '系统设置',
  icon: 'i-lucide-settings',
  to: '/admin/settings',
}], [{
  label: '主题',
  icon: 'i-lucide-palette',
  children: [{
    label: '主色',
    slot: 'chip',
    chip: appConfig.ui.colors.primary,
    content: {
      align: 'center',
      collisionPadding: 16,
    },
    children: colors.map(color => ({
      label: color,
      chip: color,
      slot: 'chip',
      checked: appConfig.ui.colors.primary === color,
      type: 'checkbox',
      onSelect: (e) => {
        e.preventDefault()
        appConfig.ui.colors.primary = color
      },
    })),
  }, {
    label: '中性色',
    slot: 'chip',
    chip: appConfig.ui.colors.neutral === 'neutral' ? 'old-neutral' : appConfig.ui.colors.neutral,
    content: {
      align: 'end',
      collisionPadding: 16,
    },
    children: neutrals.map(color => ({
      label: color,
      chip: color === 'neutral' ? 'old-neutral' : color,
      slot: 'chip',
      type: 'checkbox',
      checked: appConfig.ui.colors.neutral === color,
      onSelect: (e) => {
        e.preventDefault()
        appConfig.ui.colors.neutral = color
      },
    })),
  }],
}, {
  label: '外观',
  icon: 'i-lucide-sun-moon',
  children: [{
    label: '浅色',
    icon: 'i-lucide-sun',
    type: 'checkbox',
    checked: colorMode.value === 'light',
    onSelect(e: Event) {
      e.preventDefault()
      colorMode.preference = 'light'
    },
  }, {
    label: '深色',
    icon: 'i-lucide-moon',
    type: 'checkbox',
    checked: colorMode.value === 'dark',
    onUpdateChecked(checked: boolean) {
      if (checked) {
        colorMode.preference = 'dark'
      }
    },
    onSelect(e: Event) {
      e.preventDefault()
    },
  }],
}], [{
  label: '修改密码',
  icon: 'i-lucide-key-round',
  onSelect() {
    pwdOpen.value = true
  },
}], [{
  label: '退出登录',
  icon: 'i-lucide-log-out',
  onSelect() {
    auth.logout()
  },
}]]))
</script>

<template>
  <ClientOnly>
    <UDropdownMenu
      :key="(auth.user.value as any)?.id"
      :items="items"
      :content="{ align: 'center', collisionPadding: 12 }"
      :ui="{ content: collapsed ? 'w-48' : 'w-(--reka-dropdown-menu-trigger-width)' }"
    >
      <UButton
        :label="collapsed ? undefined : user.name"
        :avatar="user.avatar"
        :trailing-icon="collapsed ? undefined : 'i-lucide-chevrons-up-down'"
        color="neutral"
        variant="ghost"
        block
        :square="collapsed"
        class="data-[state=open]:bg-elevated"
        :ui="{
          trailingIcon: 'text-dimmed',
        }"
      />

      <template #chip-leading="{ item }">
        <div class="inline-flex items-center justify-center shrink-0 size-5">
          <span
            class="rounded-full ring ring-bg bg-(--chip-light) dark:bg-(--chip-dark) size-2"
            :style="{
              '--chip-light': `var(--color-${(item as any).chip}-500)`,
              '--chip-dark': `var(--color-${(item as any).chip}-400)`,
            }"
          />
        </div>
      </template>
    </UDropdownMenu>

    <!-- Password change modal -->
    <UModal v-model:open="pwdOpen" title="修改密码">
      <template #body>
        <div class="space-y-4">
          <UFormField label="当前密码" required>
            <UInput
              v-model="currentPwd"
              type="password"
              placeholder="输入当前密码"
              class="w-full"
            />
          </UFormField>
          <UFormField label="新密码" required>
            <UInput
              v-model="newPwd"
              type="password"
              placeholder="至少 6 位"
              class="w-full"
            />
          </UFormField>
        </div>
      </template>
      <template #footer>
        <div class="flex justify-end gap-2">
          <UButton
            label="取消"
            color="neutral"
            variant="ghost"
            @click="pwdOpen = false"
          />
          <UButton
            label="确认修改"
            color="primary"
            :loading="pwdLoading"
            @click="changePassword"
          />
        </div>
      </template>
    </UModal>
  </ClientOnly>
</template>
