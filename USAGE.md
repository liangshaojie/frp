# FRP 统一管理脚本使用指南

## 快速开始

### 1. 下载脚本

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
chmod +x frp.sh
```

### 2. 查看帮助

```bash
bash frp.sh help
```

## 完整命令列表

### 服务端命令

| 命令 | 说明 | 需要 root |
|------|------|-----------|
| `bash frp.sh install-server` | 安装 FRP 服务端 | ✅ |
| `bash frp.sh uninstall-server` | 卸载 FRP 服务端 | ✅ |
| `bash frp.sh status-server` | 查看服务端状态 | ❌ |
| `bash frp.sh restart-server` | 重启服务端 | ✅ |
| `bash frp.sh logs-server` | 查看服务端日志（实时） | ❌ |
| `bash frp.sh info-server` | 查看服务端配置信息 | ❌ |

### 客户端命令

| 命令 | 说明 | 需要 root |
|------|------|-----------|
| `bash frp.sh install-client` | 安装 FRP 客户端 | ✅ |
| `bash frp.sh uninstall-client` | 卸载 FRP 客户端 | ✅ |
| `bash frp.sh status-client` | 查看客户端状态 | ❌ |
| `bash frp.sh restart-client` | 重启客户端 | ✅ |
| `bash frp.sh logs-client` | 查看客户端日志（实时） | ❌ |
| `bash frp.sh config-client` | 编辑客户端配置 | ✅ |

### 通用命令

| 命令 | 说明 |
|------|------|
| `bash frp.sh help` | 显示帮助信息 |
| `bash frp.sh version` | 显示版本信息 |
| `bash frp.sh update` | 更新脚本到最新版本 |

## 使用场景示例

### 场景 1：首次部署服务端

```bash
# 1. 下载脚本
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
chmod +x frp.sh

# 2. 安装服务端
sudo bash frp.sh install-server

# 3. 记录输出的 Token 和密码信息

# 4. 查看状态
bash frp.sh status-server

# 5. 查看配置信息（如果忘记了）
bash frp.sh info-server
```

### 场景 2：首次部署客户端

```bash
# 1. 下载脚本
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
chmod +x frp.sh

# 2. 安装客户端（会提示输入服务端 IP 和 Token）
sudo bash frp.sh install-client

# 3. 查看状态
bash frp.sh status-client

# 4. 查看日志确认连接成功
bash frp.sh logs-client
```

### 场景 3：修改客户端配置

```bash
# 1. 编辑配置文件
sudo bash frp.sh config-client

# 2. 修改后会提示是否重启，选择 Y

# 3. 查看日志确认
bash frp.sh logs-client
```

### 场景 4：排查连接问题

```bash
# 1. 查看服务端状态
bash frp.sh status-server

# 2. 查看服务端日志
bash frp.sh logs-server

# 3. 在另一个终端查看客户端日志
bash frp.sh logs-client

# 4. 如果需要重启
sudo bash frp.sh restart-server
sudo bash frp.sh restart-client
```

### 场景 5：完全卸载

```bash
# 卸载服务端
sudo bash frp.sh uninstall-server

# 卸载客户端
sudo bash frp.sh uninstall-client

# 配置文件会自动备份到 ~/frp_backup_* 目录
```

## 常见问题

### Q: 如何查看服务端的 Token？

```bash
bash frp.sh info-server
```

### Q: 如何添加多个代理？

```bash
# 1. 编辑配置
sudo bash frp.sh config-client

# 2. 添加新的 [[proxies]] 块
[[proxies]]
name = "web2"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3000
remotePort = 6002

# 3. 保存并重启
```

### Q: 如何查看实时日志？

```bash
# 服务端
bash frp.sh logs-server

# 客户端
bash frp.sh logs-client

# 按 Ctrl+C 退出
```

### Q: 脚本安装在哪里？

- FRP 程序：`/usr/local/frp/`
- 配置文件：`/usr/local/frp/frps.toml` 或 `/usr/local/frp/frpc.toml`
- 日志文件：`/usr/local/frp/frps.log` 或 `/usr/local/frp/frpc.log`
- systemd 服务：`/etc/systemd/system/frps.service` 或 `/etc/systemd/system/frpc.service`

### Q: 如何更新 FRP 版本？

目前需要重新安装：

```bash
# 1. 备份配置
cp /usr/local/frp/frpc.toml ~/frpc.toml.backup

# 2. 卸载
sudo bash frp.sh uninstall-client

# 3. 修改脚本中的版本号或等待脚本更新

# 4. 重新安装
sudo bash frp.sh install-client

# 5. 如需要，恢复配置
```

## 与独立脚本的对比

| 特性 | 统一脚本 (frp.sh) | 独立脚本 |
|------|-------------------|----------|
| 安装 | ✅ | ✅ |
| 卸载 | ✅ | ✅ |
| 状态查看 | ✅ | ❌ |
| 日志查看 | ✅ | ❌ |
| 配置编辑 | ✅ | ❌ |
| 重启服务 | ✅ | ❌ |
| 一键命令 | ❌ | ✅ |
| 帮助文档 | ✅ | ❌ |

**推荐使用统一脚本**，功能更完整，管理更方便！

## 技术细节

### 支持的系统

- Ubuntu 18.04+
- Debian 10+
- CentOS 7+
- Rocky Linux 8+
- 其他支持 systemd 的 Linux 发行版

### 依赖工具

- `wget` - 下载文件
- `systemctl` - 服务管理
- `openssl` - 生成随机密码
- `vim` 或 `$EDITOR` - 编辑配置

### 安全特性

- ✅ 自动生成强随机密码（25 位）
- ✅ 配置文件权限保护（600）
- ✅ 支持 Token 认证
- ✅ 支持 SSH 加密和压缩
- ✅ 卸载时自动备份配置

## 贡献

欢迎提交 Issue 和 Pull Request！

项目地址：https://github.com/liangshaojie/frp
