--
-- PostgreSQL database dump
--

\restrict 579KTeCzwjpAdISysfpC6wgWN9hh27a0ZOZIEFx9LCdHlW1pmTDoaoWWbmgadd1

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.django_content_type VALUES (1, 'admin', 'logentry');
INSERT INTO public.django_content_type VALUES (2, 'auth', 'group');
INSERT INTO public.django_content_type VALUES (3, 'auth', 'permission');
INSERT INTO public.django_content_type VALUES (4, 'contenttypes', 'contenttype');
INSERT INTO public.django_content_type VALUES (5, 'sessions', 'session');
INSERT INTO public.django_content_type VALUES (6, 'tenants', 'tenant');
INSERT INTO public.django_content_type VALUES (7, 'accounts', 'user');
INSERT INTO public.django_content_type VALUES (8, 'accounts', 'usertenant');
INSERT INTO public.django_content_type VALUES (9, 'products', 'category');
INSERT INTO public.django_content_type VALUES (10, 'products', 'product');
INSERT INTO public.django_content_type VALUES (11, 'products', 'productsku');
INSERT INTO public.django_content_type VALUES (12, 'inventory', 'inventoryrecord');
INSERT INTO public.django_content_type VALUES (13, 'inventory', 'stockcheck');
INSERT INTO public.django_content_type VALUES (14, 'pos', 'order');
INSERT INTO public.django_content_type VALUES (15, 'pos', 'orderitem');
INSERT INTO public.django_content_type VALUES (16, 'members', 'member');
INSERT INTO public.django_content_type VALUES (17, 'suppliers', 'supplier');
INSERT INTO public.django_content_type VALUES (18, 'employees', 'shift');
INSERT INTO public.django_content_type VALUES (19, 'finance', 'dailysummary');


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.auth_permission VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO public.auth_permission VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO public.auth_permission VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO public.auth_permission VALUES (4, 'Can view log entry', 1, 'view_logentry');
INSERT INTO public.auth_permission VALUES (5, 'Can add permission', 3, 'add_permission');
INSERT INTO public.auth_permission VALUES (6, 'Can change permission', 3, 'change_permission');
INSERT INTO public.auth_permission VALUES (7, 'Can delete permission', 3, 'delete_permission');
INSERT INTO public.auth_permission VALUES (8, 'Can view permission', 3, 'view_permission');
INSERT INTO public.auth_permission VALUES (9, 'Can add group', 2, 'add_group');
INSERT INTO public.auth_permission VALUES (10, 'Can change group', 2, 'change_group');
INSERT INTO public.auth_permission VALUES (11, 'Can delete group', 2, 'delete_group');
INSERT INTO public.auth_permission VALUES (12, 'Can view group', 2, 'view_group');
INSERT INTO public.auth_permission VALUES (13, 'Can add content type', 4, 'add_contenttype');
INSERT INTO public.auth_permission VALUES (14, 'Can change content type', 4, 'change_contenttype');
INSERT INTO public.auth_permission VALUES (15, 'Can delete content type', 4, 'delete_contenttype');
INSERT INTO public.auth_permission VALUES (16, 'Can view content type', 4, 'view_contenttype');
INSERT INTO public.auth_permission VALUES (17, 'Can add session', 5, 'add_session');
INSERT INTO public.auth_permission VALUES (18, 'Can change session', 5, 'change_session');
INSERT INTO public.auth_permission VALUES (19, 'Can delete session', 5, 'delete_session');
INSERT INTO public.auth_permission VALUES (20, 'Can view session', 5, 'view_session');
INSERT INTO public.auth_permission VALUES (21, 'Can add 租户', 6, 'add_tenant');
INSERT INTO public.auth_permission VALUES (22, 'Can change 租户', 6, 'change_tenant');
INSERT INTO public.auth_permission VALUES (23, 'Can delete 租户', 6, 'delete_tenant');
INSERT INTO public.auth_permission VALUES (24, 'Can view 租户', 6, 'view_tenant');
INSERT INTO public.auth_permission VALUES (25, 'Can add 用户', 7, 'add_user');
INSERT INTO public.auth_permission VALUES (26, 'Can change 用户', 7, 'change_user');
INSERT INTO public.auth_permission VALUES (27, 'Can delete 用户', 7, 'delete_user');
INSERT INTO public.auth_permission VALUES (28, 'Can view 用户', 7, 'view_user');
INSERT INTO public.auth_permission VALUES (29, 'Can add 用户-租户关联', 8, 'add_usertenant');
INSERT INTO public.auth_permission VALUES (30, 'Can change 用户-租户关联', 8, 'change_usertenant');
INSERT INTO public.auth_permission VALUES (31, 'Can delete 用户-租户关联', 8, 'delete_usertenant');
INSERT INTO public.auth_permission VALUES (32, 'Can view 用户-租户关联', 8, 'view_usertenant');
INSERT INTO public.auth_permission VALUES (33, 'Can add 商品分类', 9, 'add_category');
INSERT INTO public.auth_permission VALUES (34, 'Can change 商品分类', 9, 'change_category');
INSERT INTO public.auth_permission VALUES (35, 'Can delete 商品分类', 9, 'delete_category');
INSERT INTO public.auth_permission VALUES (36, 'Can view 商品分类', 9, 'view_category');
INSERT INTO public.auth_permission VALUES (37, 'Can add 商品', 10, 'add_product');
INSERT INTO public.auth_permission VALUES (38, 'Can change 商品', 10, 'change_product');
INSERT INTO public.auth_permission VALUES (39, 'Can delete 商品', 10, 'delete_product');
INSERT INTO public.auth_permission VALUES (40, 'Can view 商品', 10, 'view_product');
INSERT INTO public.auth_permission VALUES (41, 'Can add 商品SKU', 11, 'add_productsku');
INSERT INTO public.auth_permission VALUES (42, 'Can change 商品SKU', 11, 'change_productsku');
INSERT INTO public.auth_permission VALUES (43, 'Can delete 商品SKU', 11, 'delete_productsku');
INSERT INTO public.auth_permission VALUES (44, 'Can view 商品SKU', 11, 'view_productsku');
INSERT INTO public.auth_permission VALUES (45, 'Can add 库存流水', 12, 'add_inventoryrecord');
INSERT INTO public.auth_permission VALUES (46, 'Can change 库存流水', 12, 'change_inventoryrecord');
INSERT INTO public.auth_permission VALUES (47, 'Can delete 库存流水', 12, 'delete_inventoryrecord');
INSERT INTO public.auth_permission VALUES (48, 'Can view 库存流水', 12, 'view_inventoryrecord');
INSERT INTO public.auth_permission VALUES (49, 'Can add 盘点单', 13, 'add_stockcheck');
INSERT INTO public.auth_permission VALUES (50, 'Can change 盘点单', 13, 'change_stockcheck');
INSERT INTO public.auth_permission VALUES (51, 'Can delete 盘点单', 13, 'delete_stockcheck');
INSERT INTO public.auth_permission VALUES (52, 'Can view 盘点单', 13, 'view_stockcheck');
INSERT INTO public.auth_permission VALUES (53, 'Can add 收银订单', 14, 'add_order');
INSERT INTO public.auth_permission VALUES (54, 'Can change 收银订单', 14, 'change_order');
INSERT INTO public.auth_permission VALUES (55, 'Can delete 收银订单', 14, 'delete_order');
INSERT INTO public.auth_permission VALUES (56, 'Can view 收银订单', 14, 'view_order');
INSERT INTO public.auth_permission VALUES (57, 'Can add 订单明细', 15, 'add_orderitem');
INSERT INTO public.auth_permission VALUES (58, 'Can change 订单明细', 15, 'change_orderitem');
INSERT INTO public.auth_permission VALUES (59, 'Can delete 订单明细', 15, 'delete_orderitem');
INSERT INTO public.auth_permission VALUES (60, 'Can view 订单明细', 15, 'view_orderitem');
INSERT INTO public.auth_permission VALUES (61, 'Can add 会员', 16, 'add_member');
INSERT INTO public.auth_permission VALUES (62, 'Can change 会员', 16, 'change_member');
INSERT INTO public.auth_permission VALUES (63, 'Can delete 会员', 16, 'delete_member');
INSERT INTO public.auth_permission VALUES (64, 'Can view 会员', 16, 'view_member');
INSERT INTO public.auth_permission VALUES (65, 'Can add 供应商', 17, 'add_supplier');
INSERT INTO public.auth_permission VALUES (66, 'Can change 供应商', 17, 'change_supplier');
INSERT INTO public.auth_permission VALUES (67, 'Can delete 供应商', 17, 'delete_supplier');
INSERT INTO public.auth_permission VALUES (68, 'Can view 供应商', 17, 'view_supplier');
INSERT INTO public.auth_permission VALUES (69, 'Can add 排班', 18, 'add_shift');
INSERT INTO public.auth_permission VALUES (70, 'Can change 排班', 18, 'change_shift');
INSERT INTO public.auth_permission VALUES (71, 'Can delete 排班', 18, 'delete_shift');
INSERT INTO public.auth_permission VALUES (72, 'Can view 排班', 18, 'view_shift');
INSERT INTO public.auth_permission VALUES (73, 'Can add 日结汇总', 19, 'add_dailysummary');
INSERT INTO public.auth_permission VALUES (74, 'Can change 日结汇总', 19, 'change_dailysummary');
INSERT INTO public.auth_permission VALUES (75, 'Can delete 日结汇总', 19, 'delete_dailysummary');
INSERT INTO public.auth_permission VALUES (76, 'Can view 日结汇总', 19, 'view_dailysummary');


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."user" VALUES (1, 'pbkdf2_sha256$1200000$oAu1WXDPY6PbhjqqWc3UHY$fYrDtjg3u3pSgUh4H+ghY+BazVuwID8Kdmay6NYSayg=', NULL, true, 'admin', '', '', 'admin@anju.com', true, true, '2026-06-30 17:30:38.226607+08', '', '');
INSERT INTO public."user" VALUES (2, 'pbkdf2_sha256$1200000$Y7peHjpv1dts8rDkNNUARn$CeBEWGCPkMLV90EA2qWp6/zfrZe9uRrvmSSF7JeboCY=', NULL, false, 'anjuadmin', '', '', '', false, true, '2026-06-30 17:38:03.169175+08', '13800138000', '');


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.django_migrations VALUES (1, 'tenants', '0001_initial', '2026-06-30 17:30:31.123943+08');
INSERT INTO public.django_migrations VALUES (2, 'contenttypes', '0001_initial', '2026-06-30 17:30:31.13276+08');
INSERT INTO public.django_migrations VALUES (3, 'contenttypes', '0002_remove_content_type_name', '2026-06-30 17:30:31.135601+08');
INSERT INTO public.django_migrations VALUES (4, 'auth', '0001_initial', '2026-06-30 17:30:31.154471+08');
INSERT INTO public.django_migrations VALUES (5, 'auth', '0002_alter_permission_name_max_length', '2026-06-30 17:30:31.163961+08');
INSERT INTO public.django_migrations VALUES (6, 'auth', '0003_alter_user_email_max_length', '2026-06-30 17:30:31.166193+08');
INSERT INTO public.django_migrations VALUES (7, 'auth', '0004_alter_user_username_opts', '2026-06-30 17:30:31.168128+08');
INSERT INTO public.django_migrations VALUES (8, 'auth', '0005_alter_user_last_login_null', '2026-06-30 17:30:31.169982+08');
INSERT INTO public.django_migrations VALUES (9, 'auth', '0006_require_contenttypes_0002', '2026-06-30 17:30:31.170569+08');
INSERT INTO public.django_migrations VALUES (10, 'auth', '0007_alter_validators_add_error_messages', '2026-06-30 17:30:31.172571+08');
INSERT INTO public.django_migrations VALUES (11, 'auth', '0008_alter_user_username_max_length', '2026-06-30 17:30:31.174509+08');
INSERT INTO public.django_migrations VALUES (12, 'auth', '0009_alter_user_last_name_max_length', '2026-06-30 17:30:31.176128+08');
INSERT INTO public.django_migrations VALUES (13, 'auth', '0010_alter_group_name_max_length', '2026-06-30 17:30:31.179399+08');
INSERT INTO public.django_migrations VALUES (14, 'auth', '0011_update_proxy_permissions', '2026-06-30 17:30:31.18169+08');
INSERT INTO public.django_migrations VALUES (15, 'auth', '0012_alter_user_first_name_max_length', '2026-06-30 17:30:31.183361+08');
INSERT INTO public.django_migrations VALUES (16, 'accounts', '0001_initial', '2026-06-30 17:30:31.213046+08');
INSERT INTO public.django_migrations VALUES (17, 'admin', '0001_initial', '2026-06-30 17:30:31.22841+08');
INSERT INTO public.django_migrations VALUES (18, 'admin', '0002_logentry_remove_auto_add', '2026-06-30 17:30:31.231953+08');
INSERT INTO public.django_migrations VALUES (19, 'admin', '0003_logentry_add_action_flag_choices', '2026-06-30 17:30:31.235195+08');
INSERT INTO public.django_migrations VALUES (20, 'employees', '0001_initial', '2026-06-30 17:30:31.246528+08');
INSERT INTO public.django_migrations VALUES (21, 'finance', '0001_initial', '2026-06-30 17:30:31.255809+08');
INSERT INTO public.django_migrations VALUES (22, 'products', '0001_initial', '2026-06-30 17:30:31.287044+08');
INSERT INTO public.django_migrations VALUES (23, 'inventory', '0001_initial', '2026-06-30 17:30:31.312472+08');
INSERT INTO public.django_migrations VALUES (24, 'members', '0001_initial', '2026-06-30 17:30:31.328473+08');
INSERT INTO public.django_migrations VALUES (25, 'pos', '0001_initial', '2026-06-30 17:30:31.355187+08');
INSERT INTO public.django_migrations VALUES (26, 'sessions', '0001_initial', '2026-06-30 17:30:31.369593+08');
INSERT INTO public.django_migrations VALUES (27, 'suppliers', '0001_initial', '2026-06-30 17:30:31.380467+08');
INSERT INTO public.django_migrations VALUES (28, 'pos', '0002_alter_orderitem_spec_name', '2026-06-30 17:46:25.996101+08');


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tenant VALUES (1, '安居生活超市', 'tpugxdr', '', '', '010-12345678', '', true, '2026-06-30 17:38:03.30844+08');


--
-- Data for Name: employee_shift; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: finance_daily_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product_category VALUES (1, '2026-06-30 17:44:06.155517+08', '2026-06-30 17:44:06.155526+08', '饮料', 0, NULL, 1);
INSERT INTO public.product_category VALUES (2, '2026-06-30 17:44:06.157752+08', '2026-06-30 17:44:06.157757+08', '食品', 0, NULL, 1);
INSERT INTO public.product_category VALUES (3, '2026-06-30 17:44:06.158352+08', '2026-06-30 17:44:06.158356+08', '乳制品', 0, NULL, 1);
INSERT INTO public.product_category VALUES (4, '2026-06-30 20:45:02.964117+08', '2026-06-30 20:45:02.964127+08', '零食', 0, NULL, 1);
INSERT INTO public.product_category VALUES (5, '2026-06-30 20:45:02.968426+08', '2026-06-30 20:45:02.968432+08', '酒类', 0, NULL, 1);
INSERT INTO public.product_category VALUES (6, '2026-06-30 20:45:02.969425+08', '2026-06-30 20:45:02.969429+08', '调味品', 0, NULL, 1);
INSERT INTO public.product_category VALUES (7, '2026-06-30 20:45:02.970293+08', '2026-06-30 20:45:02.970297+08', '日用品', 0, NULL, 1);
INSERT INTO public.product_category VALUES (8, '2026-06-30 20:45:02.971161+08', '2026-06-30 20:45:02.971165+08', '冷冻食品', 0, NULL, 1);
INSERT INTO public.product_category VALUES (9, '2026-06-30 20:45:02.972+08', '2026-06-30 20:45:02.972004+08', '粮油米面', 0, NULL, 1);
INSERT INTO public.product_category VALUES (10, '2026-06-30 20:45:02.972674+08', '2026-06-30 20:45:02.972678+08', '个人护理', 0, NULL, 1);
INSERT INTO public.product_category VALUES (11, '2026-06-30 20:45:02.9733+08', '2026-06-30 20:45:02.973303+08', '家居清洁', 0, NULL, 1);
INSERT INTO public.product_category VALUES (12, '2026-06-30 20:45:02.974137+08', '2026-06-30 20:45:02.97414+08', '文具玩具', 0, NULL, 1);


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product VALUES (2, '2026-06-30 17:44:06.163334+08', '2026-06-30 17:44:06.163338+08', '农夫山泉', '', '瓶', false, true, 1, 1);
INSERT INTO public.product VALUES (3, '2026-06-30 17:44:06.164151+08', '2026-06-30 17:44:06.164154+08', '康师傅方便面', '', '袋', false, true, 2, 1);
INSERT INTO public.product VALUES (4, '2026-06-30 17:44:06.164907+08', '2026-06-30 17:44:06.16491+08', '伊利纯牛奶', '', '盒', false, true, 3, 1);
INSERT INTO public.product VALUES (5, '2026-06-30 17:44:06.165857+08', '2026-06-30 17:44:06.165861+08', '旺旺雪饼', '', '袋', false, true, 2, 1);
INSERT INTO public.product VALUES (6, '2026-06-30 17:44:06.166837+08', '2026-06-30 17:44:06.16684+08', '青岛啤酒', '', '瓶', false, true, 1, 1);
INSERT INTO public.product VALUES (1, '2026-06-30 17:44:06.160456+08', '2026-06-30 18:09:14.348083+08', '可口可乐(大瓶)', '', '瓶', false, true, 1, 1);


--
-- Data for Name: product_sku; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product_sku VALUES (2, '2026-06-30 17:44:06.16374+08', '2026-06-30 17:44:06.163743+08', '6901234567891', '550ml', '{}', 1.00, 2.00, 200.000, 30.000, 2, 1);
INSERT INTO public.product_sku VALUES (3, '2026-06-30 17:44:06.164511+08', '2026-06-30 17:44:06.164514+08', '6901234567892', '红烧牛肉', '{}', 3.00, 4.50, 80.000, 10.000, 3, 1);
INSERT INTO public.product_sku VALUES (4, '2026-06-30 17:44:06.165375+08', '2026-06-30 17:44:06.165378+08', '6901234567893', '250ml', '{}', 4.00, 5.50, 60.000, 10.000, 4, 1);
INSERT INTO public.product_sku VALUES (5, '2026-06-30 17:44:06.166337+08', '2026-06-30 17:44:06.16634+08', '6901234567894', '520g', '{}', 8.00, 12.80, 45.000, 5.000, 5, 1);
INSERT INTO public.product_sku VALUES (6, '2026-06-30 17:44:06.167252+08', '2026-06-30 17:44:06.167256+08', '6901234567895', '500ml', '{}', 3.50, 6.00, 100.000, 15.000, 6, 1);
INSERT INTO public.product_sku VALUES (1, '2026-06-30 17:44:06.161724+08', '2026-06-30 17:44:06.161727+08', '6901234567890', '330ml', '{}', 2.00, 3.00, 200.000, 20.000, 1, 1);


--
-- Data for Name: inventory_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.inventory_record VALUES (1, '2026-06-30 17:53:05.277511+08', '2026-06-30 17:53:05.277521+08', 'purchase_in', 50.000, 150.000, 200.000, 'test', 2, 1, 1);


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.member VALUES (1, '2026-06-30 17:44:06.167962+08', '2026-06-30 17:44:06.167966+08', '张三', '13800001001', 'M001', 100, 50.00, 0.00, '', 1);
INSERT INTO public.member VALUES (2, '2026-06-30 17:44:06.169112+08', '2026-06-30 17:44:06.169115+08', '李四', '13800001002', 'M002', 200, 100.00, 0.00, '', 1);


--
-- Data for Name: pos_order; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pos_order VALUES (37, '2026-06-30 19:27:52.683836+08', '2026-06-30 19:30:32.439243+08', 'POS1782818872224', 4.00, 0.00, 4.00, 'member_card', 'completed', '2026-06-19 08:20:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (36, '2026-06-30 19:27:52.671918+08', '2026-06-30 19:30:32.440663+08', 'POS1782818872786', 27.50, 0.00, 27.50, 'cash', 'completed', '2026-06-17 10:31:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (35, '2026-06-30 19:27:52.65988+08', '2026-06-30 19:30:32.441396+08', 'POS1782818872413', 31.00, 0.00, 31.00, 'cash', 'completed', '2026-06-29 19:24:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (34, '2026-06-30 19:27:52.647162+08', '2026-06-30 19:30:32.442044+08', 'POS1782818872257', 50.40, 0.00, 50.40, 'alipay', 'completed', '2026-06-27 17:25:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (33, '2026-06-30 19:27:52.635371+08', '2026-06-30 19:30:32.442619+08', 'POS1782818872231', 51.90, 0.00, 51.90, 'member_card', 'completed', '2026-06-19 12:03:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (32, '2026-06-30 19:27:52.624261+08', '2026-06-30 19:30:32.443168+08', 'POS1782818872252', 12.00, 0.00, 12.00, 'cash', 'completed', '2026-06-30 19:32:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (31, '2026-06-30 19:27:52.611693+08', '2026-06-30 19:30:32.443614+08', 'POS1782818872245', 35.50, 0.00, 35.50, 'wechat', 'completed', '2026-06-29 15:00:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (30, '2026-06-30 19:27:52.599711+08', '2026-06-30 19:30:32.444116+08', 'POS1782818872282', 54.90, 0.00, 54.90, 'cash', 'completed', '2026-06-23 16:10:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (29, '2026-06-30 19:27:52.587306+08', '2026-06-30 19:30:32.444581+08', 'POS1782818872989', 9.00, 0.00, 9.00, 'member_card', 'completed', '2026-06-24 13:34:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (28, '2026-06-30 19:27:52.575474+08', '2026-06-30 19:30:32.444976+08', 'POS1782818872618', 6.00, 0.00, 6.00, 'cash', 'completed', '2026-06-19 10:30:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (27, '2026-06-30 19:27:52.564108+08', '2026-06-30 19:30:32.445343+08', 'POS1782818872214', 6.00, 0.00, 6.00, 'alipay', 'completed', '2026-06-26 13:54:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (26, '2026-06-30 19:27:52.551348+08', '2026-06-30 19:30:32.445705+08', 'POS1782818872320', 23.00, 0.00, 23.00, 'alipay', 'completed', '2026-06-19 18:19:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (25, '2026-06-30 19:27:52.540084+08', '2026-06-30 19:30:32.446057+08', 'POS1782818872982', 16.50, 0.00, 16.50, 'cash', 'completed', '2026-06-21 09:13:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (24, '2026-06-30 19:27:52.528564+08', '2026-06-30 19:30:32.446447+08', 'POS1782818872405', 9.00, 0.00, 9.00, 'alipay', 'completed', '2026-06-26 20:39:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (23, '2026-06-30 19:27:52.516052+08', '2026-06-30 19:30:32.446802+08', 'POS1782818872256', 47.90, 0.00, 47.90, 'wechat', 'completed', '2026-06-20 20:19:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (22, '2026-06-30 19:27:52.502801+08', '2026-06-30 19:30:32.447272+08', 'POS1782818872334', 37.50, 0.00, 37.50, 'wechat', 'completed', '2026-06-27 13:03:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (21, '2026-06-30 19:27:52.489487+08', '2026-06-30 19:30:32.447738+08', 'POS1782818872545', 27.00, 0.00, 27.00, 'alipay', 'completed', '2026-06-30 12:23:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (20, '2026-06-30 19:27:52.476184+08', '2026-06-30 19:30:32.448165+08', 'POS1782818872806', 36.00, 0.00, 36.00, 'cash', 'completed', '2026-06-28 20:50:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (19, '2026-06-30 19:27:52.462098+08', '2026-06-30 19:30:32.448699+08', 'POS1782818872423', 27.50, 0.00, 27.50, 'wechat', 'completed', '2026-06-23 21:29:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (18, '2026-06-30 19:27:52.449084+08', '2026-06-30 19:30:32.449236+08', 'POS1782818872617', 12.00, 0.00, 12.00, 'member_card', 'completed', '2026-06-30 09:07:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (17, '2026-06-30 19:27:52.4374+08', '2026-06-30 19:30:32.449746+08', 'POS1782818872622', 9.00, 0.00, 9.00, 'member_card', 'completed', '2026-06-27 15:36:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (16, '2026-06-30 19:27:52.425578+08', '2026-06-30 19:30:32.450266+08', 'POS1782818872997', 12.00, 0.00, 12.00, 'member_card', 'completed', '2026-06-29 13:06:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (15, '2026-06-30 19:27:52.413517+08', '2026-06-30 19:30:32.450788+08', 'POS1782818872387', 25.80, 0.00, 25.80, 'alipay', 'completed', '2026-06-23 21:23:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (14, '2026-06-30 19:27:52.402322+08', '2026-06-30 19:30:32.451311+08', 'POS1782818872611', 6.00, 0.00, 6.00, 'alipay', 'completed', '2026-06-19 10:24:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (13, '2026-06-30 19:27:52.389935+08', '2026-06-30 19:30:32.451839+08', 'POS1782818872978', 40.50, 0.00, 40.50, 'alipay', 'completed', '2026-06-22 12:39:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (12, '2026-06-30 19:27:52.377905+08', '2026-06-30 19:30:32.452373+08', 'POS1782818872507', 13.00, 0.00, 13.00, 'cash', 'completed', '2026-06-24 14:22:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (11, '2026-06-30 19:27:52.366367+08', '2026-06-30 19:30:32.452897+08', 'POS1782818872598', 2.00, 0.00, 2.00, 'wechat', 'completed', '2026-06-21 21:18:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (10, '2026-06-30 19:27:52.352904+08', '2026-06-30 19:30:32.453394+08', 'POS1782818872566', 42.60, 0.00, 42.60, 'member_card', 'completed', '2026-06-30 18:46:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (9, '2026-06-30 19:27:52.340503+08', '2026-06-30 19:30:32.453903+08', 'POS1782818872467', 43.90, 0.00, 43.90, 'alipay', 'completed', '2026-06-24 08:45:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (8, '2026-06-30 19:27:52.328071+08', '2026-06-30 19:30:32.454415+08', 'POS1782818872139', 9.50, 0.00, 9.50, 'member_card', 'completed', '2026-06-21 16:16:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (7, '2026-06-30 19:27:52.311934+08', '2026-06-30 19:30:32.454926+08', 'POS1782818872880', 21.00, 0.00, 21.00, 'member_card', 'completed', '2026-06-26 10:03:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (6, '2026-06-30 19:27:52.299218+08', '2026-06-30 19:30:32.455465+08', 'POS1782818872556', 37.50, 0.00, 37.50, 'alipay', 'completed', '2026-06-23 17:14:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (5, '2026-06-30 19:27:52.286637+08', '2026-06-30 19:30:32.456018+08', 'POS1782818872324', 40.40, 0.00, 40.40, 'cash', 'completed', '2026-06-29 13:23:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (4, '2026-06-30 19:27:52.274427+08', '2026-06-30 19:30:32.456571+08', 'POS1782818872854', 30.80, 0.00, 30.80, 'member_card', 'completed', '2026-06-27 16:25:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (3, '2026-06-30 19:27:52.259568+08', '2026-06-30 19:30:32.457128+08', 'POS1782818872424', 21.80, 0.00, 21.80, 'alipay', 'completed', '2026-06-19 12:28:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (2, '2026-06-30 17:46:44.071492+08', '2026-06-30 19:30:32.45802+08', 'POS1782812804862', 10.50, 0.00, 10.50, 'wechat', 'completed', '2026-06-18 12:18:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (1, '2026-06-30 17:45:39.214605+08', '2026-06-30 19:30:32.458555+08', 'POS1782812739548', 10.50, 0.00, 10.50, 'wechat', 'completed', '2026-06-26 09:25:00+08', 2, NULL, 1);
INSERT INTO public.pos_order VALUES (38, '2026-06-30 19:47:18.229739+08', '2026-06-30 19:47:18.229749+08', 'POS1782820038875', 5.50, 0.00, 5.50, 'alipay', 'completed', '2026-06-30 19:47:18.229773+08', 1, NULL, 1);


--
-- Data for Name: pos_order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pos_order_item VALUES (1, '2026-06-30 17:45:39.216592+08', '2026-06-30 17:45:39.216596+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 1, 1, 1);
INSERT INTO public.pos_order_item VALUES (2, '2026-06-30 17:46:44.072766+08', '2026-06-30 17:46:44.072769+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 2, 1, 1);
INSERT INTO public.pos_order_item VALUES (3, '2026-06-30 19:27:52.262191+08', '2026-06-30 19:27:52.262196+08', '康师傅方便面', '红烧牛肉', 3.000, 4.50, 13.50, 3, 4, 1);
INSERT INTO public.pos_order_item VALUES (4, '2026-06-30 19:27:52.263594+08', '2026-06-30 19:27:52.263599+08', '旺旺雪饼', '520g', 1.000, 12.80, 12.80, 3, 2, 1);
INSERT INTO public.pos_order_item VALUES (5, '2026-06-30 19:27:52.275248+08', '2026-06-30 19:27:52.275255+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 4, 3, 1);
INSERT INTO public.pos_order_item VALUES (6, '2026-06-30 19:27:52.275879+08', '2026-06-30 19:27:52.275883+08', '旺旺雪饼', '520g', 2.000, 12.80, 25.60, 4, 6, 1);
INSERT INTO public.pos_order_item VALUES (7, '2026-06-30 19:27:52.287438+08', '2026-06-30 19:27:52.287445+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 5, 3, 1);
INSERT INTO public.pos_order_item VALUES (8, '2026-06-30 19:27:52.288111+08', '2026-06-30 19:27:52.288115+08', '旺旺雪饼', '520g', 3.000, 12.80, 38.40, 5, 3, 1);
INSERT INTO public.pos_order_item VALUES (9, '2026-06-30 19:27:52.300024+08', '2026-06-30 19:27:52.30003+08', '康师傅方便面', '红烧牛肉', 1.000, 4.50, 4.50, 6, 1, 1);
INSERT INTO public.pos_order_item VALUES (10, '2026-06-30 19:27:52.300667+08', '2026-06-30 19:27:52.300671+08', '可口可乐', '330ml', 3.000, 3.00, 9.00, 6, 2, 1);
INSERT INTO public.pos_order_item VALUES (11, '2026-06-30 19:27:52.30124+08', '2026-06-30 19:27:52.301244+08', '青岛啤酒', '500ml', 1.000, 6.00, 6.00, 6, 6, 1);
INSERT INTO public.pos_order_item VALUES (12, '2026-06-30 19:27:52.315628+08', '2026-06-30 19:27:52.315633+08', '康师傅方便面', '红烧牛肉', 1.000, 4.50, 4.50, 7, 1, 1);
INSERT INTO public.pos_order_item VALUES (13, '2026-06-30 19:27:52.316304+08', '2026-06-30 19:27:52.316308+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 7, 4, 1);
INSERT INTO public.pos_order_item VALUES (14, '2026-06-30 19:27:52.329101+08', '2026-06-30 19:27:52.329106+08', '伊利纯牛奶', '250ml', 1.000, 5.50, 5.50, 8, 1, 1);
INSERT INTO public.pos_order_item VALUES (15, '2026-06-30 19:27:52.329738+08', '2026-06-30 19:27:52.329742+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 8, 2, 1);
INSERT INTO public.pos_order_item VALUES (16, '2026-06-30 19:27:52.341409+08', '2026-06-30 19:27:52.341414+08', '旺旺雪饼', '520g', 1.000, 12.80, 12.80, 9, 6, 1);
INSERT INTO public.pos_order_item VALUES (17, '2026-06-30 19:27:52.342079+08', '2026-06-30 19:27:52.342083+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 9, 3, 1);
INSERT INTO public.pos_order_item VALUES (18, '2026-06-30 19:27:52.353699+08', '2026-06-30 19:27:52.353703+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 10, 6, 1);
INSERT INTO public.pos_order_item VALUES (19, '2026-06-30 19:27:52.354608+08', '2026-06-30 19:27:52.354613+08', '可口可乐', '330ml', 1.000, 3.00, 3.00, 10, 2, 1);
INSERT INTO public.pos_order_item VALUES (20, '2026-06-30 19:27:52.355194+08', '2026-06-30 19:27:52.355198+08', '旺旺雪饼', '520g', 3.000, 12.80, 38.40, 10, 2, 1);
INSERT INTO public.pos_order_item VALUES (21, '2026-06-30 19:27:52.367036+08', '2026-06-30 19:27:52.36704+08', '农夫山泉', '550ml', 3.000, 2.00, 6.00, 11, 6, 1);
INSERT INTO public.pos_order_item VALUES (22, '2026-06-30 19:27:52.378493+08', '2026-06-30 19:27:52.378497+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 12, 1, 1);
INSERT INTO public.pos_order_item VALUES (23, '2026-06-30 19:27:52.379008+08', '2026-06-30 19:27:52.379013+08', '农夫山泉', '550ml', 1.000, 2.00, 2.00, 12, 1, 1);
INSERT INTO public.pos_order_item VALUES (24, '2026-06-30 19:27:52.390616+08', '2026-06-30 19:27:52.390621+08', '青岛啤酒', '500ml', 1.000, 6.00, 6.00, 13, 6, 1);
INSERT INTO public.pos_order_item VALUES (25, '2026-06-30 19:27:52.391177+08', '2026-06-30 19:27:52.391182+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 13, 3, 1);
INSERT INTO public.pos_order_item VALUES (26, '2026-06-30 19:27:52.391709+08', '2026-06-30 19:27:52.391713+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 13, 3, 1);
INSERT INTO public.pos_order_item VALUES (27, '2026-06-30 19:27:52.402913+08', '2026-06-30 19:27:52.402917+08', '青岛啤酒', '500ml', 2.000, 6.00, 12.00, 14, 4, 1);
INSERT INTO public.pos_order_item VALUES (28, '2026-06-30 19:27:52.414066+08', '2026-06-30 19:27:52.414069+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 15, 1, 1);
INSERT INTO public.pos_order_item VALUES (29, '2026-06-30 19:27:52.414485+08', '2026-06-30 19:27:52.414488+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 15, 3, 1);
INSERT INTO public.pos_order_item VALUES (30, '2026-06-30 19:27:52.414883+08', '2026-06-30 19:27:52.414888+08', '旺旺雪饼', '520g', 3.000, 12.80, 38.40, 15, 2, 1);
INSERT INTO public.pos_order_item VALUES (31, '2026-06-30 19:27:52.426387+08', '2026-06-30 19:27:52.426391+08', '青岛啤酒', '500ml', 2.000, 6.00, 12.00, 16, 2, 1);
INSERT INTO public.pos_order_item VALUES (32, '2026-06-30 19:27:52.438206+08', '2026-06-30 19:27:52.43821+08', '可口可乐', '330ml', 3.000, 3.00, 9.00, 17, 1, 1);
INSERT INTO public.pos_order_item VALUES (33, '2026-06-30 19:27:52.45007+08', '2026-06-30 19:27:52.450077+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 18, 4, 1);
INSERT INTO public.pos_order_item VALUES (34, '2026-06-30 19:27:52.450884+08', '2026-06-30 19:27:52.45089+08', '农夫山泉', '550ml', 3.000, 2.00, 6.00, 18, 2, 1);
INSERT INTO public.pos_order_item VALUES (35, '2026-06-30 19:27:52.463152+08', '2026-06-30 19:27:52.463158+08', '康师傅方便面', '红烧牛肉', 1.000, 4.50, 4.50, 19, 3, 1);
INSERT INTO public.pos_order_item VALUES (36, '2026-06-30 19:27:52.463905+08', '2026-06-30 19:27:52.46391+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 19, 6, 1);
INSERT INTO public.pos_order_item VALUES (37, '2026-06-30 19:27:52.46475+08', '2026-06-30 19:27:52.464755+08', '青岛啤酒', '500ml', 1.000, 6.00, 6.00, 19, 2, 1);
INSERT INTO public.pos_order_item VALUES (38, '2026-06-30 19:27:52.4772+08', '2026-06-30 19:27:52.477205+08', '伊利纯牛奶', '250ml', 2.000, 5.50, 11.00, 20, 2, 1);
INSERT INTO public.pos_order_item VALUES (39, '2026-06-30 19:27:52.477952+08', '2026-06-30 19:27:52.477958+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 20, 4, 1);
INSERT INTO public.pos_order_item VALUES (40, '2026-06-30 19:27:52.478606+08', '2026-06-30 19:27:52.478612+08', '农夫山泉', '550ml', 1.000, 2.00, 2.00, 20, 6, 1);
INSERT INTO public.pos_order_item VALUES (41, '2026-06-30 19:27:52.490439+08', '2026-06-30 19:27:52.490445+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 21, 1, 1);
INSERT INTO public.pos_order_item VALUES (42, '2026-06-30 19:27:52.491188+08', '2026-06-30 19:27:52.491192+08', '农夫山泉', '550ml', 1.000, 2.00, 2.00, 21, 2, 1);
INSERT INTO public.pos_order_item VALUES (43, '2026-06-30 19:27:52.49182+08', '2026-06-30 19:27:52.491824+08', '青岛啤酒', '500ml', 1.000, 6.00, 6.00, 21, 3, 1);
INSERT INTO public.pos_order_item VALUES (44, '2026-06-30 19:27:52.503726+08', '2026-06-30 19:27:52.503731+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 22, 6, 1);
INSERT INTO public.pos_order_item VALUES (45, '2026-06-30 19:27:52.504461+08', '2026-06-30 19:27:52.504467+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 22, 5, 1);
INSERT INTO public.pos_order_item VALUES (46, '2026-06-30 19:27:52.505146+08', '2026-06-30 19:27:52.505152+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 22, 6, 1);
INSERT INTO public.pos_order_item VALUES (47, '2026-06-30 19:27:52.516788+08', '2026-06-30 19:27:52.516793+08', '伊利纯牛奶', '250ml', 1.000, 5.50, 5.50, 23, 4, 1);
INSERT INTO public.pos_order_item VALUES (48, '2026-06-30 19:27:52.517408+08', '2026-06-30 19:27:52.517413+08', '旺旺雪饼', '520g', 3.000, 12.80, 38.40, 23, 3, 1);
INSERT INTO public.pos_order_item VALUES (49, '2026-06-30 19:27:52.517955+08', '2026-06-30 19:27:52.517959+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 23, 1, 1);
INSERT INTO public.pos_order_item VALUES (50, '2026-06-30 19:27:52.529122+08', '2026-06-30 19:27:52.529126+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 24, 6, 1);
INSERT INTO public.pos_order_item VALUES (51, '2026-06-30 19:27:52.540629+08', '2026-06-30 19:27:52.540633+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 25, 5, 1);
INSERT INTO public.pos_order_item VALUES (52, '2026-06-30 19:27:52.551956+08', '2026-06-30 19:27:52.55196+08', '青岛啤酒', '500ml', 2.000, 6.00, 12.00, 26, 4, 1);
INSERT INTO public.pos_order_item VALUES (53, '2026-06-30 19:27:52.552478+08', '2026-06-30 19:27:52.552482+08', '可口可乐', '330ml', 1.000, 3.00, 3.00, 26, 6, 1);
INSERT INTO public.pos_order_item VALUES (54, '2026-06-30 19:27:52.553219+08', '2026-06-30 19:27:52.553223+08', '伊利纯牛奶', '250ml', 1.000, 5.50, 5.50, 26, 1, 1);
INSERT INTO public.pos_order_item VALUES (55, '2026-06-30 19:27:52.564658+08', '2026-06-30 19:27:52.564662+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 27, 3, 1);
INSERT INTO public.pos_order_item VALUES (56, '2026-06-30 19:27:52.576315+08', '2026-06-30 19:27:52.57632+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 28, 3, 1);
INSERT INTO public.pos_order_item VALUES (57, '2026-06-30 19:27:52.588079+08', '2026-06-30 19:27:52.588084+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 29, 3, 1);
INSERT INTO public.pos_order_item VALUES (58, '2026-06-30 19:27:52.588662+08', '2026-06-30 19:27:52.588666+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 29, 1, 1);
INSERT INTO public.pos_order_item VALUES (59, '2026-06-30 19:27:52.60045+08', '2026-06-30 19:27:52.600454+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 30, 1, 1);
INSERT INTO public.pos_order_item VALUES (60, '2026-06-30 19:27:52.601033+08', '2026-06-30 19:27:52.601037+08', '旺旺雪饼', '520g', 2.000, 12.80, 25.60, 30, 3, 1);
INSERT INTO public.pos_order_item VALUES (61, '2026-06-30 19:27:52.612558+08', '2026-06-30 19:27:52.612564+08', '青岛啤酒', '500ml', 2.000, 6.00, 12.00, 31, 4, 1);
INSERT INTO public.pos_order_item VALUES (62, '2026-06-30 19:27:52.613146+08', '2026-06-30 19:27:52.61315+08', '农夫山泉', '550ml', 3.000, 2.00, 6.00, 31, 6, 1);
INSERT INTO public.pos_order_item VALUES (63, '2026-06-30 19:27:52.613579+08', '2026-06-30 19:27:52.613583+08', '康师傅方便面', '红烧牛肉', 2.000, 4.50, 9.00, 31, 1, 1);
INSERT INTO public.pos_order_item VALUES (64, '2026-06-30 19:27:52.624814+08', '2026-06-30 19:27:52.624819+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 32, 5, 1);
INSERT INTO public.pos_order_item VALUES (65, '2026-06-30 19:27:52.635995+08', '2026-06-30 19:27:52.636+08', '旺旺雪饼', '520g', 3.000, 12.80, 38.40, 33, 5, 1);
INSERT INTO public.pos_order_item VALUES (66, '2026-06-30 19:27:52.636597+08', '2026-06-30 19:27:52.636601+08', '康师傅方便面', '红烧牛肉', 3.000, 4.50, 13.50, 33, 4, 1);
INSERT INTO public.pos_order_item VALUES (67, '2026-06-30 19:27:52.647708+08', '2026-06-30 19:27:52.647712+08', '康师傅方便面', '红烧牛肉', 3.000, 4.50, 13.50, 34, 3, 1);
INSERT INTO public.pos_order_item VALUES (68, '2026-06-30 19:27:52.648152+08', '2026-06-30 19:27:52.648155+08', '可口可乐', '330ml', 2.000, 3.00, 6.00, 34, 5, 1);
INSERT INTO public.pos_order_item VALUES (69, '2026-06-30 19:27:52.648497+08', '2026-06-30 19:27:52.6485+08', '旺旺雪饼', '520g', 2.000, 12.80, 25.60, 34, 2, 1);
INSERT INTO public.pos_order_item VALUES (70, '2026-06-30 19:27:52.660524+08', '2026-06-30 19:27:52.660529+08', '康师傅方便面', '红烧牛肉', 3.000, 4.50, 13.50, 35, 1, 1);
INSERT INTO public.pos_order_item VALUES (71, '2026-06-30 19:27:52.66094+08', '2026-06-30 19:27:52.660943+08', '青岛啤酒', '500ml', 3.000, 6.00, 18.00, 35, 2, 1);
INSERT INTO public.pos_order_item VALUES (72, '2026-06-30 19:27:52.661263+08', '2026-06-30 19:27:52.661266+08', '伊利纯牛奶', '250ml', 3.000, 5.50, 16.50, 35, 2, 1);
INSERT INTO public.pos_order_item VALUES (73, '2026-06-30 19:27:52.672557+08', '2026-06-30 19:27:52.672563+08', '农夫山泉', '550ml', 3.000, 2.00, 6.00, 36, 4, 1);
INSERT INTO public.pos_order_item VALUES (74, '2026-06-30 19:27:52.672973+08', '2026-06-30 19:27:52.672976+08', '可口可乐', '330ml', 3.000, 3.00, 9.00, 36, 4, 1);
INSERT INTO public.pos_order_item VALUES (75, '2026-06-30 19:27:52.673313+08', '2026-06-30 19:27:52.673316+08', '伊利纯牛奶', '250ml', 2.000, 5.50, 11.00, 36, 5, 1);
INSERT INTO public.pos_order_item VALUES (76, '2026-06-30 19:27:52.684431+08', '2026-06-30 19:27:52.684434+08', '农夫山泉', '550ml', 2.000, 2.00, 4.00, 37, 6, 1);
INSERT INTO public.pos_order_item VALUES (77, '2026-06-30 19:47:18.231722+08', '2026-06-30 19:47:18.231727+08', '伊利纯牛奶', '250ml', 1.000, 5.50, 5.50, 38, 4, 1);


--
-- Data for Name: stock_check; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.supplier VALUES (1, '2026-06-30 17:44:06.169742+08', '2026-06-30 17:44:06.169745+08', '宏达食品批发', '王总', '13900002001', '', '', 1);
INSERT INTO public.supplier VALUES (2, '2026-06-30 17:44:06.171106+08', '2026-06-30 17:44:06.17111+08', '永利商贸', '陈经理', '13900002002', '', '', 1);


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_tenant; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_tenant VALUES (1, 'super_admin', '2026-06-30 17:38:03.309761+08', 1, 2);
INSERT INTO public.user_tenant VALUES (2, 'manager', '2026-06-30 18:09:13.936467+08', 1, 1);


--
-- Data for Name: user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 76, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 19, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 28, true);


--
-- Name: employee_shift_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_shift_id_seq', 1, false);


--
-- Name: finance_daily_summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finance_daily_summary_id_seq', 1, false);


--
-- Name: inventory_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_record_id_seq', 1, true);


--
-- Name: member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.member_id_seq', 2, true);


--
-- Name: pos_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pos_order_id_seq', 38, true);


--
-- Name: pos_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pos_order_item_id_seq', 77, true);


--
-- Name: product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_category_id_seq', 12, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 6, true);


--
-- Name: product_sku_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_sku_id_seq', 6, true);


--
-- Name: stock_check_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_check_id_seq', 1, false);


--
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_id_seq', 2, true);


--
-- Name: tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tenant_id_seq', 1, true);


--
-- Name: user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_groups_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 2, true);


--
-- Name: user_tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_tenant_id_seq', 2, true);


--
-- Name: user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_user_permissions_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

\unrestrict 579KTeCzwjpAdISysfpC6wgWN9hh27a0ZOZIEFx9LCdHlW1pmTDoaoWWbmgadd1

