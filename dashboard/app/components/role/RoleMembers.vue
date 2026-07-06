<script setup lang="ts">
import type { RoleMember } from './types'
import { ROLE_OPTIONS } from './constants'

interface Props {
  members: RoleMember[]
  roleCode: string | undefined
}

interface Emits {
  (e: 'changeRole', userId: number, newRole: string): void
}

defineProps<Props>()
const emit = defineEmits<Emits>()

function currentRole(member: RoleMember): string {
  return member.role || member.role_label || 'cashier'
}
</script>

<template>
  <div>
    <!-- Empty -->
    <div
      v-if="members.length === 0"
      class="flex flex-col items-center py-10"
    >
      <div class="flex size-12 items-center justify-center rounded-full bg-(--ui-bg-elevated)">
        <UIcon name="i-lucide-user-round-x" class="size-5 text-(--ui-text-muted)/40" />
      </div>
      <p class="mt-3 text-sm text-(--ui-text-muted)">暂无成员</p>
      <p class="mt-0.5 text-xs text-(--ui-text-muted)/60">当前角色尚未分配员工</p>
    </div>

    <!-- Members list -->
    <div v-else class="space-y-px">
      <div
        v-for="member in members"
        :key="member.id"
        class="flex items-center gap-3 rounded-lg px-3 py-2.5 -mx-3 transition-colors hover:bg-(--ui-bg-elevated)/50"
      >
        <!-- Avatar -->
        <UAvatar
          :alt="member.name || member.username"
          size="sm"
          :text="(member.name || member.username).charAt(0)"
          class="shrink-0"
        />

        <!-- Identity -->
        <div class="min-w-0 flex-1">
          <p class="truncate text-sm font-medium text-(--ui-text-highlighted)">
            {{ member.name || member.username }}
          </p>
          <p class="truncate text-xs text-(--ui-text-muted)">
            {{ member.username }}
            <span v-if="member.phone" class="hidden sm:inline"> · {{ member.phone }}</span>
          </p>
        </div>

        <!-- Role changer -->
        <USelect
          :model-value="currentRole(member)"
          :items="ROLE_OPTIONS"
          size="xs"
          class="w-28 shrink-0"
          @change="emit('changeRole', member.id, ($event as unknown) as string)"
        />
      </div>
    </div>
  </div>
</template>
