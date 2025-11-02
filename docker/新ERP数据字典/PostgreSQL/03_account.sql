-- =============================================
-- 账务管理模块 (Account Module)
-- 表前缀: acc_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- 1. 账款管理
-- =============================================

-- 账款表
DROP TABLE IF EXISTS acc_account CASCADE;
CREATE TABLE acc_account (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    contract_id UUID,
    tenant_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    period VARCHAR(7) NOT NULL,

    -- 金额信息
    original_amt NUMERIC(19,4) NOT NULL,
    discount_amt NUMERIC(19,4) DEFAULT 0,
    actual_amt NUMERIC(19,4) NOT NULL,
    paid_amt NUMERIC(19,4) DEFAULT 0,
    unpaid_amt NUMERIC(19,4),

    -- 日期信息
    start_date DATE,
    end_date DATE,
    due_date DATE,

    status VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    remark VARCHAR(512)
);

CREATE INDEX idx_account_project ON acc_account(project_id);
CREATE INDEX idx_account_contract ON acc_account(contract_id);
CREATE INDEX idx_account_tenant ON acc_account(tenant_id);
CREATE INDEX idx_account_subject ON acc_account(subject_id);
CREATE INDEX idx_account_period ON acc_account(period);
CREATE INDEX idx_account_status ON acc_account(status);
CREATE INDEX idx_account_deleted ON acc_account(deleted);

CREATE TRIGGER update_acc_account_updated_at BEFORE UPDATE ON acc_account
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE acc_account IS '账款表';

-- =============================================
-- 2. 收款管理
-- =============================================

-- 收款单表
DROP TABLE IF EXISTS acc_receipt CASCADE;
CREATE TABLE acc_receipt (
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
    receipt_date DATE NOT NULL,
    total_amt NUMERIC(19,4) NOT NULL,
    payment_method_id UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    collector_uuid UUID,
    remark VARCHAR(512)
);

CREATE INDEX idx_receipt_project ON acc_receipt(project_id);
CREATE INDEX idx_receipt_tenant ON acc_receipt(tenant_id);
CREATE INDEX idx_receipt_code ON acc_receipt(code);
CREATE INDEX idx_receipt_date ON acc_receipt(receipt_date);
CREATE INDEX idx_receipt_status ON acc_receipt(status);
CREATE INDEX idx_receipt_deleted ON acc_receipt(deleted);

CREATE TRIGGER update_acc_receipt_updated_at BEFORE UPDATE ON acc_receipt
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE acc_receipt IS '收款单表';

-- 收款明细表
DROP TABLE IF EXISTS acc_receipt_detail CASCADE;
CREATE TABLE acc_receipt_detail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_id UUID NOT NULL,
    account_id UUID NOT NULL,
    receipt_amt NUMERIC(19,4) NOT NULL,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rd_receipt ON acc_receipt_detail(receipt_id);
CREATE INDEX idx_rd_account ON acc_receipt_detail(account_id);

COMMENT ON TABLE acc_receipt_detail IS '收款明细表';

-- =============================================
-- 3. 付款管理
-- =============================================

-- 付款单表
DROP TABLE IF EXISTS acc_payment CASCADE;
CREATE TABLE acc_payment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    payee_type VARCHAR(20) NOT NULL,
    payee_id UUID NOT NULL,
    name VARCHAR(128),
    payment_date DATE NOT NULL,
    total_amt NUMERIC(19,4) NOT NULL,
    payment_method_id UUID,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    payer_uuid UUID,
    remark VARCHAR(512)
);

CREATE INDEX idx_payment_project ON acc_payment(project_id);
CREATE INDEX idx_payment_payee ON acc_payment(payee_id);
CREATE INDEX idx_payment_code ON acc_payment(code);
CREATE INDEX idx_payment_date ON acc_payment(payment_date);
CREATE INDEX idx_payment_status ON acc_payment(status);
CREATE INDEX idx_payment_deleted ON acc_payment(deleted);

CREATE TRIGGER update_acc_payment_updated_at BEFORE UPDATE ON acc_payment
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE acc_payment IS '付款单表';

-- 付款明细表
DROP TABLE IF EXISTS acc_payment_detail CASCADE;
CREATE TABLE acc_payment_detail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL,
    subject_id UUID,
    payment_amt NUMERIC(19,4) NOT NULL,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pd_payment ON acc_payment_detail(payment_id);
CREATE INDEX idx_pd_subject ON acc_payment_detail(subject_id);

COMMENT ON TABLE acc_payment_detail IS '付款明细表';

-- =============================================
-- 4. 发票管理
-- =============================================

-- 发票表
DROP TABLE IF EXISTS acc_invoice CASCADE;
CREATE TABLE acc_invoice (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    project_id UUID NOT NULL,
    tenant_id UUID,
    invoice_type VARCHAR(20) NOT NULL,
    invoice_no VARCHAR(64),
    invoice_date DATE NOT NULL,
    total_amt NUMERIC(19,4) NOT NULL,
    tax_amt NUMERIC(19,4),
    tax_rate NUMERIC(5,2),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    remark VARCHAR(512)
);

CREATE INDEX idx_invoice_project ON acc_invoice(project_id);
CREATE INDEX idx_invoice_tenant ON acc_invoice(tenant_id);
CREATE INDEX idx_invoice_no ON acc_invoice(invoice_no);
CREATE INDEX idx_invoice_date ON acc_invoice(invoice_date);
CREATE INDEX idx_invoice_status ON acc_invoice(status);
CREATE INDEX idx_invoice_deleted ON acc_invoice(deleted);

CREATE TRIGGER update_acc_invoice_updated_at BEFORE UPDATE ON acc_invoice
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE acc_invoice IS '发票表';

-- =============================================
-- 5. 结算管理
-- =============================================

-- 月度结账表
DROP TABLE IF EXISTS acc_month_close CASCADE;
CREATE TABLE acc_month_close (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL,
    period VARCHAR(7) NOT NULL,
    close_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    close_by_uuid UUID,
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mc_project ON acc_month_close(project_id);
CREATE INDEX idx_mc_period ON acc_month_close(period);
CREATE INDEX idx_mc_status ON acc_month_close(status);
CREATE UNIQUE INDEX uk_mc_project_period ON acc_month_close(project_id, period);

CREATE TRIGGER update_acc_month_close_updated_at BEFORE UPDATE ON acc_month_close
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE acc_month_close IS '月度结账表';
