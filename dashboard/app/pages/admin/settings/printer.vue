<script setup lang="ts">
/** 系统设置 → 打印模板 */
const auth = useAuth()
const toast = useToast()
const tenantSlug = useCurrentTenantSlug()

const paperWidth = ref('58')
const showLogo = ref(true)
const showBarcode = ref(true)
const storeName = ref('')
const address = ref('')
const phone = ref('')
const businessHours = ref('')
const footerText = ref('')
const saving = ref(false)

// Pre-fill from tenant info
const seeded = ref(false)
watch(() => auth.currentTenant.value, (tenant) => {
  if (seeded.value || !tenant) return
  const t = tenant as Record<string, any>
  storeName.value = t.name ?? ''
  address.value = t.address ?? ''
  phone.value = t.phone ?? ''
  businessHours.value = t.business_hours ?? ''
  paperWidth.value = t.paper_width ?? '58'
  showLogo.value = t.print_logo ?? true
  showBarcode.value = t.print_barcode ?? true
  footerText.value = t.footer_text ?? ''
  seeded.value = true
}, { immediate: true })

const paperOptions = [
  { label: '58mm 热敏纸（标准）', value: '58' },
  { label: '80mm 热敏纸（宽版）', value: '80' },
]

async function save() {
  saving.value = true
  try {
    await $fetch(`/api/tenant/${tenantSlug.value}/`, {
      method: 'PATCH',
      body: {
        name: storeName.value,
        address: address.value,
        phone: phone.value,
        business_hours: businessHours.value,
        paper_width: paperWidth.value,
        print_logo: showLogo.value,
        print_barcode: showBarcode.value,
        footer_text: footerText.value,
      },
    })
    toast.add({ title: '打印设置已保存', color: 'success' })
  } catch {
    toast.add({ title: '保存失败', color: 'error' })
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <UPageCard
      title="打印模板"
      description="配置小票打印机纸张格式及打印内容"
      variant="naked"
      orientation="horizontal"
    >
      <UButton
        label="保存设置"
        color="neutral"
        :loading="saving"
        class="w-fit lg:ms-auto"
        @click="save"
      />
    </UPageCard>

    <!-- Paper format -->
    <UPageCard title="纸张格式" variant="subtle">
      <UFormField label="纸张宽度">
        <USelect v-model="paperWidth" :items="paperOptions" class="max-w-xs" />
      </UFormField>
    </UPageCard>

    <!-- Store info -->
    <UPageCard title="超市信息" description="打印在小票页眉，默认取超市信息" variant="subtle" class="space-y-4">
      <UFormField label="超市名称" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="storeName" class="max-w-sm" placeholder="超市名称" />
      </UFormField>
      <USeparator />
      <UFormField label="地址" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="address" class="max-w-sm" placeholder="详细地址" />
      </UFormField>
      <USeparator />
      <UFormField label="联系电话" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="phone" class="max-w-sm" placeholder="客服电话" />
      </UFormField>
      <USeparator />
      <UFormField label="营业时间" class="flex max-sm:flex-col justify-between items-start gap-4">
        <UInput v-model="businessHours" class="max-w-sm" placeholder="如 09:00-22:00" />
      </UFormField>
    </UPageCard>

    <!-- Print content -->
    <UPageCard title="打印内容" variant="subtle" class="space-y-3">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-(--ui-text)">打印超市 Logo</p>
          <p class="text-xs text-(--ui-text-muted) mt-0.5">在页眉显示超市品牌标识</p>
        </div>
        <USwitch v-model="showLogo" size="md" />
      </div>
      <USeparator />
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-(--ui-text)">打印商品条码</p>
          <p class="text-xs text-(--ui-text-muted) mt-0.5">退换货时扫码读取订单信息</p>
        </div>
        <USwitch v-model="showBarcode" size="md" />
      </div>
    </UPageCard>

    <!-- Footer -->
    <UPageCard title="页脚文字" description="打印在小票底部，支持感谢语和退换货政策" variant="subtle" class="space-y-3">
      <UTextarea
        v-model="footerText"
        :rows="3"
        placeholder="如：感谢您的光临！退换货请凭小票 7 日内办理。客服电话：0371-XXXXXXXX"
        class="w-full"
      />
      <p class="text-xs text-(--ui-text-muted)">
        示例：感谢您的光临！退换货请凭小票 7 日内办理
      </p>
    </UPageCard>
  </div>
</template>
