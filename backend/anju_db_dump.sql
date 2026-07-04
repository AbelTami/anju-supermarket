--
-- PostgreSQL database dump
--

\restrict wLtzRVJpWt3JcNOqTrcXWKhY885G1WrBizHAFzY6gH1eDdHB2C60neaaWcHa6zO

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

ALTER TABLE ONLY public.user_user_permissions DROP CONSTRAINT user_user_permissions_user_id_ed4a47ea_fk_user_id;
ALTER TABLE ONLY public.user_user_permissions DROP CONSTRAINT user_user_permission_permission_id_9deb68a3_fk_auth_perm;
ALTER TABLE ONLY public.user_tenant DROP CONSTRAINT user_tenant_user_id_e4d2580a_fk_user_id;
ALTER TABLE ONLY public.user_tenant DROP CONSTRAINT user_tenant_tenant_id_ea6c5f74_fk_tenant_id;
ALTER TABLE ONLY public.user_groups DROP CONSTRAINT user_groups_user_id_abaea130_fk_user_id;
ALTER TABLE ONLY public.user_groups DROP CONSTRAINT user_groups_group_id_b76f8aba_fk_auth_group_id;
ALTER TABLE ONLY public.supplier DROP CONSTRAINT supplier_tenant_id_8a35a691_fk_tenant_id;
ALTER TABLE ONLY public.stock_check DROP CONSTRAINT stock_check_tenant_id_2c1968d7_fk_tenant_id;
ALTER TABLE ONLY public.stock_check_item DROP CONSTRAINT stock_check_item_tenant_id_12d5e3db_fk_tenant_id;
ALTER TABLE ONLY public.stock_check_item DROP CONSTRAINT stock_check_item_stock_check_id_09bba7d2_fk_stock_check_id;
ALTER TABLE ONLY public.stock_check_item DROP CONSTRAINT stock_check_item_sku_id_620df826_fk_product_sku_id;
ALTER TABLE ONLY public.stock_check DROP CONSTRAINT stock_check_created_by_id_83ff223f_fk_user_id;
ALTER TABLE ONLY public.product DROP CONSTRAINT product_tenant_id_957f8279_fk_tenant_id;
ALTER TABLE ONLY public.product_sku DROP CONSTRAINT product_sku_tenant_id_7e9c5687_fk_tenant_id;
ALTER TABLE ONLY public.product_sku DROP CONSTRAINT product_sku_product_id_ecb13de3_fk_product_id;
ALTER TABLE ONLY public.product_category DROP CONSTRAINT product_category_tenant_id_137164b9_fk_tenant_id;
ALTER TABLE ONLY public.product_category DROP CONSTRAINT product_category_parent_id_f6860923_fk_product_category_id;
ALTER TABLE ONLY public.product DROP CONSTRAINT product_category_id_640030a0_fk_product_category_id;
ALTER TABLE ONLY public.pos_order DROP CONSTRAINT pos_order_tenant_id_13a991ec_fk_tenant_id;
ALTER TABLE ONLY public.pos_order DROP CONSTRAINT pos_order_member_id_4f7e71f7_fk_member_id;
ALTER TABLE ONLY public.pos_order_item DROP CONSTRAINT pos_order_item_tenant_id_20bba519_fk_tenant_id;
ALTER TABLE ONLY public.pos_order_item DROP CONSTRAINT pos_order_item_sku_id_5e26bb77_fk_product_sku_id;
ALTER TABLE ONLY public.pos_order_item DROP CONSTRAINT pos_order_item_order_id_6a977ad5_fk_pos_order_id;
ALTER TABLE ONLY public.pos_order DROP CONSTRAINT pos_order_cashier_id_0d96b16a_fk_user_id;
ALTER TABLE ONLY public.member DROP CONSTRAINT member_tenant_id_94eee4ea_fk_tenant_id;
ALTER TABLE ONLY public.inventory_record DROP CONSTRAINT inventory_record_tenant_id_b2250982_fk_tenant_id;
ALTER TABLE ONLY public.inventory_record DROP CONSTRAINT inventory_record_sku_id_046543aa_fk_product_sku_id;
ALTER TABLE ONLY public.inventory_record DROP CONSTRAINT inventory_record_operator_id_60220831_fk_user_id;
ALTER TABLE ONLY public.finance_daily_summary DROP CONSTRAINT finance_daily_summary_tenant_id_b2e91384_fk_tenant_id;
ALTER TABLE ONLY public.employee_shift DROP CONSTRAINT employee_shift_user_id_cb49ebd8_fk_user_id;
ALTER TABLE ONLY public.employee_shift DROP CONSTRAINT employee_shift_tenant_id_988ca8c3_fk_tenant_id;
ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_user_id_c564eba6_fk_user_id;
ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co;
ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co;
ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
DROP INDEX public.user_username_cf016618_like;
DROP INDEX public.user_user_permissions_user_id_ed4a47ea;
DROP INDEX public.user_user_permissions_permission_id_9deb68a3;
DROP INDEX public.user_tenant_user_id_e4d2580a;
DROP INDEX public.user_tenant_tenant_id_ea6c5f74;
DROP INDEX public.user_groups_user_id_abaea130;
DROP INDEX public.user_groups_group_id_b76f8aba;
DROP INDEX public.tenant_slug_812ad82d_like;
DROP INDEX public.supplier_tenant_id_8a35a691;
DROP INDEX public.stock_check_tenant_id_2c1968d7;
DROP INDEX public.stock_check_item_tenant_id_12d5e3db;
DROP INDEX public.stock_check_item_stock_check_id_09bba7d2;
DROP INDEX public.stock_check_item_sku_id_620df826;
DROP INDEX public.stock_check_created_by_id_83ff223f;
DROP INDEX public.product_tenant_id_957f8279;
DROP INDEX public.product_sku_tenant_id_7e9c5687;
DROP INDEX public.product_sku_product_id_ecb13de3;
DROP INDEX public.product_category_tenant_id_137164b9;
DROP INDEX public.product_category_parent_id_f6860923;
DROP INDEX public.product_category_id_640030a0;
DROP INDEX public.pos_order_tenant_id_13a991ec;
DROP INDEX public.pos_order_order_no_1f17503d_like;
DROP INDEX public.pos_order_member_id_4f7e71f7;
DROP INDEX public.pos_order_item_tenant_id_20bba519;
DROP INDEX public.pos_order_item_sku_id_5e26bb77;
DROP INDEX public.pos_order_item_order_id_6a977ad5;
DROP INDEX public.pos_order_cashier_id_0d96b16a;
DROP INDEX public.member_tenant_id_94eee4ea;
DROP INDEX public.inventory_record_tenant_id_b2250982;
DROP INDEX public.inventory_record_sku_id_046543aa;
DROP INDEX public.inventory_record_operator_id_60220831;
DROP INDEX public.finance_daily_summary_tenant_id_b2e91384;
DROP INDEX public.employee_shift_user_id_cb49ebd8;
DROP INDEX public.employee_shift_tenant_id_988ca8c3;
DROP INDEX public.django_session_session_key_c0390e0f_like;
DROP INDEX public.django_session_expire_date_a5c62663;
DROP INDEX public.django_admin_log_user_id_c564eba6;
DROP INDEX public.django_admin_log_content_type_id_c4bce8eb;
DROP INDEX public.auth_permission_content_type_id_2f476e4b;
DROP INDEX public.auth_group_permissions_permission_id_84c5c92e;
DROP INDEX public.auth_group_permissions_group_id_b120cbf9;
DROP INDEX public.auth_group_name_a6ea08ec_like;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_username_key;
ALTER TABLE ONLY public.user_user_permissions DROP CONSTRAINT user_user_permissions_user_id_permission_id_7dc6e2e0_uniq;
ALTER TABLE ONLY public.user_user_permissions DROP CONSTRAINT user_user_permissions_pkey;
ALTER TABLE ONLY public.user_tenant DROP CONSTRAINT user_tenant_user_id_tenant_id_36fd9a85_uniq;
ALTER TABLE ONLY public.user_tenant DROP CONSTRAINT user_tenant_pkey;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
ALTER TABLE ONLY public.user_groups DROP CONSTRAINT user_groups_user_id_group_id_40beef00_uniq;
ALTER TABLE ONLY public.user_groups DROP CONSTRAINT user_groups_pkey;
ALTER TABLE ONLY public.product_sku DROP CONSTRAINT uq_tenant_barcode;
ALTER TABLE ONLY public.tenant DROP CONSTRAINT tenant_slug_key;
ALTER TABLE ONLY public.tenant DROP CONSTRAINT tenant_pkey;
ALTER TABLE ONLY public.supplier DROP CONSTRAINT supplier_pkey;
ALTER TABLE ONLY public.stock_check DROP CONSTRAINT stock_check_pkey;
ALTER TABLE ONLY public.stock_check_item DROP CONSTRAINT stock_check_item_stock_check_id_sku_id_79b9bfc8_uniq;
ALTER TABLE ONLY public.stock_check_item DROP CONSTRAINT stock_check_item_pkey;
ALTER TABLE ONLY public.product_sku DROP CONSTRAINT product_sku_pkey;
ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
ALTER TABLE ONLY public.product_category DROP CONSTRAINT product_category_pkey;
ALTER TABLE ONLY public.pos_order DROP CONSTRAINT pos_order_pkey;
ALTER TABLE ONLY public.pos_order DROP CONSTRAINT pos_order_order_no_key;
ALTER TABLE ONLY public.pos_order_item DROP CONSTRAINT pos_order_item_pkey;
ALTER TABLE ONLY public.member DROP CONSTRAINT member_pkey;
ALTER TABLE ONLY public.inventory_record DROP CONSTRAINT inventory_record_pkey;
ALTER TABLE ONLY public.finance_daily_summary DROP CONSTRAINT finance_daily_summary_tenant_id_date_6e1879a8_uniq;
ALTER TABLE ONLY public.finance_daily_summary DROP CONSTRAINT finance_daily_summary_pkey;
ALTER TABLE ONLY public.employee_shift DROP CONSTRAINT employee_shift_pkey;
ALTER TABLE ONLY public.django_session DROP CONSTRAINT django_session_pkey;
ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_pkey;
ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq;
ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_pkey;
ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_pkey;
ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq;
ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_pkey;
ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_pkey;
ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_name_key;
DROP TABLE public.user_user_permissions;
DROP TABLE public.user_tenant;
DROP TABLE public.user_groups;
DROP TABLE public."user";
DROP TABLE public.tenant;
DROP TABLE public.supplier;
DROP TABLE public.stock_check_item;
DROP TABLE public.stock_check;
DROP TABLE public.product_sku;
DROP TABLE public.product_category;
DROP TABLE public.product;
DROP TABLE public.pos_order_item;
DROP TABLE public.pos_order;
DROP TABLE public.member;
DROP TABLE public.inventory_record;
DROP TABLE public.finance_daily_summary;
DROP TABLE public.employee_shift;
DROP TABLE public.django_session;
DROP TABLE public.django_migrations;
DROP TABLE public.django_content_type;
DROP TABLE public.django_admin_log;
DROP TABLE public.auth_permission;
DROP TABLE public.auth_group_permissions;
DROP TABLE public.auth_group;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


--
-- Name: employee_shift; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_shift (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    tenant_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: employee_shift_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.employee_shift ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.employee_shift_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: finance_daily_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.finance_daily_summary (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    date date NOT NULL,
    total_orders integer NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    cash_amount numeric(12,2) NOT NULL,
    wechat_amount numeric(12,2) NOT NULL,
    alipay_amount numeric(12,2) NOT NULL,
    member_amount numeric(12,2) NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: finance_daily_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.finance_daily_summary ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.finance_daily_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_record (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    type character varying(20) NOT NULL,
    quantity numeric(12,3) NOT NULL,
    before_quantity numeric(12,3) NOT NULL,
    after_quantity numeric(12,3) NOT NULL,
    remark text NOT NULL,
    operator_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: inventory_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.inventory_record ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.inventory_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.member (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    card_no character varying(50) NOT NULL,
    points integer NOT NULL,
    balance numeric(10,2) NOT NULL,
    total_spent numeric(12,2) NOT NULL,
    remark text NOT NULL,
    tenant_id bigint NOT NULL,
    password character varying(128) NOT NULL,
    token character varying(128) NOT NULL,
    token_created_at timestamp with time zone
);


--
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.member ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pos_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pos_order (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    order_no character varying(50) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    discount_amount numeric(10,2) NOT NULL,
    paid_amount numeric(10,2) NOT NULL,
    payment_method character varying(20) NOT NULL,
    status character varying(20) NOT NULL,
    paid_at timestamp with time zone NOT NULL,
    cashier_id bigint,
    member_id bigint,
    tenant_id bigint NOT NULL
);


--
-- Name: pos_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pos_order ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pos_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pos_order_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pos_order_item (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    product_name character varying(200) NOT NULL,
    spec_name character varying(200) NOT NULL,
    quantity numeric(10,3) NOT NULL,
    price numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    order_id bigint NOT NULL,
    sku_id bigint NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: pos_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pos_order_item ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pos_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(200) NOT NULL,
    image character varying(100),
    unit character varying(20) NOT NULL,
    is_weighted boolean NOT NULL,
    is_active boolean NOT NULL,
    category_id bigint,
    tenant_id bigint NOT NULL,
    image_url character varying(500) NOT NULL
);


--
-- Name: product_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(100) NOT NULL,
    sort_order integer NOT NULL,
    parent_id bigint,
    tenant_id bigint NOT NULL
);


--
-- Name: product_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_category ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_sku; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_sku (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    barcode character varying(100) NOT NULL,
    spec_name character varying(200) NOT NULL,
    spec_attrs jsonb NOT NULL,
    purchase_price numeric(10,2) NOT NULL,
    selling_price numeric(10,2) NOT NULL,
    stock_quantity numeric(12,3) NOT NULL,
    stock_alert numeric(12,3) NOT NULL,
    product_id bigint NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: product_sku_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_sku ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_sku_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stock_check; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_check (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status character varying(20) NOT NULL,
    remark text NOT NULL,
    created_by_id bigint NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: stock_check_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stock_check ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.stock_check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stock_check_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_check_item (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    system_quantity numeric(12,3) NOT NULL,
    actual_quantity numeric(12,3) NOT NULL,
    diff_quantity numeric(12,3) NOT NULL,
    remark character varying(200) NOT NULL,
    sku_id bigint NOT NULL,
    stock_check_id bigint NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: stock_check_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stock_check_item ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.stock_check_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplier (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying(200) NOT NULL,
    contact character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    address text NOT NULL,
    remark text NOT NULL,
    tenant_id bigint NOT NULL
);


--
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.supplier ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(50) NOT NULL,
    logo character varying(100),
    address text NOT NULL,
    phone character varying(20) NOT NULL,
    business_hours character varying(100) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tenant ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    phone character varying(20) NOT NULL,
    avatar character varying(100)
);


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_tenant (
    id bigint NOT NULL,
    role character varying(20) NOT NULL,
    joined_at timestamp with time zone NOT NULL,
    tenant_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: user_tenant_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.user_tenant ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_user_permissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	3	add_permission
6	Can change permission	3	change_permission
7	Can delete permission	3	delete_permission
8	Can view permission	3	view_permission
9	Can add group	2	add_group
10	Can change group	2	change_group
11	Can delete group	2	delete_group
12	Can view group	2	view_group
13	Can add content type	4	add_contenttype
14	Can change content type	4	change_contenttype
15	Can delete content type	4	delete_contenttype
16	Can view content type	4	view_contenttype
17	Can add session	5	add_session
18	Can change session	5	change_session
19	Can delete session	5	delete_session
20	Can view session	5	view_session
21	Can add 租户	6	add_tenant
22	Can change 租户	6	change_tenant
23	Can delete 租户	6	delete_tenant
24	Can view 租户	6	view_tenant
25	Can add 用户	7	add_user
26	Can change 用户	7	change_user
27	Can delete 用户	7	delete_user
28	Can view 用户	7	view_user
29	Can add 用户-租户关联	8	add_usertenant
30	Can change 用户-租户关联	8	change_usertenant
31	Can delete 用户-租户关联	8	delete_usertenant
32	Can view 用户-租户关联	8	view_usertenant
33	Can add 商品分类	9	add_category
34	Can change 商品分类	9	change_category
35	Can delete 商品分类	9	delete_category
36	Can view 商品分类	9	view_category
37	Can add 商品	10	add_product
38	Can change 商品	10	change_product
39	Can delete 商品	10	delete_product
40	Can view 商品	10	view_product
41	Can add 商品SKU	11	add_productsku
42	Can change 商品SKU	11	change_productsku
43	Can delete 商品SKU	11	delete_productsku
44	Can view 商品SKU	11	view_productsku
45	Can add 库存流水	12	add_inventoryrecord
46	Can change 库存流水	12	change_inventoryrecord
47	Can delete 库存流水	12	delete_inventoryrecord
48	Can view 库存流水	12	view_inventoryrecord
49	Can add 盘点单	13	add_stockcheck
50	Can change 盘点单	13	change_stockcheck
51	Can delete 盘点单	13	delete_stockcheck
52	Can view 盘点单	13	view_stockcheck
53	Can add 收银订单	14	add_order
54	Can change 收银订单	14	change_order
55	Can delete 收银订单	14	delete_order
56	Can view 收银订单	14	view_order
57	Can add 订单明细	15	add_orderitem
58	Can change 订单明细	15	change_orderitem
59	Can delete 订单明细	15	delete_orderitem
60	Can view 订单明细	15	view_orderitem
61	Can add 会员	16	add_member
62	Can change 会员	16	change_member
63	Can delete 会员	16	delete_member
64	Can view 会员	16	view_member
65	Can add 供应商	17	add_supplier
66	Can change 供应商	17	change_supplier
67	Can delete 供应商	17	delete_supplier
68	Can view 供应商	17	view_supplier
69	Can add 排班	18	add_shift
70	Can change 排班	18	change_shift
71	Can delete 排班	18	delete_shift
72	Can view 排班	18	view_shift
73	Can add 日结汇总	19	add_dailysummary
74	Can change 日结汇总	19	change_dailysummary
75	Can delete 日结汇总	19	delete_dailysummary
76	Can view 日结汇总	19	view_dailysummary
77	Can add 充值记录	20	add_rechargerecord
78	Can change 充值记录	20	change_rechargerecord
79	Can delete 充值记录	20	delete_rechargerecord
80	Can view 充值记录	20	view_rechargerecord
81	Can add 盘点明细	21	add_stockcheckitem
82	Can change 盘点明细	21	change_stockcheckitem
83	Can delete 盘点明细	21	delete_stockcheckitem
84	Can view 盘点明细	21	view_stockcheckitem
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	group
3	auth	permission
4	contenttypes	contenttype
5	sessions	session
6	tenants	tenant
7	accounts	user
8	accounts	usertenant
9	products	category
10	products	product
11	products	productsku
12	inventory	inventoryrecord
13	inventory	stockcheck
14	pos	order
15	pos	orderitem
16	members	member
17	suppliers	supplier
18	employees	shift
19	finance	dailysummary
20	members	rechargerecord
21	inventory	stockcheckitem
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	tenants	0001_initial	2026-07-04 16:45:56.448912+08
2	contenttypes	0001_initial	2026-07-04 16:45:56.454653+08
3	contenttypes	0002_remove_content_type_name	2026-07-04 16:45:56.457319+08
4	auth	0001_initial	2026-07-04 16:45:56.474675+08
5	auth	0002_alter_permission_name_max_length	2026-07-04 16:45:56.479322+08
6	auth	0003_alter_user_email_max_length	2026-07-04 16:45:56.481037+08
7	auth	0004_alter_user_username_opts	2026-07-04 16:45:56.48259+08
8	auth	0005_alter_user_last_login_null	2026-07-04 16:45:56.484273+08
9	auth	0006_require_contenttypes_0002	2026-07-04 16:45:56.484857+08
10	auth	0007_alter_validators_add_error_messages	2026-07-04 16:45:56.486553+08
11	auth	0008_alter_user_username_max_length	2026-07-04 16:45:56.488408+08
12	auth	0009_alter_user_last_name_max_length	2026-07-04 16:45:56.490256+08
13	auth	0010_alter_group_name_max_length	2026-07-04 16:45:56.493037+08
14	auth	0011_update_proxy_permissions	2026-07-04 16:45:56.494803+08
15	auth	0012_alter_user_first_name_max_length	2026-07-04 16:45:56.496464+08
16	accounts	0001_initial	2026-07-04 16:45:56.524588+08
17	admin	0001_initial	2026-07-04 16:45:56.539606+08
18	admin	0002_logentry_remove_auto_add	2026-07-04 16:45:56.548909+08
19	admin	0003_logentry_add_action_flag_choices	2026-07-04 16:45:56.551803+08
20	employees	0001_initial	2026-07-04 16:45:56.560006+08
21	finance	0001_initial	2026-07-04 16:45:56.568496+08
22	products	0001_initial	2026-07-04 16:45:56.596475+08
23	inventory	0001_initial	2026-07-04 16:45:56.623289+08
24	members	0001_initial	2026-07-04 16:45:56.633851+08
25	members	0002_member_password	2026-07-04 16:45:56.639244+08
26	members	0003_member_token	2026-07-04 16:45:56.643714+08
27	members	0004_member_token_created_at	2026-07-04 16:45:56.647607+08
28	members	0005_hash_existing_passwords	2026-07-04 16:45:56.653885+08
29	pos	0001_initial	2026-07-04 16:45:56.678623+08
30	pos	0002_alter_orderitem_spec_name	2026-07-04 16:45:56.690791+08
31	products	0002_product_image_url	2026-07-04 16:45:56.697577+08
32	sessions	0001_initial	2026-07-04 16:45:56.703484+08
33	suppliers	0001_initial	2026-07-04 16:45:56.717946+08
34	inventory	0002_stockcheckitem	2026-07-04 17:33:38.854395+08
35	products	0003_alter_productsku_barcode_and_more	2026-07-04 17:33:38.870171+08
36	pos	0003_alter_order_cashier	2026-07-04 18:13:49.376229+08
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
lt3dtn86np6l4frmg0272no49103q1m2	.eJxVjMsOgjAQAP-lZ9PQ0gfr0Tvf0Ox2F4uaklA4Gf_dkHDQ68xk3irhvpW0N1nTzOqqjLr8MsL8lHoIfmC9LzovdVtn0keiT9v0uLC8bmf7NyjYyrHtHTKBQ0sYnAEvZvJAZqBMeepDBPbeiAuugz6zHUA6CBEDdz5aiurzBeE2N3s:1wfwJT:8bQyn0F2U-ActuQCPeM2OcqVeJOSMsqHVWZg3FZaiuc	2026-07-18 17:05:27.825993+08
\.


--
-- Data for Name: employee_shift; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_shift (id, created_at, updated_at, start_time, end_time, tenant_id, user_id) FROM stdin;
\.


--
-- Data for Name: finance_daily_summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.finance_daily_summary (id, created_at, updated_at, date, total_orders, total_amount, cash_amount, wechat_amount, alipay_amount, member_amount, tenant_id) FROM stdin;
\.


--
-- Data for Name: inventory_record; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_record (id, created_at, updated_at, type, quantity, before_quantity, after_quantity, remark, operator_id, sku_id, tenant_id) FROM stdin;
1	2026-06-30 17:53:05.277511+08	2026-06-30 17:53:05.277521+08	purchase_in	50.000	150.000	200.000	test	2	1	1
2	2026-07-04 17:35:39.835181+08	2026-07-04 17:35:39.83519+08	check_out	2.000	100.000	98.000	盘点单 #2 自动生成	1	13	1
3	2026-07-04 17:37:55.163393+08	2026-07-04 17:37:55.1634+08	return_in	1.000	98.000	99.000	customer return	1	13	1
4	2026-07-04 17:38:02.61734+08	2026-07-04 17:38:02.617346+08	return_in	1.000	99.000	100.000	customer return	1	13	1
5	2026-07-04 17:39:14.888881+08	2026-07-04 17:39:14.888888+08	purchase_in	10.000	100.000	110.000	test-purchase_in	1	13	1
6	2026-07-04 17:39:15.318475+08	2026-07-04 17:39:15.318483+08	return_in	3.000	110.000	113.000	test-return_in	1	13	1
7	2026-07-04 17:39:15.791061+08	2026-07-04 17:39:15.791071+08	check_in	2.000	113.000	115.000	test-check_in	1	13	1
8	2026-07-04 17:39:16.228503+08	2026-07-04 17:39:16.22851+08	sale_out	5.000	115.000	110.000	test-sale_out	1	13	1
9	2026-07-04 17:39:16.68974+08	2026-07-04 17:39:16.689746+08	damage_out	1.000	110.000	109.000	test-damage_out	1	13	1
10	2026-07-04 17:39:17.115802+08	2026-07-04 17:39:17.115808+08	check_out	2.000	109.000	107.000	test-check_out	1	13	1
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.member (id, created_at, updated_at, name, phone, card_no, points, balance, total_spent, remark, tenant_id, password, token, token_created_at) FROM stdin;
3	2026-07-01 18:54:57.033056+08	2026-07-03 18:39:50.744703+08	张三	13800001001	M001	234	367.20	234.80		1	pbkdf2_sha256$1200000$q3hK8l21XmXvO5HJEGrIV7$+zfp4vnoCrwlwE5IYJ7Ag9byOZkHpu3XLVdnCgWBzII=	fccb791a2c0a17eaa44fc71b6b323fc634ab43fae35828b4676131465e51d120	\N
5	2026-07-04 17:55:29.598317+08	2026-07-04 17:55:29.598327+08	ZhangSan	13800000001	M001	246	362.00	146.00		1	pbkdf2_sha256$1200000$A8u58shc3yjtKYU9HRzxXA$MlxkQ3kjizeggWJHGQ6sZxM+iYP4LnZA7v9Z5Gzt2zE=	c1d0c4787907ac224e23f87c867c63f181ebfe09bdda65f0e6eb00e49f16ab7d	2026-07-04 18:19:56.528023+08
\.


--
-- Data for Name: pos_order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pos_order (id, created_at, updated_at, order_no, total_amount, discount_amount, paid_amount, payment_method, status, paid_at, cashier_id, member_id, tenant_id) FROM stdin;
37	2026-06-30 19:27:52.683836+08	2026-06-30 19:30:32.439243+08	POS1782818872224	4.00	0.00	4.00	member_card	completed	2026-06-19 08:20:00+08	2	\N	1
36	2026-06-30 19:27:52.671918+08	2026-06-30 19:30:32.440663+08	POS1782818872786	27.50	0.00	27.50	cash	completed	2026-06-17 10:31:00+08	2	\N	1
35	2026-06-30 19:27:52.65988+08	2026-06-30 19:30:32.441396+08	POS1782818872413	31.00	0.00	31.00	cash	completed	2026-06-29 19:24:00+08	2	\N	1
34	2026-06-30 19:27:52.647162+08	2026-06-30 19:30:32.442044+08	POS1782818872257	50.40	0.00	50.40	alipay	completed	2026-06-27 17:25:00+08	2	\N	1
33	2026-06-30 19:27:52.635371+08	2026-06-30 19:30:32.442619+08	POS1782818872231	51.90	0.00	51.90	member_card	completed	2026-06-19 12:03:00+08	2	\N	1
32	2026-06-30 19:27:52.624261+08	2026-06-30 19:30:32.443168+08	POS1782818872252	12.00	0.00	12.00	cash	completed	2026-06-30 19:32:00+08	2	\N	1
31	2026-06-30 19:27:52.611693+08	2026-06-30 19:30:32.443614+08	POS1782818872245	35.50	0.00	35.50	wechat	completed	2026-06-29 15:00:00+08	2	\N	1
30	2026-06-30 19:27:52.599711+08	2026-06-30 19:30:32.444116+08	POS1782818872282	54.90	0.00	54.90	cash	completed	2026-06-23 16:10:00+08	2	\N	1
29	2026-06-30 19:27:52.587306+08	2026-06-30 19:30:32.444581+08	POS1782818872989	9.00	0.00	9.00	member_card	completed	2026-06-24 13:34:00+08	2	\N	1
28	2026-06-30 19:27:52.575474+08	2026-06-30 19:30:32.444976+08	POS1782818872618	6.00	0.00	6.00	cash	completed	2026-06-19 10:30:00+08	2	\N	1
27	2026-06-30 19:27:52.564108+08	2026-06-30 19:30:32.445343+08	POS1782818872214	6.00	0.00	6.00	alipay	completed	2026-06-26 13:54:00+08	2	\N	1
26	2026-06-30 19:27:52.551348+08	2026-06-30 19:30:32.445705+08	POS1782818872320	23.00	0.00	23.00	alipay	completed	2026-06-19 18:19:00+08	2	\N	1
25	2026-06-30 19:27:52.540084+08	2026-06-30 19:30:32.446057+08	POS1782818872982	16.50	0.00	16.50	cash	completed	2026-06-21 09:13:00+08	2	\N	1
24	2026-06-30 19:27:52.528564+08	2026-06-30 19:30:32.446447+08	POS1782818872405	9.00	0.00	9.00	alipay	completed	2026-06-26 20:39:00+08	2	\N	1
23	2026-06-30 19:27:52.516052+08	2026-06-30 19:30:32.446802+08	POS1782818872256	47.90	0.00	47.90	wechat	completed	2026-06-20 20:19:00+08	2	\N	1
22	2026-06-30 19:27:52.502801+08	2026-06-30 19:30:32.447272+08	POS1782818872334	37.50	0.00	37.50	wechat	completed	2026-06-27 13:03:00+08	2	\N	1
21	2026-06-30 19:27:52.489487+08	2026-06-30 19:30:32.447738+08	POS1782818872545	27.00	0.00	27.00	alipay	completed	2026-06-30 12:23:00+08	2	\N	1
20	2026-06-30 19:27:52.476184+08	2026-06-30 19:30:32.448165+08	POS1782818872806	36.00	0.00	36.00	cash	completed	2026-06-28 20:50:00+08	2	\N	1
19	2026-06-30 19:27:52.462098+08	2026-06-30 19:30:32.448699+08	POS1782818872423	27.50	0.00	27.50	wechat	completed	2026-06-23 21:29:00+08	2	\N	1
18	2026-06-30 19:27:52.449084+08	2026-06-30 19:30:32.449236+08	POS1782818872617	12.00	0.00	12.00	member_card	completed	2026-06-30 09:07:00+08	2	\N	1
17	2026-06-30 19:27:52.4374+08	2026-06-30 19:30:32.449746+08	POS1782818872622	9.00	0.00	9.00	member_card	completed	2026-06-27 15:36:00+08	2	\N	1
16	2026-06-30 19:27:52.425578+08	2026-06-30 19:30:32.450266+08	POS1782818872997	12.00	0.00	12.00	member_card	completed	2026-06-29 13:06:00+08	2	\N	1
15	2026-06-30 19:27:52.413517+08	2026-06-30 19:30:32.450788+08	POS1782818872387	25.80	0.00	25.80	alipay	completed	2026-06-23 21:23:00+08	2	\N	1
14	2026-06-30 19:27:52.402322+08	2026-06-30 19:30:32.451311+08	POS1782818872611	6.00	0.00	6.00	alipay	completed	2026-06-19 10:24:00+08	2	\N	1
13	2026-06-30 19:27:52.389935+08	2026-06-30 19:30:32.451839+08	POS1782818872978	40.50	0.00	40.50	alipay	completed	2026-06-22 12:39:00+08	2	\N	1
12	2026-06-30 19:27:52.377905+08	2026-06-30 19:30:32.452373+08	POS1782818872507	13.00	0.00	13.00	cash	completed	2026-06-24 14:22:00+08	2	\N	1
11	2026-06-30 19:27:52.366367+08	2026-06-30 19:30:32.452897+08	POS1782818872598	2.00	0.00	2.00	wechat	completed	2026-06-21 21:18:00+08	2	\N	1
10	2026-06-30 19:27:52.352904+08	2026-06-30 19:30:32.453394+08	POS1782818872566	42.60	0.00	42.60	member_card	completed	2026-06-30 18:46:00+08	2	\N	1
9	2026-06-30 19:27:52.340503+08	2026-06-30 19:30:32.453903+08	POS1782818872467	43.90	0.00	43.90	alipay	completed	2026-06-24 08:45:00+08	2	\N	1
8	2026-06-30 19:27:52.328071+08	2026-06-30 19:30:32.454415+08	POS1782818872139	9.50	0.00	9.50	member_card	completed	2026-06-21 16:16:00+08	2	\N	1
7	2026-06-30 19:27:52.311934+08	2026-06-30 19:30:32.454926+08	POS1782818872880	21.00	0.00	21.00	member_card	completed	2026-06-26 10:03:00+08	2	\N	1
6	2026-06-30 19:27:52.299218+08	2026-06-30 19:30:32.455465+08	POS1782818872556	37.50	0.00	37.50	alipay	completed	2026-06-23 17:14:00+08	2	\N	1
5	2026-06-30 19:27:52.286637+08	2026-06-30 19:30:32.456018+08	POS1782818872324	40.40	0.00	40.40	cash	completed	2026-06-29 13:23:00+08	2	\N	1
4	2026-06-30 19:27:52.274427+08	2026-06-30 19:30:32.456571+08	POS1782818872854	30.80	0.00	30.80	member_card	completed	2026-06-27 16:25:00+08	2	\N	1
3	2026-06-30 19:27:52.259568+08	2026-06-30 19:30:32.457128+08	POS1782818872424	21.80	0.00	21.80	alipay	completed	2026-06-19 12:28:00+08	2	\N	1
2	2026-06-30 17:46:44.071492+08	2026-06-30 19:30:32.45802+08	POS1782812804862	10.50	0.00	10.50	wechat	completed	2026-06-18 12:18:00+08	2	\N	1
1	2026-06-30 17:45:39.214605+08	2026-06-30 19:30:32.458555+08	POS1782812739548	10.50	0.00	10.50	wechat	completed	2026-06-26 09:25:00+08	2	\N	1
38	2026-06-30 19:47:18.229739+08	2026-06-30 19:47:18.229749+08	POS1782820038875	5.50	0.00	5.50	alipay	completed	2026-06-30 19:47:18.229773+08	1	\N	1
39	2026-07-01 19:11:13.657587+08	2026-07-01 19:11:13.657601+08	POS1782904273499	3.00	0.00	3.00	member_card	completed	2026-07-01 19:11:13.65763+08	1	\N	1
40	2026-07-01 19:47:38.416012+08	2026-07-01 19:47:38.416022+08	POS1782906458463	28.00	0.00	28.00	cash	completed	2026-07-01 19:47:38.416046+08	1	\N	1
41	2026-07-01 19:47:38.893808+08	2026-07-01 19:47:38.893814+08	POS1782906458189	28.00	0.00	28.00	cash	completed	2026-07-01 19:47:38.893834+08	1	3	1
42	2026-07-01 19:48:38.346069+08	2026-07-01 19:48:38.346076+08	POS1782906518214	34.00	0.00	34.00	cash	completed	2026-07-01 19:48:38.346094+08	1	3	1
43	2026-07-01 19:53:24.813771+08	2026-07-01 19:53:24.81378+08	POS1782906804101	50.00	0.00	50.00	cash	completed	2026-07-01 19:53:24.813803+08	1	3	1
44	2026-07-01 19:59:36.34521+08	2026-07-01 19:59:36.34522+08	POS1782907176211	22.00	0.00	22.00	cash	completed	2026-07-01 19:59:36.345244+08	1	3	1
45	2026-07-03 18:45:14.919506+08	2026-07-03 18:45:14.919515+08	POS1783075514231	68.00	0.00	68.00	wechat	completed	2026-07-03 18:45:14.919542+08	1	3	1
46	2026-07-03 19:00:31.784699+08	2026-07-03 19:00:31.784708+08	POS1783076431385	32.80	0.00	32.80	member_card	completed	2026-07-03 19:00:31.784732+08	1	3	1
47	2026-07-04 17:27:19.718943+08	2026-07-04 17:27:19.718952+08	POS1783157239956	12.50	0.00	12.50	wechat	completed	2026-07-04 17:27:19.718974+08	1	\N	1
48	2026-07-04 17:27:38.518596+08	2026-07-04 17:27:38.518603+08	POS1783157258342	25.00	0.00	25.00	cash	completed	2026-07-04 17:27:38.518621+08	1	\N	1
49	2026-07-04 18:14:36.747658+08	2026-07-04 18:14:36.747665+08	POS1783160076910	12.50	0.00	12.50	member_card	completed	2026-07-04 18:14:36.747687+08	\N	5	1
50	2026-07-04 18:15:21.883877+08	2026-07-04 18:15:21.883883+08	POS1783160121118	43.00	0.00	43.00	cash	completed	2026-07-04 18:15:21.883899+08	\N	5	1
51	2026-07-04 18:19:48.919225+08	2026-07-04 18:19:48.919233+08	POS1783160388258	30.00	0.00	30.00	wechat	completed	2026-07-04 18:19:48.919254+08	\N	5	1
52	2026-07-04 18:21:29.511481+08	2026-07-04 18:21:29.511488+08	POS1783160489173	58.00	0.00	58.00	cash	completed	2026-07-04 18:21:29.511506+08	\N	5	1
\.


--
-- Data for Name: pos_order_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pos_order_item (id, created_at, updated_at, product_name, spec_name, quantity, price, subtotal, order_id, sku_id, tenant_id) FROM stdin;
1	2026-06-30 17:45:39.216592+08	2026-06-30 17:45:39.216596+08	可口可乐	330ml	2.000	3.00	6.00	1	1	1
2	2026-06-30 17:46:44.072766+08	2026-06-30 17:46:44.072769+08	可口可乐	330ml	2.000	3.00	6.00	2	1	1
3	2026-06-30 19:27:52.262191+08	2026-06-30 19:27:52.262196+08	康师傅方便面	红烧牛肉	3.000	4.50	13.50	3	4	1
4	2026-06-30 19:27:52.263594+08	2026-06-30 19:27:52.263599+08	旺旺雪饼	520g	1.000	12.80	12.80	3	2	1
5	2026-06-30 19:27:52.275248+08	2026-06-30 19:27:52.275255+08	青岛啤酒	500ml	3.000	6.00	18.00	4	3	1
6	2026-06-30 19:27:52.275879+08	2026-06-30 19:27:52.275883+08	旺旺雪饼	520g	2.000	12.80	25.60	4	6	1
7	2026-06-30 19:27:52.287438+08	2026-06-30 19:27:52.287445+08	农夫山泉	550ml	2.000	2.00	4.00	5	3	1
8	2026-06-30 19:27:52.288111+08	2026-06-30 19:27:52.288115+08	旺旺雪饼	520g	3.000	12.80	38.40	5	3	1
9	2026-06-30 19:27:52.300024+08	2026-06-30 19:27:52.30003+08	康师傅方便面	红烧牛肉	1.000	4.50	4.50	6	1	1
10	2026-06-30 19:27:52.300667+08	2026-06-30 19:27:52.300671+08	可口可乐	330ml	3.000	3.00	9.00	6	2	1
11	2026-06-30 19:27:52.30124+08	2026-06-30 19:27:52.301244+08	青岛啤酒	500ml	1.000	6.00	6.00	6	6	1
12	2026-06-30 19:27:52.315628+08	2026-06-30 19:27:52.315633+08	康师傅方便面	红烧牛肉	1.000	4.50	4.50	7	1	1
13	2026-06-30 19:27:52.316304+08	2026-06-30 19:27:52.316308+08	伊利纯牛奶	250ml	3.000	5.50	16.50	7	4	1
14	2026-06-30 19:27:52.329101+08	2026-06-30 19:27:52.329106+08	伊利纯牛奶	250ml	1.000	5.50	5.50	8	1	1
15	2026-06-30 19:27:52.329738+08	2026-06-30 19:27:52.329742+08	农夫山泉	550ml	2.000	2.00	4.00	8	2	1
16	2026-06-30 19:27:52.341409+08	2026-06-30 19:27:52.341414+08	旺旺雪饼	520g	1.000	12.80	12.80	9	6	1
17	2026-06-30 19:27:52.342079+08	2026-06-30 19:27:52.342083+08	伊利纯牛奶	250ml	3.000	5.50	16.50	9	3	1
18	2026-06-30 19:27:52.353699+08	2026-06-30 19:27:52.353703+08	伊利纯牛奶	250ml	3.000	5.50	16.50	10	6	1
19	2026-06-30 19:27:52.354608+08	2026-06-30 19:27:52.354613+08	可口可乐	330ml	1.000	3.00	3.00	10	2	1
20	2026-06-30 19:27:52.355194+08	2026-06-30 19:27:52.355198+08	旺旺雪饼	520g	3.000	12.80	38.40	10	2	1
21	2026-06-30 19:27:52.367036+08	2026-06-30 19:27:52.36704+08	农夫山泉	550ml	3.000	2.00	6.00	11	6	1
22	2026-06-30 19:27:52.378493+08	2026-06-30 19:27:52.378497+08	伊利纯牛奶	250ml	3.000	5.50	16.50	12	1	1
23	2026-06-30 19:27:52.379008+08	2026-06-30 19:27:52.379013+08	农夫山泉	550ml	1.000	2.00	2.00	12	1	1
24	2026-06-30 19:27:52.390616+08	2026-06-30 19:27:52.390621+08	青岛啤酒	500ml	1.000	6.00	6.00	13	6	1
25	2026-06-30 19:27:52.391177+08	2026-06-30 19:27:52.391182+08	可口可乐	330ml	2.000	3.00	6.00	13	3	1
26	2026-06-30 19:27:52.391709+08	2026-06-30 19:27:52.391713+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	13	3	1
27	2026-06-30 19:27:52.402913+08	2026-06-30 19:27:52.402917+08	青岛啤酒	500ml	2.000	6.00	12.00	14	4	1
28	2026-06-30 19:27:52.414066+08	2026-06-30 19:27:52.414069+08	农夫山泉	550ml	2.000	2.00	4.00	15	1	1
29	2026-06-30 19:27:52.414485+08	2026-06-30 19:27:52.414488+08	可口可乐	330ml	2.000	3.00	6.00	15	3	1
30	2026-06-30 19:27:52.414883+08	2026-06-30 19:27:52.414888+08	旺旺雪饼	520g	3.000	12.80	38.40	15	2	1
31	2026-06-30 19:27:52.426387+08	2026-06-30 19:27:52.426391+08	青岛啤酒	500ml	2.000	6.00	12.00	16	2	1
32	2026-06-30 19:27:52.438206+08	2026-06-30 19:27:52.43821+08	可口可乐	330ml	3.000	3.00	9.00	17	1	1
33	2026-06-30 19:27:52.45007+08	2026-06-30 19:27:52.450077+08	青岛啤酒	500ml	3.000	6.00	18.00	18	4	1
34	2026-06-30 19:27:52.450884+08	2026-06-30 19:27:52.45089+08	农夫山泉	550ml	3.000	2.00	6.00	18	2	1
35	2026-06-30 19:27:52.463152+08	2026-06-30 19:27:52.463158+08	康师傅方便面	红烧牛肉	1.000	4.50	4.50	19	3	1
36	2026-06-30 19:27:52.463905+08	2026-06-30 19:27:52.46391+08	农夫山泉	550ml	2.000	2.00	4.00	19	6	1
37	2026-06-30 19:27:52.46475+08	2026-06-30 19:27:52.464755+08	青岛啤酒	500ml	1.000	6.00	6.00	19	2	1
38	2026-06-30 19:27:52.4772+08	2026-06-30 19:27:52.477205+08	伊利纯牛奶	250ml	2.000	5.50	11.00	20	2	1
39	2026-06-30 19:27:52.477952+08	2026-06-30 19:27:52.477958+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	20	4	1
40	2026-06-30 19:27:52.478606+08	2026-06-30 19:27:52.478612+08	农夫山泉	550ml	1.000	2.00	2.00	20	6	1
41	2026-06-30 19:27:52.490439+08	2026-06-30 19:27:52.490445+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	21	1	1
42	2026-06-30 19:27:52.491188+08	2026-06-30 19:27:52.491192+08	农夫山泉	550ml	1.000	2.00	2.00	21	2	1
43	2026-06-30 19:27:52.49182+08	2026-06-30 19:27:52.491824+08	青岛啤酒	500ml	1.000	6.00	6.00	21	3	1
44	2026-06-30 19:27:52.503726+08	2026-06-30 19:27:52.503731+08	青岛啤酒	500ml	3.000	6.00	18.00	22	6	1
45	2026-06-30 19:27:52.504461+08	2026-06-30 19:27:52.504467+08	农夫山泉	550ml	2.000	2.00	4.00	22	5	1
46	2026-06-30 19:27:52.505146+08	2026-06-30 19:27:52.505152+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	22	6	1
47	2026-06-30 19:27:52.516788+08	2026-06-30 19:27:52.516793+08	伊利纯牛奶	250ml	1.000	5.50	5.50	23	4	1
48	2026-06-30 19:27:52.517408+08	2026-06-30 19:27:52.517413+08	旺旺雪饼	520g	3.000	12.80	38.40	23	3	1
49	2026-06-30 19:27:52.517955+08	2026-06-30 19:27:52.517959+08	农夫山泉	550ml	2.000	2.00	4.00	23	1	1
50	2026-06-30 19:27:52.529122+08	2026-06-30 19:27:52.529126+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	24	6	1
51	2026-06-30 19:27:52.540629+08	2026-06-30 19:27:52.540633+08	伊利纯牛奶	250ml	3.000	5.50	16.50	25	5	1
52	2026-06-30 19:27:52.551956+08	2026-06-30 19:27:52.55196+08	青岛啤酒	500ml	2.000	6.00	12.00	26	4	1
53	2026-06-30 19:27:52.552478+08	2026-06-30 19:27:52.552482+08	可口可乐	330ml	1.000	3.00	3.00	26	6	1
54	2026-06-30 19:27:52.553219+08	2026-06-30 19:27:52.553223+08	伊利纯牛奶	250ml	1.000	5.50	5.50	26	1	1
55	2026-06-30 19:27:52.564658+08	2026-06-30 19:27:52.564662+08	农夫山泉	550ml	2.000	2.00	4.00	27	3	1
56	2026-06-30 19:27:52.576315+08	2026-06-30 19:27:52.57632+08	青岛啤酒	500ml	3.000	6.00	18.00	28	3	1
57	2026-06-30 19:27:52.588079+08	2026-06-30 19:27:52.588084+08	可口可乐	330ml	2.000	3.00	6.00	29	3	1
58	2026-06-30 19:27:52.588662+08	2026-06-30 19:27:52.588666+08	农夫山泉	550ml	2.000	2.00	4.00	29	1	1
59	2026-06-30 19:27:52.60045+08	2026-06-30 19:27:52.600454+08	伊利纯牛奶	250ml	3.000	5.50	16.50	30	1	1
60	2026-06-30 19:27:52.601033+08	2026-06-30 19:27:52.601037+08	旺旺雪饼	520g	2.000	12.80	25.60	30	3	1
61	2026-06-30 19:27:52.612558+08	2026-06-30 19:27:52.612564+08	青岛啤酒	500ml	2.000	6.00	12.00	31	4	1
62	2026-06-30 19:27:52.613146+08	2026-06-30 19:27:52.61315+08	农夫山泉	550ml	3.000	2.00	6.00	31	6	1
63	2026-06-30 19:27:52.613579+08	2026-06-30 19:27:52.613583+08	康师傅方便面	红烧牛肉	2.000	4.50	9.00	31	1	1
64	2026-06-30 19:27:52.624814+08	2026-06-30 19:27:52.624819+08	青岛啤酒	500ml	3.000	6.00	18.00	32	5	1
65	2026-06-30 19:27:52.635995+08	2026-06-30 19:27:52.636+08	旺旺雪饼	520g	3.000	12.80	38.40	33	5	1
66	2026-06-30 19:27:52.636597+08	2026-06-30 19:27:52.636601+08	康师傅方便面	红烧牛肉	3.000	4.50	13.50	33	4	1
67	2026-06-30 19:27:52.647708+08	2026-06-30 19:27:52.647712+08	康师傅方便面	红烧牛肉	3.000	4.50	13.50	34	3	1
68	2026-06-30 19:27:52.648152+08	2026-06-30 19:27:52.648155+08	可口可乐	330ml	2.000	3.00	6.00	34	5	1
69	2026-06-30 19:27:52.648497+08	2026-06-30 19:27:52.6485+08	旺旺雪饼	520g	2.000	12.80	25.60	34	2	1
70	2026-06-30 19:27:52.660524+08	2026-06-30 19:27:52.660529+08	康师傅方便面	红烧牛肉	3.000	4.50	13.50	35	1	1
71	2026-06-30 19:27:52.66094+08	2026-06-30 19:27:52.660943+08	青岛啤酒	500ml	3.000	6.00	18.00	35	2	1
72	2026-06-30 19:27:52.661263+08	2026-06-30 19:27:52.661266+08	伊利纯牛奶	250ml	3.000	5.50	16.50	35	2	1
73	2026-06-30 19:27:52.672557+08	2026-06-30 19:27:52.672563+08	农夫山泉	550ml	3.000	2.00	6.00	36	4	1
74	2026-06-30 19:27:52.672973+08	2026-06-30 19:27:52.672976+08	可口可乐	330ml	3.000	3.00	9.00	36	4	1
75	2026-06-30 19:27:52.673313+08	2026-06-30 19:27:52.673316+08	伊利纯牛奶	250ml	2.000	5.50	11.00	36	5	1
76	2026-06-30 19:27:52.684431+08	2026-06-30 19:27:52.684434+08	农夫山泉	550ml	2.000	2.00	4.00	37	6	1
77	2026-06-30 19:47:18.231722+08	2026-06-30 19:47:18.231727+08	伊利纯牛奶	250ml	1.000	5.50	5.50	38	4	1
78	2026-07-01 19:11:13.658773+08	2026-07-01 19:11:13.658778+08	可口可乐(大瓶)	330ml	1.000	3.00	3.00	39	1	1
79	2026-07-01 19:47:38.417626+08	2026-07-01 19:47:38.417632+08	测试	默认	1.000	10.00	10.00	40	7	1
80	2026-07-01 19:47:38.894923+08	2026-07-01 19:47:38.894927+08	测试	默认	1.000	10.00	10.00	41	7	1
81	2026-07-01 19:48:38.347005+08	2026-07-01 19:48:38.347009+08	妙卡巧克力	100g	1.000	12.00	12.00	42	12	1
82	2026-07-01 19:48:38.347655+08	2026-07-01 19:48:38.347658+08	亨氏番茄酱	650g	1.000	22.00	22.00	42	10	1
83	2026-07-01 19:53:24.81478+08	2026-07-01 19:53:24.814784+08	雀巢巧伴伴	430g	1.000	28.00	28.00	43	11	1
84	2026-07-01 19:53:24.815459+08	2026-07-01 19:53:24.815462+08	亨氏番茄酱	650g	1.000	22.00	22.00	43	10	1
85	2026-07-01 19:59:36.346253+08	2026-07-01 19:59:36.346257+08	亨氏番茄酱	650g	1.000	22.00	22.00	44	10	1
86	2026-07-03 18:45:14.921196+08	2026-07-03 18:45:14.921201+08	零度可乐		1.000	3.00	3.00	45	13	1
87	2026-07-03 18:45:14.922594+08	2026-07-03 18:45:14.922599+08	妙卡巧克力		1.000	12.00	12.00	45	12	1
88	2026-07-03 18:45:14.92323+08	2026-07-03 18:45:14.923234+08	雀巢巧伴伴		1.000	28.00	28.00	45	11	1
89	2026-07-03 18:45:14.923762+08	2026-07-03 18:45:14.923766+08	亨氏番茄酱		1.000	22.00	22.00	45	10	1
90	2026-07-03 18:45:14.924328+08	2026-07-03 18:45:14.924332+08	可口可乐		1.000	3.00	3.00	45	9	1
91	2026-07-03 19:00:31.786447+08	2026-07-03 19:00:31.786453+08	农夫山泉		1.000	2.00	2.00	46	8	1
92	2026-07-03 19:00:31.787777+08	2026-07-03 19:00:31.787782+08	青岛啤酒		3.000	6.00	18.00	46	6	1
93	2026-07-03 19:00:31.788325+08	2026-07-03 19:00:31.788329+08	旺旺雪饼		1.000	12.80	12.80	46	5	1
94	2026-07-04 17:27:19.720534+08	2026-07-04 17:27:19.72054+08	Test	default	1.000	12.50	12.50	47	13	1
95	2026-07-04 17:27:38.519935+08	2026-07-04 17:27:38.519939+08	TestItem	default	2.000	12.50	25.00	48	13	1
96	2026-07-04 18:14:36.749329+08	2026-07-04 18:14:36.749333+08	Test	default	1.000	12.50	12.50	49	13	1
97	2026-07-04 18:15:21.885522+08	2026-07-04 18:15:21.885527+08	零度可乐		1.000	3.00	3.00	50	13	1
98	2026-07-04 18:15:21.88672+08	2026-07-04 18:15:21.886725+08	妙卡巧克力		1.000	12.00	12.00	50	12	1
99	2026-07-04 18:15:21.887354+08	2026-07-04 18:15:21.887358+08	雀巢巧伴伴		1.000	28.00	28.00	50	11	1
100	2026-07-04 18:19:48.920117+08	2026-07-04 18:19:48.920122+08	Test	default	2.000	15.00	30.00	51	13	1
101	2026-07-04 18:21:29.512322+08	2026-07-04 18:21:29.512325+08	雀巢巧伴伴		1.000	28.00	28.00	52	11	1
102	2026-07-04 18:21:29.51294+08	2026-07-04 18:21:29.512945+08	亨氏番茄酱		1.000	22.00	22.00	52	10	1
103	2026-07-04 18:21:29.513264+08	2026-07-04 18:21:29.513268+08	可口可乐		1.000	3.00	3.00	52	9	1
104	2026-07-04 18:21:29.513521+08	2026-07-04 18:21:29.513526+08	百事可乐		1.000	3.00	3.00	52	7	1
105	2026-07-04 18:21:29.513807+08	2026-07-04 18:21:29.513811+08	农夫山泉		1.000	2.00	2.00	52	8	1
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product (id, created_at, updated_at, name, image, unit, is_weighted, is_active, category_id, tenant_id, image_url) FROM stdin;
2	2026-06-30 17:44:06.163334+08	2026-06-30 17:44:06.163338+08	农夫山泉		瓶	f	t	1	1	
3	2026-06-30 17:44:06.164151+08	2026-06-30 17:44:06.164154+08	康师傅方便面		袋	f	t	2	1	
4	2026-06-30 17:44:06.164907+08	2026-06-30 17:44:06.16491+08	伊利纯牛奶		盒	f	t	3	1	
5	2026-06-30 17:44:06.165857+08	2026-06-30 17:44:06.165861+08	旺旺雪饼		袋	f	t	2	1	
6	2026-06-30 17:44:06.166837+08	2026-06-30 17:44:06.16684+08	青岛啤酒		瓶	f	t	1	1	
8	2026-07-01 19:32:50.619434+08	2026-07-01 19:32:50.619443+08	农夫山泉		瓶	f	t	1	1	https://images.openfoodfacts.org/images/products/692/116/850/9256/front_en.3.400.jpg
9	2026-07-01 19:32:55.311548+08	2026-07-01 19:32:55.311559+08	可口可乐		罐	f	t	1	1	https://images.openfoodfacts.org/images/products/544/900/000/0996/front_en.1035.400.jpg
10	2026-07-01 19:32:58.504454+08	2026-07-01 19:32:58.50446+08	亨氏番茄酱		瓶	f	t	6	1	https://images.openfoodfacts.org/images/products/871/570/011/0622/front_fr.18.400.jpg
11	2026-07-01 19:33:01.883422+08	2026-07-01 19:33:01.883429+08	雀巢巧伴伴		盒	f	t	4	1	https://images.openfoodfacts.org/images/products/761/303/462/6844/front_fr.355.400.jpg
12	2026-07-01 19:33:05.274356+08	2026-07-01 19:33:05.274362+08	妙卡巧克力		块	f	t	4	1	https://images.openfoodfacts.org/images/products/304/514/010/5502/front_fr.625.400.jpg
7	2026-07-01 19:28:29.361813+08	2026-07-01 20:10:49.148794+08	百事可乐	products/百事可乐_o8g33xU.jpg	瓶	f	t	1	1	
1	2026-06-30 17:44:06.160456+08	2026-07-01 20:18:55.239678+08	可口可乐(大瓶)	products/可口可乐大瓶.jpg	瓶	f	t	1	1	
13	2026-07-01 19:33:08.604991+08	2026-07-04 17:40:04.963213+08	零度可乐	products/百事可乐_rqFtmLx.jpg	罐	f	f	1	1	https://images.openfoodfacts.org/images/products/544/900/013/1805/front_en.687.400.jpg
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_category (id, created_at, updated_at, name, sort_order, parent_id, tenant_id) FROM stdin;
1	2026-06-30 17:44:06.155517+08	2026-06-30 17:44:06.155526+08	饮料	0	\N	1
2	2026-06-30 17:44:06.157752+08	2026-06-30 17:44:06.157757+08	食品	0	\N	1
3	2026-06-30 17:44:06.158352+08	2026-06-30 17:44:06.158356+08	乳制品	0	\N	1
4	2026-06-30 20:45:02.964117+08	2026-06-30 20:45:02.964127+08	零食	0	\N	1
5	2026-06-30 20:45:02.968426+08	2026-06-30 20:45:02.968432+08	酒类	0	\N	1
6	2026-06-30 20:45:02.969425+08	2026-06-30 20:45:02.969429+08	调味品	0	\N	1
7	2026-06-30 20:45:02.970293+08	2026-06-30 20:45:02.970297+08	日用品	0	\N	1
8	2026-06-30 20:45:02.971161+08	2026-06-30 20:45:02.971165+08	冷冻食品	0	\N	1
9	2026-06-30 20:45:02.972+08	2026-06-30 20:45:02.972004+08	粮油米面	0	\N	1
10	2026-06-30 20:45:02.972674+08	2026-06-30 20:45:02.972678+08	个人护理	0	\N	1
11	2026-06-30 20:45:02.9733+08	2026-06-30 20:45:02.973303+08	家居清洁	0	\N	1
12	2026-06-30 20:45:02.974137+08	2026-06-30 20:45:02.97414+08	文具玩具	0	\N	1
\.


--
-- Data for Name: product_sku; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_sku (id, created_at, updated_at, barcode, spec_name, spec_attrs, purchase_price, selling_price, stock_quantity, stock_alert, product_id, tenant_id) FROM stdin;
2	2026-06-30 17:44:06.16374+08	2026-06-30 17:44:06.163743+08	6901234567891	550ml	{}	1.00	2.00	200.000	30.000	2	1
3	2026-06-30 17:44:06.164511+08	2026-06-30 17:44:06.164514+08	6901234567892	红烧牛肉	{}	3.00	4.50	80.000	10.000	3	1
4	2026-06-30 17:44:06.165375+08	2026-06-30 17:44:06.165378+08	6901234567893	250ml	{}	4.00	5.50	60.000	10.000	4	1
5	2026-06-30 17:44:06.166337+08	2026-06-30 17:44:06.16634+08	6901234567894	520g	{}	8.00	12.80	45.000	5.000	5	1
6	2026-06-30 17:44:06.167252+08	2026-06-30 17:44:06.167256+08	6901234567895	500ml	{}	3.50	6.00	100.000	15.000	6	1
1	2026-06-30 17:44:06.161724+08	2026-06-30 17:44:06.161727+08	6901234567890	330ml	{}	2.00	3.00	200.000	20.000	1	1
7	2026-07-01 19:28:29.36273+08	2026-07-01 19:28:29.362733+08	5449000214911	330ml	{}	2.20	3.00	120.000	20.000	7	1
8	2026-07-01 19:32:50.620283+08	2026-07-01 19:32:50.620287+08	6921168509256	550ml	{}	1.00	2.00	200.000	10.000	8	1
9	2026-07-01 19:32:55.312496+08	2026-07-01 19:32:55.312501+08	5449000000996	330ml	{}	2.00	3.00	150.000	10.000	9	1
10	2026-07-01 19:32:58.50529+08	2026-07-01 19:32:58.505295+08	8715700110622	650g	{}	15.00	22.00	30.000	10.000	10	1
11	2026-07-01 19:33:01.884217+08	2026-07-01 19:33:01.88422+08	7613034626844	430g	{}	18.00	28.00	20.000	10.000	11	1
12	2026-07-01 19:33:05.27523+08	2026-07-01 19:33:05.275233+08	3045140105502	100g	{}	8.00	12.00	50.000	10.000	12	1
13	2026-07-01 19:33:08.605819+08	2026-07-01 19:33:08.605822+08	5449000131805	330ml	{}	2.00	3.00	107.000	10.000	13	1
\.


--
-- Data for Name: stock_check; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_check (id, created_at, updated_at, status, remark, created_by_id, tenant_id) FROM stdin;
1	2026-07-04 17:34:04.118229+08	2026-07-04 17:34:04.11824+08	checking	monthly check	1	1
2	2026-07-04 17:34:44.313175+08	2026-07-04 17:34:44.313185+08	done	test	1	1
\.


--
-- Data for Name: stock_check_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_check_item (id, created_at, updated_at, system_quantity, actual_quantity, diff_quantity, remark, sku_id, stock_check_id, tenant_id) FROM stdin;
2	2026-07-04 17:34:04.120863+08	2026-07-04 17:34:04.120868+08	0.000	52.000	0.000	test2	12	1	1
1	2026-07-04 17:34:04.11949+08	2026-07-04 17:34:04.119495+08	0.000	98.000	98.000	test	13	1	1
3	2026-07-04 17:34:44.314055+08	2026-07-04 17:34:44.314062+08	100.000	98.000	-2.000		13	2	1
\.


--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.supplier (id, created_at, updated_at, name, contact, phone, address, remark, tenant_id) FROM stdin;
1	2026-06-30 17:44:06.169742+08	2026-06-30 17:44:06.169745+08	宏达食品批发	王总	13900002001			1
2	2026-06-30 17:44:06.171106+08	2026-06-30 17:44:06.17111+08	永利商贸	陈经理	13900002002			1
\.


--
-- Data for Name: tenant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tenant (id, name, slug, logo, address, phone, business_hours, is_active, created_at) FROM stdin;
1	安居生活超市	tpugxdr			010-12345678		t	2026-06-30 17:38:03.30844+08
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, phone, avatar) FROM stdin;
3	pbkdf2_sha256$1200000$Ri0eB6pCY06POrgQNO6YbQ$wT+OcmF0SHMNCp8Xnscm3MI9j/q/NUnXM/VaIasQWxQ=	\N	t	boss			boss@anju.com	t	t	2026-07-01 18:23:21.476052+08	18888888888	
1	pbkdf2_sha256$1200000$oAu1WXDPY6PbhjqqWc3UHY$fYrDtjg3u3pSgUh4H+ghY+BazVuwID8Kdmay6NYSayg=	2026-07-04 17:05:27.824369+08	t	admin			admin@anju.com	t	t	2026-06-30 17:30:38.226607+08		
2	pbkdf2_sha256$1200000$Y7peHjpv1dts8rDkNNUARn$CeBEWGCPkMLV90EA2qWp6/zfrZe9uRrvmSSF7JeboCY=	\N	f	anjuadmin				f	f	2026-06-30 17:38:03.169175+08	13800138000	
\.


--
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: user_tenant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_tenant (id, role, joined_at, tenant_id, user_id) FROM stdin;
2	manager	2026-06-30 18:09:13.936467+08	1	1
3	super_admin	2026-07-01 18:23:50.650003+08	1	3
1	manager	2026-06-30 17:38:03.309761+08	1	2
\.


--
-- Data for Name: user_user_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 84, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 21, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 36, true);


--
-- Name: employee_shift_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_shift_id_seq', 1, false);


--
-- Name: finance_daily_summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.finance_daily_summary_id_seq', 1, false);


--
-- Name: inventory_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_record_id_seq', 10, true);


--
-- Name: member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.member_id_seq', 5, true);


--
-- Name: pos_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pos_order_id_seq', 52, true);


--
-- Name: pos_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pos_order_item_id_seq', 105, true);


--
-- Name: product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_category_id_seq', 12, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_id_seq', 13, true);


--
-- Name: product_sku_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_sku_id_seq', 13, true);


--
-- Name: stock_check_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_check_id_seq', 2, true);


--
-- Name: stock_check_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_check_item_id_seq', 3, true);


--
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplier_id_seq', 2, true);


--
-- Name: tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tenant_id_seq', 1, true);


--
-- Name: user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_groups_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_id_seq', 3, true);


--
-- Name: user_tenant_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_tenant_id_seq', 3, true);


--
-- Name: user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_user_permissions_id_seq', 1, false);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: employee_shift employee_shift_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_shift
    ADD CONSTRAINT employee_shift_pkey PRIMARY KEY (id);


--
-- Name: finance_daily_summary finance_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_daily_summary
    ADD CONSTRAINT finance_daily_summary_pkey PRIMARY KEY (id);


--
-- Name: finance_daily_summary finance_daily_summary_tenant_id_date_6e1879a8_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_daily_summary
    ADD CONSTRAINT finance_daily_summary_tenant_id_date_6e1879a8_uniq UNIQUE (tenant_id, date);


--
-- Name: inventory_record inventory_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_record
    ADD CONSTRAINT inventory_record_pkey PRIMARY KEY (id);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: pos_order_item pos_order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order_item
    ADD CONSTRAINT pos_order_item_pkey PRIMARY KEY (id);


--
-- Name: pos_order pos_order_order_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order
    ADD CONSTRAINT pos_order_order_no_key UNIQUE (order_no);


--
-- Name: pos_order pos_order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order
    ADD CONSTRAINT pos_order_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sku product_sku_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sku
    ADD CONSTRAINT product_sku_pkey PRIMARY KEY (id);


--
-- Name: stock_check_item stock_check_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check_item
    ADD CONSTRAINT stock_check_item_pkey PRIMARY KEY (id);


--
-- Name: stock_check_item stock_check_item_stock_check_id_sku_id_79b9bfc8_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check_item
    ADD CONSTRAINT stock_check_item_stock_check_id_sku_id_79b9bfc8_uniq UNIQUE (stock_check_id, sku_id);


--
-- Name: stock_check stock_check_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check
    ADD CONSTRAINT stock_check_pkey PRIMARY KEY (id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- Name: tenant tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (id);


--
-- Name: tenant tenant_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_slug_key UNIQUE (slug);


--
-- Name: product_sku uq_tenant_barcode; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sku
    ADD CONSTRAINT uq_tenant_barcode UNIQUE (tenant_id, barcode);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_user_id_group_id_40beef00_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_user_id_group_id_40beef00_uniq UNIQUE (user_id, group_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_tenant user_tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tenant
    ADD CONSTRAINT user_tenant_pkey PRIMARY KEY (id);


--
-- Name: user_tenant user_tenant_user_id_tenant_id_36fd9a85_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tenant
    ADD CONSTRAINT user_tenant_user_id_tenant_id_36fd9a85_uniq UNIQUE (user_id, tenant_id);


--
-- Name: user_user_permissions user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_user_permissions
    ADD CONSTRAINT user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: user_user_permissions user_user_permissions_user_id_permission_id_7dc6e2e0_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_user_permissions
    ADD CONSTRAINT user_user_permissions_user_id_permission_id_7dc6e2e0_uniq UNIQUE (user_id, permission_id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: employee_shift_tenant_id_988ca8c3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_shift_tenant_id_988ca8c3 ON public.employee_shift USING btree (tenant_id);


--
-- Name: employee_shift_user_id_cb49ebd8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_shift_user_id_cb49ebd8 ON public.employee_shift USING btree (user_id);


--
-- Name: finance_daily_summary_tenant_id_b2e91384; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX finance_daily_summary_tenant_id_b2e91384 ON public.finance_daily_summary USING btree (tenant_id);


--
-- Name: inventory_record_operator_id_60220831; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_record_operator_id_60220831 ON public.inventory_record USING btree (operator_id);


--
-- Name: inventory_record_sku_id_046543aa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_record_sku_id_046543aa ON public.inventory_record USING btree (sku_id);


--
-- Name: inventory_record_tenant_id_b2250982; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_record_tenant_id_b2250982 ON public.inventory_record USING btree (tenant_id);


--
-- Name: member_tenant_id_94eee4ea; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX member_tenant_id_94eee4ea ON public.member USING btree (tenant_id);


--
-- Name: pos_order_cashier_id_0d96b16a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_cashier_id_0d96b16a ON public.pos_order USING btree (cashier_id);


--
-- Name: pos_order_item_order_id_6a977ad5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_item_order_id_6a977ad5 ON public.pos_order_item USING btree (order_id);


--
-- Name: pos_order_item_sku_id_5e26bb77; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_item_sku_id_5e26bb77 ON public.pos_order_item USING btree (sku_id);


--
-- Name: pos_order_item_tenant_id_20bba519; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_item_tenant_id_20bba519 ON public.pos_order_item USING btree (tenant_id);


--
-- Name: pos_order_member_id_4f7e71f7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_member_id_4f7e71f7 ON public.pos_order USING btree (member_id);


--
-- Name: pos_order_order_no_1f17503d_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_order_no_1f17503d_like ON public.pos_order USING btree (order_no varchar_pattern_ops);


--
-- Name: pos_order_tenant_id_13a991ec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pos_order_tenant_id_13a991ec ON public.pos_order USING btree (tenant_id);


--
-- Name: product_category_id_640030a0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_category_id_640030a0 ON public.product USING btree (category_id);


--
-- Name: product_category_parent_id_f6860923; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_category_parent_id_f6860923 ON public.product_category USING btree (parent_id);


--
-- Name: product_category_tenant_id_137164b9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_category_tenant_id_137164b9 ON public.product_category USING btree (tenant_id);


--
-- Name: product_sku_product_id_ecb13de3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_sku_product_id_ecb13de3 ON public.product_sku USING btree (product_id);


--
-- Name: product_sku_tenant_id_7e9c5687; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_sku_tenant_id_7e9c5687 ON public.product_sku USING btree (tenant_id);


--
-- Name: product_tenant_id_957f8279; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX product_tenant_id_957f8279 ON public.product USING btree (tenant_id);


--
-- Name: stock_check_created_by_id_83ff223f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stock_check_created_by_id_83ff223f ON public.stock_check USING btree (created_by_id);


--
-- Name: stock_check_item_sku_id_620df826; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stock_check_item_sku_id_620df826 ON public.stock_check_item USING btree (sku_id);


--
-- Name: stock_check_item_stock_check_id_09bba7d2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stock_check_item_stock_check_id_09bba7d2 ON public.stock_check_item USING btree (stock_check_id);


--
-- Name: stock_check_item_tenant_id_12d5e3db; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stock_check_item_tenant_id_12d5e3db ON public.stock_check_item USING btree (tenant_id);


--
-- Name: stock_check_tenant_id_2c1968d7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stock_check_tenant_id_2c1968d7 ON public.stock_check USING btree (tenant_id);


--
-- Name: supplier_tenant_id_8a35a691; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX supplier_tenant_id_8a35a691 ON public.supplier USING btree (tenant_id);


--
-- Name: tenant_slug_812ad82d_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tenant_slug_812ad82d_like ON public.tenant USING btree (slug varchar_pattern_ops);


--
-- Name: user_groups_group_id_b76f8aba; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_groups_group_id_b76f8aba ON public.user_groups USING btree (group_id);


--
-- Name: user_groups_user_id_abaea130; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_groups_user_id_abaea130 ON public.user_groups USING btree (user_id);


--
-- Name: user_tenant_tenant_id_ea6c5f74; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_tenant_tenant_id_ea6c5f74 ON public.user_tenant USING btree (tenant_id);


--
-- Name: user_tenant_user_id_e4d2580a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_tenant_user_id_e4d2580a ON public.user_tenant USING btree (user_id);


--
-- Name: user_user_permissions_permission_id_9deb68a3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_user_permissions_permission_id_9deb68a3 ON public.user_user_permissions USING btree (permission_id);


--
-- Name: user_user_permissions_user_id_ed4a47ea; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_user_permissions_user_id_ed4a47ea ON public.user_user_permissions USING btree (user_id);


--
-- Name: user_username_cf016618_like; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_username_cf016618_like ON public."user" USING btree (username varchar_pattern_ops);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: employee_shift employee_shift_tenant_id_988ca8c3_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_shift
    ADD CONSTRAINT employee_shift_tenant_id_988ca8c3_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: employee_shift employee_shift_user_id_cb49ebd8_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_shift
    ADD CONSTRAINT employee_shift_user_id_cb49ebd8_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: finance_daily_summary finance_daily_summary_tenant_id_b2e91384_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_daily_summary
    ADD CONSTRAINT finance_daily_summary_tenant_id_b2e91384_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: inventory_record inventory_record_operator_id_60220831_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_record
    ADD CONSTRAINT inventory_record_operator_id_60220831_fk_user_id FOREIGN KEY (operator_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: inventory_record inventory_record_sku_id_046543aa_fk_product_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_record
    ADD CONSTRAINT inventory_record_sku_id_046543aa_fk_product_sku_id FOREIGN KEY (sku_id) REFERENCES public.product_sku(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: inventory_record inventory_record_tenant_id_b2250982_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_record
    ADD CONSTRAINT inventory_record_tenant_id_b2250982_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: member member_tenant_id_94eee4ea_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_tenant_id_94eee4ea_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order pos_order_cashier_id_0d96b16a_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order
    ADD CONSTRAINT pos_order_cashier_id_0d96b16a_fk_user_id FOREIGN KEY (cashier_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order_item pos_order_item_order_id_6a977ad5_fk_pos_order_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order_item
    ADD CONSTRAINT pos_order_item_order_id_6a977ad5_fk_pos_order_id FOREIGN KEY (order_id) REFERENCES public.pos_order(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order_item pos_order_item_sku_id_5e26bb77_fk_product_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order_item
    ADD CONSTRAINT pos_order_item_sku_id_5e26bb77_fk_product_sku_id FOREIGN KEY (sku_id) REFERENCES public.product_sku(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order_item pos_order_item_tenant_id_20bba519_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order_item
    ADD CONSTRAINT pos_order_item_tenant_id_20bba519_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order pos_order_member_id_4f7e71f7_fk_member_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order
    ADD CONSTRAINT pos_order_member_id_4f7e71f7_fk_member_id FOREIGN KEY (member_id) REFERENCES public.member(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: pos_order pos_order_tenant_id_13a991ec_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pos_order
    ADD CONSTRAINT pos_order_tenant_id_13a991ec_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product product_category_id_640030a0_fk_product_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_640030a0_fk_product_category_id FOREIGN KEY (category_id) REFERENCES public.product_category(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_category product_category_parent_id_f6860923_fk_product_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_id_f6860923_fk_product_category_id FOREIGN KEY (parent_id) REFERENCES public.product_category(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_category product_category_tenant_id_137164b9_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_tenant_id_137164b9_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_sku product_sku_product_id_ecb13de3_fk_product_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sku
    ADD CONSTRAINT product_sku_product_id_ecb13de3_fk_product_id FOREIGN KEY (product_id) REFERENCES public.product(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_sku product_sku_tenant_id_7e9c5687_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sku
    ADD CONSTRAINT product_sku_tenant_id_7e9c5687_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product product_tenant_id_957f8279_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_tenant_id_957f8279_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: stock_check stock_check_created_by_id_83ff223f_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check
    ADD CONSTRAINT stock_check_created_by_id_83ff223f_fk_user_id FOREIGN KEY (created_by_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: stock_check_item stock_check_item_sku_id_620df826_fk_product_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check_item
    ADD CONSTRAINT stock_check_item_sku_id_620df826_fk_product_sku_id FOREIGN KEY (sku_id) REFERENCES public.product_sku(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: stock_check_item stock_check_item_stock_check_id_09bba7d2_fk_stock_check_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check_item
    ADD CONSTRAINT stock_check_item_stock_check_id_09bba7d2_fk_stock_check_id FOREIGN KEY (stock_check_id) REFERENCES public.stock_check(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: stock_check_item stock_check_item_tenant_id_12d5e3db_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check_item
    ADD CONSTRAINT stock_check_item_tenant_id_12d5e3db_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: stock_check stock_check_tenant_id_2c1968d7_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_check
    ADD CONSTRAINT stock_check_tenant_id_2c1968d7_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: supplier supplier_tenant_id_8a35a691_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_tenant_id_8a35a691_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_groups user_groups_group_id_b76f8aba_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_group_id_b76f8aba_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_groups user_groups_user_id_abaea130_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_user_id_abaea130_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_tenant user_tenant_tenant_id_ea6c5f74_fk_tenant_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tenant
    ADD CONSTRAINT user_tenant_tenant_id_ea6c5f74_fk_tenant_id FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_tenant user_tenant_user_id_e4d2580a_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tenant
    ADD CONSTRAINT user_tenant_user_id_e4d2580a_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_user_permissions user_user_permission_permission_id_9deb68a3_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_user_permissions
    ADD CONSTRAINT user_user_permission_permission_id_9deb68a3_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_user_permissions user_user_permissions_user_id_ed4a47ea_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_user_permissions
    ADD CONSTRAINT user_user_permissions_user_id_ed4a47ea_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

\unrestrict wLtzRVJpWt3JcNOqTrcXWKhY885G1WrBizHAFzY6gH1eDdHB2C60neaaWcHa6zO

