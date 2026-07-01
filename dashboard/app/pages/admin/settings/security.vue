<script setup lang="ts">
/** 系统设置 → 打印模板 */
import { useAuth } from '~/composables/useAuth'

const toast = useToast()
const template = ref('standard')
const showLogo = ref(true)
const showBarcode = ref(true)
const showFooter = ref(true)

const templates = [
  { label: '标准小票 (58mm)', value: 'standard' },
  { label: '宽版小票 (80mm)', value: 'wide' },
  { label: 'A4 发票', value: 'a4' },
]

// Password change
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
  } catch (e: any) {
    toast.add({ title: e?.data?.error || '修改失败', color: 'error' })
  } finally {
    pwdLoading.value = false
  }
}

function save() {
  toast.add({ title: '打印设置已保存', color: 'success' })
}
</script>

<template>
  <div class="space-y-6">
    <UPageCard title="打印模板" description="配置小票打印机格式及打印内容" variant="naked" orientation="horizontal">
      <UButton label="保存设置" color="neutral" @click="save" class="w-fit lg:ms-auto" />
    </UPageCard>

    <UPageCard variant="subtle" class="space-y-4">
      <UFormField label="模板格式">
        <USelect v-model="template" :items="templates" class="max-w-xs" />
      </UFormField>
      <USeparator />
      <div class="space-y-3">
        <UCheckbox v-model="showLogo" label="打印超市Logo" />
        <UCheckbox v-model="showBarcode" label="打印商品条码" />
        <UCheckbox v-model="showFooter" label="打印页脚（欢迎语+客服电话）" />
      </div>
    </UPageCard>

    <UPageCard title="修改密码" description="修改当前账号的登录密码" variant="subtle">
      <div class="flex flex-col gap-4 max-w-xs">
        <UInput v-model="currentPwd" type="password" placeholder="当前密码" />
        <UInput v-model="newPwd" type="password" placeholder="新密码（至少6位）" />
        <UButton label="修改密码" class="w-fit" color="neutral" :loading="pwdLoading" @click="changePassword" />
      </div>
    </UPageCard>
  </div>
</template>
