# FRP 内网穿透 - 一键部署

> 使用一个脚本，3 分钟搞定内网穿透

## 什么是 FRP？

**FRP**（Fast Reverse Proxy）是一个高性能的内网穿透工具，让外网可以访问你的内网服务。

**工作原理**：
```
外网用户 → 公网服务器(frps) → 内网机器(frpc) → 本地服务
```

---

## 一键部署

### 服务端部署（公网服务器）

在有公网 IP 的服务器上执行：

```bash
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frps-install.sh | sudo bash
```

或手动下载脚本：

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frps-install.sh
chmod +x frps-install.sh
sudo bash frps-install.sh
```

**脚本会自动完成**：
- ✅ 下载并安装 FRP 服务端
- ✅ 自动生成强密码（Token 和 Web 密码）
- ✅ 配置 systemd 服务（开机自启）
- ✅ 配置防火墙规则
- ✅ 输出配置信息供客户端使用

---

### 客户端部署（内网机器）

在内网机器上执行：

```bash
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh | sudo bash
```

或手动下载脚本：

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh
chmod +x frpc-install.sh
sudo bash frpc-install.sh
```

**交互式配置**：
1. 输入服务端 IP 地址
2. 输入认证 Token（从服务端安装输出中获取）
3. 选择代理类型：
   - SSH 远程登录
   - Web 服务
   - 自定义配置

---

## 使用示例

### SSH 远程登录

服务端安装完成后，客户端选择 "SSH 远程登录"，然后从外网访问：

```bash
ssh root@服务器IP -p 6000
```

### Web 服务访问

客户端选择 "Web 服务"，然后浏览器访问：

```bash
http://服务器IP:6001
```

### 查看 Web 管理面板

浏览器访问：

```bash
http://服务器IP:7500
```

使用服务端安装时输出的用户名和密码登录。

---

## 常用命令

### 服务端管理

```bash
# 查看服务状态
systemctl status frps

# 重启服务
systemctl restart frps

# 停止服务
systemctl stop frps

# 查看日志
tail -f /usr/local/frp/frps.log

# 查看配置信息
cat /usr/local/frp/install_info.txt
```

### 客户端管理

```bash
# 查看服务状态
systemctl status frpc

# 重启服务
systemctl restart frpc

# 停止服务
systemctl stop frpc

# 查看日志
tail -f /usr/local/frp/frpc.log

# 编辑配置
vim /usr/local/frp/frpc.toml
```

---

## 故障排查

### 客户端连接失败

```bash
# 1. 检查服务端是否运行
systemctl status frps

# 2. 检查防火墙
ufw status
firewall-cmd --list-ports

# 3. 检查 Token 是否一致
cat /usr/local/frp/frps.toml | grep token
cat /usr/local/frp/frpc.toml | grep token

# 4. 查看日志
tail -f /usr/local/frp/frps.log
tail -f /usr/local/frp/frpc.log
```

### 无法访问服务

```bash
# 1. 检查客户端服务是否运行
systemctl status frpc

# 2. 检查本地服务是否正常
# 例如 SSH：
systemctl status sshd

# 3. 检查端口是否被占用
netstat -tlnp | grep 6000

# 4. 测试本地服务
# 例如 SSH：
ssh localhost -p 22
```

---

## 安全建议

1. **使用强密码**：Token 和 Web 密码必须复杂（脚本已自动生成）
2. **限制端口**：只开放必要的端口范围（默认 6000-60000）
3. **启用加密**：SSH 代理已自动启用加密和压缩
4. **定期更新**：及时更新 FRP 版本
5. **监控日志**：定期检查访问日志

---

## 配置文件说明

### 服务端配置文件

位置：`/usr/local/frp/frps.toml`

```toml
bindAddr = "0.0.0.0"      # 监听地址
bindPort = 7000           # 客户端连接端口

auth.method = "token"     # 认证方式
auth.token = "..."        # 认证密钥（自动生成）

webServer.addr = "0.0.0.0"
webServer.port = 7500     # Web 管理面板端口
webServer.user = "admin"
webServer.password = "..." # Web 密码（自动生成）

allowPorts = [{ start = 6000, end = 60000 }]  # 允许的端口范围

log.to = "/usr/local/frp/frps.log"
log.level = "info"
log.maxDays = 3
```

### 客户端配置文件

位置：`/usr/local/frp/frpc.toml`

```toml
serverAddr = "服务器IP"    # 服务端地址
serverPort = 7000          # 服务端端口

auth.method = "token"
auth.token = "..."         # 与服务端一致

# SSH 代理示例
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
transport.useEncryption = true
transport.useCompression = true

# Web 代理示例
[[proxies]]
name = "web"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 6001
```

---

## 文件结构

```
/usr/local/frp/
├── frps              # 服务端可执行文件
├── frpc              # 客户端可执行文件
├── frps.toml         # 服务端配置文件
├── frpc.toml         # 客户端配置文件
├── frps.log          # 服务端日志
├── frpc.log          # 客户端日志
└── install_info.txt  # 安装信息（仅服务端）
```

---

## 卸载

### 卸载服务端

```bash
# 停止并禁用服务
systemctl stop frps
systemctl disable frps

# 删除服务文件
rm -f /etc/systemd/system/frps.service

# 删除安装目录
rm -rf /usr/local/frp

# 重新加载 systemd
systemctl daemon-reload
```

### 卸载客户端

```bash
# 停止并禁用服务
systemctl stop frpc
systemctl disable frpc

# 删除服务文件
rm -f /etc/systemd/system/frpc.service

# 删除安装目录
rm -rf /usr/local/frp

# 重新加载 systemd
systemctl daemon-reload
```

---

## 参考资料

- **官方文档**：https://gofrp.org/
- **GitHub 仓库**：https://github.com/fatedier/frp
- **下载地址**：https://github.com/fatedier/frp/releases
- **本项目地址**：https://github.com/liangshaojie/frp

---

## 许可证

MIT License

---

## 贡献

欢迎提交 Issue 和 Pull Request！
