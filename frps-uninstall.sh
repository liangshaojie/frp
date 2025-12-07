#!/bin/bash
# frps-uninstall.sh - FRP 服务端卸载脚本
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

echo_info "开始卸载 FRP 服务端..."

# 停止服务
if systemctl is-active --quiet frps; then
    echo_info "停止 frps 服务..."
    systemctl stop frps
else
    echo_warn "frps 服务未运行"
fi

# 禁用服务
if systemctl is-enabled --quiet frps 2>/dev/null; then
    echo_info "禁用 frps 服务..."
    systemctl disable frps
fi

# 删除 systemd 服务文件
if [ -f /etc/systemd/system/frps.service ]; then
    echo_info "删除服务文件..."
    rm -f /etc/systemd/system/frps.service
    systemctl daemon-reload
fi

# 备份配置信息（如果存在）
if [ -f /usr/local/frp/install_info.txt ]; then
    BACKUP_DIR="$HOME/frp_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp /usr/local/frp/install_info.txt "$BACKUP_DIR/"
    cp /usr/local/frp/frps.toml "$BACKUP_DIR/" 2>/dev/null || true
    echo_info "配置已备份到: $BACKUP_DIR"
fi

# 删除安装目录
if [ -d /usr/local/frp ]; then
    echo_info "删除安装目录..."
    rm -rf /usr/local/frp
fi

# 清理防火墙规则（可选）
read -p "是否删除防火墙规则？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v ufw &> /dev/null; then
        ufw delete allow 7000/tcp 2>/dev/null || true
        ufw delete allow 7500/tcp 2>/dev/null || true
        ufw delete allow 6000:60000/tcp 2>/dev/null || true
        echo_info "已删除 ufw 防火墙规则"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --remove-port=7000/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=7500/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=6000-60000/tcp 2>/dev/null || true
        firewall-cmd --reload
        echo_info "已删除 firewalld 防火墙规则"
    fi
fi

echo ""
echo "========================================="
echo_info "FRP 服务端卸载完成！"
echo "========================================="
