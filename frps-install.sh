#!/bin/bash
# frps-install.sh - FRP 服务端一键部署
set -e

# 配置
FRP_VERSION="0.65.0"
INSTALL_DIR="/usr/local/frp"

# 颜色输出
GREEN='\033[0;32m'
NC='\033[0m'
echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请使用 root 权限运行: sudo bash $0"
   exit 1
fi

# 生成随机密码
AUTH_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
WEB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

echo_info "开始安装 FRP 服务端..."

# 下载 FRP
cd /tmp
wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz
tar -xzf frp_${FRP_VERSION}_linux_amd64.tar.gz

# 安装
mkdir -p ${INSTALL_DIR}
cp frp_${FRP_VERSION}_linux_amd64/frps ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frps

# 创建配置文件
cat > ${INSTALL_DIR}/frps.toml << EOF
bindAddr = "0.0.0.0"
bindPort = 7000

auth.method = "token"
auth.token = "${AUTH_TOKEN}"

webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "${WEB_PASSWORD}"

allowPorts = [{ start = 6000, end = 60000 }]

log.to = "${INSTALL_DIR}/frps.log"
log.level = "info"
log.maxDays = 3
EOF

# 创建 systemd 服务
cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/frps -c ${INSTALL_DIR}/frps.toml
WorkingDirectory=${INSTALL_DIR}
Restart=on-failure
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 配置防火墙
if command -v ufw &> /dev/null; then
    ufw allow 7000/tcp
    ufw allow 7500/tcp
    ufw allow 6000:60000/tcp
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=7000/tcp
    firewall-cmd --permanent --add-port=7500/tcp
    firewall-cmd --permanent --add-port=6000-60000/tcp
    firewall-cmd --reload
fi

# 启动服务
systemctl daemon-reload
systemctl enable frps
systemctl start frps

# 获取公网 IP
SERVER_IP=$(curl -s ifconfig.me || echo "获取失败")

# 输出配置信息
echo ""
echo "========================================="
echo "FRP 服务端安装完成！"
echo "========================================="
echo "服务器 IP: ${SERVER_IP}"
echo "认证 Token: ${AUTH_TOKEN}"
echo "Web 管理面板: http://${SERVER_IP}:7500"
echo "Web 用户名: admin"
echo "Web 密码: ${WEB_PASSWORD}"
echo ""
echo "⚠️  请保存以上信息！"
echo ""
echo "客户端连接配置："
echo "  serverAddr = \"${SERVER_IP}\""
echo "  serverPort = 7000"
echo "  auth.token = \"${AUTH_TOKEN}\""
echo "========================================="

# 保存配置信息
cat > ${INSTALL_DIR}/install_info.txt << EOF
服务器 IP: ${SERVER_IP}
认证 Token: ${AUTH_TOKEN}
Web 管理面板: http://${SERVER_IP}:7500
Web 用户名: admin
Web 密码: ${WEB_PASSWORD}
安装时间: $(date)
EOF
chmod 600 ${INSTALL_DIR}/install_info.txt

echo "配置信息已保存到: ${INSTALL_DIR}/install_info.txt"
