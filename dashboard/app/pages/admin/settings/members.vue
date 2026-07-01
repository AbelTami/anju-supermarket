<script setup lang="ts">
/** 系统设置 → 员工账号 */
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = () => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/employees` : ''

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })
const q = ref('')

const filtered = computed(() => {
  if (!data.value?.results) return []
  return data.value.results.filter((e: any) =>
    !q.value || (e.name || e.username).includes(q.value)
  )
})
</script>

<template>
  <div class="space-y-6">
    <UPageCard title="员工账号" description="管理超市员工及角色分配" variant="naked" orientation="horizontal">
      <EmployeesAddModal @created="refresh()" />
    </UPageCard>

    <UPageCard variant="subtle" :ui="{ container: 'p-0 sm:p-0 gap-y-0', header: 'p-4 mb-0 border-b border-default' }">
      <template #header>
        <UInput v-model="q" icon="i-lucide-search" placeholder="搜索员工..." class="w-full" />
      </template>

      <div v-if="status === 'pending'" class="text-center py-8 text-dimmed">加载中...</div>
      <div v-else class="divide-y divide-default">
        <div v-for="emp in filtered" :key="emp.id" class="flex items-center justify-between p-4 hover:bg-elevated/50">
          <div>
            <div class="font-medium">{{ emp.name || emp.username }}</div>
            <div class="text-sm text-dimmed">{{ emp.username }} · {{ emp.role_label || '无角色' }} · {{ emp.phone }}</div>
          </div>
          <div class="flex items-center gap-2">
            <UBadge :color="emp.is_active ? 'success' : 'neutral'" variant="subtle">
              {{ emp.is_active ? '在职' : '离职' }}
            </UBadge>
            <UButton icon="i-lucide-ellipsis-vertical" size="xs" color="neutral" variant="ghost" />
          </div>
        </div>
      </div>
    </UPageCard>
  </div>
</template>
