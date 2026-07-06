# 安居超市管理系统 - Dashboard

Nuxt 4 + Nuxt UI v4 前端应用。包含 **顾客前台** (门店) 和 **管理后台** 两套布局。

## 技术栈

- Nuxt 4.4 + Vue 3.5
- Nuxt UI v4 (125+ 组件)
- Tailwind CSS v4
- TypeScript
- pnpm

## 快速启动

```bash
pnpm install
pnpm dev          # → http://localhost:3000
pnpm build        # 生产构建
pnpm preview      # 预览生产构建
```

## 目录结构

```
dashboard/
├── app/
│   ├── pages/
│   │   ├── [slug]/         # 顾客前台
│   │   └── admin/          # 管理后台
│   ├── components/
│   ├── composables/        # useAuth / useRoles / useShopCart / useReceiptPrint
│   ├── layouts/            # dashboard / shop / auth
│   └── types/
├── server/api/             # BFF 代理层
│   ├── auth/               # 管理端认证代理
│   ├── tenant/             # 管理端租户 API 代理
│   └── shop/               # 顾客端 API 代理
└── nuxt.config.ts
```

## 后端依赖

本前端依赖 Django 后端运行在 `http://localhost:8000`。启动方式见项目根目录 README。
