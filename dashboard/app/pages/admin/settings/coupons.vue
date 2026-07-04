<script setup lang="ts">
/** 系统设置 → 优惠券管理 */
import { useAuth } from '~/composables/useAuth'

const auth = useAuth()
const toast = useToast()
const tenantSlug = computed(() => (auth.currentTenant.value as any)?.slug || '')
const apiUrl = computed(() => tenantSlug.value ? `/api/tenant/${tenantSlug.value}/coupons` : undefined)

const { data, status, refresh } = useFetch(apiUrl, { lazy: true, server: false, watch: [tenantSlug] })

// Create modal
const createOpen = ref(false)
const form = ref({ title: '', discount_type: 'fixed', discount_value: '', min_amount: '0', total_count: '100' })

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
      },
    })
    toast.add({ title: '优惠券创建成功', color: 'success' })
    createOpen.value = false
    form.value = { title: '', discount_type: 'fixed', discount_value: '', min_amount: '0', total_count: '100' }
    refresh()
  } catch { toast.add({ title: '创建失败', color: 'error' }) }
}

// Assign modal
const assignOpen = ref(false)
const assignCouponId = ref<number | null>(null)
const assignMemberId = ref('')
const assignMemberIds = ref<string[]>([])

function openAssign(couponId: number) {
  assignCouponId.value = couponId
  assignMemberIds.value = []
  assignMemberId.value = ''
  assignOpen.value = true
}

function addMember() {
  const id = assignMemberId.value.trim()
  if (id && !assignMemberIds.value.includes(id)) {
    assignMemberIds.value = [...assignMemberIds.value, id]
    assignMemberId.value = ''
  }
}

async function doAssign() {
  if (!assignCouponId.value || assignMemberIds.value.length === 0) return
  try {
    const resp = await $fetch(`/api/tenant/${tenantSlug.value}/coupons/${assignCouponId.value}/assign/`, {
      method: 'POST',
      body: { member_ids: assignMemberIds.value.map(Number) },
    })
    toast.add({ title: `已分配 ${(resp as any).assigned} 张`, color: 'success' })
    assignOpen.value = false
    refresh()
  } catch { toast.add({ title: '分配失败', color: 'error' }) }
}

const coupons = computed(() => (data.value as any)?.results || [])
</script>

<template>
  <div class="space-y-6">
    <UPageCard title="优惠券管理" description="创建和分配优惠券" variant="naked" orientation="horizontal">
      <UButton label="创建优惠券" icon="i-lucide-plus" @click="createOpen = true" />
    </UPageCard>

    <UPageCard variant="subtle" :ui="{ container: 'p-0 sm:p-0 gap-y-0' }">
      <div v-if="status === 'pending'" class="text-center py-8 text-dimmed">加载中...</div>
      <div v-else-if="coupons.length === 0" class="text-center py-8 text-dimmed">暂无优惠券</div>
      <div v-else class="divide-y divide-default">
        <div v-for="c in coupons" :key="c.id" class="flex items-center justify-between p-4 hover:bg-elevated/50">
          <div>
            <div class="font-medium">{{ c.title }}</div>
            <div class="text-sm text-dimmed">
              {{ c.discount_type_label }} ¥{{ c.discount_value }} · 满¥{{ c.min_amount }}可用
              · 已领 {{ c.used_count }}/{{ c.total_count }}
            </div>
          </div>
          <div class="flex items-center gap-2">
            <UBadge :color="c.is_active ? 'success' : 'neutral'" variant="subtle">{{ c.is_active ? '启用' : '停用' }}</UBadge>
            <UButton label="分配" size="xs" variant="soft" @click="openAssign(c.id)" />
          </div>
        </div>
      </div>
    </UPageCard>

    <!-- Create modal -->
    <UModal v-model:open="createOpen" title="创建优惠券">
      <template #body>
        <div class="space-y-4">
          <UFormField label="名称"><UInput v-model="form.title" placeholder="例：新人礼券" /></UFormField>
          <UFormField label="类型">
            <USelect v-model="form.discount_type" :items="[{ label: '满减', value: 'fixed' }, { label: '折扣', value: 'percent' }]" />
          </UFormField>
          <UFormField label="优惠值"><UInput v-model="form.discount_value" placeholder="10.00" /></UFormField>
          <UFormField label="最低消费"><UInput v-model="form.min_amount" placeholder="50.00" /></UFormField>
          <UFormField label="发行数量"><UInput v-model="form.total_count" placeholder="100" /></UFormField>
          <div class="flex justify-end gap-2">
            <UButton label="取消" color="neutral" variant="subtle" @click="createOpen = false" />
            <UButton label="创建" color="primary" @click="createCoupon" />
          </div>
        </div>
      </template>
    </UModal>

    <!-- Assign modal -->
    <UModal v-model:open="assignOpen" title="分配优惠券">
      <template #body>
        <div class="space-y-4">
          <div class="flex gap-2">
            <UInput v-model="assignMemberId" placeholder="输入会员ID" class="flex-1" @keyup.enter="addMember" />
            <UButton label="添加" variant="soft" @click="addMember" />
          </div>
          <div v-if="assignMemberIds.length" class="flex flex-wrap gap-1">
            <UBadge v-for="id in assignMemberIds" :key="id" color="primary" variant="subtle">会员 #{{ id }}</UBadge>
          </div>
          <div class="flex justify-end gap-2">
            <UButton label="取消" color="neutral" variant="subtle" @click="assignOpen = false" />
            <UButton label="确认分配" color="primary" @click="doAssign" />
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>
