#!/bin/bash
# ==============================================================================
# 桌面环境配置脚本
# 功能：为xrdp+openbox环境配置完整的桌面体验，包括图标、剪贴板、主题等
# 逻辑分层：1. 系统级配置 -> 2. 全局会话配置 -> 3. 用户模板配置
# ==============================================================================

set -euo pipefail

# ==============================================
# 第一部分：系统级配置（影响所有用户和全局行为）
# ==============================================

# 配置全局X会话启动流程
config_global_xsession() {
    cat > /etc/X11/Xsession << 'EOF'
#!/bin/sh
# 全局X会话启动入口

# 确保D-Bus会话已启动
if test -z "$DBUS_SESSION_BUS_ADDRESS" && type dbus-launch >/dev/null 2>&1; then
    eval `dbus-launch --sh-syntax --exit-with-session`
fi

# 启动PCManFM桌面管理（负责显示桌面图标和背景）
if [ -x /usr/bin/pcmanfm ]; then
    sleep 0.2
    pcmanfm --desktop &
fi

# 等待后台进程启动完成
sleep 0.3

# 启动Openbox窗口管理器
exec openbox-session
EOF
    chmod +x /etc/X11/Xsession
}

# ==============================================
# 第二部分：用户模板配置（/etc/skel，新用户自动继承）
# ==============================================

# 配置桌面快捷方式
config_user_shortcuts() {
    mkdir -p /etc/skel/Desktop

    # 文件管理器快捷方式
    cat > /etc/skel/Desktop/pcmanfm.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=文件管理器
Comment=浏览和管理系统文件
Exec=pcmanfm
Icon=system-file-manager
Terminal=false
Categories=System;FileManager;Utility;
EOF
    chmod +x /etc/skel/Desktop/pcmanfm.desktop

    # 终端快捷方式
    cat > /etc/skel/Desktop/xterm.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=终端
Comment=命令行终端
Exec=xterm
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;Utility;
EOF
    chmod +x /etc/skel/Desktop/xterm.desktop
}

# 配置Openbox用户自动启动项
config_user_openbox() {
    mkdir -p /etc/skel/.config/openbox
    cat > /etc/skel/.config/openbox/autostart << 'EOF'
# Openbox会话自动启动程序
pcmanfm --desktop &  # 启动桌面管理
EOF
    chmod +x /etc/skel/.config/openbox/autostart
}

# 配置PCManFM桌面参数
config_user_pcmanfm() {
    mkdir -p /etc/skel/.config/pcmanfm/default

    cat > /etc/skel/.config/pcmanfm/default/pcmanfm.conf << 'EOF'
[desktop]
wallpaper_mode=color       # 使用纯色背景
wallpaper_common=1         # 所有工作区使用相同背景
show_icons=1               # 显示桌面图标
show_trash=1               # 显示回收站图标
show_home=1                # 显示主目录图标
show_mounts=1              # 显示已挂载的设备图标
icon_size=48               # 图标大小48px
desktop_bg=#2c3e50         # 深蓝色背景
desktop_fg=#ecf0f1         # 浅灰色文字
desktop_shadow=#000000     # 文字阴影
single_click=0             # 双击打开文件
show_documents=0           # 不显示文档文件夹
show_downloads=0           # 不显示下载文件夹
show_music=0               # 不显示音乐文件夹
show_pictures=0            # 不显示图片文件夹
show_videos=0              # 不显示视频文件夹

[behavior]
execution_mode=execute     # 点击可执行文件直接运行，不提示
EOF

    # 配置全局默认参数
    mkdir -p /etc/xdg/pcmanfm/default
    cp /etc/skel/.config/pcmanfm/default/pcmanfm.conf /etc/xdg/pcmanfm/default/

    # 配置GTK图标主题
    mkdir -p /etc/skel/.config/gtk-3.0
    cat > /etc/skel/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-icon-theme-name = Adwaita
gtk-theme-name = Adwaita
gtk-font-name = WenQuanYi Micro Hei 10
EOF

    # 配置libfm：关闭.desktop文件执行提示
    mkdir -p /etc/skel/.config/libfm
    cat > /etc/skel/.config/libfm/libfm.conf << 'EOF'
[config]
quick_exec=1                  # 点击可执行文件直接运行，不提示
EOF
}

# 配置用户环境变量
config_user_environment() {
    cat > /etc/skel/.xsessionrc << 'EOF'
# 用户会话环境变量
export XDG_CONFIG_HOME="$HOME/.config"
export LANG=zh_CN.UTF-8
EOF
}

# ==============================================
# 主执行流程
# ==============================================
main() {
    # 1. 执行系统级配置
    config_global_xsession

    # 2. 执行用户模板配置
    config_user_shortcuts
    config_user_openbox
    config_user_pcmanfm
    config_user_environment

    # 清理工作
    rm -rf /tmp/* /var/tmp/*
}

# 启动主流程
main "$@"
