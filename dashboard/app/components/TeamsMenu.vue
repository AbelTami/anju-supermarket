<script setup lang="ts">
import type { DropdownMenuItem } from '@nuxt/ui'

defineProps<{
  collapsed?: boolean
}>()

// 安居超市管理系统 — 租户切换
const auth = useAuth()

const tenantItems = computed<DropdownMenuItem[][]>(() => {
  const tenantList = (auth.tenants.value || []).map((t: any) => ({
    label: t.name,
    onSelect() {
      auth.switchTenant(t)
    },
  }))

  return [
    tenantList.length ? tenantList : [{ label: '暂无超市', disabled: true }],
    [{
      label: '注册新超市',
      icon: 'i-lucide-circle-plus',
      to: '/admin/auth/register',
    }],
  ]
})

const currentLabel = computed(() => {
  if (auth.currentTenant.value) {
    return (auth.currentTenant.value as any).name
  }
  return '安居超市'
})
</script>

<template>
  <ClientOnly>
    <UDropdownMenu
      :items="tenantItems"
      :content="{ align: 'center', collisionPadding: 12 }"
      :ui="{ content: collapsed ? 'w-40' : 'w-(--reka-dropdown-menu-trigger-width)' }"
    >
      <UButton
        :label="collapsed ? undefined : currentLabel"
        :icon="'i-lucide-store'"
        :trailing-icon="collapsed ? undefined : 'i-lucide-chevrons-up-down'"
        color="neutral"
        variant="ghost"
        block
        :square="collapsed"
        class="data-[state=open]:bg-elevated"
        :class="[!collapsed && 'py-2']"
        :ui="{
          trailingIcon: 'text-dimmed',
        }"
      />
    </UDropdownMenu>
  </ClientOnly>
</template>
