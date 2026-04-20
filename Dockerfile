FROM ubuntu:24.04

ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
# 全局locale配置，CTP接口必须GB18030编码
ENV LANG=zh_CN.GB18030
ENV LC_ALL=zh_CN.GB18030
ENV LANGUAGE=zh_CN.GB18030
# 终端编码配置，解决程序输出中文乱码
ENV LC_CTYPE=zh_CN.GB18030
ENV LC_MESSAGES=zh_CN.GB18030
ENV G_FILENAME_ENCODING=GB18030
ENV PYTHONIOENCODING=GB18030

RUN rm -f /etc/apt/sources.list /etc/apt/sources.list.d/* && \
    cat > /etc/apt/sources.list.d/ubuntu.sources <<-'EOF'
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# 安装软件包+配置+清理，合并为单个RUN减少镜像层
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    openbox \
    obconf \
    locales \
    fonts-wqy-microhei \
    tzdata \
    sudo \
    xserver-xorg-core \
    xserver-xorg-video-dummy \
    xorgxrdp \
    dbus-x11 \
    # 桌面环境组件
    pcmanfm \
    # 轻量终端，默认支持中文
    lxterminal \
    && \
    # 系统配置 - 仅使用GB18030编码，满足CTP接口要求
    sed -i 's/# zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/' /etc/locale.gen && \
    locale-gen zh_CN.GB18030 && \
    update-locale LANG=zh_CN.GB18030 LC_ALL=zh_CN.GB18030 LC_CTYPE=zh_CN.GB18030 LC_MESSAGES=zh_CN.GB18030 && \
    # 全局profile配置
    echo 'export LANG=zh_CN.GB18030' >> /etc/profile && \
    echo 'export LC_ALL=zh_CN.GB18030' >> /etc/profile && \
    echo 'export LANGUAGE=zh_CN.GB18030' >> /etc/profile && \
    echo 'export LC_CTYPE=zh_CN.GB18030' >> /etc/profile && \
    echo 'export LC_MESSAGES=zh_CN.GB18030' >> /etc/profile && \
    echo 'export PYTHONIOENCODING=GB18030' >> /etc/profile && \
    echo 'export G_FILENAME_ENCODING=GB18030' >> /etc/profile && \
    # 用户默认配置
    echo 'export LANG=zh_CN.GB18030' >> /etc/skel/.bashrc && \
    echo 'export LC_ALL=zh_CN.GB18030' >> /etc/skel/.bashrc && \
    echo 'export LANGUAGE=zh_CN.GB18030' >> /etc/skel/.bashrc && \
    echo 'export LC_CTYPE=zh_CN.GB18030' >> /etc/skel/.bashrc && \
    echo 'export LC_MESSAGES=zh_CN.GB18030' >> /etc/skel/.bashrc && \
    echo 'export PYTHONIOENCODING=GB18030' >> /etc/skel/.bashrc && \
    echo 'export G_FILENAME_ENCODING=GB18030' >> /etc/skel/.bashrc && \
    # 终端编码配置
    echo 'UTF-8' >> /etc/locale.alias && \
    echo 'GB18030' >> /etc/locale.alias && \
    echo 'LXTerminal*encoding: GB18030' >> /etc/skel/.Xresources && \
    echo 'xterm*encoding: GB18030' >> /etc/skel/.Xresources && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # 修复中文字体缓存
    fc-cache -fv /usr/share/fonts/truetype/wqy/ && \
    # 修复PAM登录问题：在容器环境中pam_loginuid需要设置为optional
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/' /etc/pam.d/common-session && \
    echo "session optional pam_loginuid.so" >> /etc/pam.d/xrdp-sesman && \
    # xrdp配置
    mkdir -p /var/run/dbus && \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config && \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
    echo "openbox-session" > /etc/skel/.Xsession && \
    echo "openbox-session" > /etc/X11/Xsession && \
    # 极致清理
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/locale/* \
        /usr/share/info/* \
        /usr/share/fonts/truetype/dejavu/* \
        /var/cache/*

# 复制桌面配置脚本
COPY setup-desktop.sh /usr/bin/setup-desktop.sh
RUN chmod +x /usr/bin/setup-desktop.sh && \
    sed -i 's/\r$//' /usr/bin/setup-desktop.sh && \
    /usr/bin/setup-desktop.sh

# 复制并配置启动脚本
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh && \
    sed -i 's/\r$//' /usr/bin/run.sh && \
    # 最终清理 - 保留必需的主题和图标
    rm -rf /var/cache/apt/archives/* \
           /usr/share/sounds/*

EXPOSE 3389
ENTRYPOINT ["/usr/bin/run.sh"]
