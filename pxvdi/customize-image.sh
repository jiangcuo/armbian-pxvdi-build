#!/bin/bash
#
# Armbian build hook for PXVDI thin-client.
#
# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
# 已在 chroot 内执行：网络通、apt 可用、root 权限。
# host 上 userpatches/overlay 已 bind-mount 到 /tmp/overlay。
#
# 重要差异 vs 原 buildrootfs.sh：
#  1. 不再调用 chroot/debootstrap/grub-mkimage（rootfs 已就绪，bootloader 由 Armbian 处理）
#  2. 不再装 grub-efi-* 和自定义内核（用 Armbian 的 U-Boot + extlinux 链）
#  3. 文件不再用 heredoc 写，改成从 /tmp/overlay 拷过去

set -e

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

OVERLAY=/tmp/overlay

errlog() { echo -e "\033[31m[pxvdi ERROR] $*\033[0m"; exit 1; }
log()    { echo -e "\033[32m[pxvdi] $*\033[0m"; }

# Armbian 调用 customize-image.sh 时， image-late 阶段的 apt sources 还没部署
# (见 lib/functions/main/rootfs-image.sh: customize_image 在 create_sources_list_and_deploy_repo_key "image-late" 之前)
# 所以这里临时写一份 Debian 源，确保 apt install 能用。
ensure_apt_sources() {
    if [ ! -f /etc/apt/sources.list.d/debian.sources ] && \
       [ ! -f /etc/apt/sources.list.d/debian-temp.sources ] && \
       ( [ ! -f /etc/apt/sources.list ] || [ ! -s /etc/apt/sources.list ] ); then
        log "deploying temporary Debian sources for customize-image phase"
        cat > /etc/apt/sources.list.d/debian-temp.sources <<EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: ${RELEASE} ${RELEASE}-updates ${RELEASE}-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://security.debian.org/debian-security
Suites: ${RELEASE}-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    fi
    apt-get update || errlog "apt update failed"
}

# ---- 1. base packages（来自 buildrootfs.sh debian_start 的 apt 列表） ----
install_pxvdi_packages() {
    log "install base packages"

    ensure_apt_sources

    # 区域设置（先 set 再 install locales，避免重复 dpkg-reconfigure）
    echo "locales locales/default_environment_locale select zh_CN.UTF-8" | debconf-set-selections
    echo "locales locales/locales_to_be_generated select en_US.UTF-8 UTF-8, zh_CN.UTF-8 UTF-8" | debconf-set-selections

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        udiskie chrony console-setup zstd gzip bash-completion locales locales-all \
        libmagic1 network-manager-gnome wpagui iw gnome-network-displays \
        xserver-xorg-input-all lightdm network-manager xfonts-intl-chinese \
        virt-viewer openbox xorg pavucontrol pulseaudio \
        feh xfonts-wqy plymouth plymouth-themes plymouth-x11 \
        fonts-noto-cjk gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-ugly \
        gstreamer1.0-plugins-rtp gstreamer1.0-plugins-bad gstreamer1.0-nice initramfs-tools \
        system-config-printer printer-driver-all cups rsync pciutils \
        fcitx5 fcitx5-chinese-addons fcitx5-frontend-all fcitx5-config-qt \
        fcitx5-mozc fcitx5-anthy im-config xterm \
        desktop-base \
        || errlog "base apt install failed"

    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend noninteractive locales
}

# ---- 2. user_set ----
user_set() {
    log "user_set"
    groupadd -f autologin
    groupadd -f nopasswdlogin
    usermod -aG autologin,nopasswdlogin root
    passwd -d root
}

# ---- 3. openbox_config ----
openbox_config() {
    log "openbox_config"
    install -D -m 0644 "$OVERLAY/openbox/autostart"   /etc/xdg/openbox/autostart
    install -D -m 0644 "$OVERLAY/openbox/menu.xml"    /etc/xdg/openbox/menu.xml
    install -D -m 0644 "$OVERLAY/openbox/menu-zh.xml" /etc/xdg/openbox/menu-zh.xml
    install -D -m 0644 "$OVERLAY/openbox/menu-en.xml" /etc/xdg/openbox/menu-en.xml
    install -D -m 0644 "$OVERLAY/openbox/menu-jp.xml" /etc/xdg/openbox/menu-jp.xml
    install -D -m 0644 "$OVERLAY/openbox/rc.xml"      /root/.config/openbox/rc.xml
    install -D -m 0755 "$OVERLAY/bin/langsetting"     /usr/bin/langsetting
}

# ---- 4. lightdm_config ----
lightdm_config() {
    log "lightdm_config"
    cat > /etc/lightdm/lightdm.conf <<'EOF'
[LightDM]

[Seat:*]
autologin-user=root
autologin-user-timeout=0
autologin-session=openbox
xserver-command=X -novtswitch

[XDMCPServer]

[VNCServer]
EOF
    [ -f /etc/pam.d/lightdm-autologin ] && sed -i "/root/d" /etc/pam.d/lightdm-autologin

    cat > /etc/environment <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
EOF
}

# ---- 6. pxvdi deb (apt 仓库) ----
pxvdi_deb() {
    log "pxvdi_deb"
    curl -fL https://mirrors.lierfang.com/pxcloud/lierfang.gpg \
        -o /etc/apt/trusted.gpg.d/lierfang.gpg || errlog "fetch lierfang gpg failed"

    echo "deb https://mirrors.lierfang.com/pxcloud/pxvdi/ $RELEASE main" \
        > /etc/apt/sources.list.d/pxvdi.list

    ensure_apt_sources

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        pxvdi-thin-client pxvdistream \
        freerdp3-x11 freerdp3-sdl freerdp3-wayland \
        pxvdistreamclient pxvdi-theme \
        || errlog "pxvdi apt install failed"

    # Rockchip 平台额外加 gstreamer1.0-rockchip1 + Rockchip 视频/图形加速库（来自 pxvdi 私有源）
    case "$LINUXFAMILY" in
        rockchip*|rk35xx)
            DEBIAN_FRONTEND=noninteractive apt-get install -y \
                gstreamer1.0-rockchip1 \
                librga2 \
                librockchip-mpp1 \
                librockchip-vpu0 \
                || errlog "rockchip accel libs install failed for $LINUXFAMILY"
            ;;
    esac
}

# ---- 6.5. pxvdi runtime env defaults ----
# 写到 /etc/default/pxvdi，由 openbox autostart 在拉起 pxvdi-thin-client
# 之前 source。默认只设 PXVDI_BUFFER_SIZE=4，其它选项注释掉，瘦终端
# 现场调优时把 # 去掉即可。
pxvdi_env() {
    log "pxvdi_env"
    cat > /etc/default/pxvdi <<'EOF'

# 解码缓冲帧数。默认 4 适合多数硬件；
# 低端 CPU / 软解码场景调到 8 可减少卡顿，但会增加延迟。
# PXVDI_BUFFER_SIZE=4

# 开启垂直同步
PXVDI_VSYNC=1

# 强制使用软件编码器（无硬件编码或硬编出问题时启用）。
#FORCE_SOFTWARE=1

export PXVDI_BUFFER_SIZE PXVDI_VSYNC FORCE_SOFTWARE
EOF
    chmod 0644 /etc/default/pxvdi
}

# ---- 7. wallpaper + pxvdi_config ----
pxvdi_config() {
    log "pxvdi_config"
    install -D -m 0644 "$OVERLAY/wallpaper/bizhi.jpg" /usr/share/bizhi.jpg
    echo "pxvdi" > /etc/hostname

    mkdir -p /root/.lierfang/
    [ -f "$OVERLAY/config/pxvdithinclientconfig.json" ] && \
        cp "$OVERLAY/config/pxvdithinclientconfig.json" /root/.lierfang/
    [ -f "$OVERLAY/config/pxvdistream.conf" ] && \
        cp "$OVERLAY/config/pxvdistream.conf" /root/.lierfang/

    if [ -f /usr/share/plymouth/themes/pxvdi/watermark.png ] && \
       [ -d /usr/share/desktop-base/debian-logos ]; then
        cp /usr/share/plymouth/themes/pxvdi/watermark.png \
           /usr/share/desktop-base/debian-logos/logo-text-version-64.png || true
    fi
    if [ -f "$OVERLAY/config/custom.png" ] && \
       [ -d /usr/share/desktop-base/debian-logos ]; then
        cp "$OVERLAY/config/custom.png" \
           /usr/share/desktop-base/debian-logos/logo-text-version-64.png
    fi

    plymouth-set-default-theme -R pxvdi || log "plymouth pxvdi theme not available, skipping"

    mkdir -p /root/.config/pulse
    pxvdistream install ||log "pxvdistream service install failed,skipping"
    systemctl enable pxvdistream || log "pxvdistream service enable failed,skipping"
}

# ---- 8. 去 Armbian 化 ----
deArmbian() {
    log "de-Armbian: 禁用首次运行向导/banner/motd/profile"

    # 禁用 + mask Armbian 自动配置
    # 注意：armbian-resize-filesystem 必须保留，开机首次自动把 rootfs 扩到整盘
    # 如果禁掉它，烧到大容量介质后只能用镜像原本的 ~4GB
    for svc in armbian-firstrun armbian-firstrun-config armbian-firstlogin \
               armbian-zram-config armbian-ramlog \
               armbian-led-state armbian-disk-health armbian-hardware-monitor \
               armbian-hardware-optimize ; do
        systemctl disable "$svc" 2>/dev/null || true
        systemctl mask    "$svc" 2>/dev/null || true
    done

    # MOTD：删除 Armbian banner、系统信息、tips
    rm -f /etc/update-motd.d/*armbian* \
          /etc/update-motd.d/05-motd-news \
          /etc/update-motd.d/10-armbian-header \
          /etc/update-motd.d/30-armbian-sysinfo \
          /etc/update-motd.d/35-armbian-tips \
          /etc/update-motd.d/41-armbian-config

    # profile.d：去掉 Armbian 的环境引入和首登录提示
    rm -f /etc/profile.d/armbian-*.sh \
          /etc/profile.d/check_first_login.sh \
          /etc/profile.d/check_first_login_reboot.sh \
          /etc/profile.d/armbian-check-first-login.sh

    # 不要 Armbian 的 issue / hostname banner
    [ -f /etc/issue.net ] && echo "PXVDI ThinClient \\n \\l" > /etc/issue.net
    [ -f /etc/issue ]     && echo "PXVDI ThinClient \\n \\l" > /etc/issue

    # 改 os-release 让 PRETTY_NAME 不显示 Armbian
    if [ -f /etc/os-release ]; then
        sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="PXVDI ThinClient (based on Debian)"/' /etc/os-release
        sed -i 's/^NAME=.*/NAME="PXVDI"/' /etc/os-release
    fi

    # /etc/armbian-release 是 BSP 脚本运行时的配置（INITRD_ARCH 等），
    # 不能整文件覆盖，否则 99-uboot / armbianmonitor 等会失败。
    # 只追加 / 替换 vendor 标识，保留原有变量。
    if [ -f /etc/armbian-release ]; then
        sed -i 's/^VENDOR=.*/VENDOR="PXVDI"/' /etc/armbian-release
        grep -q '^VENDOR=' /etc/armbian-release || echo 'VENDOR="PXVDI"' >> /etc/armbian-release
        sed -i 's|^VENDORURL=.*|VENDORURL="https://lierfang.com"|' /etc/armbian-release || true
    fi

    # 删除 force-password-change 的 chage 标记（Armbian 默认强制改密）
    rm -f /root/.not_logged_in_yet

    # 关掉强制改密
    chage -d 99999 root || true

    # armbian-config 是 TUI 工具，瘦客户机不需要
    DEBIAN_FRONTEND=noninteractive apt-get purge -y armbian-config armbian-zsh 2>/dev/null || true
}

# ---- 9. cleanup ----
pxvdi_cleanup() {
    log "cleanup"

    # 删掉我们临时部署的 Debian 源（image-late 会写入正式的）
    rm -f /etc/apt/sources.list.d/debian-temp.sources

    apt-get autoremove -y --purge || true
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    rm -rf /var/cache/apt/archives/*.deb

    # 清掉构建期产生的 log
    rm -rf /var/log/*.log /var/log/apt/* /var/log/dpkg.log* 2>/dev/null || true

    # truncate（不能 rm，systemd 还在用）
    : > /var/log/lastlog || true
    : > /var/log/wtmp    || true
}

Main() {
    install_pxvdi_packages
    user_set
    openbox_config
    lightdm_config
    pxvdi_deb
    pxvdi_env
    pxvdi_config
    deArmbian
    pxvdi_cleanup
}

Main "$@"
