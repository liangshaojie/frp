#!/bin/bash
# 测试颜色显示

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo "========================================="
echo "颜色显示测试"
echo "========================================="
echo ""

echo "测试 1: 使用 echo（不带 -e）"
echo "这是 ${RED}红色${NC} 文本"
echo "这是 ${GREEN}绿色${NC} 文本"
echo "这是 ${BOLD}粗体${NC} 文本"
echo ""

echo "测试 2: 使用 echo -e"
echo -e "这是 ${RED}红色${NC} 文本"
echo -e "这是 ${GREEN}绿色${NC} 文本"
echo -e "这是 ${BOLD}粗体${NC} 文本"
echo ""

echo "测试 3: 图标显示"
echo -e "${GREEN}✓${NC} 成功"
echo -e "${RED}✗${NC} 错误"
echo -e "${CYAN}ℹ${NC} 信息"
echo -e "${YELLOW}⚠${NC} 警告"
echo -e "${CYAN}▶${NC} 步骤"
echo ""

echo "测试 4: 菜单显示"
echo -e "  ${BOLD}服务端管理${NC}"
echo "    1) 安装服务端"
echo "    2) 卸载服务端"
echo ""
echo -e "  ${BOLD}客户端管理${NC}"
echo "    3) 安装客户端"
echo "    4) 卸载客户端"
echo ""

echo "测试 5: 混合显示"
echo -e "   服务器 IP: ${BOLD}192.168.1.1${NC}"
echo -e "   查看状态: ${CYAN}bash frp.sh status-server${NC}"
echo ""

echo "========================================="
echo "测试完成"
echo "========================================="
