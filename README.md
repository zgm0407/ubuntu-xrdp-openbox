# Ubuntu XRDP OpenBox Docker Image

[中文](#中文说明) | [English](#english-description)

---

## 中文说明

基于Debian 12的轻量级远程桌面镜像，使用xrdp提供RDP协议访问，Openbox作为窗口管理器，体积小、速度快、支持完整中文显示。

## 特点
- 🐧 基于Debian 12 Slim，体积更小，稳定可靠
- 🖥️ xrdp远程桌面服务，支持所有标准RDP客户端连接
- 🪟 Openbox轻量级窗口管理器，资源占用极低
- 🇨🇳 完整中文支持，预装文泉驿微米黑字体，中文显示无乱码
- ⏰ 时区默认配置为Asia/Shanghai
- 👤 支持多用户创建，每个用户可独立配置sudo权限
- 📦 镜像体积约300MB，极致精简

## 快速开始

### 构建镜像
```bash
docker build -t ubuntu-xrdp-openbox .
```

### 运行容器
必须传入用户参数，每个用户需要3个参数：`用户名 密码 是否授予sudo权限(yes/no)`

#### 单用户示例：
```bash
docker run -d -p 3389:3389 --name my-desktop ubuntu-xrdp-openbox ubuntu 123456 yes
```

#### 多用户示例：
```bash
docker run -d -p 3389:3389 --name my-desktop ubuntu-xrdp-openbox \
    user1 pass1 yes \
    user2 pass2 no
```

### 远程连接
使用任意RDP客户端连接：
- **地址**：`localhost:3389`（服务器IP替换为实际地址）
- **用户名**：你创建的用户名
- **密码**：你设置的密码

## 使用说明

### 登录后黑屏解决方法
首次登录可能会出现短暂黑屏，这是正常现象：
1. **在黑屏处点击鼠标右键**，会弹出Openbox的系统菜单
2. 通过菜单可以启动终端、文件管理器、配置工具等程序
3. 桌面默认没有图标，所有操作都通过右键菜单完成

### 常用操作
- **右键菜单** → **Terminal**：打开xterm终端
- **右键菜单** → **Obconf**：打开Openbox配置工具，可以修改主题、字体、快捷键等
- **右键菜单** → **Reconfigure**：修改配置后点击刷新，让新配置立即生效
- **右键菜单** → **Exit**：退出桌面会话

### 安装软件
如果需要安装更多软件，可以在终端中执行：
```bash
sudo apt update && sudo apt install -y [软件包名]
```

推荐安装的常用工具：
- `pcmanfm`：轻量级文件管理器
- `firefox`：火狐浏览器
- `gedit`：图形化文本编辑器

## 端口说明
- `3389`：标准RDP远程桌面端口

## 目录说明
- 所有用户的家目录：`/home/[用户名]/`
- Openbox系统级配置：`/etc/xdg/openbox/`
- 用户级配置：`~/.config/openbox/`（登录后自动生成）

## 安全建议
- 不要使用弱密码，生产环境建议使用复杂度高的密码
- 不要将3389端口直接暴露到公网，建议使用VPN或防火墙限制访问IP
- 不需要sudo权限的用户不要授予sudo权限

## 故障排除

### 无法连接RDP
1. 检查容器是否正常运行：`docker ps`
2. 检查3389端口是否被占用：`netstat -ano | findstr 3389`（Windows）或`ss -tlnp | grep 3389`（Linux）
3. 查看容器日志：`docker logs [容器名]`

### 中文显示乱码
镜像已经预装中文locale和字体，通常不会出现乱码。如果出现问题，请检查RDP客户端的编码设置，确认使用UTF-8编码。

### 右键菜单没有Obconf
Obconf是默认预装的，如果没有可以手动安装：
```bash
sudo apt install -y obconf
```

---

## English Description

A lightweight remote desktop Docker image based on Debian 12 Slim, with XRDP for RDP protocol access and OpenBox as window manager. Small size, fast performance, and full Chinese display support.

## Features

- 🐧 Based on Debian 12 Slim, smaller size, stable and reliable
- 🖥️ XRDP remote desktop service, supports all standard RDP clients
- 🪟 OpenBox lightweight window manager, extremely low resource usage
- 🇨🇳 Full Chinese support, pre-installed WQY Microhei fonts, no garbled characters
- ⏰ Default timezone set to Asia/Shanghai (easily configurable)
- 👤 Supports multiple user creation, each user can have independent sudo permissions
- 📦 Image size ~300MB, extremely streamlined

## Quick Start

### Build the image
```bash
docker build -t ubuntu-xrdp-openbox .
```

### Run the container
You must pass user parameters, each user requires 3 parameters: `username password sudo_permission(yes/no)`

#### Single user example:
```bash
docker run -d -p 3389:3389 --name my-desktop ubuntu-xrdp-openbox ubuntu 123456 yes
```

#### Multiple users example:
```bash
docker run -d -p 3389:3389 --name my-desktop ubuntu-xrdp-openbox \
    user1 pass1 yes \
    user2 pass2 no
```

### Remote Connection
Use any RDP client to connect:
- **Address**: `localhost:3389` (replace with your server IP)
- **Username**: The username you created
- **Password**: The password you set

## Usage Instructions

### Black screen after login
A brief black screen on first login is normal:
1. **Right-click on the black screen** to open the Openbox system menu
2. Launch terminal, file manager, configuration tools and other programs through the menu
3. Desktop has no icons by default, all operations are done through the right-click menu

### Common Operations
- **Right-click menu** → **Terminal**: Open xterm terminal
- **Right-click menu** → **Obconf**: Open Openbox configuration tool, modify themes, fonts, shortcuts, etc.
- **Right-click menu** → **Reconfigure**: Refresh after modifying configuration to apply changes immediately
- **Right-click menu** → **Exit**: Exit desktop session

### Install Software
If you need to install more software, execute in terminal:
```bash
sudo apt update && sudo apt install -y [package-name]
```

Recommended tools to install:
- `pcmanfm`: Lightweight file manager
- `firefox`: Firefox browser
- `gedit`: Graphical text editor

## Ports
- `3389`: Standard RDP remote desktop port

## Directories
- All user home directories: `/home/[username]/`
- Openbox system-wide configuration: `/etc/xdg/openbox/`
- User-level configuration: `~/.config/openbox/` (auto-generated after login)

## Security Recommendations
- Don't use weak passwords, use complex passwords in production environments
- Don't expose port 3389 directly to the public internet, use VPN or firewall to restrict access IPs
- Don't grant sudo permissions to users who don't need them

## Troubleshooting

### Cannot connect to RDP
1. Check if container is running: `docker ps`
2. Check if port 3389 is occupied: `netstat -ano | findstr 3389` (Windows) or `ss -tlnp | grep 3389` (Linux)
3. Check container logs: `docker logs [container-name]`

### Chinese display garbled
The image already has Chinese locale and fonts pre-installed, garbled characters usually don't occur. If there are issues, check your RDP client encoding settings, make sure UTF-8 is used.

### Obconf not in right-click menu
Obconf is pre-installed by default, if missing you can install manually:
```bash
sudo apt install -y obconf
```
