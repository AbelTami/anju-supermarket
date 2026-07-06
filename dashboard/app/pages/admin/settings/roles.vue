<script setup lang="ts">
import type { Role } from '~/components/role/types'

const { roles, selectedRole, members, isLoading, selectRole, changeRole, refresh } = useRoles()

function handleRoleClick(role: Role) {
  selectRole(role)
}
</script>

<template>
  <div class="space-y-8">
    <!-- Page header -->
    <UPageCard
      title="角色权限管理"
      description="管理系统预定义角色，查看权限矩阵并分配成员"
      variant="naked"
      orientation="horizontal"
    >
      <UButton
        icon="i-lucide-refresh-cw"
        variant="ghost"
        color="neutral"
        size="sm"
        :loading="isLoading"
        @click="refresh()"
      >
        刷新
      </UButton>
    </UPageCard>

    <!-- Role cards -->
    <section>
      <div class="mb-4 flex items-baseline gap-3">
        <h2 class="text-sm font-semibold text-(--ui-text-highlighted)">
          预定义角色
        </h2>
        <span class="text-xs text-(--ui-text-muted)">
          点击卡片查看详情
        </span>
      </div>

      <!-- Skeleton -->
      <div
        v-if="isLoading && !selectedRole"
        class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-3"
      >
        <USkeleton v-for="i in 5" :key="i" class="h-[160px] rounded-xl" />
      </div>

      <!-- Cards -->
      <div
        v-else
        class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-3"
      >
        <RoleCard
          v-for="role in roles"
          :key="role.code"
          :role="role"
          :selected="selectedRole?.code === role.code"
          @click="handleRoleClick"
        />
      </div>
    </section>

    <!-- Detail panel -->
    <Transition name="fade">
      <section v-if="selectedRole" class="space-y-5">
        <!-- Role info bar -->
        <div class="flex items-center gap-3">
          <div class="flex size-8 items-center justify-center rounded-lg bg-(--ui-primary)/10">
            <UIcon :name="selectedRole.icon" class="size-4 text-(--ui-primary)" />
          </div>
          <div>
            <h2 class="text-sm font-semibold text-(--ui-text-highlighted)">
              {{ selectedRole.name }}
            </h2>
            <p class="text-xs text-(--ui-text-muted)">
              {{ selectedRole.description }}
            </p>
          </div>
        </div>

        <!-- Matrix -->
        <UPageCard
          title="权限矩阵"
          :description="`${selectedRole.permissions.length} 个模块`"
          variant="subtle"
        >
          <RoleMatrix :role="selectedRole" />
        </UPageCard>

        <!-- Members -->
        <UPageCard
          title="角色成员"
          :description="`共 ${members.length} 人`"
          variant="subtle"
        >
          <div v-if="isLoading" class="flex items-center gap-2 py-8 justify-center text-sm text-(--ui-text-muted)">
            <UIcon name="i-lucide-loader-circle" class="size-4 animate-spin" />
            加载中…
          </div>
          <RoleMembers
            v-else
            :members="members"
            :role-code="selectedRole.code"
            @change-role="changeRole"
          />
        </UPageCard>
      </section>
    </Transition>

    <!-- Empty -->
    <div
      v-if="!selectedRole && !isLoading"
      class="flex flex-col items-center py-20"
    >
      <div class="flex size-16 items-center justify-center rounded-2xl bg-(--ui-bg-elevated)">
        <UIcon name="i-lucide-fingerprint" class="size-8 text-(--ui-text-muted)/30" />
      </div>
      <p class="mt-5 text-sm font-medium text-(--ui-text-muted)">选择角色以查看详情</p>
      <p class="mt-1 text-xs text-(--ui-text-muted)/50">点击上方角色卡片查看权限矩阵与成员信息</p>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
