-- =============================================
-- 系统管理模块 (System Module)
-- 表前缀: sys_
-- 数据库: PostgreSQL
-- 创建时间: 2025-11-02 15:56:21
-- =============================================

-- =============================================
-- 1. 用户管理
-- =============================================

-- 用户表
DROP TABLE IF EXISTS sys_user CASCADE;
CREATE TABLE sys_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(64) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    real_name VARCHAR(64),
    email VARCHAR(128),
    mobile VARCHAR(32),
    avatar_url VARCHAR(256),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at TIMESTAMP,
    last_login_ip VARCHAR(64),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX idx_user_username ON sys_user(username);
CREATE INDEX idx_user_mobile ON sys_user(mobile);
CREATE INDEX idx_user_status ON sys_user(status);
CREATE INDEX idx_user_deleted ON sys_user(deleted);

CREATE TRIGGER update_sys_user_updated_at BEFORE UPDATE ON sys_user
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_user IS '用户表';

-- =============================================
-- 2. 角色权限
-- =============================================

-- 角色表
DROP TABLE IF EXISTS sys_role CASCADE;
CREATE TABLE sys_role (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    role_key VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    sort_order INTEGER DEFAULT 0,
    remark VARCHAR(512)
);

CREATE INDEX idx_role_code ON sys_role(code);
CREATE INDEX idx_role_key ON sys_role(role_key);
CREATE INDEX idx_role_status ON sys_role(status);
CREATE INDEX idx_role_deleted ON sys_role(deleted);

CREATE TRIGGER update_sys_role_updated_at BEFORE UPDATE ON sys_role
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_role IS '角色表';

-- 用户角色关联表
DROP TABLE IF EXISTS sys_user_role CASCADE;
CREATE TABLE sys_user_role (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ur_user ON sys_user_role(user_id);
CREATE INDEX idx_ur_role ON sys_user_role(role_id);
CREATE UNIQUE INDEX uk_ur_user_role ON sys_user_role(user_id, role_id);

COMMENT ON TABLE sys_user_role IS '用户角色关联表';

-- 权限表
DROP TABLE IF EXISTS sys_permission CASCADE;
CREATE TABLE sys_permission (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    permission_key VARCHAR(128) NOT NULL,
    permission_type VARCHAR(20) NOT NULL,
    parent_id UUID,
    path VARCHAR(256),
    component VARCHAR(256),
    icon VARCHAR(64),
    sort_order INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_perm_code ON sys_permission(code);
CREATE INDEX idx_perm_key ON sys_permission(permission_key);
CREATE INDEX idx_perm_parent ON sys_permission(parent_id);
CREATE INDEX idx_perm_type ON sys_permission(permission_type);
CREATE INDEX idx_perm_deleted ON sys_permission(deleted);

CREATE TRIGGER update_sys_permission_updated_at BEFORE UPDATE ON sys_permission
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_permission IS '权限表';

-- 角色权限关联表
DROP TABLE IF EXISTS sys_role_permission CASCADE;
CREATE TABLE sys_role_permission (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rp_role ON sys_role_permission(role_id);
CREATE INDEX idx_rp_permission ON sys_role_permission(permission_id);
CREATE UNIQUE INDEX uk_rp_role_permission ON sys_role_permission(role_id, permission_id);

COMMENT ON TABLE sys_role_permission IS '角色权限关联表';

-- =============================================
-- 3. 部门管理
-- =============================================

-- 部门表
DROP TABLE IF EXISTS sys_dept CASCADE;
CREATE TABLE sys_dept (
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
    leader_uuid UUID,
    phone VARCHAR(32),
    email VARCHAR(128),
    sort_order INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_dept_code ON sys_dept(code);
CREATE INDEX idx_dept_parent ON sys_dept(parent_id);
CREATE INDEX idx_dept_level ON sys_dept(level);
CREATE INDEX idx_dept_status ON sys_dept(status);
CREATE INDEX idx_dept_deleted ON sys_dept(deleted);

CREATE TRIGGER update_sys_dept_updated_at BEFORE UPDATE ON sys_dept
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_dept IS '部门表';

-- =============================================
-- 4. 系统配置
-- =============================================

-- 系统配置表
DROP TABLE IF EXISTS sys_config CASCADE;
CREATE TABLE sys_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key VARCHAR(128) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(20),
    description VARCHAR(256),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID
);

CREATE INDEX idx_config_key ON sys_config(config_key);
CREATE INDEX idx_config_type ON sys_config(config_type);

CREATE TRIGGER update_sys_config_updated_at BEFORE UPDATE ON sys_config
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_config IS '系统配置表';

-- 数据字典表
DROP TABLE IF EXISTS sys_dict CASCADE;
CREATE TABLE sys_dict (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) NOT NULL,
    version BIGINT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    deleted SMALLINT DEFAULT 0,
    name VARCHAR(128) NOT NULL,
    dict_type VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512)
);

CREATE INDEX idx_dict_code ON sys_dict(code);
CREATE INDEX idx_dict_type ON sys_dict(dict_type);
CREATE INDEX idx_dict_status ON sys_dict(status);
CREATE INDEX idx_dict_deleted ON sys_dict(deleted);

CREATE TRIGGER update_sys_dict_updated_at BEFORE UPDATE ON sys_dict
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_dict IS '数据字典表';

-- 字典项表
DROP TABLE IF EXISTS sys_dict_item CASCADE;
CREATE TABLE sys_dict_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dict_id UUID NOT NULL,
    label VARCHAR(128) NOT NULL,
    value VARCHAR(128) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    remark VARCHAR(512),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_di_dict ON sys_dict_item(dict_id);
CREATE INDEX idx_di_value ON sys_dict_item(value);
CREATE INDEX idx_di_status ON sys_dict_item(status);

CREATE TRIGGER update_sys_dict_item_updated_at BEFORE UPDATE ON sys_dict_item
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_dict_item IS '字典项表';

-- =============================================
-- 5. 操作日志
-- =============================================

-- 操作日志表
DROP TABLE IF EXISTS sys_operation_log CASCADE;
CREATE TABLE sys_operation_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    username VARCHAR(64),
    operation_type VARCHAR(20),
    module VARCHAR(64),
    description VARCHAR(256),
    method VARCHAR(128),
    params TEXT,
    result TEXT,
    ip VARCHAR(64),
    user_agent VARCHAR(256),
    status VARCHAR(20),
    error_msg TEXT,
    execute_time INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_log_user ON sys_operation_log(user_id);
CREATE INDEX idx_log_type ON sys_operation_log(operation_type);
CREATE INDEX idx_log_module ON sys_operation_log(module);
CREATE INDEX idx_log_created ON sys_operation_log(created_at);

COMMENT ON TABLE sys_operation_log IS '操作日志表';
