# FRP 快速开始指南

## 🚀 3 分钟快速部署

### 第一步：下载脚本

```bash
wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
chmod +x frp.sh
```

### 第二步：使用交互式菜单

```bash
bash frp.sh
```

你会看到这样的菜单：

```
=========================================
   FRP 内网穿透 - 统一管理工具
   版本: 1.0.0
=========================================

请选择操作：

  服务端管理
    1) 安装服务端
    2) 卸载服务端
    3) 查看服务端状态
    4) 重启服务端
    5) 查看服务端日志
    6) 查看服务端配置信息

  客户端管理
    7) 安装客户端
    8) 卸载客户端
    9) 查看客户端状态
   10) 重启客户端
   11) 查看客户端日志
   12) 编辑客户端配置

  其他
   13) 显示帮助信息
   14) 更新脚本
    0) 退出

请输入选项 [0-14]:
```

### 第三步：安装服务端（在公网服务器上）

1. 选择 `1` - 安装服务端
2. 等待安装完成
3. **记录输出的信息**：
   - 服务器 IP
   - 认证 Token
   - Web 管理面板地址和密码

示例输出：
```
╔════════════════════════════════════════╗
║     🎉 FRP 服务端安装完成！          ║
╚════════════════════════════════════════╝

ℹ 📋 服务器信息：
   服务器 IP: 8.146.198.118
   认证 Token: FxJUDFtGkHDU9CO0sarHwLS3m

ℹ 🌐 Web 管理面板：
   访问地址: http://8.146.198.118:7500
   用户名: admin
   密码: AbCdEfGhIjKlMnOpQrStU

⚠ ⚠️  请妥善保存以上信息！

ℹ 📱 客户端连接配置：
   serverAddr = "8.146.198.118"
   serverPort = 7000
   auth.token = "FxJUDFtGkHDU9CO0sarHwLS3m"
```

### 第四步：安装客户端（在内网机器上）

1. 下载并运行脚本：
   ```bash
   wget https://raw.githubusercontent.com/liangshaojie/frp/main/frp.sh
   chmod +x frp.sh
   bash frp.sh
   ```

2. 选择 `7` - 安装客户端

3. 输入服务端信息：
   - 服务端 IP 地址：`8.146.198.118`
   - 认证 Token：`FxJUDFtGkHDU9CO0sarHwLS3m`

4. 选择代理类型：
   - `1` - SSH 远程登录（推荐新手）
   - `2` - Web 服务
   - `3` - 自定义配置

5. 等待安装完成

### 第五步：测试连接

#### 如果选择了 SSH 代理：

```bash
ssh root@8.146.198.118 -p 6000
```

#### 如果选择了 Web 服务：

浏览器访问：
```
http://8.146.198.118:6001
```

#### 查看 Web 管理面板：

浏览器访问：
```
http://8.146.198.118:7500
```

使用服务端安装时输出的用户名和密码登录。

---

## 📖 常见场景

### 场景 1：远程 SSH 登录内网机器

**需求**：从外网 SSH 登录家里的 Linux 服务器

**步骤**：
1. 在有公网 IP 的服务器上安装服务端
2. 在家里的服务器上安装客户端，选择 "SSH 远程登录"
3. 从外网使用 `ssh root@公网IP -p 6000` 连接

### 场景 2：访问内网 Web 服务

**需求**：从外网访问内网的 Web 应用（如 Home Assistant）

**步骤**：
1. 在有公网 IP 的服务器上安装服务端
2. 在内网机器上安装客户端，选择 "Web 服务"
3. 从外网访问 `http://公网IP:6001`

### 场景 3：多个服务代理

**需求**：同时代理 SSH 和多个 Web 服务

**步骤**：
1. 安装客户端时选择 "SSH 远程登录"
2. 安装完成后，运行 `bash frp.sh config-client` 编辑配置
3. 添加更多代理配置：

```toml
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000

[[proxies]]
name = "web1"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 6001

[[proxies]]
name = "web2"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3000
remotePort = 6002
```

4. 重启客户端：`bash frp.sh restart-client`

---

## 🔧 日常管理

### 查看服务状态

```bash
bash frp.sh status-server  # 服务端
bash frp.sh status-client  # 客户端
```

### 查看实时日志

```bash
bash frp.sh logs-server    # 服务端日志
bash frp.sh logs-client    # 客户端日志
```

按 `Ctrl+C` 退出日志查看

### 重启服务

```bash
sudo bash frp.sh restart-server  # 重启服务端
sudo bash frp.sh restart-client  # 重启客户端
```

### 修改配置

```bash
sudo bash frp.sh config-client
```

修改后会提示是否重启服务

### 查看服务端配置信息

```bash
bash frp.sh info-server
```

如果忘记了 Token 或密码，使用此命令查看

---

## ❓ 常见问题

### Q: 如何确认服务正常运行？

**服务端**：
```bash
# 1. 查看服务状态
bash frp.sh status-server

# 2. 访问 Web 面板
http://服务器IP:7500

# 3. 查看日志
bash frp.sh logs-server
```

**客户端**：
```bash
# 1. 查看服务状态
bash frp.sh status-client

# 2. 查看日志，应该看到 "login to server success"
bash frp.sh logs-client
```

### Q: 连接失败怎么办？

1. **检查服务端是否运行**：
   ```bash
   bash frp.sh status-server
   ```

2. **检查防火墙**：
   - 确保端口 7000, 7500, 6000-60000 已开放
   - 云服务器需要在安全组中开放端口

3. **检查 Token 是否一致**：
   ```bash
   # 服务端
   bash frp.sh info-server
   
   # 客户端
   cat /usr/local/frp/frpc.toml | grep token
   ```

4. **查看日志排查**：
   ```bash
   bash frp.sh logs-server
   bash frp.sh logs-client
   ```

### Q: 如何添加更多代理？

```bash
# 1. 编辑配置
sudo bash frp.sh config-client

# 2. 添加新的 [[proxies]] 块
# 3. 保存并重启
```

### Q: 如何更换服务器？

```bash
# 1. 编辑配置
sudo bash frp.sh config-client

# 2. 修改 serverAddr 和 auth.token
# 3. 保存并重启
```

### Q: 如何卸载？

```bash
# 卸载服务端
sudo bash frp.sh uninstall-server

# 卸载客户端
sudo bash frp.sh uninstall-client
```

配置文件会自动备份到 `~/frp_backup_*` 目录

---

## 🎓 进阶技巧

### 1. 使用域名访问

如果你有域名，可以配置 DNS 解析到服务器 IP，然后使用域名访问：
```
http://your-domain.com:6001
```

### 2. 配置 HTTPS

可以在服务器上配置 Nginx 反向代理，添加 SSL 证书：
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://127.0.0.1:6001;
    }
}
```

### 3. 监控和告警

可以配合监控工具（如 Prometheus）监控 FRP 服务状态

### 4. 性能优化

编辑配置文件，启用压缩和加密：
```toml
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
transport.useEncryption = true      # 启用加密
transport.useCompression = true     # 启用压缩
```

---

## 📚 更多资源

- **完整文档**：[README.md](./README.md)
- **使用指南**：[USAGE.md](./USAGE.md)
- **官方文档**：https://gofrp.org/
- **项目地址**：https://github.com/liangshaojie/frp

---

## 💡 小贴士

1. ✅ 定期查看日志，确保服务正常运行
2. ✅ 妥善保管 Token 和密码
3. ✅ 使用强密码（脚本已自动生成）
4. ✅ 定期更新 FRP 版本
5. ✅ 备份重要配置文件

祝你使用愉快！🎉
