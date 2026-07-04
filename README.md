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
│   │   │       ├── index.vue           # 仪表盘 (实时订单推送)
│   │   │       ├── pos.vue             # 收银台
│   │   │       ├── products.vue        # 商品管理
│   │   │       ├── inventory.vue       # 库存管理 (低库存预警)
│   │   │       ├── customers.vue       # 会员管理
│   │   │       ├── suppliers.vue       # 供应商管理
│   │   │       ├── employees.vue       # 员工管理 (角色编辑+停用)
│   │   │       ├── finance.vue         # 财务/报表
│   │   │       ├── inbox.vue           # 消息通知
│   │   │       └── settings/           # 系统设置
│   │   ├── components/     # Vue 组件 (通知面板、图表等)
│   │   ├── composables/    # useAuth, useMemberAuth, useRealtimeOrders 等
│   │   └── layouts/        # dashboard.vue, shop.vue, auth.vue
│   └── server/api/
│       ├── auth/           # 管理端 BFF 代理 (JWT Cookie)
│       ├── tenant/         # 管理端租户 API 代理
│       └── shop/           # 顾客端 BFF 代理 (Token 透传)
├── backend/                # Django 后端
│   ├── apps/
│   │   ├── tenants/        # 租户管理
│   │   ├── accounts/       # 用户与认证 (密码强度校验)
│   │   ├── products/       # 商品管理 (SPU+SKU + 条码查询)
│   │   ├── inventory/      # 库存管理 + 盘点 (StockCheck)
│   │   ├── pos/            # 收银/订单 + SSE 实时推送
│   │   ├── members/        # 会员管理 (含顾客登录/充值/扣减)
│   │   ├── suppliers/      # 供应商管理
│   │   ├── employees/      # 员工管理 (角色 + 超管保护)
│   │   └── finance/        # 财务/报表
│   ├── common/             # 多租户中间件、权限、Token 工具、SSE 总线
│   ├── seed_data.json      # 开发种子数据 (Django fixture)
│   ├── enable_rls.sql      # PostgreSQL 行级安全策略
│   └── config/settings/    # base.py + prod.py
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
| 商品浏览 | 分类筛选、关键词搜索、排序 |
| 商品详情 | 图片、规格选择、加购 |
| 购物车 | 加减商品、实时计价 |
| 结算 | 到店支付 + 会员储值抵扣 |
| 订单追踪 | 订单列表、展开明细 |
| 会员中心 | 积分、余额、消费记录、等级 |
| 会员登录 | 手机号 + 密码 |
| 优惠券 | 领券中心、我的优惠券 |
| 消费分析 | 消费趋势、月度图表 |
| 收藏 | 收藏商品、即时取消 |
| 充值中心 | 储值充值 (预设金额+自定义) |

### 🖥️ 管理后台

| 模块 | 功能 |
|---|---|
| 收银/POS | 扫码/搜索商品、购物车、四种支付方式 |
| 商品管理 | 分类、SPU/SKU、条码 (租户级唯一)、图片上传、扫码录入 |
| 库存管理 | 入库/出库流水、**低库存预警**、**盘点单 (创建+明细+自动完成)** |
| 消息通知 | **实时订单推送** (SSE)、铃铛红点、侧边栏 badge |
| 会员管理 | 会员 CRUD、积分、储值 |
| **优惠券管理** | **创建/分配/删除优惠券、品类限制 (文具券↛食品)、会员搜索分配、使用校验链** |
| 供应商管理 | 供应商信息 |
| 员工管理 | 员工账号、**角色编辑**、**停用保护 (禁止停用自己和最后一位超管)** |
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
python manage.py loaddata seed_data.json  # 导入测试数据

# 4. 启动后端
python manage.py runserver 8000

# 5. 启动前端 (新终端)
cd dashboard
pnpm install
pnpm dev
# → 打开 http://localhost:3000
```

### 导入测试数据

**方式 1: Django fixture (推荐，跨环境兼容)**
```bash
cd backend
python manage.py loaddata seed_data.json
```

**方式 2: pg_dump 完整恢复**
```bash
psql -U postgres anju_db < backend/anju_db_dump.sql
```

导入后包含：1 个超市 + 50+ 条码商品 + 会员 (含积分和余额) + 50+ 订单历史 + 库存流水。

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

### 认证与授权
- **管理端:** JWT httpOnly Cookie（`SameSite=Strict`，生产环境 `Secure`），不返回 body
- **会员端:** Member Token SHA-256 哈希存储，30 天过期，登录刷新
- **密码:** Django `validate_password`（最少 8 位 + 常见密码黑名单 + 不能纯数字）
- **权限:** 订单创建需认证 (IsAuthenticated | HasMemberToken)；员工管理仅超管/经理可写；财务仅超管/经理可查看

### 防护措施
- DRF 限流（匿名 30/分钟，用户 100/分钟，登录 5/分钟）
- 请求体 5MB 上限（防止 DoS）
- CORS 白名单仅允许受信来源
- 会员手机号自动脱敏（非员工看到 `138****0001`）
- 外部 API 响应校验（URL scheme 检查 + HTML 转义）
- 租户 Slug 正则校验，无效请求返回 404
- `v-html` 前端 sanitize (XSS 防护)
- 路径穿越防护 (BFF proxy `..` 拒绝 + `%` 编码拦截)
- PostgreSQL RLS 行级安全策略
- 库存操作 `select_for_update` 防竞态
- 余额扣减 TOCTOU 防护 (检查在 atomic 内)
- 超级管理员停用保护 (禁止停用最后一位)

### 安全头（生产环境）
- `HSTS` + `includeSubDomains` + `preload`
- `SECURE_SSL_REDIRECT` / `SESSION_COOKIE_SECURE` / `CSRF_COOKIE_SECURE`
- `Content-Type: nosniff` / `X-XSS-Protection`
- `SECRET_KEY` / `DB_PASSWORD` 环境变量强制，无硬编码默认值
- 生产 `DEBUG=False`，Django admin 仅 DEBUG 模式启用

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

## AI 辅助开发

项目集成了 OpenHarness 和 65 个 Agent Skills：

| Skills 来源 | 数量 | 用途 |
|---|---|---|
| karpathy-skill | 1 | Karpathy 思维框架 |
| antfu/skills | 19 | Vue/Nuxt/Vite/Unocss 最佳实践 |
| mattpocock/skills | 38 | 工程化开发流程 |
| ponytail | 6 | YAGNI 极简代码 |
| nuxt-ui | 1 | Nuxt UI v4 组件文档 |

MCP: Nuxt UI 文档服务器 (`https://ui.nuxt.com/mcp`)

## License

MIT
