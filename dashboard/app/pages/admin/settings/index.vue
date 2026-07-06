<script setup lang="ts">
/** 系统设置 → 超市信息 + 运营广播 */
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'
import { useCurrentTenantSlug } from '~/composables/useCurrentTenant'

const auth = useAuth()
const toast = useToast()
const tenantSlug = useCurrentTenantSlug()

const infoSchema = z.object({
  name: z.string().min(1, '请输入超市名称'),
  phone: z.string().optional(),
  address: z.string().optional(),
  business_hours: z.string().optional(),
})
type InfoSchema = z.output<typeof infoSchema>

const infoState = reactive<Partial<InfoSchema>>({ name: '', phone: '', address: '', business_hours: '' })
const infoSeeded = ref(false)
watch(() => auth.currentTenant.value, (tenant) => {
  if (infoSeeded.value || !tenant) return
  infoState.name = tenant.name
  infoState.phone = tenant.phone ?? ''
  infoState.address = tenant.address ?? ''
  infoState.business_hours = tenant.business_hours ?? ''
  infoSeeded.value = true
}, { immediate: true })

async function onInfoSubmit(event: FormSubmitEvent<InfoSchema>): Promise<void> {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/`, {
      method: 'PATCH',
      body: event.data,
    })
    toast.add({ title: '超市信息已更新', color: 'success' })
  } catch {
    toast.add({ title: '更新失败', color: 'error' })
  }
}

// ─── 运营广播 ───────────────────────────────────────────────────
const broadcastSchema = z.object({
  broadcast_active: z.boolean(),
  broadcast_message: z.string().max(200, '最多 200 字').default(''),
  broadcast_severity: z.enum(['info', 'warning', 'error']).default('warning'),
})
type BroadcastSchema = z.output<typeof broadcastSchema>

const broadcastState = reactive<BroadcastSchema>({
  broadcast_active: false,
  broadcast_message: '',
  broadcast_severity: 'warning',
})
const broadcastSeeded = ref(false)
const severityItems = [
  { label: '通知 — 一般提醒（营业时间调整等）', value: 'info' },
  { label: '注意 — 较重要（暴雨延迟配送等）', value: 'warning' },
  { label: '紧急 — 严重中断（关店、停业等）', value: 'error' },
]

const severityMeta: Record<string, { icon: string, color: string, bg: string, border: string }> = {
  info: { icon: 'i-lucide-info', color: 'text-(--ui-info)', bg: 'bg-(--ui-info)/10', border: 'border-(--ui-info)/30' },
  warning: { icon: 'i-lucide-triangle-alert', color: 'text-(--ui-warning)', bg: 'bg-(--ui-warning)/10', border: 'border-(--ui-warning)/30' },
  error: { icon: 'i-lucide-octagon-alert', color: 'text-(--ui-error)', bg: 'bg-(--ui-error)/10', border: 'border-(--ui-error)/30' },
}

watch(() => auth.currentTenant.value, (tenant) => {
  if (broadcastSeeded.value || !tenant) return
  broadcastState.broadcast_active = !!tenant.broadcast_active
  broadcastState.broadcast_message = tenant.broadcast_message ?? ''
  broadcastState.broadcast_severity = tenant.broadcast_severity ?? 'warning'
  broadcastSeeded.value = true
}, { immediate: true })

async function onBroadcastSubmit(event: FormSubmitEvent<BroadcastSchema>): Promise<void> {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/`, {
      method: 'PATCH',
      body: event.data,
    })
    toast.add({
      title: event.data.broadcast_active ? '广播已发布' : '广播已关闭',
      color: 'success',
    })
  } catch {
    toast.add({ title: '发布失败', color: 'error' })
  }
}
</script>

<template>
  <div class="space-y-6">
    <UForm
      :schema="infoSchema"
      :state="infoState"
      class="space-y-6"
      @submit="onInfoSubmit"
    >
      <UPageCard
        title="超市信息"
        description="管理超市基本信息"
        variant="naked"
        orientation="horizontal"
      >
        <UButton
          label="保存"
          color="neutral"
          type="submit"
          class="w-fit lg:ms-auto"
        />
      </UPageCard>

      <UPageCard variant="subtle" class="space-y-4">
        <UFormField
          name="name"
          label="超市名称"
          required
          class="flex max-sm:flex-col justify-between items-start gap-4"
        >
          <UInput v-model="infoState.name" class="max-w-sm" />
        </UFormField>
        <USeparator />
        <UFormField name="phone" label="联系电话" class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="infoState.phone" class="max-w-sm" placeholder="超市联系电话" />
        </UFormField>
        <USeparator />
        <UFormField name="address" label="超市地址" class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="infoState.address" class="max-w-sm" placeholder="详细地址" />
        </UFormField>
        <USeparator />
        <UFormField name="business_hours" label="营业时间" class="flex max-sm:flex-col justify-between items-start gap-4">
          <UInput v-model="infoState.business_hours" class="max-w-sm" placeholder="如：08:00-22:00" />
        </UFormField>
      </UPageCard>
    </UForm>

    <!-- Operational broadcast -->
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-lg font-semibold text-(--ui-text)">
            运营广播
          </h2>
          <p class="text-sm text-(--ui-text-muted) mt-0.5">
            在顾客前台顶部显示紧急通知 — 关店、延迟、营业调整等
          </p>
        </div>
        <UBadge
          v-if="broadcastState.broadcast_active"
          color="success"
          variant="subtle"
          size="sm"
        >
          已启用
        </UBadge>
        <UBadge
          v-else
          color="neutral"
          variant="subtle"
          size="sm"
        >
          未启用
        </UBadge>
      </div>

      <UForm
        :schema="broadcastSchema"
        :state="broadcastState"
        class="space-y-6"
        @submit="onBroadcastSubmit"
      >
        <!-- Preview card -->
        <div
          v-if="broadcastState.broadcast_message"
          class="rounded-xl border p-4"
          :class="[severityMeta[broadcastState.broadcast_severity].bg, severityMeta[broadcastState.broadcast_severity].border]"
        >
          <p class="text-xs text-(--ui-text-muted) mb-1.5 font-medium uppercase tracking-wide">
            顾客前台预览
          </p>
          <div class="flex items-start gap-2.5">
            <UIcon
              :name="severityMeta[broadcastState.broadcast_severity].icon"
              class="size-4 shrink-0 mt-0.5"
              :class="severityMeta[broadcastState.broadcast_severity].color"
            />
            <p class="text-sm font-medium" :class="severityMeta[broadcastState.broadcast_severity].color">
              {{ broadcastState.broadcast_message }}
            </p>
          </div>
        </div>

        <!-- Enable toggle -->
        <UPageCard variant="subtle">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-(--ui-text)">
                启用广播
              </p>
              <p class="text-xs text-(--ui-text-muted) mt-0.5">
                关闭后顾客前台不显示广播横幅
              </p>
            </div>
            <USwitch v-model="broadcastState.broadcast_active" size="md" />
          </div>
        </UPageCard>

        <!-- Severity -->
        <UPageCard variant="subtle" class="space-y-3">
          <p class="text-sm font-medium text-(--ui-text)">
            广播级别
          </p>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <button
              v-for="item in severityItems"
              :key="item.value"
              type="button"
              class="flex items-center gap-2.5 rounded-xl border p-3 text-left transition cursor-pointer"
              :class="broadcastState.broadcast_severity === item.value
                ? [severityMeta[item.value].border, severityMeta[item.value].bg, 'ring-1 ring-current']
                : 'border-(--ui-border) hover:bg-(--ui-bg-muted)'"
              @click="broadcastState.broadcast_severity = item.value"
            >
              <UIcon
                :name="severityMeta[item.value].icon"
                class="size-4 shrink-0"
                :class="severityMeta[item.value].color"
              />
              <span class="text-xs font-medium text-(--ui-text)">{{ item.value === 'info' ? '通知' : item.value === 'warning' ? '注意' : '紧急' }}</span>
            </button>
          </div>
        </UPageCard>

        <!-- Message -->
        <UPageCard variant="subtle" class="space-y-3">
          <div class="flex items-center justify-between">
            <p class="text-sm font-medium text-(--ui-text)">
              广播内容
            </p>
            <span
              class="text-xs tabular-nums"
              :class="broadcastState.broadcast_message.length > 180 ? 'text-(--ui-error)' : 'text-(--ui-text-muted)'"
            >
              {{ broadcastState.broadcast_message.length }}/200
            </span>
          </div>
          <UTextarea
            v-model="broadcastState.broadcast_message"
            :rows="3"
            placeholder="如：受台风影响，今日 18:00 提前闭店，明日恢复营业，给您带来不便敬请谅解。"
            class="w-full"
            :ui="{ base: 'rounded-xl' }"
          />
        </UPageCard>

        <!-- Submit -->
        <div class="flex justify-end">
          <UButton
            :label="broadcastState.broadcast_active ? '更新广播' : '发布广播'"
            :color="broadcastState.broadcast_active ? 'primary' : 'neutral'"
            type="submit"
            size="md"
          />
        </div>
      </UForm>
    </div>
  </div>
</template>
