FROM ubuntu:24.04

ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

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
    xterm \
    locales \
    fonts-wqy-microhei \
    tzdata \
    sudo \
    xserver-xorg-core \
    xserver-xorg-video-dummy \
    xorgxrdp \
    dbus-x11 \
    && \
    # 系统配置
    sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen --no-archive && \
    update-locale LANG=zh_CN.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/' /etc/pam.d/xrdp-sesman && \
    # xrdp配置
    mkdir -p /var/run/dbus && \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config && \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
    echo "openbox-session" > /etc/skel/.Xsession && \
    echo "openbox-session" > /etc/X11/Xsession && \
    # 缩小locale文件大小
    rm -rf /usr/lib/locale/locale-archive && \
    localedef -i zh_CN -c -f UTF-8 zh_CN.UTF-8 && \
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

# 复制并配置启动脚本（放在清理之前，确保脚本不会被清理）
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh && \
    sed -i 's/\r$//' /usr/bin/run.sh && \
    # 最终清理
    rm -rf /var/cache/apt/archives/* \
           /usr/share/icons/* \
           /usr/share/sounds/* \
           /usr/share/themes/*

EXPOSE 3389
ENTRYPOINT ["/usr/bin/run.sh"]
