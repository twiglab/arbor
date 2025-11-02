-- =============================================
-- 基础资料模块 (Master Data Module)
-- 表前缀: md_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- PostgreSQL UUID扩展
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";



-- =============================================
-- 更新时间触发器函数
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- =============================================
-- 1. 项目管理
-- =============================================

-- 项目表
DROP TABLE IF EXISTS md_project CASCADE;
CREATE TABLE md_project (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    short_name VARCHAR(64),
    english_name VARCHAR(128),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    project_type VARCHAR(20),
    address VARCHAR(256),
    total_area NUMERIC(19,2),
    business_area NUMERIC(19,2),
    opening_date DATE,
    contact_person VARCHAR(64),
    contact_phone VARCHAR(32),
    remark VARCHAR(512)
);

CREATE INDEX idx_project_code ON md_project(code);
CREATE INDEX idx_project_status ON md_project(status);
CREATE INDEX idx_project_deleted ON md_project(deleted);
CREATE UNIQUE INDEX uk_project_code ON md_project(code) WHERE deleted = 0;

CREATE TRIGGER update_md_project_updated_at BEFORE UPDATE ON md_project
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_project IS '项目表';
COMMENT ON COLUMN md_project.id IS '主键UUID';
COMMENT ON COLUMN md_project.code IS '项目编码';
COMMENT ON COLUMN md_project.name IS '项目名称';
COMMENT ON COLUMN md_project.status IS '状态: ACTIVE-运营中, INACTIVE-已关闭';

-- =============================================
-- 2. 商户管理
-- =============================================

-- 商户表
DROP TABLE IF EXISTS md_tenant CASCADE;
CREATE TABLE md_tenant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    short_name VARCHAR(64),
    english_name VARCHAR(128),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    tenant_type VARCHAR(20) NOT NULL,
    industry_id UUID,
    biz_type_id UUID,

    -- 企业信息
    legal_name VARCHAR(128),
    uscc VARCHAR(32),
    legal_person VARCHAR(64),
    register_address VARCHAR(256),
    business_address VARCHAR(256),

    -- 税务信息
    taxpayer_type VARCHAR(20),
    tax_code VARCHAR(64),

    -- 联系信息
    contact_person VARCHAR(64),
    contact_phone VARCHAR(32),
    email VARCHAR(128),
    website VARCHAR(256),

    -- 评级信息
    grade_level VARCHAR(20),
    grade_score NUMERIC(5,2),

    remark VARCHAR(512)
);

CREATE INDEX idx_tenant_code ON md_tenant(code);
CREATE INDEX idx_tenant_status ON md_tenant(status);
CREATE INDEX idx_tenant_type ON md_tenant(tenant_type);
CREATE INDEX idx_tenant_industry ON md_tenant(industry_id);
CREATE INDEX idx_tenant_biz_type ON md_tenant(biz_type_id);
CREATE INDEX idx_tenant_deleted ON md_tenant(deleted);
CREATE UNIQUE INDEX uk_tenant_code ON md_tenant(code) WHERE deleted = 0;

CREATE TRIGGER update_md_tenant_updated_at BEFORE UPDATE ON md_tenant
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_tenant IS '商户表';
COMMENT ON COLUMN md_tenant.code IS '商户编码';
COMMENT ON COLUMN md_tenant.name IS '商户名称';
COMMENT ON COLUMN md_tenant.tenant_type IS '类型: MERCHANT-商户, PROPERTY-业主, PARKING-停车';

-- 商户联系方式表
DROP TABLE IF EXISTS md_tenant_contact CASCADE;
CREATE TABLE md_tenant_contact (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    contact_type VARCHAR(20) NOT NULL,
    name VARCHAR(64) NOT NULL,
    position VARCHAR(64),
    phone VARCHAR(32),
    mobile VARCHAR(32),
    email VARCHAR(128),
    qq VARCHAR(32),
    wechat VARCHAR(64),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX idx_contact_tenant ON md_tenant_contact(tenant_id);
CREATE INDEX idx_contact_type ON md_tenant_contact(contact_type);
CREATE INDEX idx_contact_deleted ON md_tenant_contact(deleted);

CREATE TRIGGER update_md_tenant_contact_updated_at BEFORE UPDATE ON md_tenant_contact
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_tenant_contact IS '商户联系方式表';

-- 商户银行信息表
DROP TABLE IF EXISTS md_tenant_bank CASCADE;
CREATE TABLE md_tenant_bank (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    bank_id UUID,
    bank_name VARCHAR(128) NOT NULL,
    account_name VARCHAR(128) NOT NULL,
    account_number VARCHAR(64) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX idx_tenant_bank_tenant ON md_tenant_bank(tenant_id);
CREATE INDEX idx_tenant_bank_bank_id ON md_tenant_bank(bank_id);
CREATE INDEX idx_tenant_bank_deleted ON md_tenant_bank(deleted);

CREATE TRIGGER update_md_tenant_bank_updated_at BEFORE UPDATE ON md_tenant_bank
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_tenant_bank IS '商户银行信息表';

-- =============================================
-- 3. 品牌管理
-- =============================================

-- 品牌表
DROP TABLE IF EXISTS md_brand CASCADE;
CREATE TABLE md_brand (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    english_name VARCHAR(128),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    brand_level VARCHAR(20),
    industry_id UUID,
    country VARCHAR(64),
    introduction TEXT,
    logo_url VARCHAR(256),
    remark VARCHAR(512)
);

CREATE INDEX idx_brand_code ON md_brand(code);
CREATE INDEX idx_brand_status ON md_brand(status);
CREATE INDEX idx_brand_industry ON md_brand(industry_id);
CREATE INDEX idx_brand_deleted ON md_brand(deleted);
CREATE UNIQUE INDEX uk_brand_code ON md_brand(code) WHERE deleted = 0;

CREATE TRIGGER update_md_brand_updated_at BEFORE UPDATE ON md_brand
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_brand IS '品牌表';

-- 商户品牌关联表
DROP TABLE IF EXISTS md_tenant_brand CASCADE;
CREATE TABLE md_tenant_brand (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    brand_id UUID NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    start_date DATE,
    end_date DATE,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tb_tenant ON md_tenant_brand(tenant_id);
CREATE INDEX idx_tb_brand ON md_tenant_brand(brand_id);
CREATE UNIQUE INDEX uk_tb_tenant_brand ON md_tenant_brand(tenant_id, brand_id);

COMMENT ON TABLE md_tenant_brand IS '商户品牌关联表';

-- =============================================
-- 4. 分类字典
-- =============================================

-- 行业表
DROP TABLE IF EXISTS md_industry CASCADE;
CREATE TABLE md_industry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    parent_id UUID,
    level INTEGER NOT NULL DEFAULT 1,
    path VARCHAR(512),
    sort_order INTEGER DEFAULT 0,
    is_leaf BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_industry_code ON md_industry(code);
CREATE INDEX idx_industry_parent ON md_industry(parent_id);
CREATE INDEX idx_industry_level ON md_industry(level);
CREATE INDEX idx_industry_deleted ON md_industry(deleted);

CREATE TRIGGER update_md_industry_updated_at BEFORE UPDATE ON md_industry
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_industry IS '行业表';

-- 业态表
DROP TABLE IF EXISTS md_biz_type CASCADE;
CREATE TABLE md_biz_type (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    parent_id UUID,
    level INTEGER NOT NULL DEFAULT 1,
    path VARCHAR(512),
    sort_order INTEGER DEFAULT 0,
    is_leaf BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_biztype_code ON md_biz_type(code);
CREATE INDEX idx_biztype_parent ON md_biz_type(parent_id);
CREATE INDEX idx_biztype_level ON md_biz_type(level);
CREATE INDEX idx_biztype_deleted ON md_biz_type(deleted);

CREATE TRIGGER update_md_biz_type_updated_at BEFORE UPDATE ON md_biz_type
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_biz_type IS '业态表';

-- 区域表
DROP TABLE IF EXISTS md_area CASCADE;
CREATE TABLE md_area (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    name VARCHAR(128) NOT NULL,
    parent_id UUID,
    level INTEGER NOT NULL DEFAULT 1,
    path VARCHAR(512),
    area_type VARCHAR(20),
    area_size NUMERIC(19,2),
    sort_order INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_area_project ON md_area(project_id);
CREATE INDEX idx_area_code ON md_area(project_id, code);
CREATE INDEX idx_area_parent ON md_area(parent_id);
CREATE INDEX idx_area_deleted ON md_area(deleted);

CREATE TRIGGER update_md_area_updated_at BEFORE UPDATE ON md_area
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_area IS '区域表';

-- 位置表 (铺位/档口)
DROP TABLE IF EXISTS md_position CASCADE;
CREATE TABLE md_position (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    area_id UUID,
    name VARCHAR(128) NOT NULL,
    position_type VARCHAR(20),
    area_size NUMERIC(19,2),
    status VARCHAR(20) NOT NULL DEFAULT 'VACANT',
    lease_type VARCHAR(20),
    rent_price NUMERIC(19,4),
    property_fee NUMERIC(19,4),
    floor VARCHAR(20),
    position_no VARCHAR(64),
    remark VARCHAR(512)
);

CREATE INDEX idx_position_project ON md_position(project_id);
CREATE INDEX idx_position_area ON md_position(area_id);
CREATE INDEX idx_position_code ON md_position(project_id, code);
CREATE INDEX idx_position_status ON md_position(status);
CREATE INDEX idx_position_deleted ON md_position(deleted);

CREATE TRIGGER update_md_position_updated_at BEFORE UPDATE ON md_position
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_position IS '位置表(铺位/档口)';

-- =============================================
-- 5. 收费科目
-- =============================================

-- 科目类型表
DROP TABLE IF EXISTS md_subject_type CASCADE;
CREATE TABLE md_subject_type (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512)
);

CREATE INDEX idx_stype_code ON md_subject_type(code);
CREATE INDEX idx_stype_deleted ON md_subject_type(deleted);

CREATE TRIGGER update_md_subject_type_updated_at BEFORE UPDATE ON md_subject_type
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_subject_type IS '科目类型表';

-- 收费科目表
DROP TABLE IF EXISTS md_subject CASCADE;
CREATE TABLE md_subject (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID,
    type_id UUID NOT NULL,
    name VARCHAR(128) NOT NULL,
    short_name VARCHAR(64),
    subject_nature VARCHAR(20) NOT NULL,
    charge_type VARCHAR(20),
    unit VARCHAR(20),
    unit_price NUMERIC(19,4),
    tax_rate NUMERIC(5,2),
    is_invoiceable BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512)
);

CREATE INDEX idx_subject_project ON md_subject(project_id);
CREATE INDEX idx_subject_type ON md_subject(type_id);
CREATE INDEX idx_subject_code ON md_subject(code);
CREATE INDEX idx_subject_nature ON md_subject(subject_nature);
CREATE INDEX idx_subject_deleted ON md_subject(deleted);

CREATE TRIGGER update_md_subject_updated_at BEFORE UPDATE ON md_subject
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_subject IS '收费科目表';

-- =============================================
-- 6. 付款方式
-- =============================================

-- 付款方式表
DROP TABLE IF EXISTS md_payment_method CASCADE;
CREATE TABLE md_payment_method (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    method_type VARCHAR(20) NOT NULL,
    is_online BOOLEAN DEFAULT FALSE,
    fee_rate NUMERIC(5,4),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512)
);

CREATE INDEX idx_paymethod_code ON md_payment_method(code);
CREATE INDEX idx_paymethod_type ON md_payment_method(method_type);
CREATE INDEX idx_paymethod_deleted ON md_payment_method(deleted);

CREATE TRIGGER update_md_payment_method_updated_at BEFORE UPDATE ON md_payment_method
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_payment_method IS '付款方式表';

-- =============================================
-- 7. 银行资料
-- =============================================

-- 银行表
DROP TABLE IF EXISTS md_bank CASCADE;
CREATE TABLE md_bank (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    short_name VARCHAR(64),
    bank_type VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512)
);

CREATE INDEX idx_bank_code ON md_bank(code);
CREATE INDEX idx_bank_deleted ON md_bank(deleted);

CREATE TRIGGER update_md_bank_updated_at BEFORE UPDATE ON md_bank
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_bank IS '银行表';

-- =============================================
-- 8. 物品字典
-- =============================================

-- 物品表
DROP TABLE IF EXISTS md_goods CASCADE;
CREATE TABLE md_goods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    category VARCHAR(64),
    unit VARCHAR(20),
    spec VARCHAR(128),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_goods_code ON md_goods(code);
CREATE INDEX idx_goods_category ON md_goods(category);
CREATE INDEX idx_goods_deleted ON md_goods(deleted);

CREATE TRIGGER update_md_goods_updated_at BEFORE UPDATE ON md_goods
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE md_goods IS '物品表';
