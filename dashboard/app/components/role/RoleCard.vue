<script setup lang="ts">
import type { Role } from './types'
import { getLevelMeta } from './constants'

interface Props {
  role: Role
  selected?: boolean
}

interface Emits {
  (e: 'click', role: Role): void
}

const props = withDefaults(defineProps<Props>(), {
  selected: false,
})

const emit = defineEmits<Emits>()

const levelInfo = computed(() => getLevelMeta(props.role.level))
</script>

<template>
  <button
    type="button"
    class="group relative w-full rounded-xl text-left transition-all duration-200
           bg-(--ui-bg) border border-(--ui-border)
           hover:border-(--ui-primary)/30 hover:shadow-md hover:-translate-y-0.5
           focus-visible:outline-2 focus-visible:outline-(--ui-primary)"
    :class="selected
      ? 'border-(--ui-primary) shadow-md ring-1 ring-(--ui-primary)/20'
      : ''"
    @click="emit('click', role)"
  >
    <!-- Selected top accent -->
    <div
      v-if="selected"
      class="absolute top-0 inset-x-0 h-1 rounded-t-xl bg-(--ui-primary)"
    />

    <div class="flex flex-col gap-4 p-5">
      <!-- Icon row -->
      <div class="flex items-start justify-between">
        <div
          class="flex size-10 shrink-0 items-center justify-center rounded-lg transition-colors"
          :class="selected
            ? 'bg-(--ui-primary) text-(--ui-bg)'
            : 'bg-(--ui-bg-elevated) text-(--ui-text-muted) group-hover:bg-(--ui-primary)/10 group-hover:text-(--ui-primary)'"
        >
          <UIcon :name="role.icon" class="size-5" />
        </div>
        <!-- Selected check -->
        <div
          v-if="selected"
          class="flex size-5 items-center justify-center rounded-full bg-(--ui-primary)"
        >
          <UIcon name="i-lucide-check" class="size-3 text-(--ui-bg)" />
        </div>
      </div>

      <!-- Info -->
      <div>
        <div class="flex items-center gap-2">
          <h3 class="text-sm font-semibold text-(--ui-text-highlighted)">
            {{ role.name }}
          </h3>
          <UBadge :color="levelInfo.color" variant="subtle" size="sm" class="shrink-0">
            {{ levelInfo.label }}
          </UBadge>
        </div>
        <p class="mt-1 text-xs text-(--ui-text-muted) line-clamp-2 leading-relaxed">
          {{ role.description }}
        </p>
      </div>

      <!-- Footer -->
      <div class="flex items-center gap-2 pt-0.5">
        <UIcon
          :name="role.memberCount > 0 ? 'i-lucide-user-check' : 'i-lucide-user-round'"
          class="size-3.5"
          :class="role.memberCount > 0 ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)/50'"
        />
        <span class="text-xs font-medium tabular-nums" :class="role.memberCount > 0 ? 'text-(--ui-primary)' : 'text-(--ui-text-muted)'">
          {{ role.memberCount }}
        </span>
        <span class="text-xs text-(--ui-text-muted)">人</span>
      </div>
    </div>
  </button>
</template>
