#!/bin/bash
# frp.sh - FRP 内网穿透统一管理脚本
# 使用方法: bash frp.sh [command]
# 项目地址: https://github.com/liangshaojie/frp

set -e

# 配置
FRP_VERSION="0.65.0"
INSTALL_DIR="/usr/local/frp"
SCRIPT_VERSION="1.0.0"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo_error() { echo -e "${RED}✗${NC} $1"; }
echo_success() { echo -e "${GREEN}✓${NC} $1"; }
echo_info() { echo -e "${CYAN}ℹ${NC} $1"; }
echo_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
echo_title() { echo -e "${BOLD}${BLUE}$1${NC}"; }
echo_step() { echo -e "${CYAN}▶${NC} $1"; }

# 显示 Logo
show_logo() {
    echo_title "========================================="
    echo_title "   FRP 内网穿透 - 统一管理工具"
    echo_title "   版本: ${SCRIPT_VERSION}"
    echo_title "========================================="
    echo ""
}

# 显示交互式菜单
show_menu() {
    show_logo
    echo_title "请选择操作："
    echo ""
    echo -e "  ${BOLD}服务端管理${NC}"
    echo "    1) 安装服务端"
    echo "    2) 卸载服务端"
    echo "    3) 查看服务端状态"
    echo "    4) 重启服务端"
    echo "    5) 查看服务端日志"
    echo "    6) 查看服务端配置信息"
    echo ""
    echo -e "  ${BOLD}客户端管理${NC}"
    echo "    7) 安装客户端"
    echo "    8) 卸载客户端"
    echo "    9) 查看客户端状态"
    echo "   10) 重启客户端"
    echo "   11) 查看客户端日志"
    echo "   12) 编辑客户端配置"
    echo ""
    echo -e "  ${BOLD}其他${NC}"
    echo "   13) 显示帮助信息"
    echo "   14) 更新脚本"
    echo "    0) 退出"
    echo ""
    
    local choice
    read_input "请输入选项 [0-14]: " choice
    
    case $choice in
        1) install_server ;;
        2) uninstall_server ;;
        3) status_server ;;
        4) restart_server ;;
        5) logs_server ;;
        6) info_server ;;
        7) install_client ;;
        8) uninstall_client ;;
        9) status_client ;;
        10) restart_client ;;
        11) logs_client ;;
        12) config_client ;;
        13) show_help ;;
        14) update_script ;;
        0) echo_info "再见！"; exit 0 ;;
        *) echo_error "无效选项"; exit 1 ;;
    esac
}

# 显示帮助信息
show_help() {
    show_logo
    echo -e "${BOLD}使用方法:${NC}"
    echo "  bash frp.sh [命令]"
    echo "  bash frp.sh          # 无参数时显示交互式菜单"
    echo ""
    echo -e "${BOLD}可用命令:${NC}"
    echo ""
    echo -e "  ${CYAN}服务端管理:${NC}"
    echo "    install-server      安装 FRP 服务端"
    echo "    uninstall-server    卸载 FRP 服务端"
    echo "    status-server       查看服务端状态"
    echo "    restart-server      重启服务端"
    echo "    logs-server         查看服务端日志"
    echo "    info-server         查看服务端配置信息"
    echo ""
    echo -e "  ${CYAN}客户端管理:${NC}"
    echo "    install-client      安装 FRP 客户端"
    echo "    uninstall-client    卸载 FRP 客户端"
    echo "    status-client       查看客户端状态"
    echo "    restart-client      重启客户端"
    echo "    logs-client         查看客户端日志"
    echo "    config-client       编辑客户端配置"
    echo ""
    echo -e "  ${CYAN}通用命令:${NC}"
    echo "    menu                显示交互式菜单"
    echo "    help                显示此帮助信息"
    echo "    version             显示版本信息"
    echo "    update              更新此脚本"
    echo ""
    echo -e "${BOLD}示例:${NC}"
    echo "  # 显示交互式菜单"
    echo "  bash frp.sh"
    echo ""
    echo "  # 安装服务端"
    echo "  bash frp.sh install-server"
    echo ""
    echo "  # 安装客户端"
    echo "  bash frp.sh install-client"
    echo ""
    echo "  # 查看服务端状态"
    echo "  bash frp.sh status-server"
    echo ""
    echo "  # 查看日志（实时）"
    echo "  bash frp.sh logs-client"
    echo ""
    echo -e "${BOLD}更多信息:${NC} https://github.com/liangshaojie/frp"
}

# 显示版本信息
show_version() {
    echo "FRP 管理脚本版本: ${SCRIPT_VERSION}"
    echo "FRP 版本: ${FRP_VERSION}"
}

# 检查 root 权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo_error "此操作需要 root 权限，请使用: sudo bash $0 $1"
        exit 1
    fi
}

# 读取用户输入（支持管道执行）
read_input() {
    local prompt="$1"
    local var_name="$2"
    
    if [ -t 0 ]; then
        read -p "$prompt" $var_name
    else
        read -p "$prompt" $var_name </dev/tty
    fi
}

# 显示进度条
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '='
    printf "%$((width - completed))s" | tr ' ' ' '
    printf "] %d%%" $percentage
}

# 下载文件（带进度和重试）
download_frp() {
    local download_dir="$1"
    
    cd "$download_dir"
    
    # 清理旧文件
    echo_step "清理旧文件..."
    rm -f frp_${FRP_VERSION}_linux_amd64.tar.gz
    rm -rf frp_${FRP_VERSION}_linux_amd64
    
    echo_step "正在下载 FRP v${FRP_VERSION}..."
    local download_url="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
    
    # 尝试下载
    if ! wget --show-progress -O frp_${FRP_VERSION}_linux_amd64.tar.gz "${download_url}" 2>&1; then
        echo_warn "GitHub 下载失败，尝试使用镜像源..."
        local mirror_url="https://mirror.ghproxy.com/${download_url}"
        if ! wget --show-progress -O frp_${FRP_VERSION}_linux_amd64.tar.gz "${mirror_url}" 2>&1; then
            echo_error "下载失败，请检查网络连接"
            exit 1
        fi
    fi
    
    # 验证文件
    echo_step "验证下载文件..."
    if [ ! -f frp_${FRP_VERSION}_linux_amd64.tar.gz ]; then
        echo_error "下载的文件不存在"
        exit 1
    fi
    
    local file_size=$(stat -f%z frp_${FRP_VERSION}_linux_amd64.tar.gz 2>/dev/null || stat -c%s frp_${FRP_VERSION}_linux_amd64.tar.gz 2>/dev/null)
    if [ "$file_size" -lt 1000000 ]; then
        echo_error "下载的文件太小（${file_size} 字节），可能下载不完整"
        exit 1
    fi
    echo_success "文件验证通过（$(numfmt --to=iec-i --suffix=B $file_size 2>/dev/null || echo "${file_size} bytes")）"
    
    # 解压
    echo_step "解压文件..."
    if ! tar -xzf frp_${FRP_VERSION}_linux_amd64.tar.gz; then
        echo_error "解压失败，文件可能已损坏"
        exit 1
    fi
    echo_success "解压完成"
}

# 安装服务端
install_server() {
    check_root "install-server"
    
    show_logo
    echo_title "🚀 开始安装 FRP 服务端"
    echo ""
    
    # 停止现有服务
    if systemctl is-active --quiet frps 2>/dev/null; then
        echo_step "检测到 frps 服务正在运行，先停止服务..."
        systemctl stop frps
        echo_success "服务已停止"
    fi
    
    # 生成随机密码
    echo_step "生成安全密钥..."
    local auth_token=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    local web_password=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo_success "密钥生成完成"
    
    # 下载 FRP
    download_frp "/tmp"
    
    # 安装
    echo_step "安装 FRP 程序..."
    mkdir -p ${INSTALL_DIR}
    cp /tmp/frp_${FRP_VERSION}_linux_amd64/frps ${INSTALL_DIR}/
    chmod +x ${INSTALL_DIR}/frps
    echo_success "程序安装完成"
    
    # 创建配置文件
    cat > ${INSTALL_DIR}/frps.toml << EOF
bindAddr = "0.0.0.0"
bindPort = 7000

auth.method = "token"
auth.token = "${auth_token}"

webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "${web_password}"

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
    echo_step "配置防火墙规则..."
    if command -v ufw &> /dev/null; then
        ufw allow 7000/tcp 2>/dev/null || true
        ufw allow 7500/tcp 2>/dev/null || true
        ufw allow 6000:60000/tcp 2>/dev/null || true
        echo_success "防火墙配置完成 (ufw)"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=7000/tcp 2>/dev/null || true
        firewall-cmd --permanent --add-port=7500/tcp 2>/dev/null || true
        firewall-cmd --permanent --add-port=6000-60000/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        echo_success "防火墙配置完成 (firewalld)"
    else
        echo_warn "未检测到防火墙，请手动开放端口 7000, 7500, 6000-60000"
    fi
    
    # 启动服务
    echo_step "启动 FRP 服务..."
    systemctl daemon-reload
    systemctl enable frps
    systemctl start frps
    
    # 检查服务状态
    sleep 2
    if systemctl is-active --quiet frps; then
        echo_success "服务启动成功"
    else
        echo_error "服务启动失败，请检查日志"
        exit 1
    fi
    
    # 获取公网 IP
    echo_step "获取服务器公网 IP..."
    local server_ip=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 ip.sb || echo "获取失败")
    
    # 保存配置信息
    cat > ${INSTALL_DIR}/install_info.txt << EOF
服务器 IP: ${server_ip}
认证 Token: ${auth_token}
Web 管理面板: http://${server_ip}:7500
Web 用户名: admin
Web 密码: ${web_password}
安装时间: $(date)
EOF
    chmod 600 ${INSTALL_DIR}/install_info.txt
    
    # 输出结果
    echo ""
    echo_title "╔════════════════════════════════════════╗"
    echo_title "║     🎉 FRP 服务端安装完成！          ║"
    echo_title "╚════════════════════════════════════════╝"
    echo ""
    echo_info "📋 服务器信息："
    echo -e "   服务器 IP: ${BOLD}${server_ip}${NC}"
    echo -e "   认证 Token: ${BOLD}${auth_token}${NC}"
    echo ""
    echo_info "🌐 Web 管理面板："
    echo -e "   访问地址: ${BOLD}http://${server_ip}:7500${NC}"
    echo -e "   用户名: ${BOLD}admin${NC}"
    echo -e "   密码: ${BOLD}${web_password}${NC}"
    echo ""
    echo_warn "⚠️  请妥善保存以上信息！"
    echo ""
    echo_info "📱 客户端连接配置："
    echo "   serverAddr = \"${server_ip}\""
    echo "   serverPort = 7000"
    echo "   auth.token = \"${auth_token}\""
    echo ""
    echo_info "💾 配置已保存到: ${INSTALL_DIR}/install_info.txt"
    echo ""
    echo_info "🔧 常用管理命令："
    echo -e "   查看状态: ${CYAN}bash frp.sh status-server${NC}"
    echo -e "   查看日志: ${CYAN}bash frp.sh logs-server${NC}"
    echo -e "   重启服务: ${CYAN}bash frp.sh restart-server${NC}"
    echo ""
    echo_success "安装完成！"
}

# 安装客户端
install_client() {
    check_root "install-client"
    
    show_logo
    echo_title "🔧 FRP 客户端配置"
    echo ""
    
    # 交互式配置
    local server_ip auth_token proxy_type
    echo_step "请输入服务端信息："
    read_input "  服务端 IP 地址: " server_ip
    read_input "  认证 Token: " auth_token
    
    # 验证输入
    if [ -z "$server_ip" ] || [ -z "$auth_token" ]; then
        echo_error "服务端 IP 和 Token 不能为空"
        exit 1
    fi
    
    echo ""
    echo_step "选择代理类型："
    echo -e "  ${BOLD}1)${NC} SSH 远程登录 (端口 22 -> 6000)"
    echo -e "  ${BOLD}2)${NC} Web 服务 (端口 8080 -> 6001)"
    echo -e "  ${BOLD}3)${NC} 自定义配置"
    echo ""
    read_input "请选择 [1-3]: " proxy_type
    
    if [ -z "$proxy_type" ]; then
        echo_error "必须选择代理类型"
        exit 1
    fi
    
    echo ""
    echo_title "🚀 开始安装 FRP 客户端"
    echo ""
    
    # 停止现有服务
    if systemctl is-active --quiet frpc 2>/dev/null; then
        echo_info "检测到 frpc 服务正在运行，先停止服务..."
        systemctl stop frpc
    fi
    
    # 下载 FRP
    download_frp "/tmp"
    
    # 安装
    mkdir -p ${INSTALL_DIR}
    cp /tmp/frp_${FRP_VERSION}_linux_amd64/frpc ${INSTALL_DIR}/
    chmod +x ${INSTALL_DIR}/frpc
    
    # 创建配置文件
    cat > ${INSTALL_DIR}/frpc.toml << EOF
serverAddr = "${server_ip}"
serverPort = 7000

auth.method = "token"
auth.token = "${auth_token}"

log.to = "${INSTALL_DIR}/frpc.log"
log.level = "info"
log.maxDays = 3
EOF
    
    # 根据选择添加代理配置
    case $proxy_type in
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
            local access_info="ssh root@${server_ip} -p 6000"
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
            local access_info="http://${server_ip}:6001"
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
            local access_info="请手动编辑配置: ${INSTALL_DIR}/frpc.toml"
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
    echo_step "启动 FRP 客户端服务..."
    systemctl daemon-reload
    systemctl enable frpc
    systemctl start frpc
    
    # 检查服务状态
    sleep 2
    if systemctl is-active --quiet frpc; then
        echo_success "服务启动成功"
    else
        echo_error "服务启动失败，请检查日志"
        exit 1
    fi
    
    # 输出结果
    echo ""
    echo_title "╔════════════════════════════════════════╗"
    echo_title "║     🎉 FRP 客户端安装完成！          ║"
    echo_title "╚════════════════════════════════════════╝"
    echo ""
    echo_info "📋 连接信息："
    echo -e "   服务端: ${BOLD}${server_ip}:7000${NC}"
    echo "   配置文件: ${INSTALL_DIR}/frpc.toml"
    echo "   日志文件: ${INSTALL_DIR}/frpc.log"
    echo ""
    if [ -n "$access_info" ]; then
        echo_info "🌐 访问方式："
        echo -e "   ${BOLD}${access_info}${NC}"
        echo ""
    fi
    echo_info "🔧 常用管理命令："
    echo -e "   查看状态: ${CYAN}bash frp.sh status-client${NC}"
    echo -e "   查看日志: ${CYAN}bash frp.sh logs-client${NC}"
    echo -e "   重启服务: ${CYAN}bash frp.sh restart-client${NC}"
    echo -e "   编辑配置: ${CYAN}bash frp.sh config-client${NC}"
    echo ""
    echo_success "安装完成！"
}

# 卸载服务端
uninstall_server() {
    check_root "uninstall-server"
    
    echo_info "开始卸载 FRP 服务端..."
    
    # 停止服务
    if systemctl is-active --quiet frps 2>/dev/null; then
        echo_info "停止 frps 服务..."
        systemctl stop frps
    fi
    
    # 禁用服务
    if systemctl is-enabled --quiet frps 2>/dev/null; then
        systemctl disable frps
    fi
    
    # 删除服务文件
    if [ -f /etc/systemd/system/frps.service ]; then
        rm -f /etc/systemd/system/frps.service
        systemctl daemon-reload
    fi
    
    # 备份配置
    if [ -f ${INSTALL_DIR}/install_info.txt ]; then
        local backup_dir="$HOME/frp_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp ${INSTALL_DIR}/install_info.txt "$backup_dir/" 2>/dev/null || true
        cp ${INSTALL_DIR}/frps.toml "$backup_dir/" 2>/dev/null || true
        echo_info "配置已备份到: $backup_dir"
    fi
    
    # 删除安装目录
    if [ -d ${INSTALL_DIR} ]; then
        rm -rf ${INSTALL_DIR}
    fi
    
    # 询问是否删除防火墙规则
    echo ""
    local reply
    read_input "是否删除防火墙规则？(y/N): " reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        if command -v ufw &> /dev/null; then
            ufw delete allow 7000/tcp 2>/dev/null || true
            ufw delete allow 7500/tcp 2>/dev/null || true
            ufw delete allow 6000:60000/tcp 2>/dev/null || true
            echo_info "已删除 ufw 防火墙规则"
        elif command -v firewall-cmd &> /dev/null; then
            firewall-cmd --permanent --remove-port=7000/tcp 2>/dev/null || true
            firewall-cmd --permanent --remove-port=7500/tcp 2>/dev/null || true
            firewall-cmd --permanent --remove-port=6000-60000/tcp 2>/dev/null || true
            firewall-cmd --reload 2>/dev/null || true
            echo_info "已删除 firewalld 防火墙规则"
        fi
    fi
    
    echo ""
    echo_info "FRP 服务端卸载完成！"
}

# 卸载客户端
uninstall_client() {
    check_root "uninstall-client"
    
    echo_info "开始卸载 FRP 客户端..."
    
    # 停止服务
    if systemctl is-active --quiet frpc 2>/dev/null; then
        echo_info "停止 frpc 服务..."
        systemctl stop frpc
    fi
    
    # 禁用服务
    if systemctl is-enabled --quiet frpc 2>/dev/null; then
        systemctl disable frpc
    fi
    
    # 删除服务文件
    if [ -f /etc/systemd/system/frpc.service ]; then
        rm -f /etc/systemd/system/frpc.service
        systemctl daemon-reload
    fi
    
    # 备份配置
    if [ -f ${INSTALL_DIR}/frpc.toml ]; then
        local backup_dir="$HOME/frp_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp ${INSTALL_DIR}/frpc.toml "$backup_dir/"
        echo_info "配置已备份到: $backup_dir"
    fi
    
    # 删除安装目录
    if [ -d ${INSTALL_DIR} ]; then
        rm -rf ${INSTALL_DIR}
    fi
    
    echo ""
    echo_info "FRP 客户端卸载完成！"
}

# 查看服务端状态
status_server() {
    echo_info "FRP 服务端状态："
    echo ""
    systemctl status frps --no-pager || echo_error "服务端未安装或未运行"
}

# 查看客户端状态
status_client() {
    echo_info "FRP 客户端状态："
    echo ""
    systemctl status frpc --no-pager || echo_error "客户端未安装或未运行"
}

# 重启服务端
restart_server() {
    check_root "restart-server"
    echo_info "重启 FRP 服务端..."
    systemctl restart frps
    echo_info "服务端已重启"
}

# 重启客户端
restart_client() {
    check_root "restart-client"
    echo_info "重启 FRP 客户端..."
    systemctl restart frpc
    echo_info "客户端已重启"
}

# 查看服务端日志
logs_server() {
    if [ -f ${INSTALL_DIR}/frps.log ]; then
        tail -f ${INSTALL_DIR}/frps.log
    else
        echo_error "日志文件不存在: ${INSTALL_DIR}/frps.log"
    fi
}

# 查看客户端日志
logs_client() {
    if [ -f ${INSTALL_DIR}/frpc.log ]; then
        tail -f ${INSTALL_DIR}/frpc.log
    else
        echo_error "日志文件不存在: ${INSTALL_DIR}/frpc.log"
    fi
}

# 查看服务端配置信息
info_server() {
    if [ -f ${INSTALL_DIR}/install_info.txt ]; then
        echo_info "服务端配置信息："
        echo ""
        cat ${INSTALL_DIR}/install_info.txt
    else
        echo_error "配置信息文件不存在: ${INSTALL_DIR}/install_info.txt"
    fi
}

# 编辑客户端配置
config_client() {
    check_root "config-client"
    
    if [ ! -f ${INSTALL_DIR}/frpc.toml ]; then
        echo_error "配置文件不存在: ${INSTALL_DIR}/frpc.toml"
        exit 1
    fi
    
    ${EDITOR:-vim} ${INSTALL_DIR}/frpc.toml
    
    echo ""
    local reply
    read_input "是否重启客户端使配置生效？(Y/n): " reply
    if [[ ! $reply =~ ^[Nn]$ ]]; then
        systemctl restart frpc
        echo_info "客户端已重启"
    fi
}

# 更新脚本
update_script() {
    echo_info "更新脚本..."
    local script_url="https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh"
    
    if wget -O /tmp/frp.sh.new "$script_url" 2>&1; then
        chmod +x /tmp/frp.sh.new
        mv /tmp/frp.sh.new "$0"
        echo_info "脚本更新成功！"
    else
        echo_error "脚本更新失败"
        exit 1
    fi
}

# 主函数
main() {
    # 无参数时显示交互式菜单
    if [ $# -eq 0 ]; then
        show_menu
        return
    fi
    
    local command="$1"
    
    case "$command" in
        install-server)
            install_server
            ;;
        install-client)
            install_client
            ;;
        uninstall-server)
            uninstall_server
            ;;
        uninstall-client)
            uninstall_client
            ;;
        status-server)
            status_server
            ;;
        status-client)
            status_client
            ;;
        restart-server)
            restart_server
            ;;
        restart-client)
            restart_client
            ;;
        logs-server)
            logs_server
            ;;
        logs-client)
            logs_client
            ;;
        info-server)
            info_server
            ;;
        config-client)
            config_client
            ;;
        menu)
            show_menu
            ;;
        version|-v|--version)
            show_version
            ;;
        update)
            update_script
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo_error "未知命令: $command"
            echo ""
            echo_info "使用 ${CYAN}bash frp.sh help${NC} 查看帮助"
            echo_info "使用 ${CYAN}bash frp.sh${NC} 显示交互式菜单"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
