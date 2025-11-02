-- =============================================
-- 物业管理模块 (Property Module)
-- 表前缀: prop_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- 1. 设备管理
-- =============================================

-- 设备分类表
DROP TABLE IF EXISTS prop_device_category CASCADE;
CREATE TABLE prop_device_category (
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

CREATE INDEX idx_dc_code ON prop_device_category(code);
CREATE INDEX idx_dc_parent ON prop_device_category(parent_id);
CREATE INDEX idx_dc_deleted ON prop_device_category(deleted);

CREATE TRIGGER update_prop_device_category_updated_at BEFORE UPDATE ON prop_device_category
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_device_category IS '设备分类表';

-- 设备表
DROP TABLE IF EXISTS prop_device CASCADE;
CREATE TABLE prop_device (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    category_id UUID NOT NULL,
    name VARCHAR(128) NOT NULL,
    position_id UUID,
    model VARCHAR(64),
    brand VARCHAR(64),
    purchase_date DATE,
    install_date DATE,
    warranty_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    remark VARCHAR(512)
);

CREATE INDEX idx_device_project ON prop_device(project_id);
CREATE INDEX idx_device_category ON prop_device(category_id);
CREATE INDEX idx_device_position ON prop_device(position_id);
CREATE INDEX idx_device_code ON prop_device(code);
CREATE INDEX idx_device_status ON prop_device(status);
CREATE INDEX idx_device_deleted ON prop_device(deleted);

CREATE TRIGGER update_prop_device_updated_at BEFORE UPDATE ON prop_device
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_device IS '设备表';

-- 设备保养计划表
DROP TABLE IF EXISTS prop_device_maint_plan CASCADE;
CREATE TABLE prop_device_maint_plan (
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
    category_id UUID,
    plan_type VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    cycle_unit VARCHAR(20),
    cycle_value INTEGER,
    responsible_uuid UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_dmp_project ON prop_device_maint_plan(project_id);
CREATE INDEX idx_dmp_category ON prop_device_maint_plan(category_id);
CREATE INDEX idx_dmp_code ON prop_device_maint_plan(code);
CREATE INDEX idx_dmp_status ON prop_device_maint_plan(status);
CREATE INDEX idx_dmp_deleted ON prop_device_maint_plan(deleted);

CREATE TRIGGER update_prop_device_maint_plan_updated_at BEFORE UPDATE ON prop_device_maint_plan
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_device_maint_plan IS '设备保养计划表';

-- 设备保养记录表
DROP TABLE IF EXISTS prop_device_maint_record CASCADE;
CREATE TABLE prop_device_maint_record (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    plan_id UUID,
    device_id UUID NOT NULL,
    maint_date DATE NOT NULL,
    maint_person_uuid UUID,
    result VARCHAR(20),
    problem TEXT,
    solution TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    remark VARCHAR(512)
);

CREATE INDEX idx_dmr_plan ON prop_device_maint_record(plan_id);
CREATE INDEX idx_dmr_device ON prop_device_maint_record(device_id);
CREATE INDEX idx_dmr_code ON prop_device_maint_record(code);
CREATE INDEX idx_dmr_date ON prop_device_maint_record(maint_date);
CREATE INDEX idx_dmr_deleted ON prop_device_maint_record(deleted);

CREATE TRIGGER update_prop_device_maint_record_updated_at BEFORE UPDATE ON prop_device_maint_record
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_device_maint_record IS '设备保养记录表';

-- =============================================
-- 2. 能源管理
-- =============================================

-- 仪表表
DROP TABLE IF EXISTS prop_meter CASCADE;
CREATE TABLE prop_meter (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    position_id UUID,
    meter_type VARCHAR(20) NOT NULL,
    name VARCHAR(128) NOT NULL,
    install_date DATE,
    initial_reading NUMERIC(19,4),
    current_reading NUMERIC(19,4),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_meter_project ON prop_meter(project_id);
CREATE INDEX idx_meter_position ON prop_meter(position_id);
CREATE INDEX idx_meter_code ON prop_meter(code);
CREATE INDEX idx_meter_type ON prop_meter(meter_type);
CREATE INDEX idx_meter_status ON prop_meter(status);
CREATE INDEX idx_meter_deleted ON prop_meter(deleted);

CREATE TRIGGER update_prop_meter_updated_at BEFORE UPDATE ON prop_meter
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_meter IS '仪表表';

-- 抄表记录表
DROP TABLE IF EXISTS prop_meter_reading CASCADE;
CREATE TABLE prop_meter_reading (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meter_id UUID NOT NULL,
    reading_date DATE NOT NULL,
    previous_reading NUMERIC(19,4),
    current_reading NUMERIC(19,4),
    usage NUMERIC(19,4),
    reader_uuid UUID,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mr_meter ON prop_meter_reading(meter_id);
CREATE INDEX idx_mr_date ON prop_meter_reading(reading_date);

COMMENT ON TABLE prop_meter_reading IS '抄表记录表';

-- =============================================
-- 3. 物料管理
-- =============================================

-- 物料分类表
DROP TABLE IF EXISTS prop_material_category CASCADE;
CREATE TABLE prop_material_category (
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

CREATE INDEX idx_mc_code ON prop_material_category(code);
CREATE INDEX idx_mc_parent ON prop_material_category(parent_id);
CREATE INDEX idx_mc_deleted ON prop_material_category(deleted);

CREATE TRIGGER update_prop_material_category_updated_at BEFORE UPDATE ON prop_material_category
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_material_category IS '物料分类表';

-- 物料表
DROP TABLE IF EXISTS prop_material CASCADE;
CREATE TABLE prop_material (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    category_id UUID NOT NULL,
    name VARCHAR(128) NOT NULL,
    spec VARCHAR(128),
    unit VARCHAR(20),
    min_stock NUMERIC(19,4),
    max_stock NUMERIC(19,4),
    unit_price NUMERIC(19,4),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_material_category ON prop_material(category_id);
CREATE INDEX idx_material_code ON prop_material(code);
CREATE INDEX idx_material_name ON prop_material(name);
CREATE INDEX idx_material_status ON prop_material(status);
CREATE INDEX idx_material_deleted ON prop_material(deleted);

CREATE TRIGGER update_prop_material_updated_at BEFORE UPDATE ON prop_material
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_material IS '物料表';

-- 入库单表
DROP TABLE IF EXISTS prop_inbound CASCADE;
CREATE TABLE prop_inbound (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    name VARCHAR(128),
    inbound_date DATE NOT NULL,
    inbound_type VARCHAR(20) NOT NULL,
    supplier_id UUID,
    warehouse_uuid UUID,
    total_amt NUMERIC(19,4),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    remark VARCHAR(512)
);

CREATE INDEX idx_inbound_project ON prop_inbound(project_id);
CREATE INDEX idx_inbound_code ON prop_inbound(code);
CREATE INDEX idx_inbound_date ON prop_inbound(inbound_date);
CREATE INDEX idx_inbound_status ON prop_inbound(status);
CREATE INDEX idx_inbound_deleted ON prop_inbound(deleted);

CREATE TRIGGER update_prop_inbound_updated_at BEFORE UPDATE ON prop_inbound
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_inbound IS '入库单表';

-- 入库明细表
DROP TABLE IF EXISTS prop_inbound_detail CASCADE;
CREATE TABLE prop_inbound_detail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inbound_id UUID NOT NULL,
    material_id UUID NOT NULL,
    quantity NUMERIC(19,4) NOT NULL,
    unit_price NUMERIC(19,4),
    total_amt NUMERIC(19,4),
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_id_inbound ON prop_inbound_detail(inbound_id);
CREATE INDEX idx_id_material ON prop_inbound_detail(material_id);

COMMENT ON TABLE prop_inbound_detail IS '入库明细表';

-- 出库单表
DROP TABLE IF EXISTS prop_outbound CASCADE;
CREATE TABLE prop_outbound (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    name VARCHAR(128),
    outbound_date DATE NOT NULL,
    outbound_type VARCHAR(20) NOT NULL,
    receiver_uuid UUID,
    warehouse_uuid UUID,
    total_amt NUMERIC(19,4),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    remark VARCHAR(512)
);

CREATE INDEX idx_outbound_project ON prop_outbound(project_id);
CREATE INDEX idx_outbound_code ON prop_outbound(code);
CREATE INDEX idx_outbound_date ON prop_outbound(outbound_date);
CREATE INDEX idx_outbound_status ON prop_outbound(status);
CREATE INDEX idx_outbound_deleted ON prop_outbound(deleted);

CREATE TRIGGER update_prop_outbound_updated_at BEFORE UPDATE ON prop_outbound
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_outbound IS '出库单表';

-- 出库明细表
DROP TABLE IF EXISTS prop_outbound_detail CASCADE;
CREATE TABLE prop_outbound_detail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    outbound_id UUID NOT NULL,
    material_id UUID NOT NULL,
    quantity NUMERIC(19,4) NOT NULL,
    unit_price NUMERIC(19,4),
    total_amt NUMERIC(19,4),
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_od_outbound ON prop_outbound_detail(outbound_id);
CREATE INDEX idx_od_material ON prop_outbound_detail(material_id);

COMMENT ON TABLE prop_outbound_detail IS '出库明细表';

-- 库存表
DROP TABLE IF EXISTS prop_stock CASCADE;
CREATE TABLE prop_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL,
    material_id UUID NOT NULL,
    warehouse_uuid UUID,
    quantity NUMERIC(19,4) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_project ON prop_stock(project_id);
CREATE INDEX idx_stock_material ON prop_stock(material_id);
CREATE INDEX idx_stock_warehouse ON prop_stock(warehouse_uuid);
CREATE UNIQUE INDEX uk_stock_project_material_warehouse ON prop_stock(project_id, material_id, warehouse_uuid);

CREATE TRIGGER update_prop_stock_updated_at BEFORE UPDATE ON prop_stock
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE prop_stock IS '库存表';
