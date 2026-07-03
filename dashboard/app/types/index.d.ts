export type Period = 'daily' | 'weekly' | 'monthly'

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

export interface TenantInfo {
  id: number
  name: string
  slug: string
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
