export type Period = 'daily' | 'weekly' | 'monthly'

export type Role = 'super_admin' | 'manager' | 'cashier' | 'warehouse' | 'accountant'

export interface Range {
  start: Date
  end: Date
}

/** Stat card — used by HomeStats component. */
export interface Stat {
  title: string
  icon: string
  value: number | string
  variation: number
}

// API response types

/**
 * Admin tenant info — 租户管理端返回的完整租户信息
 *
 * 使用场景:
 * - `/api/auth/profile` - 返回当前用户可访问的租户列表
 * - `/api/tenant/{slug}/` - 返回指定租户的详细信息（管理端）
 *
 * @property id - 租户唯一标识符
 * @property name - 超市名称
 * @property slug - URL友好的唯一标识符
 * @property broadcast_active - 是否启用运营广播
 * @property broadcast_message - 运营广播消息内容（最多200字）
 * @property broadcast_severity - 广告级别（info=通知, warning=注意, error=紧急）
 * @property role - 用户在该租户中的角色
 */
export interface TenantInfo {
  id: number
  name: string
  slug: string
  broadcast_active: boolean
  broadcast_message: string
  broadcast_severity: 'info' | 'warning' | 'error'
  role: Role
}

/**
 * Public tenant info — 顾客前台返回的公开租户信息
 *
 * 使用场景:
 * - `/api/shop/{slug}/info/` - 返回指定租户的公开信息（顾客端）
 *
 * @property name - 超市名称
 * @property slug - URL友好的唯一标识符
 * @property phone - 联系电话
 * @property address - 超市地址
 * @property business_hours - 营业时间
 * @property broadcast_active - 是否启用运营广播
 * @property broadcast_message - 运营广播消息内容
 * @property broadcast_severity - 广告级别（info=通知, warning=注意, error=紧急）
 */
export interface TenantPublicInfo {
  name: string
  slug: string
  phone: string
  address: string
  business_hours: string
  broadcast_active: boolean
  broadcast_message: string
  broadcast_severity: 'info' | 'warning' | 'error'
  paper_width: string
  print_barcode: boolean
  footer_text: string
}

export interface UserInfo {
  id: number
  username: string
  phone: string
  email: string
  first_name?: string
}

export interface PaginatedResponse<T> {
  count: number
  next: string | null
  previous: string | null
  results: T[]
}

export interface CategoryInfo {
  id: number
  name: string
  parent?: number | null
  children?: CategoryInfo[]
  sort_order?: number
}

export interface ProductSkuInfo {
  id: number
  barcode: string
  spec_name: string
  spec_attrs: Record<string, string>
  purchase_price: string
  selling_price: string
  stock_quantity: string
  stock_alert: string
}

export interface ProductInfo {
  id: number
  name: string
  category?: number | { id: number, name: string }
  category_name?: string
  image?: string
  image_url?: string
  /** Default selling price display */
  price?: string
  unit: string
  is_weighted: boolean
  is_active: boolean
  skus?: ProductSkuInfo[]
  sku_count?: number
  created_at?: string
  /** Rating score (0-5) */
  rating?: number
  /** Monthly sales count */
  monthly_sales?: number
  /** Whether product is new */
  is_new?: boolean
  /** Whether product is hot */
  is_hot?: boolean
  /** Discount percent (0-100) */
  discount?: number
  /** Original price before discount */
  original_price?: string
  /** Description HTML */
  description?: string
  /** Extra images */
  images?: string[]
  image_list?: string[]
}

export interface BannerInfo {
  id: number
  title: string
  subtitle?: string
  image: string
  link?: string
  sort_order?: number
  is_active?: boolean
}

export interface MemberInfo {
  id: number
  name: string
  phone: string
  card_no: string
  points: number
  balance: string
  total_spent: string
  remark: string
  tenant?: number
  created_at?: string
}

export interface OrderInfo {
  id: number
  order_no: string
  total_amount: string
  discount_amount: string
  paid_amount: string
  payment_method: string
  member?: number | null
  cashier_name?: string
  status: string
  paid_at: string
  items_count?: number
}

export interface EmployeeInfo {
  id: number
  username: string
  name?: string
  phone: string
  role?: string
  role_label?: string
  is_active: boolean
}

export interface SupplierInfo {
  id: number
  name: string
  contact: string
  phone: string
  address: string
  remark: string
}

export interface InventoryRecordInfo {
  id: number
  type: string
  type_label?: string
  quantity: string
  before_quantity: string
  after_quantity: string
  remark: string
  operator_name?: string
  created_at: string
}

export interface DailySummaryOverview {
  days: number
  period: string
  total_amount: number
  total_orders: number
  cash_amount: number
  wechat_amount: number
  alipay_amount: number
  member_amount: number
  daily: DailySummaryItem[]
}

export interface DailySummaryItem {
  date: string
  amount: number
  orders: number
  cash: number
  wechat: number
  alipay: number
  member: number
}

export interface Sale {
  id: string
  date: string
  status: 'paid' | 'failed' | 'refunded'
  email: string
  amount: number
}

export interface CouponInfo {
  id: number
  title: string
  minAmount: number
  discount: number
  code: string
  validUntil: string
  used: boolean
  expired: boolean
  discountRate?: number
}
