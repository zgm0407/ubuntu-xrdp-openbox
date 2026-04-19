# Ubuntu XRDP OpenBox Docker Image

[中文](#中文说明) | [English](#english-description)

---

## 中文说明

基于Ubuntu 24.04的轻量级远程桌面镜像，使用xrdp提供RDP协议访问，Openbox作为窗口管理器，PCManFM提供桌面管理，体积小、速度快、支持完整中文显示。

## 特点
- 🐧 基于Ubuntu 24.04 LTS，稳定可靠
- 🖥️ xrdp远程桌面服务，支持所有标准RDP客户端连接
- 🪟 Openbox轻量级窗口管理器，资源占用极低
- 📁 PCManFM文件管理器，提供完整桌面图标支持
- 🇨🇳 完整中文支持，预装文泉驿微米黑字体，中文显示无乱码
- ⏰ 时区默认配置为Asia/Shanghai
- 👤 支持多用户创建，每个用户可独立配置sudo权限
- 🖱️ 桌面默认显示快捷方式，点击直接运行，无执行提示
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
# 推荐使用非3389端口避免冲突
docker run -d -p 3390:3389 --name my-desktop ubuntu-xrdp-openbox ubuntu 123456 yes
```

#### 多用户示例：
```bash
docker run -d -p 3390:3389 --name my-desktop ubuntu-xrdp-openbox \
    user1 pass1 yes \
    user2 pass2 no
```

### 远程连接
使用任意RDP客户端连接：
- **地址**：`localhost:3390`（服务器IP替换为实际地址，端口对应你映射的端口）
- **用户名**：你创建的用户名
- **密码**：你设置的密码
- **注意**：请在RDP客户端的本地资源设置中勾选"剪贴板"，以支持双向复制粘贴

## 使用说明

### 桌面说明
登录后自动显示桌面：
- **深蓝色背景**：默认桌面背景色
- **文件管理器**：蓝色文件夹图标，点击打开PCManFM
- **终端**：黑色终端图标，点击打开xterm命令行
- **主目录**：个人文件夹图标，快速访问用户家目录
- **回收站**：垃圾桶图标，管理已删除文件
- **右键菜单**：在桌面空白处点击右键，打开Openbox系统菜单

### 常用操作
- **双击桌面图标**：打开对应的程序
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
- `firefox`：火狐浏览器
- `gedit`：图形化文本编辑器

## 端口说明
- `3389`：容器内部标准RDP远程桌面端口，建议映射到其他端口如3390避免冲突

## 目录说明
- 所有用户的家目录：`/home/[用户名]/`
- Openbox系统级配置：`/etc/xdg/openbox/`
- 用户级配置：`~/.config/openbox/`（登录后自动生成）
- PCManFM配置：`~/.config/pcmanfm/`
- 桌面快捷方式：`~/Desktop/`

## 安全建议
- 不要使用弱密码，生产环境建议使用复杂度高的密码
- 不要将RDP端口直接暴露到公网，建议使用VPN或防火墙限制访问IP
- 不需要sudo权限的用户不要授予sudo权限

## 故障排除

### 无法连接RDP
1. 检查容器是否正常运行：`docker ps`
2. 检查端口是否被占用：`netstat -ano | findstr 3390`（Windows）或`ss -tlnp | grep 3390`（Linux）
3. 查看容器日志：`docker logs [容器名]`

### 登录后黑屏/闪退
1. 确认使用的是最新版本镜像，旧版本可能存在PAM认证问题
2. 检查容器是否有足够的内存，建议至少分配128MB内存
3. 查看会话日志：`docker exec [容器名] cat /var/log/xrdp-sesman.log`

### 中文显示乱码
镜像已经预装中文locale和字体，通常不会出现乱码。如果出现问题，请检查RDP客户端的编码设置，确认使用UTF-8编码。

### 桌面图标不显示
1. 确认PCManFM进程是否正常运行
2. 检查配置文件：`~/.config/pcmanfm/default/pcmanfm.conf`中`show_icons`是否为1

---

## English Description

A lightweight remote desktop Docker image based on Ubuntu 24.04 LTS, with XRDP for RDP protocol access, OpenBox as window manager, and PCManFM for desktop management. Small size, fast performance, and full Chinese display support.

## Features

- 🐧 Based on Ubuntu 24.04 LTS, stable and reliable
- 🖥️ XRDP remote desktop service, supports all standard RDP clients
- 🪟 OpenBox lightweight window manager, extremely low resource usage
- 📁 PCManFM file manager with full desktop icon support
- 🇨🇳 Full Chinese support, pre-installed WQY Microhei fonts, no garbled characters
- ⏰ Default timezone set to Asia/Shanghai (easily configurable)
- 👤 Supports multiple user creation, each user can have independent sudo permissions
- 🖱️ Desktop shortcuts open directly without execution confirmation prompts
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
# Recommended to use port 3390 to avoid conflicts
docker run -d -p 3390:3389 --name my-desktop ubuntu-xrdp-openbox ubuntu 123456 yes
```

#### Multiple users example:
```bash
docker run -d -p 3390:3389 --name my-desktop ubuntu-xrdp-openbox \
    user1 pass1 yes \
    user2 pass2 no
```

### Remote Connection
Use any RDP client to connect:
- **Address**: `localhost:3390` (replace with your server IP, use the port you mapped)
- **Username**: The username you created
- **Password**: The password you set
- **Note**: Enable "Clipboard" in your RDP client's local resources settings to support bidirectional copy-paste

## Usage Instructions

### Desktop Overview
After login, the desktop will automatically appear:
- **Dark blue background**: Default desktop background color
- **File Manager**: Blue folder icon, opens PCManFM on click
- **Terminal**: Black terminal icon, opens xterm command line on click
- **Home Folder**: Personal folder icon, quick access to user's home directory
- **Trash**: Recycle bin icon, manages deleted files
- **Right-click menu**: Right-click on empty desktop area to open Openbox system menu

### Common Operations
- **Double-click desktop icons**: Open corresponding applications
- **Right-click menu** → **Terminal**: Open xterm terminal
- **Right-click menu** → **Obconf**: Open Openbox configuration tool to modify themes, fonts, shortcuts, etc.
- **Right-click menu** → **Reconfigure**: Refresh after modifying configuration to apply changes immediately
- **Right-click menu** → **Exit**: Exit desktop session

### Install Software
If you need to install more software, execute in terminal:
```bash
sudo apt update && sudo apt install -y [package-name]
```

Recommended tools to install:
- `firefox`: Firefox browser
- `gedit`: Graphical text editor

## Ports
- `3389`: Standard RDP remote desktop port inside the container, recommend mapping to other ports like 3390 to avoid conflicts

## Directories
- All user home directories: `/home/[username]/`
- Openbox system-wide configuration: `/etc/xdg/openbox/`
- User-level configuration: `~/.config/openbox/` (auto-generated after login)
- PCManFM configuration: `~/.config/pcmanfm/`
- Desktop shortcuts: `~/Desktop/`

## Security Recommendations
- Don't use weak passwords, use complex passwords in production environments
- Don't expose RDP port directly to the public internet, use VPN or firewall to restrict access IPs
- Don't grant sudo permissions to users who don't need them

## Troubleshooting

### Cannot connect to RDP
1. Check if container is running: `docker ps`
2. Check if port is occupied: `netstat -ano | findstr 3390` (Windows) or `ss -tlnp | grep 3390` (Linux)
3. Check container logs: `docker logs [container-name]`

### Black screen/crash after login
1. Make sure you are using the latest version of the image, older versions may have PAM authentication issues
2. Check if the container has enough memory, recommend at least 128MB memory allocation
3. Check session logs: `docker exec [container-name] cat /var/log/xrdp-sesman.log`

### Chinese display garbled
The image already has Chinese locale and fonts pre-installed, garbled characters usually don't occur. If there are issues, check your RDP client encoding settings, make sure UTF-8 is used.

### Desktop icons not showing
1. Confirm PCManFM process is running normally
2. Check configuration file: Make sure `show_icons` is set to 1 in `~/.config/pcmanfm/default/pcmanfm.conf`