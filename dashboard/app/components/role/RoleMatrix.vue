<script setup lang="ts">
import type { Role } from './types'
import { ACTION_KEYS, ACTION_META } from './constants'

interface Props {
  role: Role | null
}

const props = defineProps<Props>()

const permCount = computed(() => props.role?.permissions.reduce((s, p) => s + p.actions.length, 0) ?? 0)
</script>

<template>
  <div v-if="role">
    <!-- Matrix table -->
    <div class="overflow-x-auto -mx-2 sm:mx-0">
      <table class="w-full min-w-[520px]">
        <thead>
          <tr class="border-b border-(--ui-border)">
            <th class="px-3 py-3 text-left text-xs font-semibold text-(--ui-text-highlighted) w-[30%]">
              模块
            </th>
            <th
              v-for="key in ACTION_KEYS"
              :key="key"
              class="px-3 py-3 text-center text-xs font-semibold text-(--ui-text-highlighted) w-[17.5%]"
            >
              <span class="inline-flex items-center gap-1">
                <UIcon :name="ACTION_META[key]!.icon" class="size-3 text-(--ui-text-muted)" />
                {{ ACTION_META[key]!.label }}
              </span>
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-(--ui-border)">
          <tr
            v-for="(perm, idx) in role.permissions"
            :key="perm.module"
            class="transition-colors hover:bg-(--ui-bg-elevated)/40"
            :class="idx % 2 === 0 ? '' : 'bg-(--ui-bg-elevated)/20'"
          >
            <!-- Module name -->
            <td class="px-3 py-3.5">
              <span class="text-sm font-medium text-(--ui-text-highlighted)">
                {{ perm.module }}
              </span>
            </td>
            <!-- Action columns -->
            <td v-for="key in ACTION_KEYS" :key="key" class="px-3 py-3.5 text-center">
              <template v-if="perm.actions.includes(key)">
                <UIcon
                  name="i-lucide-circle-check"
                  class="size-4 text-(--ui-success)"
                />
              </template>
              <template v-else>
                <UIcon
                  name="i-lucide-x"
                  class="size-4 text-(--ui-text-muted)/20"
                />
              </template>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Footer note -->
    <div
      v-if="role.code === 'super_admin'"
      class="mt-4 flex items-center gap-2 rounded-lg bg-(--ui-success)/5 px-4 py-2.5 text-xs text-(--ui-success)"
    >
      <UIcon name="i-lucide-shield-check" class="size-3.5 shrink-0" />
      超级管理员不受权限矩阵限制，拥有系统所有模块的全部操作权限
    </div>
  </div>
</template>
