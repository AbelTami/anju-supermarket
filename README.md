# 安居超市管理系统 (Anju Supermarket)

SAAS 多租户前后端分离超市管理系统。**Nuxt 4 + Nuxt UI v4** 前端，**Django REST Framework** 后端，**PostgreSQL** 数据库。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端框架 | Nuxt 4.4 + Vue 3.5 + TypeScript |
| UI | Nuxt UI v4 + Tailwind CSS v4 |
| 后端 | Django 5/6 + DRF |
| 认证 | JWT (simplejwt) 管理端 + Token 会员端 |
| 数据库 | PostgreSQL 18 |
| 设计系统 | 自定义 CSS 设计系统（卡片、标签、动画、骨架屏） |

## 项目结构

```
anju-supermarket/
├── dashboard/              # Nuxt 4 前端
│   ├── app/
│   │   ├── pages/
│   │   │   ├── [slug]/     # 🆕 顾客前台 (门店)
│   │   │   │   ├── index.vue           # 商品列表
│   │   │   │   ├── product/[id].vue    # 商品详情
│   │   │   │   ├── cart.vue            # 购物车
│   │   │   │   ├── checkout.vue        # 结算
│   │   │   │   ├── orders.vue          # 我的订单
│   │   │   │   ├── member.vue          # 会员中心
│   │   │   │   ├── login.vue           # 顾客登录
│   │   │   │   ├── coupons.vue         # 优惠券
│   │   │   │   ├── analytics.vue       # 消费分析
│   │   │   │   ├── favorites.vue       # 收藏
│   │   │   │   └── recharge.vue        # 充值中心
│   │   │   └── admin/      # 管理后台
│   │   │       ├── index.vue           # 仪表盘
│   │   │       ├── pos.vue             # 收银台
│   │   │       ├── products.vue        # 商品管理
│   │   │       ├── inventory.vue       # 库存管理
│   │   │       ├── customers.vue       # 会员管理
│   │   │       ├── suppliers.vue       # 供应商管理
│   │   │       ├── employees.vue       # 员工管理
│   │   │       ├── finance.vue         # 财务/报表
│   │   │       └── settings/           # 系统设置
│   │   ├── components/     # Vue 组件
│   │   ├── composables/    # useAuth, useShopApi, useDashboard, useFavorite, useImageFallback
│   │   └── layouts/        # dashboard.vue, shop.vue, auth.vue
│   └── server/api/
│       ├── auth/           # 管理端 BFF 代理 (JWT Cookie)
│       ├── tenant/         # 管理端租户 API 代理
│       └── shop/           # 🆕 顾客端 BFF 代理 (Token 透传)
├── backend/                # Django 后端
│   ├── apps/
│   │   ├── tenants/        # 租户管理
│   │   ├── accounts/       # 用户与认证
│   │   ├── products/       # 商品管理 (SPU+SKU + 条码查询)
│   │   ├── inventory/      # 库存管理
│   │   ├── pos/            # 收银/订单
│   │   ├── members/        # 会员管理 (含顾客登录)
│   │   ├── suppliers/      # 供应商管理
│   │   ├── employees/      # 员工管理
│   │   └── finance/        # 财务/报表
│   └── common/             # 多租户中间件、权限
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
| `/admin/*` | 其他管理页面 | `dashboard` | 管理员 |

## 功能模块

### 🏪 顾客前台
| 功能 | 说明 |
|---|---|
| 商品浏览 | 分类筛选、关键词搜索 |
| 商品详情 | 图片、规格选择、加购 |
| 购物车 | 加减商品、实时计价 |
| 结算 | 到店支付 |
| 订单追踪 | 订单列表、展开明细 |
| 会员中心 | 积分、余额、消费记录 |
| 会员登录 | 手机号 + 密码 |
| 优惠券 | 领券中心、我的优惠券 |
| 消费分析 | 消费趋势图表 |
| 收藏 | 收藏商品 |
| 充值中心 | 会员储值 |

### 🖥️ 管理后台
| 模块 | 功能 |
|---|---|
| 收银/POS | 扫码/搜索商品、购物车、四种支付方式 |
| 商品管理 | 分类、SPU/SKU、条码、图片上传、扫码录入 |
| 库存管理 | 入库/出库流水、库存预警、彩色类型标签 |
| 优惠券管理 | 满减/折扣券 CRUD、启用/停用 |
| 会员管理 | 会员 CRUD、积分、储值 |
| 供应商管理 | 供应商信息 |
| 员工管理 | 员工账号、角色 |
| 财务/报表 | 日/周/月营业额统计 |
| 系统设置 | 超市信息、账号管理 |

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

# 3. 创建数据库 & 导入数据
createdb -U postgres anju_db
cd backend
python -m pip install -r requirements/base.txt
python manage.py migrate
psql -U postgres anju_db < seed.sql    # 可选：导入测试数据

# 4. 启动后端
python manage.py runserver 8000

# 5. 启动前端 (新终端)
cd dashboard
pnpm install
pnpm dev
# → 打开 http://localhost:3000
```

### 导入测试数据

```bash
cd backend
psql -U postgres anju_db < seed.sql
```

导入后包含：1 个超市 + 14 件商品 + 2 个会员 + 2 个供应商 + 44 笔订单。

## 测试账号

| 对象 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理员 | `boss` | `210414` | 超级管理员 |
| 测试会员 | `13800001001` | `123456` | 张三，100积分，¥50余额 |

## API 架构

```
浏览器 ──→ Nuxt BFF (:3000) ──→ Django REST (:8000) ──→ PostgreSQL
  │              │                        │
  │    /api/auth/*  (管理端JWT)     /api/{slug}/*  (业务API)
  │    /api/tenant/* (管理端代理)    租户隔离: TenantMiddleware
  │    /api/shop/*   (🆕 顾客端代理)
  │
  └── 直连 Django (仅图片加载, CORS 白名单)
```

- **管理端认证:** JWT httpOnly Cookie，Nuxt BFF 代理转发
- **顾客端认证:** Member Token + Cookie，新 BFF `/api/shop/` 代理
- **多租户:** Django TenantMiddleware 从 URL slug 提取租户，自动过滤
- **条码录入:** Open Food Facts API 自动拉取商品名称和图片

## 安全

### 认证与授权
- **管理端:** JWT httpOnly Cookie（`SameSite=Strict`，生产环境 `Secure`）
- **会员端:** Member Token，30 天过期，登录刷新
- **密码:** Django `pbkdf2_sha256` 哈希存储，最少 8 位 + 常见密码黑名单
- **权限:** 订单创建需会员 Token 或管理员认证；员工管理仅超管/经理可写

### 防护措施
- DRF 限流（匿名 30/分钟，用户 100/分钟，登录 5/分钟）
- 请求体 5MB 上限（防止 DoS）
- CORS 白名单仅允许受信来源
- 会员手机号自动脱敏（非员工看到 `138****0001`）
- 外部 API 响应校验（URL scheme 检查 + HTML 转义）
- 租户 Slug 正则校验，无效请求返回 404

### 安全头（生产环境）
- `Content-Type: nosniff` / `X-XSS-Protection`
- `SECRET_KEY` / `DB_PASSWORD` 环境变量强制，无硬编码默认值
- 所有依赖精确锁定版本

## 环境变量

### 后端 `.env`

```env
DB_NAME=anju_db
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_HOST=localhost
DB_PORT=5432
DJANGO_SECRET_KEY=change-this-in-production
DJANGO_DEBUG=True
```

## License

MIT
