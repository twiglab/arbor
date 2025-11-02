-- =============================================
-- 招商管理模块 (Investment Module)
-- 表前缀: inv_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- 1. 合同管理
-- =============================================

-- 租赁合同表
DROP TABLE IF EXISTS inv_contract CASCADE;
CREATE TABLE inv_contract (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    name VARCHAR(128),
    contract_type VARCHAR(20) NOT NULL,
    contract_nature VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',

    -- 租期信息
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    rent_free_days INTEGER DEFAULT 0,
    rent_free_start DATE,
    rent_free_end DATE,

    -- 金额信息
    total_rent_amt NUMERIC(19,4),
    deposit_amt NUMERIC(19,4),

    -- 签约信息
    sign_date DATE,
    signing_location VARCHAR(256),

    -- 附件
    contract_file_url VARCHAR(512),

    remark VARCHAR(512)
);

CREATE INDEX idx_contract_project ON inv_contract(project_id);
CREATE INDEX idx_contract_tenant ON inv_contract(tenant_id);
CREATE INDEX idx_contract_code ON inv_contract(code);
CREATE INDEX idx_contract_status ON inv_contract(status);
CREATE INDEX idx_contract_date ON inv_contract(start_date, end_date);
CREATE INDEX idx_contract_deleted ON inv_contract(deleted);

CREATE TRIGGER update_inv_contract_updated_at BEFORE UPDATE ON inv_contract
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE inv_contract IS '租赁合同表';

-- 合同位置关联表
DROP TABLE IF EXISTS inv_contract_position CASCADE;
CREATE TABLE inv_contract_position (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID NOT NULL,
    position_id UUID NOT NULL,
    area_size NUMERIC(19,2),
    rent_price NUMERIC(19,4),
    property_fee NUMERIC(19,4),
    start_date DATE,
    end_date DATE,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cp_contract ON inv_contract_position(contract_id);
CREATE INDEX idx_cp_position ON inv_contract_position(position_id);

COMMENT ON TABLE inv_contract_position IS '合同位置关联表';

-- 合同科目表
DROP TABLE IF EXISTS inv_contract_subject CASCADE;
CREATE TABLE inv_contract_subject (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    charge_type VARCHAR(20),
    unit_price NUMERIC(19,4),
    quantity NUMERIC(19,4),
    amount NUMERIC(19,4),
    start_date DATE,
    end_date DATE,
    billing_cycle VARCHAR(20),
    payment_days INTEGER,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX idx_cs_contract ON inv_contract_subject(contract_id);
CREATE INDEX idx_cs_subject ON inv_contract_subject(subject_id);
CREATE INDEX idx_cs_deleted ON inv_contract_subject(deleted);

CREATE TRIGGER update_inv_contract_subject_updated_at BEFORE UPDATE ON inv_contract_subject
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE inv_contract_subject IS '合同科目表';

-- =============================================
-- 2. 潜在商户 (招商线索)
-- =============================================

-- 潜在商户表
DROP TABLE IF EXISTS inv_potential_tenant CASCADE;
CREATE TABLE inv_potential_tenant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID,
    name VARCHAR(128) NOT NULL,
    industry_id UUID,
    contact_person VARCHAR(64),
    contact_phone VARCHAR(32),
    email VARCHAR(128),
    intention_level VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'FOLLOWING',
    follow_person_uuid UUID,
    last_follow_date DATE,
    remark TEXT
);

CREATE INDEX idx_pt_project ON inv_potential_tenant(project_id);
CREATE INDEX idx_pt_status ON inv_potential_tenant(status);
CREATE INDEX idx_pt_follow_person ON inv_potential_tenant(follow_person_uuid);
CREATE INDEX idx_pt_deleted ON inv_potential_tenant(deleted);

CREATE TRIGGER update_inv_potential_tenant_updated_at BEFORE UPDATE ON inv_potential_tenant
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE inv_potential_tenant IS '潜在商户表(招商线索)';
