-- =============================================
-- 营运管理模块 (Operation Module)
-- 表前缀: opr_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- 1. 巡检管理
-- =============================================

-- 巡检项目表
DROP TABLE IF EXISTS opr_inspection_item CASCADE;
CREATE TABLE opr_inspection_item (
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
    check_standard TEXT,
    sort_order INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_ii_code ON opr_inspection_item(code);
CREATE INDEX idx_ii_category ON opr_inspection_item(category);
CREATE INDEX idx_ii_status ON opr_inspection_item(status);
CREATE INDEX idx_ii_deleted ON opr_inspection_item(deleted);

CREATE TRIGGER update_opr_inspection_item_updated_at BEFORE UPDATE ON opr_inspection_item
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_inspection_item IS '巡检项目表';

-- 巡检计划表
DROP TABLE IF EXISTS opr_inspection_plan CASCADE;
CREATE TABLE opr_inspection_plan (
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
    plan_type VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    cycle_unit VARCHAR(20),
    cycle_value INTEGER,
    responsible_uuid UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_ip_project ON opr_inspection_plan(project_id);
CREATE INDEX idx_ip_code ON opr_inspection_plan(code);
CREATE INDEX idx_ip_status ON opr_inspection_plan(status);
CREATE INDEX idx_ip_deleted ON opr_inspection_plan(deleted);

CREATE TRIGGER update_opr_inspection_plan_updated_at BEFORE UPDATE ON opr_inspection_plan
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_inspection_plan IS '巡检计划表';

-- 巡检记录表
DROP TABLE IF EXISTS opr_inspection_record CASCADE;
CREATE TABLE opr_inspection_record (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    plan_id UUID,
    project_id UUID NOT NULL,
    inspection_date DATE NOT NULL,
    inspector_uuid UUID,
    area_id UUID,
    position_id UUID,
    result VARCHAR(20),
    problem_count INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    remark TEXT
);

CREATE INDEX idx_ir_plan ON opr_inspection_record(plan_id);
CREATE INDEX idx_ir_project ON opr_inspection_record(project_id);
CREATE INDEX idx_ir_code ON opr_inspection_record(code);
CREATE INDEX idx_ir_date ON opr_inspection_record(inspection_date);
CREATE INDEX idx_ir_status ON opr_inspection_record(status);
CREATE INDEX idx_ir_deleted ON opr_inspection_record(deleted);

CREATE TRIGGER update_opr_inspection_record_updated_at BEFORE UPDATE ON opr_inspection_record
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_inspection_record IS '巡检记录表';

-- 巡检记录明细表
DROP TABLE IF EXISTS opr_inspection_detail CASCADE;
CREATE TABLE opr_inspection_detail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    record_id UUID NOT NULL,
    item_id UUID NOT NULL,
    check_result VARCHAR(20) NOT NULL,
    problem TEXT,
    photo_url VARCHAR(512),
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ird_record ON opr_inspection_detail(record_id);
CREATE INDEX idx_ird_item ON opr_inspection_detail(item_id);

COMMENT ON TABLE opr_inspection_detail IS '巡检记录明细表';

-- =============================================
-- 2. 投诉管理
-- =============================================

-- 投诉类型表
DROP TABLE IF EXISTS opr_complaint_type CASCADE;
CREATE TABLE opr_complaint_type (
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
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_ct_code ON opr_complaint_type(code);
CREATE INDEX idx_ct_parent ON opr_complaint_type(parent_id);
CREATE INDEX idx_ct_status ON opr_complaint_type(status);
CREATE INDEX idx_ct_deleted ON opr_complaint_type(deleted);

CREATE TRIGGER update_opr_complaint_type_updated_at BEFORE UPDATE ON opr_complaint_type
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_complaint_type IS '投诉类型表';

-- 投诉表
DROP TABLE IF EXISTS opr_complaint CASCADE;
CREATE TABLE opr_complaint (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    type_id UUID NOT NULL,
    name VARCHAR(128) NOT NULL,
    complainant VARCHAR(64),
    contact_phone VARCHAR(32),
    complaint_date TIMESTAMP NOT NULL,
    position_id UUID,
    tenant_id UUID,
    content TEXT NOT NULL,
    urgency VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    handler_uuid UUID,
    handle_result TEXT,
    handle_date TIMESTAMP,
    satisfaction VARCHAR(20),
    remark VARCHAR(512)
);

CREATE INDEX idx_complaint_project ON opr_complaint(project_id);
CREATE INDEX idx_complaint_type ON opr_complaint(type_id);
CREATE INDEX idx_complaint_code ON opr_complaint(code);
CREATE INDEX idx_complaint_date ON opr_complaint(complaint_date);
CREATE INDEX idx_complaint_status ON opr_complaint(status);
CREATE INDEX idx_complaint_deleted ON opr_complaint(deleted);

CREATE TRIGGER update_opr_complaint_updated_at BEFORE UPDATE ON opr_complaint
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_complaint IS '投诉表';

-- =============================================
-- 3. 工单管理
-- =============================================

-- 工单表
DROP TABLE IF EXISTS opr_work_order CASCADE;
CREATE TABLE opr_work_order (
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
    order_type VARCHAR(20) NOT NULL,
    source_type VARCHAR(20),
    source_id UUID,
    urgency VARCHAR(20),
    position_id UUID,
    tenant_id UUID,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    assign_to_uuid UUID,
    plan_start_date TIMESTAMP,
    plan_end_date TIMESTAMP,
    actual_start_date TIMESTAMP,
    actual_end_date TIMESTAMP,
    result TEXT,
    remark VARCHAR(512)
);

CREATE INDEX idx_wo_project ON opr_work_order(project_id);
CREATE INDEX idx_wo_code ON opr_work_order(code);
CREATE INDEX idx_wo_type ON opr_work_order(order_type);
CREATE INDEX idx_wo_status ON opr_work_order(status);
CREATE INDEX idx_wo_assign ON opr_work_order(assign_to_uuid);
CREATE INDEX idx_wo_deleted ON opr_work_order(deleted);

CREATE TRIGGER update_opr_work_order_updated_at BEFORE UPDATE ON opr_work_order
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE opr_work_order IS '工单表';
