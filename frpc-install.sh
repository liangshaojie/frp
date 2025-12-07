#!/bin/bash
# frpc-install.sh - FRP 客户端一键部署
set -e

# 配置
FRP_VERSION="0.65.0"
INSTALL_DIR="/usr/local/frp"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请使用 root 权限运行: sudo bash $0"
   exit 1
fi

# 交互式配置
echo "========================================="
echo "FRP 客户端配置"
echo "========================================="
read -p "请输入服务端 IP 地址: " SERVER_IP
read -p "请输入认证 Token: " AUTH_TOKEN

echo ""
echo "选择代理类型："
echo "1) SSH 远程登录 (端口 22 -> 6000)"
echo "2) Web 服务 (端口 8080 -> 6001)"
echo "3) 自定义配置"
read -p "请选择 [1-3]: " PROXY_TYPE

echo_info "开始安装 FRP 客户端..."

# 下载 FRP
cd /tmp
wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz
tar -xzf frp_${FRP_VERSION}_linux_amd64.tar.gz

# 安装
mkdir -p ${INSTALL_DIR}
cp frp_${FRP_VERSION}_linux_amd64/frpc ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frpc

# 创建配置文件
cat > ${INSTALL_DIR}/frpc.toml << EOF
serverAddr = "${SERVER_IP}"
serverPort = 7000

auth.method = "token"
auth.token = "${AUTH_TOKEN}"

log.to = "${INSTALL_DIR}/frpc.log"
log.level = "info"
log.maxDays = 3
EOF

# 根据选择添加代理配置
case $PROXY_TYPE in
    1)
        cat >> ${INSTALL_DIR}/frpc.toml << EOF

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
transport.useEncryption = true
transport.useCompression = true
EOF
        echo_info "已配置 SSH 代理: ssh root@${SERVER_IP} -p 6000"
        ;;
    2)
        cat >> ${INSTALL_DIR}/frpc.toml << EOF

[[proxies]]
name = "web"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 6001
EOF
        echo_info "已配置 Web 代理: http://${SERVER_IP}:6001"
        ;;
    3)
        cat >> ${INSTALL_DIR}/frpc.toml << EOF

# 自定义代理配置（请手动编辑）
# [[proxies]]
# name = "custom"
# type = "tcp"
# localIP = "127.0.0.1"
# localPort = 端口号
# remotePort = 远程端口
EOF
        echo_warn "请手动编辑配置文件: ${INSTALL_DIR}/frpc.toml"
        ;;
esac

# 创建 systemd 服务
cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=FRP Client
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/frpc -c ${INSTALL_DIR}/frpc.toml
WorkingDirectory=${INSTALL_DIR}
Restart=always
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable frpc
systemctl start frpc

# 输出结果
echo ""
echo "========================================="
echo "FRP 客户端安装完成！"
echo "========================================="
echo "服务端: ${SERVER_IP}:7000"
echo "配置文件: ${INSTALL_DIR}/frpc.toml"
echo "日志文件: ${INSTALL_DIR}/frpc.log"
echo ""
echo "管理命令："
echo "  查看状态: systemctl status frpc"
echo "  查看日志: tail -f ${INSTALL_DIR}/frpc.log"
echo "  重启服务: systemctl restart frpc"
echo "========================================="
