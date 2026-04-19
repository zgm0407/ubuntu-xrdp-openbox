#!/bin/bash

start_xrdp_services() {
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid
    xrdp-sesman && exec xrdp -n
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

echo Entryponit script is Running...
echo

users=$(($#/3))
mod=$(($# % 3))

if [[ $# -eq 0 ]]; then
    echo "No input parameters. exiting..."
    echo "there should be 3 input parameters per user"
    exit
fi

if [[ $mod -ne 0 ]]; then
    echo "incorrect input. exiting..."
    echo "there should be 3 input parameters per user"
    exit 1
fi
echo "You entered $users users"

while [ $# -ne 0 ]; do
    addgroup $1
    useradd -m -s /bin/bash -g $1 $1
    echo $1:$2 | chpasswd
    if [[ $3 == "yes" ]]; then
        usermod -aG sudo $1
        echo "$1 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    echo "user '$1' is added"
    # 同步桌面配置到用户目录（--update=none参数不覆盖已存在的文件，保护用户自定义配置）
    cp -r --update=none /etc/skel/. /home/$1/ && chown -R $1:$1 /home/$1/
    shift 3
done

echo -e "This script is ended\n"
echo -e "starting xrdp services...\n"

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services
