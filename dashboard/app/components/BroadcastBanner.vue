<script setup lang="ts">
/** Operational broadcast banner — pulled from the public tenant endpoint.
 *
 * Renders a sleek alert above the storefront content when the admin
 * activates a broadcast. Dismissible per-session, re-shown on next visit.
 */
import type { TenantPublicInfo } from '~/types'

interface Props {
  compact?: boolean
}
const props = defineProps<Props>()

const route = useRoute()
const slug = computed(() => route.params.slug as string)

const { data } = useFetch<TenantPublicInfo>(
  () => `/api/shop/${slug.value}/info/`,
  {
    key: computed(() => `tenant-info-${slug.value}`),
    default: () => null,
  },
)

const dismissed = ref(false)

interface SeverityStyle {
  icon: string
  bg: string
  border: string
  text: string
  dot: string
}

const severityStyle: Record<string, SeverityStyle> = {
  info: {
    icon: 'i-lucide-info',
    bg: 'from-(--ui-info)/5 to-(--ui-info)/10',
    border: 'border-(--ui-info)/25',
    text: 'text-(--ui-info)',
    dot: 'bg-(--ui-info)',
  },
  warning: {
    icon: 'i-lucide-triangle-alert',
    bg: 'from-(--ui-warning)/5 to-(--ui-warning)/10',
    border: 'border-(--ui-warning)/25',
    text: 'text-(--ui-warning)',
    dot: 'bg-(--ui-warning)',
  },
  error: {
    icon: 'i-lucide-octagon-alert',
    bg: 'from-(--ui-error)/5 to-(--ui-error)/10',
    border: 'border-(--ui-error)/25',
    text: 'text-(--ui-error)',
    dot: 'bg-(--ui-error)',
  },
}

const style = computed(() => severityStyle[data.value?.broadcast_severity ?? 'warning'] ?? severityStyle.warning)
const visible = computed(() => Boolean(!dismissed.value && data.value?.broadcast_active && data.value?.broadcast_message))

function dismissBanner() {
  dismissed.value = true
}
</script>

<template>
  <Transition
    enter-active-class="duration-300 ease-out"
    enter-from-class="opacity-0 -translate-y-full"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="duration-200 ease-in"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 -translate-y-4"
  >
    <div
      v-if="visible"
      class="relative overflow-hidden bg-gradient-to-r border-b"
      :class="[style.bg, style.border]"
    >
      <!-- Subtle shimmer -->
      <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/[0.03] to-transparent animate-shimmer pointer-events-none" />

      <div
        class="max-w-7xl mx-auto flex items-center gap-3 px-4 lg:px-6"
        :class="compact ? 'py-2.5' : 'py-3'"
      >
        <!-- Icon + dot pulse -->
        <div class="relative shrink-0">
          <div class="absolute inset-0 rounded-full opacity-40 animate-ping" :class="style.dot" />
          <UIcon :name="style.icon" class="size-4 relative z-10" :class="style.text" />
        </div>

        <!-- Message -->
        <p
          class="flex-1 font-medium tracking-tight"
          :class="[style.text, compact ? 'text-xs' : 'text-sm']"
        >
          {{ data?.broadcast_message }}
        </p>

        <!-- Dismiss button -->
        <button
          class="shrink-0 size-7 flex items-center justify-center rounded-lg opacity-50 hover:opacity-100 transition cursor-pointer"
          :class="style.text"
          @click="dismissBanner"
        >
          <UIcon name="i-lucide-x" :class="compact ? 'size-3.5' : 'size-4'" />
        </button>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
@keyframes shimmer {
  0%   { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}
.animate-shimmer {
  animation: shimmer 3s ease-in-out infinite;
}
</style>
