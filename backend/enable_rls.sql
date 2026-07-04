-- ============================================
-- 安居超市 - Row-Level Security (RLS) Policies
-- 对所有多租户业务表启用行级安全
-- 执行方式: psql -U postgres -d anju_db -f enable_rls.sql
-- ============================================

BEGIN;

-- 对所有租户表启用 RLS 并创建隔离策略
-- 每条策略确保: tenant_id = current_setting('app.tenant_id')::bigint

-- 1. tenant (租户表本身不需要 RLS — 通过 middleware slug 解析)
-- 2. user_tenant (通过 request.user + request.tenant 关联，跳过 RLS)
-- 3. product_category
ALTER TABLE product_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_category FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON product_category
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 4. product
ALTER TABLE product ENABLE ROW LEVEL SECURITY;
ALTER TABLE product FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON product
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 5. product_sku
ALTER TABLE product_sku ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_sku FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON product_sku
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 6. member
ALTER TABLE member ENABLE ROW LEVEL SECURITY;
ALTER TABLE member FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON member
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 7. supplier
ALTER TABLE supplier ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON supplier
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 8. pos_order
ALTER TABLE pos_order ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_order FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON pos_order
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 9. pos_order_item
ALTER TABLE pos_order_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_order_item FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON pos_order_item
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 10. inventory_record
ALTER TABLE inventory_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_record FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON inventory_record
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 11. stock_check
ALTER TABLE stock_check ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_check FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON stock_check
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 12. employee_shift
ALTER TABLE employee_shift ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_shift FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON employee_shift
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

-- 13. finance_daily_summary
ALTER TABLE finance_daily_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_daily_summary FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON finance_daily_summary
  USING (tenant_id = current_setting('app.tenant_id')::bigint)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::bigint);

COMMIT;
