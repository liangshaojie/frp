# FRP 内网穿透 - 一键部署

> 使用一个脚本，3 分钟搞定内网穿透

📖 **[快速开始指南](./QUICKSTART.md)** | 📚 **[详细使用文档](./USAGE.md)**

## 特性

- 🎯 **交互式菜单** - 无需记忆命令，图形化菜单操作
- 🚀 **一键安装** - 统一管理脚本，支持服务端和客户端
- 🔐 **自动配置** - 自动生成强密码和 Token
- 📦 **开箱即用** - 自动配置 systemd 服务和防火墙
- 🛠️ **易于管理** - 内置状态查看、日志查看、配置编辑等功能
- ✨ **美化输出** - 彩色图标、清晰提示、进度反馈
- 🔄 **自动重试** - 下载失败自动切换镜像源
- 💾 **安全备份** - 卸载时自动备份配置文件
- ✅ **状态检查** - 安装后自动验证服务状态

## 什么是 FRP？

**FRP**（Fast Reverse Proxy）是一个高性能的内网穿透工具，让外网可以访问你的内网服务。

**工作原理**：
```
外网用户 → 公网服务器(frps) → 内网机器(frpc) → 本地服务
```

---

## 快速开始

### 方式一：使用统一管理脚本（推荐）⭐

**下载管理脚本**：
```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
chmod +x frp.sh
```

**交互式菜单**（最简单）：
```bash
# 直接运行，显示交互式菜单
bash frp.sh
```

**命令行模式**：
```bash
# 查看帮助
bash frp.sh help

# 安装服务端
sudo bash frp.sh install-server

# 安装客户端
sudo bash frp.sh install-client
```

**常用命令**：
```bash
# 查看状态
bash frp.sh status-server
bash frp.sh status-client

# 查看日志（实时）
bash frp.sh logs-server
bash frp.sh logs-client

# 重启服务
sudo bash frp.sh restart-server
sudo bash frp.sh restart-client

# 编辑配置
sudo bash frp.sh config-client

# 卸载
sudo bash frp.sh uninstall-server
sudo bash frp.sh uninstall-client
```

---

### 方式二：使用独立安装脚本

#### 服务端部署（公网服务器）

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

#### 客户端部署（内网机器）

**推荐方式**（支持交互式输入）：

```bash
# 先下载脚本
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh
chmod +x frpc-install.sh

# 运行脚本
sudo bash frpc-install.sh
```

**或使用一键命令**：

```bash
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh | sudo bash
```

**交互式配置**：
1. 输入服务端 IP 地址
2. 输入认证 Token（从服务端安装输出中获取）
3. 选择代理类型：
   - SSH 远程登录
   - Web 服务
   - 自定义配置

> **注意**：最新版本已修复通过管道执行时的交互问题，两种方式都可以正常使用。

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

## 验证安装

### 服务端验证

**1. 检查服务状态**
```bash
systemctl status frps
```
应该显示 `active (running)` 状态

**2. 检查端口监听**
```bash
netstat -tlnp | grep frps
# 或使用 ss 命令
ss -tlnp | grep frps
```
应该看到端口 7000 和 7500 在监听

**3. 访问 Web 管理面板**
```bash
http://服务器IP:7500
```
使用安装时输出的用户名（admin）和密码登录

**4. 查看日志确认运行正常**
```bash
tail -f /usr/local/frp/frps.log
```
应该没有错误信息

### 客户端验证

**1. 检查服务状态**
```bash
systemctl status frpc
```
应该显示 `active (running)` 状态

**2. 查看日志确认连接成功**
```bash
tail -f /usr/local/frp/frpc.log
```
应该看到 "login to server success" 等成功信息

**3. 测试实际服务**
- **SSH 代理测试**：
  ```bash
  ssh root@服务器IP -p 6000
  ```
- **Web 服务测试**：
  ```bash
  http://服务器IP:6001
  ```

**4. 在服务端 Web 面板查看**
- 访问 `http://服务器IP:7500`
- 查看客户端连接状态和代理列表

---

## 管理命令

### 使用统一脚本管理（推荐）

```bash
# 服务端管理
bash frp.sh status-server      # 查看服务端状态
bash frp.sh logs-server         # 查看服务端日志
bash frp.sh info-server         # 查看服务端配置信息
sudo bash frp.sh restart-server # 重启服务端
sudo bash frp.sh uninstall-server # 卸载服务端

# 客户端管理
bash frp.sh status-client       # 查看客户端状态
bash frp.sh logs-client         # 查看客户端日志
bash frp.sh config-client       # 编辑客户端配置
sudo bash frp.sh restart-client # 重启客户端
sudo bash frp.sh uninstall-client # 卸载客户端

# 其他命令
bash frp.sh help                # 查看帮助
bash frp.sh version             # 查看版本
bash frp.sh update              # 更新脚本
```

### 使用 systemctl 管理

**服务端管理**：
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

**客户端管理**：
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

### 安装失败：Text file busy

**问题**：重新安装时出现 `cp: cannot create regular file '/usr/local/frp/frps': Text file busy`

**原因**：服务正在运行，文件被占用

**解决方案**：

**方案 1：使用卸载脚本后重新安装**
```bash
# 先卸载
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frps-uninstall.sh | sudo bash
# 再安装
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frps-install.sh | sudo bash
```

**方案 2：手动停止服务后重新安装**
```bash
# 停止服务
systemctl stop frps
# 重新安装
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frps-install.sh | sudo bash
```

**注意**：最新版本的安装脚本已自动处理此问题，会在安装前自动停止服务。

### 安装失败：下载或解压错误

**问题**：安装时出现以下错误
```
gzip: stdin: unexpected end of file
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
```

**原因**：下载的压缩包不完整或已损坏

**排查步骤**：

1. **检查网络连接**
```bash
ping github.com
curl -I https://github.com
```

2. **手动下载并验证**
```bash
cd /tmp
# 删除旧文件
rm -f frp_0.65.0_linux_amd64.tar.gz

# 手动下载（显示进度）
wget --show-progress https://github.com/fatedier/frp/releases/download/v0.65.0/frp_0.65.0_linux_amd64.tar.gz

# 检查文件大小（应该大于 10MB）
ls -lh frp_0.65.0_linux_amd64.tar.gz

# 尝试解压测试
tar -tzf frp_0.65.0_linux_amd64.tar.gz | head
```

3. **使用镜像源下载**
```bash
# 使用 GitHub 代理镜像
wget https://mirror.ghproxy.com/https://github.com/fatedier/frp/releases/download/v0.65.0/frp_0.65.0_linux_amd64.tar.gz
```

4. **清理后重新安装**
```bash
# 清理临时文件
rm -rf /tmp/frp_*

# 重新运行安装脚本
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh | sudo bash
```

**注意**：最新版本的安装脚本已添加：
- ✅ 自动清理旧文件
- ✅ 显示下载进度
- ✅ 验证文件完整性
- ✅ 自动尝试镜像源
- ✅ 详细的错误提示

### 安装时没有交互提示

**问题**：使用 `curl | bash` 方式安装时，没有提示输入服务端 IP 和 Token，直接跳过了

**原因**：通过管道执行脚本时，标准输入被 curl 占用，`read` 命令无法从终端读取

**解决方案**：

**方案 1：推荐使用下载后执行的方式**
```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh
chmod +x frpc-install.sh
sudo bash frpc-install.sh
```

**方案 2：使用最新版本脚本**
```bash
# 最新版本已修复此问题，可以正常交互
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-install.sh | sudo bash
```

**方案 3：手动配置**
```bash
# 如果已经安装但配置为空，手动编辑配置文件
sudo vim /usr/local/frp/frpc.toml

# 修改以下内容：
serverAddr = "你的服务器IP"
auth.token = "你的Token"

# 重启服务
sudo systemctl restart frpc
```

**注意**：最新版本脚本已修复，从 `/dev/tty` 读取输入，支持通过管道执行。

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

### 一键卸载服务端

```bash
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frps-uninstall.sh | sudo bash
```

或手动下载：

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frps-uninstall.sh
chmod +x frps-uninstall.sh
sudo bash frps-uninstall.sh
```

**卸载脚本会自动**：
- ✅ 停止并禁用 frps 服务
- ✅ 删除 systemd 服务文件
- ✅ 备份配置信息到用户目录
- ✅ 删除安装目录
- ✅ 可选删除防火墙规则

### 一键卸载客户端

```bash
curl -fsSL https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-uninstall.sh | sudo bash
```

或手动下载：

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frpc-uninstall.sh
chmod +x frpc-uninstall.sh
sudo bash frpc-uninstall.sh
```

**卸载脚本会自动**：
- ✅ 停止并禁用 frpc 服务
- ✅ 删除 systemd 服务文件
- ✅ 备份配置文件到用户目录
- ✅ 删除安装目录

### 手动卸载（如果脚本失败）

**服务端**：
```bash
systemctl stop frps && systemctl disable frps
rm -f /etc/systemd/system/frps.service
rm -rf /usr/local/frp
systemctl daemon-reload
```

**客户端**：
```bash
systemctl stop frpc && systemctl disable frpc
rm -f /etc/systemd/system/frpc.service
rm -rf /usr/local/frp
systemctl daemon-reload
```

---

## 项目文件说明

```
frp/
├── frp.sh                  # 统一管理脚本（推荐使用）
├── frps-install.sh         # 服务端独立安装脚本
├── frpc-install.sh         # 客户端独立安装脚本
├── frps-uninstall.sh       # 服务端独立卸载脚本
├── frpc-uninstall.sh       # 客户端独立卸载脚本
├── README.md               # 项目说明文档
└── USAGE.md                # 统一脚本使用指南
```

**推荐使用 `frp.sh` 统一管理脚本**，功能更完整：
- ✅ 安装/卸载服务端和客户端
- ✅ 查看状态和日志
- ✅ 编辑配置和重启服务
- ✅ 内置帮助文档
- ✅ 支持脚本更新

详细使用方法请查看 [USAGE.md](./USAGE.md)

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
