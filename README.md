# 安居超市管理系统 (Anju Supermarket)

SAAS 多租户前后端分离超市管理系统。**Nuxt 4 + Nuxt UI v4** 前端，**Django REST Framework** 后端，**PostgreSQL** 数据库。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端框架 | Nuxt 4.4 + Vue 3.5 + TypeScript |
| UI | Nuxt UI v4 + Tailwind CSS v4 |
| 后端 | Django 6 + DRF |
| 认证 | JWT (simplejwt) 管理端 + Token (SHA-256) 会员端 |
| 数据库 | PostgreSQL 18 |
| 实时推送 | SSE (Server-Sent Events) |
| AI 助手 | OpenHarness + 65 个 Skills (antfu/mattpocock/ponytail/nuxt-ui) |

## 项目结构

```
anju-supermarket/
├── dashboard/              # Nuxt 4 前端
│   ├── app/
│   │   ├── pages/
│   │   │   ├── [slug]/     # 顾客前台 (门店)
│   │   │   │   ├── index.vue           # 商品列表
│   │   │   │   ├── product/[id].vue    # 商品详情
│   │   │   │   ├── cart.vue            # 购物车 (全选联动+划线原价+库存预警+左滑删除+为你推荐)
│   │   │   │   ├── checkout.vue        # 结算 (余额抵扣+优惠券+下单确认+打印小票)
│   │   │   │   ├── orders.vue          # 我的订单
│   │   │   │   ├── member.vue          # 会员中心
│   │   │   │   ├── login.vue           # 顾客登录
│   │   │   │   ├── coupons.vue         # 优惠券
│   │   │   │   ├── analytics.vue       # 消费分析
│   │   │   │   ├── favorites.vue       # 收藏
│   │   │   │   └── recharge.vue        # 充值中心
│   │   │   └── admin/      # 管理后台
│   │   │       ├── index.vue           # 仪表盘 (实时订单推送)
│   │   │       ├── pos.vue             # 收银台 (结算+打印小票)
│   │   │       ├── products.vue        # 商品管理
│   │   │       ├── inventory.vue       # 库存管理 (低库存预警)
│   │   │       ├── customers.vue       # 会员管理
│   │   │       ├── suppliers.vue       # 供应商管理
│   │   │       ├── employees.vue       # 员工管理 (角色编辑+停用)
│   │   │       ├── finance.vue         # 财务/报表
│   │   │       ├── inbox.vue           # 消息通知
│   │   │       └── settings/           # 系统设置
│   │   │           ├── index.vue       # 超市信息+运营广播
│   │   │           ├── members.vue     # 员工账号
│   │   │           ├── roles.vue       # 角色权限 (权限矩阵+成员分配)
│   │   │           ├── printer.vue     # 打印模板 (纸张格式+页眉页脚+条码开关)
│   │   │           └── coupons.vue     # 优惠券管理
│   │   ├── components/
│   │   │   ├── role/                   # 角色管理组件 (RoleCard/RoleMatrix/RoleMembers)
│   │   │   ├── BroadcastBanner.vue     # 运营广播横幅
│   │   │   ├── NotificationsSlideover.vue  # 实时订单侧边栏
│   │   │   └── UserMenu.vue            # 用户菜单 (修改密码Modal)
│   │   ├── composables/
│   │   │   ├── useAuth.ts              # 管理端认证
│   │   │   ├── useRoles.ts             # 角色权限状态管理
│   │   │   ├── useShopCart.ts          # 购物车 (不可变更新)
│   │   │   ├── useReceiptPrint.ts      # 小票打印 (HTML生成+浏览器打印)
│   │   │   ├── useRealtimeOrders.ts    # SSE实时订单
│   │   │   ├── useMemberAuth.ts        # 会员认证
│   │   │   ├── useCurrentTenant.ts     # 当前租户上下文
│   │   │   └── usePermissions.ts       # 权限检查
│   │   └── layouts/
│   │       ├── dashboard.vue           # 管理后台布局
│   │       ├── shop.vue                # 顾客前台布局
│   │       └── auth.vue                # 登录/注册布局
│   └── server/api/
│       ├── auth/           # 管理端 BFF 代理 (JWT Cookie)
│       ├── tenant/         # 管理端租户 API 代理
│       └── shop/           # 顾客端 BFF 代理 (Token 透传)
├── backend/                # Django 后端
│   ├── apps/
│   │   ├── tenants/        # 租户管理 (超市信息+广播+打印模板)
│   │   ├── accounts/       # 用户与认证 (密码强度校验)
│   │   ├── products/       # 商品管理 (SPU+SKU + 条码查询)
│   │   ├── inventory/      # 库存管理 + 盘点 (StockCheck)
│   │   ├── pos/            # 收银/订单 + SSE 实时推送
│   │   ├── members/        # 会员管理 (含顾客登录/充值/扣减)
│   │   ├── suppliers/      # 供应商管理
│   │   ├── employees/      # 员工管理 (角色 + 超管保护)
│   │   ├── coupons/        # 优惠券 (品类限制+首单+校验链)
│   │   └── finance/        # 财务/报表
│   ├── common/             # 多租户中间件、权限、Token 工具、SSE 总线
│   ├── config/settings/    # base.py + prod.py
│   ├── seed_data_utf8.json # 开发种子数据 (UTF-8)
│   ├── anju_db_dump.sql    # PostgreSQL 完整备份
│   └── setup_db.py         # 数据库初始化脚本
└── README.md
```

## 路由架构

| 路由 | 用途 | Layout | 认证 |
|---|---|---|---|
| `/` | 默认跳转到门店前台 | — | 公开 |
| `/{slug}` | 门店首页 (商品浏览) | `shop` | 公开 |
| `/{slug}/product/{id}` | 商品详情 | `shop` | 公开 |
| `/{slug}/cart` | 购物车 | `shop` | 公开 |
| `/{slug}/checkout` | 结算 | `shop` | 公开 |
| `/{slug}/login` | 顾客登录 | `shop` | 公开 |
| `/{slug}/orders` | 订单历史 | `shop` | 会员 |
| `/{slug}/member` | 会员中心 | `shop` | 会员 |
| `/{slug}/coupons` | 优惠券 | `shop` | 会员 |
| `/{slug}/analytics` | 消费分析 | `shop` | 会员 |
| `/{slug}/favorites` | 收藏 | `shop` | 会员 |
| `/{slug}/recharge` | 充值中心 | `shop` | 会员 |
| `/admin` | 仪表盘 | `dashboard` | 管理员 |
| `/admin/pos` | 收银台 | `dashboard` | 管理员 |
| `/admin/products` | 商品管理 | `dashboard` | 管理员 |
| `/admin/settings/roles` | 角色权限 | `dashboard` | 管理员 |
| `/admin/settings/printer` | 打印模板 | `dashboard` | 管理员 |
| `/admin/*` | 其他管理页面 | `dashboard` | 管理员 |

## 功能模块

### 🏪 顾客前台

| 功能 | 说明 |
|---|---|
| 商品浏览 | 分类筛选、关键词搜索、排序 |
| 商品详情 | 图片、规格选择、加购 |
| 购物车 | 全选联动、划线原价、库存预警、左滑删除、为你推荐 |
| 结算 | 余额抵扣、优惠券、下单确认、**打印小票** |
| 订单追踪 | 订单列表、展开明细 |
| 会员中心 | 积分、余额、消费记录、等级 |
| 会员登录 | 手机号 + 密码 |
| 优惠券 | 领券中心、品类限制、首单优惠 |
| 消费分析 | 消费趋势、月度图表 |
| 收藏 | 收藏商品、即时取消 |
| 充值中心 | 储值充值 (预设金额+自定义) |

### 🖥️ 管理后台

| 模块 | 功能 |
|---|---|
| 收银/POS | 扫码/搜索商品、购物车、四种支付方式、**结算后打印小票** |
| 商品管理 | 分类、SPU/SKU、条码 (租户级唯一)、图片上传、扫码录入 |
| 库存管理 | 入库/出库流水、**低库存预警**、**盘点单 (创建+明细+自动完成)** |
| 消息通知 | **实时订单推送** (SSE)、铃铛红点、侧边栏 badge |
| 会员管理 | 会员 CRUD、积分、储值 |
| **优惠券管理** | **创建/分配/删除优惠券、品类限制 (文具券↛食品)、会员搜索分配、使用校验链** |
| 供应商管理 | 供应商信息 |
| 员工管理 | 员工账号、**角色编辑**、**停用保护 (禁止停用自己和最后一位超管)** |
| **角色权限** | **预定义角色、权限矩阵、成员分配、角色切换** |
| **打印模板** | **纸张格式 (58/80mm)、页眉信息、Logo/条码开关、页脚文字** |
| 财务/报表 | 日/周/月营业额统计 |
| 系统设置 | 超市信息、运营广播、修改密码 |

## 快速启动

### 环境要求

| 依赖 | 版本 |
|---|---|
| Python | 3.12+ |
| Node.js | 22+ |
| pnpm | 11+ |
| PostgreSQL | 16+ |

### 启动步骤

```bash
# 1. 克隆项目
git clone https://github.com/AbelTami/anju-supermarket.git
cd anju-supermarket

# 2. 配置环境变量
cp backend/.env.example backend/.env
# 编辑 backend/.env 填入数据库密码和密钥

# 3. 创建数据库
createdb -U postgres anju_db

# 4. 导入数据库 (二选一)
# 方式 A: pg_dump 完整恢复 (推荐，含所有数据和Schema)
psql -U postgres anju_db < backend/anju_db_dump.sql

# 方式 B: Django migrate + seed
cd backend
python -m pip install -r requirements/base.txt
python manage.py migrate
python manage.py loaddata seed_data_utf8.json

# 5. 启动后端
cd backend
python manage.py runserver 8000

# 6. 启动前端 (新终端)
cd dashboard
pnpm install
pnpm dev
# → 打开 http://localhost:3000
```

## 测试账号

| 对象 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理员 | `admin` | `admin123` | 超级管理员 |
| 测试会员 | `13800000001` | `123456` | ZhangSan，积分+余额 |

## API 架构

```
浏览器 ──→ Nuxt BFF (:3000) ──→ Django REST (:8000) ──→ PostgreSQL
  │              │                        │
  │    /api/auth/*  (管理端JWT)     /api/{slug}/*  (业务API)
  │    /api/tenant/* (管理端代理)    租户隔离: TenantMiddleware
  │    /api/shop/*   (顾客端代理)    RLS: PostgreSQL row-level security
  │
  └── SSE (实时订单推送): /api/{slug}/orders/stream/
```

- **管理端认证:** JWT httpOnly Cookie，Nuxt BFF 代理转发
- **顾客端认证:** Member Token (SHA-256 哈希存储)，localStorage 持久化
- **多租户:** Django TenantMiddleware 从 URL slug 提取租户 + **PostgreSQL RLS 双重隔离**
- **条码录入:** Open Food Facts API 自动拉取商品名称和图片
- **实时推送:** SSE (Server-Sent Events)，订单创建即时推送到管理后台

## 安全

- **管理端:** JWT httpOnly Cookie (`SameSite=Strict`)，不返回 body
- **会员端:** Member Token SHA-256 哈希存储，30 天过期
- **权限:** 5 级角色 (收银员/库管/财务/店长/超管) + 10 模块权限矩阵
- **限流:** 匿名 120/分钟，用户 100/分钟，登录 5/分钟
- **防护:** CORS 白名单、请求体 5MB 上限、Slug 正则校验、路径穿越防护
- **数据库:** PostgreSQL RLS 行级安全、库存 `select_for_update` 防竞态、余额 TOCTOU 防护
- **超管保护:** 禁止停用最后一位超级管理员

## License

MIT
