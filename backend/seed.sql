-- ============================================
-- 安居超市 - Development Seed Data (SANITIZED)
-- 此文件为脱敏开发数据，不含真实 PII
-- 生成命令: python manage.py dumpdata --exclude auth.user --indent 2
-- ============================================

-- WARNING: 生产环境请使用 python manage.py loaddata fixtures/dev.json
-- 切勿将生产 pg_dump 提交到版本控制

-- 示例租户数据（仅开发使用）
INSERT INTO tenant (id, name, slug, is_active) VALUES
  (1, '测试超市', 'test-shop', true)
ON CONFLICT DO NOTHING;
