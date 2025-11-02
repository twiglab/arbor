# PostgreSQL版本 - 新ERP数据库建表脚本

## 📋 概述

本目录包含基于PostgreSQL的新ERP数据库完整建表脚本，**主键使用UUID**，符合第三范式设计。

**数据库**: PostgreSQL 12+
**主键类型**: UUID (使用uuid_generate_v4())
**字符集**: UTF-8
**生成日期**: 2025-11-02

---

## 📦 文件列表

| 文件名 | 模块名称 | 表数量 | 说明 |
|--------|---------|--------|------|
| 01_master_data.sql | 基础资料模块 (md_) | 16 | 项目、商户、品牌、科目等基础数据 |
| 02_investment.sql | 招商管理模块 (inv_) | 4 | 合同、潜在商户等 |
| 03_account.sql | 账务管理模块 (acc_) | 9 | 账款、收付款、发票、结算等 |
| 04_property.sql | 物业管理模块 (prop_) | 17 | 设备、能源、物料、库存等 |
| 05_operation.sql | 营运管理模块 (opr_) | 7 | 巡检、投诉、工单等 |
| 06_system.sql | 系统管理模块 (sys_) | 11 | 用户、角色、权限、日志等 |
| **总计** | **6个模块** | **64张表** | - |

---

## 🎯 核心特性

### 1. UUID主键
```sql
-- 所有表使用UUID作为主键
id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
```

**优势**:
- ✅ 分布式友好
- ✅ 无序列冲突
- ✅ 安全性高
- ✅ 便于数据迁移

### 2. 标准字段
所有业务表包含统一的标准字段：
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
code            VARCHAR(32) NOT NULL,              -- 业务编码
version         BIGINT DEFAULT 0,                  -- 乐观锁版本
created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
created_by_uuid UUID,                              -- 创建人UUID
updated_by_uuid UUID,                              -- 更新人UUID
deleted         SMALLINT DEFAULT 0                 -- 逻辑删除: 0-否, 1-是
```

### 3. 自动更新时间
使用PostgreSQL触发器自动更新updated_at：
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_md_tenant_updated_at BEFORE UPDATE ON md_tenant
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 4. 符合PostgreSQL规范
- ✅ NUMERIC替代DECIMAL
- ✅ BOOLEAN替代TINYINT
- ✅ TIMESTAMP替代DATETIME
- ✅ SMALLINT替代TINYINT
- ✅ COMMENT ON语法
- ✅ CASCADE级联删除

---

## 🚀 快速开始

### 步骤1: 创建数据库
```sql
-- 创建数据库
CREATE DATABASE erp_new
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- 连接数据库
\c erp_new
```

### 步骤2: 执行SQL脚本
```bash
# 方式1: 使用psql命令行
psql -U postgres -d erp_new -f 01_master_data.sql
psql -U postgres -d erp_new -f 02_investment.sql
psql -U postgres -d erp_new -f 03_account.sql
psql -U postgres -d erp_new -f 04_property.sql
psql -U postgres -d erp_new -f 05_operation.sql
psql -U postgres -d erp_new -f 06_system.sql

# 方式2: 一次性执行所有
cat *.sql | psql -U postgres -d erp_new
```

### 步骤3: 验证表结构
```sql
-- 查看所有表
\dt

-- 查看特定表结构
\d md_tenant

-- 查看表数量
SELECT count(*) FROM information_schema.tables
WHERE table_schema = 'public';

-- 查看所有索引
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

---

## 📊 模块详情

### 1. 基础资料模块 (md_) - 16张表

**核心表**:
- `md_project` - 项目表
- `md_tenant` - 商户表
- `md_tenant_contact` - 商户联系方式
- `md_tenant_bank` - 商户银行信息
- `md_brand` - 品牌表
- `md_tenant_brand` - 商户品牌关联
- `md_industry` - 行业表（树形）
- `md_biz_type` - 业态表（树形）
- `md_area` - 区域表
- `md_position` - 位置表（铺位/档口）
- `md_subject_type` - 科目类型
- `md_subject` - 收费科目
- `md_payment_method` - 付款方式
- `md_bank` - 银行资料
- `md_goods` - 物品字典

**关键设计**:
- 商户信息拆分为主表+联系方式+银行信息
- 树形结构（行业、业态）使用parent_id + path
- 位置支持多层级区域

### 2. 招商管理模块 (inv_) - 4张表

**核心表**:
- `inv_contract` - 租赁合同
- `inv_contract_position` - 合同位置关联（多对多）
- `inv_contract_subject` - 合同科目
- `inv_potential_tenant` - 潜在商户（线索）

**关键设计**:
- 合同与位置多对多关系
- 支持免租期、分期收费
- 招商线索跟踪

### 3. 账务管理模块 (acc_) - 9张表

**核心表**:
- `acc_account` - 账款表
- `acc_receipt` - 收款单
- `acc_receipt_detail` - 收款明细
- `acc_payment` - 付款单
- `acc_payment_detail` - 付款明细
- `acc_invoice` - 发票
- `acc_month_close` - 月度结账

**关键设计**:
- 账款与收付款解耦
- 支持多笔收款冲抵账款
- 月度结账控制

### 4. 物业管理模块 (prop_) - 17张表

**设备管理**:
- `prop_device_category` - 设备分类
- `prop_device` - 设备
- `prop_device_maint_plan` - 保养计划
- `prop_device_maint_record` - 保养记录

**能源管理**:
- `prop_meter` - 仪表
- `prop_meter_reading` - 抄表记录

**物料管理**:
- `prop_material_category` - 物料分类
- `prop_material` - 物料
- `prop_inbound` / `prop_inbound_detail` - 入库
- `prop_outbound` / `prop_outbound_detail` - 出库
- `prop_stock` - 库存

### 5. 营运管理模块 (opr_) - 7张表

**核心表**:
- `opr_inspection_item` - 巡检项目
- `opr_inspection_plan` - 巡检计划
- `opr_inspection_record` - 巡检记录
- `opr_inspection_detail` - 巡检明细
- `opr_complaint_type` - 投诉类型
- `opr_complaint` - 投诉
- `opr_work_order` - 工单

**关键设计**:
- 巡检计划与记录分离
- 投诉可自动生成工单
- 工单支持多种来源

### 6. 系统管理模块 (sys_) - 11张表

**核心表**:
- `sys_user` - 用户
- `sys_role` - 角色
- `sys_user_role` - 用户角色关联
- `sys_permission` - 权限
- `sys_role_permission` - 角色权限关联
- `sys_dept` - 部门
- `sys_config` - 系统配置
- `sys_dict` / `sys_dict_item` - 数据字典
- `sys_operation_log` - 操作日志

**关键设计**:
- RBAC权限模型
- 用户密码需加密存储
- 操作日志记录所有关键操作

---

## ⚙️ PostgreSQL特性

### 1. UUID扩展
```sql
-- 首次执行需启用UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### 2. 部分索引
```sql
-- 仅索引未删除的记录
CREATE UNIQUE INDEX uk_tenant_code ON md_tenant(code) WHERE deleted = 0;
```

### 3. 级联删除
```sql
-- 支持CASCADE选项
DROP TABLE IF EXISTS md_project CASCADE;
```

### 4. 表注释
```sql
-- 使用COMMENT ON语法
COMMENT ON TABLE md_tenant IS '商户表';
COMMENT ON COLUMN md_tenant.code IS '商户编码';
```

---

## 📈 数据库对比

| 特性 | PostgreSQL | MySQL |
|------|-----------|-------|
| 主键类型 | UUID | BIGINT AUTO_INCREMENT |
| 布尔类型 | BOOLEAN | TINYINT |
| 时间类型 | TIMESTAMP | DATETIME |
| 数值类型 | NUMERIC | DECIMAL |
| 自增 | SERIAL | AUTO_INCREMENT |
| 注释 | COMMENT ON | 行内COMMENT |
| 触发器 | FUNCTION + TRIGGER | TRIGGER |

---

## 🔧 常用命令

### 数据库操作
```sql
-- 列出所有数据库
\l

-- 切换数据库
\c erp_new

-- 列出所有表
\dt

-- 查看表结构
\d table_name

-- 查看表详细信息
\d+ table_name

-- 列出所有索引
\di

-- 列出所有视图
\dv

-- 列出所有函数
\df

-- 退出
\q
```

### 查询统计
```sql
-- 查看表大小
SELECT
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 查看表行数
SELECT
    schemaname,
    tablename,
    n_tup_ins - n_tup_del as row_count
FROM pg_stat_user_tables
ORDER BY row_count DESC;

-- 查看索引使用情况
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

---

## 💡 最佳实践

### 1. 连接池
```python
# 使用psycopg2连接池
from psycopg2 import pool

connection_pool = pool.SimpleConnectionPool(
    1, 20,
    user="postgres",
    password="password",
    host="localhost",
    port="5432",
    database="erp_new"
)
```

### 2. UUID生成
```python
import uuid

# 生成UUID v4
new_id = uuid.uuid4()
print(new_id)  # 输出: 550e8400-e29b-41d4-a716-446655440000
```

### 3. 批量插入
```sql
-- 使用COPY命令（最快）
COPY md_tenant FROM '/path/to/data.csv' CSV HEADER;

-- 使用批量INSERT
INSERT INTO md_tenant (id, code, name, ...) VALUES
    (uuid_generate_v4(), 'T001', '商户1', ...),
    (uuid_generate_v4(), 'T002', '商户2', ...),
    ...;
```

### 4. 事务处理
```sql
BEGIN;

-- 执行多个操作
INSERT INTO ...;
UPDATE ...;
DELETE ...;

COMMIT;  -- 或 ROLLBACK;
```

---

## ⚠️ 注意事项

### 1. UUID性能
- UUID占用16字节，比BIGINT(8字节)大
- 索引稍慢，但对于业务表影响很小
- 分布式场景下优势明显

### 2. 字符集
确保数据库和客户端都使用UTF-8：
```sql
SHOW server_encoding;  -- 应显示UTF8
SHOW client_encoding;  -- 应显示UTF8
```

### 3. 时区
```sql
-- 查看时区设置
SHOW timezone;

-- 设置时区
SET timezone = 'Asia/Shanghai';
```

### 4. 备份恢复
```bash
# 备份数据库
pg_dump -U postgres erp_new > erp_new_backup.sql

# 恢复数据库
psql -U postgres erp_new < erp_new_backup.sql
```

---

## 📚 相关文档

- [术语缩写规范.md](../术语缩写规范.md) - 命名规范
- [数据模型设计说明.md](../数据模型设计说明.md) - 设计文档
- [快速开始.md](../快速开始.md) - 使用指南
- [README.md](../README.md) - 项目总结

---

## 🎯 下一步

1. **测试环境**
   - 创建测试数据库
   - 执行所有SQL脚本
   - 验证表结构和索引

2. **数据迁移**
   - 编写数据迁移脚本
   - 从旧系统导入数据
   - 验证数据完整性

3. **性能优化**
   - 分析慢查询
   - 优化索引
   - 配置连接池

4. **监控告警**
   - 配置监控指标
   - 设置告警规则
   - 定期备份

---

**版本**: PostgreSQL 1.0
**更新日期**: 2025-11-02
**维护**: 数据库架构团队
