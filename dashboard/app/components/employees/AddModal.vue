<script setup lang="ts">
import { useAuth } from '~/composables/useAuth'

const emit = defineEmits<{ created: [] }>()
const auth = useAuth()
const toast = useToast()
const open = ref(false)

const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const username = ref('')
const role = ref('cashier')
const loading = ref(false)

const roleOptions = [
  { label: '收银员', value: 'cashier' },
  { label: '库管', value: 'warehouse' },
  { label: '店长', value: 'manager' },
  { label: '财务', value: 'accountant' },
]

async function submit() {
  if (!username.value) return
  loading.value = true
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/employees/`, {
      method: 'POST',
      body: { username: username.value, role: role.value },
    })
    toast.add({ title: `员工「${username.value}」添加成功`, color: 'success' })
    open.value = false
    emit('created')
    username.value = ''
  } catch (e: any) {
    let msg = '添加失败'
    try {
      const raw = e?.data?.message || e?.message || ''
      const d = typeof raw === 'string' ? JSON.parse(raw) : raw
      msg = Array.isArray(d?.username) ? d.username[0] : (d?.username || d?.detail || d?.error || raw || msg)
    } catch { msg = e?.message || msg }
    toast.add({ title: msg, color: 'error' })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <UModal v-model:open="open" title="添加员工">
    <UButton label="添加员工" icon="i-lucide-user-plus" color="primary" />

    <template #body>
      <div class="space-y-4">
        <UFormField label="用户名">
          <UInput v-model="username" placeholder="输入已有用户名" />
        </UFormField>
        <UFormField label="角色">
          <USelect v-model="role" :items="roleOptions" />
        </UFormField>
        <div class="flex justify-end gap-2">
          <UButton
            label="取消"
            color="neutral"
            variant="subtle"
            @click="open = false"
          />
          <UButton
            label="添加"
            color="primary"
            :loading="loading"
            @click="submit"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
