<script setup lang="ts">
/** 系统设置 → 优惠券管理 */
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = computed(() => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/coupons` : undefined)

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

const coupons = computed(() => (data.value as any)?.results || [])
const activeCount = computed(() => coupons.value.filter((c: any) => c.is_active).length)
const totalClaimed = computed(() => coupons.value.reduce((s: number, c: any) => s + (c.used_count || 0), 0))

// ── Create modal ──────────────────────────────────────────────
const createOpen = ref(false)
const form = ref({ title: '', discount_type: 'fixed', discount_value: '', min_amount: '0', total_count: '100', valid_from: '', valid_until: '' })

async function createCoupon() {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/coupons/`, {
      method: 'POST',
      body: {
        title: form.value.title,
        discount_type: form.value.discount_type,
        discount_value: Number(form.value.discount_value),
        min_amount: Number(form.value.min_amount),
        total_count: Number(form.value.total_count),
        valid_from: form.value.valid_from ? `${form.value.valid_from}T00:00:00` : null,
        valid_until: form.value.valid_until ? `${form.value.valid_until}T23:59:59` : null,
      },
    })
    toast.add({ title: '优惠券创建成功', color: 'success' })
    createOpen.value = false
    form.value = { title: '', discount_type: 'fixed', discount_value: '', min_amount: '0', total_count: '100', valid_from: '', valid_until: '' }
    refresh()
  } catch { toast.add({ title: '创建失败', color: 'error' }) }
}

// ── Assign modal ──────────────────────────────────────────────
const assignOpen = ref(false)
const assignCouponId = ref<number | null>(null)
const assignMemberIds = ref<number[]>([])
const assignSearch = ref('')
const assignMembersList = ref<any[]>([])
const assignDropdownOpen = ref(false)

async function openAssign(couponId: number) {
  assignCouponId.value = couponId
  assignMemberIds.value = []
  assignSearch.value = ''
  assignMembersList.value = []
  assignDropdownOpen.value = false
  assignOpen.value = true
  try {
    const resp = await $fetch(`/api/tenant/${tenantSlug.value}/members?page_size=200`)
    assignMembersList.value = (resp as any)?.results || []
  } catch { /* ignore */ }
}

const assignFilteredMembers = computed(() => {
  if (!assignSearch.value) return assignMembersList.value
  const q = assignSearch.value.toLowerCase()
  return assignMembersList.value.filter((m: any) =>
    m.name?.toLowerCase().includes(q) || m.phone?.includes(q) || String(m.id).includes(q)
  )
})

const showDropdown = computed(() =>
  assignSearch.value.length > 0 && assignFilteredMembers.value.length > 0 && assignDropdownOpen.value
)

function onSearchFocus() { assignDropdownOpen.value = true }
function onSearchBlur() { setTimeout(() => { assignDropdownOpen.value = false }, 150) }
function clearSearch() { assignSearch.value = ''; assignDropdownOpen.value = false }

function addMemberById(id: number) {
  if (!assignMemberIds.value.includes(id)) {
    assignMemberIds.value = [...assignMemberIds.value, id]
  }
  assignSearch.value = ''
  assignDropdownOpen.value = false
}

function removeMember(id: number) {
  assignMemberIds.value = assignMemberIds.value.filter(i => i !== id)
}

function getMemberInfo(id: number) {
  return assignMembersList.value.find((m: any) => m.id === id)
}

function memberInitial(id: number) {
  return getMemberInfo(id)?.name?.charAt(0) || '#'
}

async function doAssign() {
  if (!assignCouponId.value || assignMemberIds.value.length === 0) return
  try {
    const resp = await $fetch(`/api/tenant/${tenantSlug.value}/coupons/${assignCouponId.value}/assign/`, {
      method: 'POST',
      body: { member_ids: assignMemberIds.value.map(Number) },
    })
    toast.add({ title: `已成功分配 ${(resp as any).assigned} 张优惠券`, color: 'success' })
    assignOpen.value = false
    refresh()
  } catch { toast.add({ title: '分配失败，请重试', color: 'error' }) }
}

// ── Delete ────────────────────────────────────────────────────
const deleteTarget = ref<any>(null)
const confirmDeleteOpen = ref(false)

function openDeleteConfirm(c: any) {
  deleteTarget.value = c
  confirmDeleteOpen.value = true
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/coupons/${deleteTarget.value.id}/`, { method: 'DELETE' })
    toast.add({ title: '优惠券已删除', color: 'success' })
    confirmDeleteOpen.value = false
    deleteTarget.value = null
    refresh()
  } catch {
    toast.add({ title: '删除失败', color: 'error' })
  }
}

// ── Toggle ────────────────────────────────────────────────────
async function toggleActive(c: any) {
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/coupons/${c.id}/`, {
      method: 'PATCH',
      body: { is_active: !c.is_active },
    })
    toast.add({ title: c.is_active ? '已停用' : '已启用', color: 'success' })
    refresh()
  } catch { toast.add({ title: '操作失败', color: 'error' }) }
}

// ── Helpers ───────────────────────────────────────────────────
const discountIcon = (type: string) => type === 'fixed' ? 'i-lucide-ticket' : 'i-lucide-ticket-percent'
const discountGradient = (type: string) => type === 'fixed' ? 'from-indigo-500/20 to-blue-500/10' : 'from-violet-500/20 to-purple-500/10'
const isExpired = (until: string) => until ? new Date(until) < new Date() : false
</script>

<template>
  <ClientOnly>
    <div class="space-y-6">

      <!-- ═══ 页头 ═══ -->
      <UPageCard
        title="优惠券管理"
        description="创建和分配优惠券给会员，灵活配置满减与折扣规则"
        variant="naked"
        orientation="horizontal"
      >
        <UButton label="创建优惠券" icon="i-lucide-plus" size="sm" variant="outline" @click="createOpen = true" />
      </UPageCard>

      <!-- ═══ 统计卡片 ═══ -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <!-- 总计 -->
        <div class="group relative rounded-xl border border-(--ui-border)/50 bg-(--ui-bg) p-5 transition-all duration-300 hover:-translate-y-0.5 hover:border-(--ui-primary)/25 hover:shadow-sm">
          <div class="flex items-start justify-between">
            <div>
              <p class="text-xs font-medium text-(--ui-text-muted) mb-1.5 tracking-wide uppercase">总计</p>
              <p class="text-2xl font-bold tabular-nums text-(--ui-text-highlighted)">{{ coupons.length }}</p>
            </div>
            <div class="size-10 rounded-lg bg-(--ui-primary)/10 flex items-center justify-center transition-colors duration-300 group-hover:bg-(--ui-primary)/15">
              <UIcon name="i-lucide-ticket" class="size-5 text-(--ui-primary)" />
            </div>
          </div>
          <p class="text-xs text-(--ui-text-muted) mt-3">全部优惠券</p>
        </div>

        <!-- 启用中 -->
        <div class="group relative rounded-xl border border-(--ui-border)/50 bg-(--ui-bg) p-5 transition-all duration-300 hover:-translate-y-0.5 hover:border-(--ui-success)/25 hover:shadow-sm">
          <div class="flex items-start justify-between">
            <div>
              <p class="text-xs font-medium text-(--ui-text-muted) mb-1.5 tracking-wide uppercase">启用中</p>
              <p class="text-2xl font-bold tabular-nums text-(--ui-text-highlighted)">{{ activeCount }}</p>
            </div>
            <div class="size-10 rounded-lg bg-(--ui-success)/10 flex items-center justify-center transition-colors duration-300 group-hover:bg-(--ui-success)/15">
              <UIcon name="i-lucide-check-circle-2" class="size-5 text-(--ui-success)" />
            </div>
          </div>
          <p class="text-xs text-(--ui-text-muted) mt-3">当前有效的优惠券</p>
        </div>

        <!-- 已领取 -->
        <div class="group relative rounded-xl border border-(--ui-border)/50 bg-(--ui-bg) p-5 transition-all duration-300 hover:-translate-y-0.5 hover:border-(--ui-warning)/25 hover:shadow-sm">
          <div class="flex items-start justify-between">
            <div>
              <p class="text-xs font-medium text-(--ui-text-muted) mb-1.5 tracking-wide uppercase">已领取</p>
              <p class="text-2xl font-bold tabular-nums text-(--ui-text-highlighted)">{{ totalClaimed }}</p>
            </div>
            <div class="size-10 rounded-lg bg-(--ui-warning)/10 flex items-center justify-center transition-colors duration-300 group-hover:bg-(--ui-warning)/15">
              <UIcon name="i-lucide-users" class="size-5 text-(--ui-warning)" />
            </div>
          </div>
          <p class="text-xs text-(--ui-text-muted) mt-3">累计领取次数</p>
        </div>
      </div>

      <!-- ═══ 优惠券列表 ═══ -->
      <UPageCard variant="subtle" :ui="{ container: 'p-0 sm:p-0 gap-y-0' }">
        <!-- 加载 -->
        <div v-if="status === 'pending'" class="flex flex-col items-center justify-center py-20 gap-4">
          <UIcon name="i-lucide-loader-circle" class="size-8 text-(--ui-primary) animate-spin" />
          <p class="text-sm text-(--ui-text-muted)">加载优惠券中…</p>
        </div>

        <!-- 空状态 -->
        <div v-else-if="coupons.length === 0" class="flex flex-col items-center justify-center py-20">
          <div class="relative mb-5">
            <div class="size-20 rounded-full bg-(--ui-bg-muted) flex items-center justify-center">
              <UIcon name="i-lucide-ticket" class="size-9 text-(--ui-text-muted)/25" />
            </div>
            <div class="absolute -bottom-1 -right-1 size-8 rounded-full bg-(--ui-bg) border-2 border-(--ui-border)/30 flex items-center justify-center">
              <UIcon name="i-lucide-plus" class="size-4 text-(--ui-text-muted)/40" />
            </div>
          </div>
          <p class="text-lg font-semibold text-(--ui-text)">还没有优惠券</p>
          <p class="text-sm text-(--ui-text-muted) mt-1.5 mb-5">创建第一张优惠券，吸引顾客消费</p>
          <UButton label="创建优惠券" icon="i-lucide-plus" color="primary" @click="createOpen = true" />
        </div>

        <!-- 列表 -->
        <TransitionGroup v-else name="coupon-list" tag="div" class="divide-y divide-(--ui-border)/40">
          <div
            v-for="c in coupons"
            :key="c.id"
            class="group relative flex items-center gap-4 px-5 py-4 transition-all duration-200 hover:bg-(--ui-bg-muted)/60"
          >
            <!-- 左侧图标 -->
            <div
              class="size-10 rounded-lg shrink-0 flex items-center justify-center transition-all duration-200"
              :class="c.is_active
                ? `bg-gradient-to-br ${discountGradient(c.discount_type)} text-(--ui-primary)`
                : 'bg-(--ui-bg-muted) text-(--ui-text-muted)/50'"
            >
              <UIcon :name="discountIcon(c.discount_type)" class="size-5" />
            </div>

            <!-- 中间信息 -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2.5">
                <span class="font-semibold text-sm text-(--ui-text-highlighted) truncate">{{ c.title }}</span>
                <UBadge
                  size="xs"
                  :color="c.is_active ? 'success' : 'neutral'"
                  variant="subtle"
                  class="shrink-0"
                >
                  {{ c.is_active ? '启用' : '停用' }}
                </UBadge>
              </div>
              <div class="flex items-center gap-1.5 text-xs text-(--ui-text-muted) mt-1 flex-wrap">
                <span class="inline-flex items-center gap-1">
                  <UIcon name="i-lucide-tag" class="size-3" />{{ c.discount_type_label }} ¥{{ c.discount_value }}
                </span>
                <span class="text-(--ui-border) select-none">·</span>
                <span>满 ¥{{ c.min_amount }} 可用</span>
                <span class="text-(--ui-border) select-none">·</span>
                <span class="inline-flex items-center gap-1">
                  <UIcon name="i-lucide-users" class="size-3" />{{ c.used_count }}/{{ c.total_count }}
                </span>
                <template v-if="c.valid_until">
                  <span class="text-(--ui-border) select-none">·</span>
                  <span class="inline-flex items-center gap-1" :class="isExpired(c.valid_until) ? 'text-(--ui-error)' : ''">
                    <UIcon name="i-lucide-calendar" class="size-3" />
                    {{ new Date(c.valid_until).toLocaleDateString('zh-CN') }}到期
                  </span>
                </template>
              </div>

              <!-- 进度条 -->
              <div v-if="c.total_count > 0" class="mt-2">
                <div class="flex items-center justify-between text-xs mb-1">
                  <span class="text-(--ui-text-muted)">已领取 {{ c.used_count }}/{{ c.total_count }}</span>
                  <span
                    class="font-medium tabular-nums"
                    :class="(c.used_count / c.total_count) >= 0.9 ? 'text-(--ui-error)' : 'text-(--ui-text-muted)'"
                  >
                    {{ Math.round((c.used_count / c.total_count) * 100) }}%
                  </span>
                </div>
                <div class="h-2 rounded-full bg-(--ui-bg-muted) overflow-hidden">
                  <div
                    class="h-full rounded-full transition-all duration-700 ease-out"
                    :class="(c.used_count / c.total_count) >= 0.9 ? 'bg-(--ui-error)' : 'bg-(--ui-primary)'"
                    :style="{ width: `${Math.min(100, (c.used_count / c.total_count) * 100)}%` }"
                  />
                </div>
              </div>
            </div>

            <!-- 右侧操作按钮：hover 显示，分隔线隔开 -->
            <div class="flex items-center gap-0 shrink-0 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
              <UTooltip :text="c.is_active ? '停用' : '启用'">
                <UButton size="xs" variant="ghost" square :color="c.is_active ? 'neutral' : 'success'" :icon="c.is_active ? 'i-lucide-pause' : 'i-lucide-play'" @click="toggleActive(c)" />
              </UTooltip>
              <div class="border-l border-(--ui-border)/40 h-5 mx-1.5" />
              <UTooltip text="分配会员">
                <UButton size="xs" variant="ghost" square color="primary" icon="i-lucide-user-plus" @click="openAssign(c.id)" />
              </UTooltip>
              <div class="border-l border-(--ui-border)/40 h-5 mx-1.5" />
              <UTooltip text="删除优惠券">
                <UButton size="xs" variant="ghost" square color="error" icon="i-lucide-trash-2" @click="openDeleteConfirm(c)" />
              </UTooltip>
            </div>
          </div>
        </TransitionGroup>
      </UPageCard>

      <!-- ═══ 创建弹窗 ═══ -->
      <UModal
        v-model:open="createOpen"
        title="创建优惠券"
        description="设置优惠券的基本信息和生效规则"
        :ui="{ content: 'sm:max-w-lg' }"
      >
        <template #body>
          <div class="space-y-5">
            <UFormField label="优惠券名称">
              <UInput v-model="form.title" icon="i-lucide-tag" placeholder="例：新人满减礼券" />
            </UFormField>
            <div class="grid grid-cols-2 gap-4">
              <UFormField label="优惠类型">
                <USelect
                  v-model="form.discount_type"
                  icon="i-lucide-ticket"
                  :items="[{ label: '满减', value: 'fixed' }, { label: '折扣', value: 'percent' }]"
                />
              </UFormField>
              <UFormField label="优惠值">
                <UInput v-model="form.discount_value" icon="i-lucide-coins" placeholder="10.00" />
              </UFormField>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <UFormField label="最低消费">
                <UInput v-model="form.min_amount" icon="i-lucide-shopping-cart" placeholder="50.00" />
              </UFormField>
              <UFormField label="发行数量">
                <UInput v-model="form.total_count" icon="i-lucide-hash" placeholder="100" />
              </UFormField>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <UFormField label="生效时间">
                <UInput v-model="form.valid_from" type="date" icon="i-lucide-calendar" />
              </UFormField>
              <UFormField label="过期时间">
                <UInput v-model="form.valid_until" type="date" icon="i-lucide-calendar" />
              </UFormField>
            </div>
          </div>
        </template>
        <template #footer>
          <div class="flex justify-end gap-2.5 pt-1">
            <UButton label="取消" color="neutral" variant="subtle" @click="createOpen = false" />
            <UButton label="确认创建" color="primary" icon="i-lucide-sparkles" @click="createCoupon" />
          </div>
        </template>
      </UModal>

      <!-- ═══ 分配弹窗 ═══ -->
      <UModal
        v-model:open="assignOpen"
        title="分配优惠券"
        description="搜索并选择会员，支持批量分配"
        :ui="{ content: 'sm:max-w-lg' }"
      >
        <template #body>
          <div class="space-y-5">
            <!-- 搜索 -->
            <div class="relative">
              <div class="relative">
                <UInput
                  v-model="assignSearch"
                  icon="i-lucide-search"
                  placeholder="搜索会员姓名、手机号或 ID…"
                  class="flex-1"
                  @focus="onSearchFocus"
                  @blur="onSearchBlur"
                />
                <button
                  v-if="assignSearch"
                  type="button"
                  class="absolute right-2.5 top-1/2 -translate-y-1/2 size-6 rounded-full flex items-center justify-center bg-(--ui-bg-muted)/70 hover:bg-(--ui-bg-muted) text-(--ui-text-muted) hover:text-(--ui-text) transition-all duration-150 hover:scale-110 active:scale-95"
                  @mousedown.prevent="clearSearch()"
                >
                  <UIcon name="i-lucide-x" class="size-3.5" />
                </button>
              </div>

              <Transition name="dropdown-fade">
                <div
                  v-if="showDropdown"
                  class="absolute z-20 top-full mt-1.5 left-0 right-0 bg-(--ui-bg) border border-(--ui-border) rounded-xl shadow-xl shadow-black/5 overflow-hidden"
                >
                  <div class="max-h-52 overflow-y-auto divide-y divide-(--ui-border)/20">
                    <button
                      v-for="m in assignFilteredMembers.slice(0, 15)"
                      :key="m.id"
                      type="button"
                      class="w-full text-left px-4 py-3 flex items-center gap-3 transition-all duration-150 hover:bg-(--ui-primary)/8 active:bg-(--ui-primary)/12"
                      :class="assignMemberIds.includes(m.id) ? 'opacity-40 pointer-events-none bg-(--ui-bg-muted)/50' : ''"
                      :disabled="assignMemberIds.includes(m.id)"
                      @mousedown.prevent="addMemberById(m.id)"
                    >
                      <div
                        class="size-9 rounded-full shrink-0 flex items-center justify-center text-sm font-bold transition-colors duration-150"
                        :class="assignMemberIds.includes(m.id)
                          ? 'bg-(--ui-bg-muted) text-(--ui-text-muted)'
                          : 'bg-gradient-to-br from-(--ui-primary)/20 to-(--ui-primary)/10 text-(--ui-primary)'"
                      >
                        {{ m.name?.charAt(0) || '#' }}
                      </div>
                      <div class="flex-1 min-w-0">
                        <div class="flex items-baseline gap-1.5">
                          <span class="text-sm font-semibold text-(--ui-text-highlighted) truncate">{{ m.name }}</span>
                          <span class="text-xs text-(--ui-text-muted)/50 tabular-nums shrink-0">#{{ m.id }}</span>
                        </div>
                        <p v-if="m.phone" class="text-xs text-(--ui-text-muted) mt-0.5">{{ m.phone }}</p>
                      </div>
                      <UIcon v-if="assignMemberIds.includes(m.id)" name="i-lucide-check-circle" class="size-5 text-(--ui-primary)/40 shrink-0" />
                      <UIcon v-else name="i-lucide-plus-circle" class="size-5 text-(--ui-text-muted)/20 group-hover:text-(--ui-primary)/60 shrink-0 transition-colors" />
                    </button>
                  </div>
                </div>
              </Transition>
            </div>

            <!-- 已选标签 -->
            <div v-if="assignMemberIds.length" class="space-y-3">
              <div class="flex items-center justify-between">
                <p class="text-xs font-semibold text-(--ui-text-muted) tracking-wide uppercase">
                  已选择 <span class="text-(--ui-primary) tabular-nums">{{ assignMemberIds.length }}</span> 位会员
                </p>
                <button class="text-xs text-(--ui-text-muted) hover:text-(--ui-error) transition-colors" @click="assignMemberIds = []">
                  清空全部
                </button>
              </div>
              <div class="flex flex-wrap gap-2 p-4 rounded-xl border border-dashed border-(--ui-primary)/20 bg-gradient-to-br from-(--ui-primary)/3 to-(--ui-primary)/1">
                <TransitionGroup name="assign-tag">
                  <div
                    v-for="id in assignMemberIds"
                    :key="id"
                    class="group/tag inline-flex items-center gap-2.5 pl-1.5 pr-2.5 py-1.5 rounded-full bg-(--ui-bg) border border-(--ui-border)/50 shadow-sm transition-all duration-200 hover:shadow hover:border-(--ui-border) hover:-translate-y-px cursor-default select-none"
                  >
                    <div class="size-7 rounded-full shrink-0 flex items-center justify-center text-[11px] font-bold bg-gradient-to-br from-(--ui-primary)/20 to-(--ui-primary)/10 text-(--ui-primary)">
                      {{ memberInitial(id) }}
                    </div>
                    <div class="flex flex-col leading-none">
                      <span class="text-[13px] font-semibold text-(--ui-text-highlighted)">{{ getMemberInfo(id)?.name || '#' + id }}</span>
                      <span v-if="getMemberInfo(id)?.phone" class="text-[10px] text-(--ui-text-muted) mt-0.5">{{ getMemberInfo(id)?.phone }}</span>
                    </div>
                    <button
                      class="size-5 rounded-full flex items-center justify-center text-(--ui-text-muted)/50 group-hover/tag:text-(--ui-error) group-hover/tag:bg-(--ui-error)/6 transition-all"
                      @click="removeMember(id)"
                    >
                      <UIcon name="i-lucide-x" class="size-3" />
                    </button>
                  </div>
                </TransitionGroup>
              </div>
            </div>

            <!-- 空状态 -->
            <div v-else class="flex flex-col items-center justify-center py-10 text-(--ui-text-muted)">
              <div class="relative mb-4">
                <div class="size-16 rounded-2xl bg-(--ui-bg-muted) flex items-center justify-center">
                  <UIcon name="i-lucide-user-search" class="size-7 opacity-20" />
                </div>
                <div class="absolute -bottom-1.5 -right-1.5 size-6 rounded-full bg-(--ui-warning)/15 flex items-center justify-center">
                  <UIcon name="i-lucide-arrow-up" class="size-3.5 text-(--ui-warning)/60" />
                </div>
              </div>
              <p class="text-sm font-medium">还没有选择会员</p>
              <p class="text-xs mt-1 opacity-50">在上方搜索框中输入姓名、手机号或 ID 来查找会员</p>
            </div>
          </div>
        </template>
        <template #footer>
          <div class="flex items-center justify-between pt-1">
            <p v-if="assignMemberIds.length" class="text-xs text-(--ui-text-muted)">
              将为 <span class="font-semibold text-(--ui-text)">{{ assignMemberIds.length }}</span> 位会员各分配 1 张优惠券
            </p>
            <span v-else />
            <div class="flex gap-2.5">
              <UButton label="取消" color="neutral" variant="subtle" @click="assignOpen = false" />
              <UButton label="确认分配" color="primary" icon="i-lucide-send" :disabled="assignMemberIds.length === 0" @click="doAssign" />
            </div>
          </div>
        </template>
      </UModal>

      <!-- ═══ 删除确认弹窗 ═══ -->
      <UModal
        v-model:open="confirmDeleteOpen"
        title="确认删除"
        :ui="{ content: 'sm:max-w-md' }"
      >
        <template #body>
          <div class="flex flex-col items-center text-center py-4">
            <div class="size-14 rounded-2xl bg-(--ui-error)/10 flex items-center justify-center mb-5">
              <UIcon name="i-lucide-trash-2" class="size-7 text-(--ui-error)" />
            </div>
            <p class="text-sm text-(--ui-text)">
              确定要删除优惠券 <span class="font-semibold text-(--ui-text-highlighted)">「{{ deleteTarget?.title }}」</span> 吗？
            </p>
            <p class="text-xs text-(--ui-text-muted) mt-1.5">
              删除后已领取的记录仍保留，但该券将不再可用。此操作不可撤销。
            </p>
          </div>
        </template>
        <template #footer>
          <div class="flex justify-end gap-2.5 pt-1">
            <UButton label="取消" color="neutral" variant="subtle" @click="confirmDeleteOpen = false" />
            <UButton label="确认删除" color="error" icon="i-lucide-trash-2" @click="confirmDelete" />
          </div>
        </template>
      </UModal>

    </div>
  </ClientOnly>
</template>

<style scoped>
/* ── 列表动画 ── */
.coupon-list-enter-active { transition: all 0.35s ease-out; }
.coupon-list-leave-active { transition: all 0.25s ease-in; }
.coupon-list-enter-from { opacity: 0; transform: translateY(-8px); }
.coupon-list-leave-to { opacity: 0; transform: translateX(20px); }
.coupon-list-move { transition: transform 0.3s ease; }

/* ── 分配标签动画 ── */
.assign-tag-enter-active { transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.assign-tag-leave-active { transition: all 0.2s ease-in; }
.assign-tag-enter-from { opacity: 0; transform: scale(0.7); }
.assign-tag-leave-to { opacity: 0; transform: scale(0.7) translateY(-4px); }
.assign-tag-move { transition: transform 0.3s ease; }

/* ── 搜索下拉动画 ── */
.dropdown-fade-enter-active { transition: all 0.2s ease-out; }
.dropdown-fade-leave-active { transition: all 0.15s ease-in; }
.dropdown-fade-enter-from { opacity: 0; transform: translateY(-6px) scale(0.98); }
.dropdown-fade-leave-to { opacity: 0; transform: translateY(-4px) scale(0.98); }
</style>
