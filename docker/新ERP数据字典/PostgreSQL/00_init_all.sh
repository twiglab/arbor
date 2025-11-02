#!/bin/bash
# ==========================================
# PostgreSQL新ERP数据库初始化脚本
# 一键执行所有建表SQL
# ==========================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 数据库配置
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-erp_new}

echo "=========================================="
echo "PostgreSQL新ERP数据库初始化"
echo "=========================================="
echo ""
echo "配置信息:"
echo "  主机: $DB_HOST"
echo "  端口: $DB_PORT"
echo "  用户: $DB_USER"
echo "  数据库: $DB_NAME"
echo ""

# 检查PostgreSQL是否可用
echo -e "${YELLOW}检查PostgreSQL连接...${NC}"
if ! psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c '\q' 2>/dev/null; then
    echo -e "${RED}❌ 无法连接到PostgreSQL，请检查配置${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL连接成功${NC}"
echo ""

# 询问是否删除已存在的数据库
read -p "是否删除已存在的数据库 $DB_NAME ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}删除数据库 $DB_NAME...${NC}"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
    echo -e "${GREEN}✓ 数据库已删除${NC}"
fi

# 创建数据库
echo -e "${YELLOW}创建数据库 $DB_NAME...${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME ENCODING='UTF8';" 2>/dev/null || true
echo -e "${GREEN}✓ 数据库已创建${NC}"
echo ""

# SQL文件列表
SQL_FILES=(
    "01_master_data.sql"
    "02_investment.sql"
    "03_account.sql"
    "04_property.sql"
    "05_operation.sql"
    "06_system.sql"
)

# 执行SQL文件
echo "=========================================="
echo "开始执行建表SQL..."
echo "=========================================="
echo ""

TOTAL=${#SQL_FILES[@]}
CURRENT=0

for sql_file in "${SQL_FILES[@]}"; do
    CURRENT=$((CURRENT + 1))
    echo -e "${YELLOW}[$CURRENT/$TOTAL] 执行 $sql_file...${NC}"

    if [ ! -f "$sql_file" ]; then
        echo -e "${RED}❌ 文件不存在: $sql_file${NC}"
        exit 1
    fi

    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$sql_file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $sql_file 执行成功${NC}"
    else
        echo -e "${RED}❌ $sql_file 执行失败${NC}"
        exit 1
    fi
    echo ""
done

echo "=========================================="
echo "验证结果"
echo "=========================================="
echo ""

# 统计表数量
TABLE_COUNT=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';")
echo -e "${GREEN}✓ 共创建 $TABLE_COUNT 张表${NC}"

# 显示所有表
echo ""
echo "所有表列表:"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt" 2>/dev/null | grep "public |"

# 显示部分表结构示例
echo ""
echo "=========================================="
echo "表结构示例"
echo "=========================================="
echo ""

echo "商户表 (md_tenant):"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\d md_tenant" 2>/dev/null | head -20

echo ""
echo "=========================================="
echo -e "${GREEN}✅ 初始化完成！${NC}"
echo "=========================================="
echo ""
echo "下一步:"
echo "  1. 查看所有表: psql -U $DB_USER -d $DB_NAME -c '\dt'"
echo "  2. 查看表结构: psql -U $DB_USER -d $DB_NAME -c '\d md_tenant'"
echo "  3. 连接数据库: psql -U $DB_USER -d $DB_NAME"
echo ""
