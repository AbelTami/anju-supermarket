# 安居超市管理系统 (Anju Supermarket Management System)

SAAS 多租户前后端分离超市管理系统。基于 **Nuxt 4 + Vue 3 + Nuxt UI v4** 前端，**Django + Django REST Framework** 后端，**PostgreSQL** 数据库。

## 技术栈

| 层 | 技术 | 版本 |
|---|---|---|
| 前端框架 | Nuxt | 4.4.x |
| UI 组件 | Nuxt UI (Tailwind CSS v4) | 4.x |
| 前端语言 | TypeScript / Vue 3 | 3.5.x |
| 图表 | Unovis | — |
| 后端框架 | Django | 5.x |
| API | Django REST Framework | — |
| 认证 | JWT (simplejwt) | — |
| 数据库 | PostgreSQL | 18 |
| 包管理 | pnpm | 11.x |

## 项目结构

```
anju-supermarket/
├── dashboard/          # 前端 Nuxt 4 项目
│   ├── app/            # 页面、组件、composables
│   │   ├── pages/      # 路由页面
│   │   ├── components/ # Vue 组件
│   │   ├── composables/# useAuth, useDashboard
│   │   ├── layouts/    # default.vue, auth.vue
│   │   └── middleware/ # auth.global.ts
│   ├── server/         # BFF 代理层
│   │   └── api/
│   │       ├── auth/   # 登录/注册/刷新
│   │       └── tenant/ # 租户 API 代理
│   └── nuxt.config.ts
├── backend/            # 后端 Django 项目
│   ├── config/         # Django 配置
│   ├── apps/           # 业务模块
│   │   ├── tenants/    # 租户管理
│   │   ├── accounts/   # 用户与认证
│   │   ├── products/   # 商品管理 (SPU+SKU)
│   │   ├── inventory/  # 库存管理
│   │   ├── pos/        # 收银/POS
│   │   ├── members/    # 会员管理
│   │   ├── suppliers/  # 供应商管理
│   │   ├── employees/  # 员工管理
│   │   └── finance/    # 财务/报表
│   ├── common/         # 多租户中间件、权限
│   └── manage.py
└── README.md
```

## 功能模块

| 模块 | 功能 | API 端点 |
|---|---|---|
| 🏠 首页仪表盘 | 实时营业额/订单统计、趋势图、近期订单 | `/api/{slug}/daily-summaries/` |
| 💰 收银/POS | 商品搜索、购物车、现金/微信/支付宝/会员结算 | `/api/{slug}/orders/` |
| 📦 商品管理 | 分类管理、SPU/SKU、条码、多规格 | `/api/{slug}/products/` |
| 📋 库存管理 | 入库/出库、库存流水、实时库存更新 | `/api/{slug}/inventory-records/` |
| 👥 会员管理 | 会员注册、积分、储值余额 | `/api/{slug}/members/` |
| 🚚 供应商管理 | 供应商信息、联系人 | `/api/{slug}/suppliers/` |
| 👤 员工管理 | 添加员工、角色分配 | `/api/{slug}/employees/` |
| 📊 财务/报表 | 日/周/月聚合、营业额/订单统计 | `/api/{slug}/daily-summaries/overview/` |
| ⚙️ 系统设置 | 超市信息、员工账号、角色权限、打印模板 | `/api/{slug}/` |
| 🔐 认证 | JWT 登录/注册、密码修改 | `/api/auth/` |

### 角色权限

| 角色 | 商品 | 库存 | POS | 会员 | 供应商 | 员工 | 财务 | 设置 |
|---|---|---|---|---|---|---|---|---|
| 超级管理员 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 店长 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| 收银员 | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 库管 | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| 财务 | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |

## 快速启动

### 环境要求

| 依赖 | 版本 |
|---|---|
| Python | 3.12+ |
| Node.js | 22+ |
| pnpm | 11+ |
| PostgreSQL | 16+ |

### 4 步启动

```bash
# 1. 克隆项目
git clone <your-repo-url>
cd anju-supermarket

# 2. 启动后端
cd backend
pip install -r requirements/base.txt
cp .env.example .env          # 按需修改数据库密码
psql -U postgres -c "CREATE DATABASE anju_db;"
python manage.py migrate
python manage.py runserver 8000

# 3. 启动前端 (新终端)
cd dashboard
pnpm install
pnpm dev
# → 打开 http://localhost:3000
```

### 导入测试数据（可选）

```bash
cd backend
psql -U postgres anju_db < seed.sql
```

导入后包含：1 个超市 + 6 个商品（含 SKU）+ 2 个会员 + 2 个供应商 + 37 笔订单（跨 14 天）。

## 测试账号

| 角色 | 账号 | 密码 | 超市 |
|---|---|---|---|
| 超级管理员 | anjuadmin | 123456789 | 安居生活超市 |
| 超级管理员 | admin | admin123 | — |

> 注册页面 `http://localhost:3000/auth/register` 可自助创建新超市。

## API 架构

```
浏览器 → Nuxt BFF (:3000) → Django REST (:8000) → PostgreSQL
         │                       │
    登录/注册/token刷新      业务 API (租户隔离)
    Cookie: access_token      Authorization: Bearer
    Cookie: refresh_token     租户通过 URL: /api/{slug}/...
```

- **BFF 代理:** `dashboard/server/api/tenant/[slug]/[...].ts` 自动转发所有租户 API
- **认证:** Nuxt middleware 全局守卫，未登录自动跳转 `/auth/login`
- **多租户:** Django TenantMiddleware 从 URL 提取 slug，所有查询自动过滤

## 环境变量

### 后端 `.env`

```env
DB_NAME=anju_db
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DJANGO_SECRET_KEY=your-secret
```

### 前端 `nuxt.config.ts`

BFF 代理目标地址硬编码 `http://localhost:8000`，生产环境需修改。

## 开发约定

- 前端全局遵循 [Nuxt UI v4 规范](https://ui.nuxt.com)
- 图标使用 `i-lucide-*` (Lucide 图标集)
- 语义色：`text-default`、`bg-elevated`、`text-dimmed` 等
- 后端遵循 RESTful API 设计
- 所有模型继承 `TenantAwareModel` 自动多租户隔离

## License

MIT
