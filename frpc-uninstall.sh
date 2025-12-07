#!/bin/bash
# frpc-uninstall.sh - FRP 客户端卸载脚本
set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo_error "请使用 root 权限运行: sudo bash $0"
   exit 1
fi

echo_info "开始卸载 FRP 客户端..."

# 停止服务
if systemctl is-active --quiet frpc; then
    echo_info "停止 frpc 服务..."
    systemctl stop frpc
else
    echo_warn "frpc 服务未运行"
fi

# 禁用服务
if systemctl is-enabled --quiet frpc 2>/dev/null; then
    echo_info "禁用 frpc 服务..."
    systemctl disable frpc
fi

# 删除 systemd 服务文件
if [ -f /etc/systemd/system/frpc.service ]; then
    echo_info "删除服务文件..."
    rm -f /etc/systemd/system/frpc.service
    systemctl daemon-reload
fi

# 备份配置文件（如果存在）
if [ -f /usr/local/frp/frpc.toml ]; then
    BACKUP_DIR="$HOME/frp_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp /usr/local/frp/frpc.toml "$BACKUP_DIR/"
    echo_info "配置已备份到: $BACKUP_DIR"
fi

# 删除安装目录
if [ -d /usr/local/frp ]; then
    echo_info "删除安装目录..."
    rm -rf /usr/local/frp
fi

echo ""
echo "========================================="
echo_info "FRP 客户端卸载完成！"
echo "========================================="
