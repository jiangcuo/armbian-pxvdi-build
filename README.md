# PXVDI 嵌入式瘦客户端构建项目

基于 [Armbian build framework](https://github.com/armbian/build) 定制的 **PXVDI 云桌面瘦客户端** 镜像构建项目。

烧录产出的 `.img` 即可获得一台开机自动登录、自动启动 PXVDI 客户端、即插即用的瘦客户机设备。

目前arm 仅支持 freerdp、spice、pxvdi 3种连接方式，moonlight还未适配。

## 硬件要求

当前硬件加速**仅支持 Rockchip 平台**，并要求：

- **CPU**：四核及以上 ARMv8 (aarch64)
- **解码器**：实验性支持 rockchip mpp硬件加速
- **内存**：≥ 1 GB（推荐 ≥ 2 GB）
- **存储**：≥ 8 GB（eMMC / SD / NVMe）

不满足以上条件的板子（例如 RK3308 / RV1106 / 单核 IoT 类 SoC）无法运行 PXVDI 客户端。

如果不需要硬件加速，纯靠cpu 算力，那么直接使用即可。


## 理论上已支持的 Rockchip 板子

### RK3588 / RK3588S  性能说明： pxvdi 60fps / RDP 60fps

| 板子 | BOARD 参数 | BRANCH |
|------|-----------|--------|
| Radxa Rock 5B | `rock-5b` | current / vendor |
| Radxa Rock 5B Plus | `rock-5b-plus` | current / vendor |
| Radxa Rock 5A | `rock-5a` | current / vendor |
| Radxa Rock 5C | `rock-5c` | current |
| Radxa Rock 5T | `rock-5t` | current |
| Rock 5 ITX | `rock-5-itx` | current |
| Orange Pi 5 | `orangepi5` | current / vendor |
| Orange Pi 5 Plus | `orangepi5-plus` | current / vendor |
| Orange Pi 5 Pro | `orangepi5pro` | vendor |
| Orange Pi 5 Max | `orangepi5-max` | current |
| Orange Pi 5 Ultra | `orangepi5-ultra` | current |
| Orange Pi 5B | `orangepi5b` | vendor |
| NanoPC T6 / T6 LTS | `nanopct6` / `nanopct6-lts` | current |
| NanoPi M6 | `nanopi-m6` | current |
| NanoPi R6S / R6C | `nanopi-r6s` / `nanopi-r6c` | current |
| Khadas Edge2 | `khadas-edge2` | current / vendor |
| Radxa CM5 IO / CM5 | `radxa-cm5-io` / `rock-5-cmio` | current |
| FriendlyElec CM3588 NAS | `cm3588-nas` | current |
| ArmSoM Sige7 / W3 / AIM7 IO | `armsom-sige7` / `armsom-w3` / `armsom-aim7-io` | vendor |
| Banana Pi M7 | `bananapim7` | current |
| Indiedroid Nova | `indiedroid-nova` | current |
| Mixtile Blade3 / Core3588E | `mixtile-blade3` / `mixtile-core3588e` | current |
| Turing RK1 | `turing-rk1` | current |
| Hinlink H88K | `hinlink-h88k` | current |
| Firefly ITX-3588J | `firefly-itx-3588j` | current |
| FxBlox RK1 | `fxblox-rk1` | current |
| CoolPi CM5 / GenBook | `coolpi-cm5` / `coolpi-genbook` | current |
| IMB3588 | `imb3588` | vendor |
| Station M3 | `station-m3` | current |
| Mekotronics R58 系列 | `mekotronics-r58x` 等 | current |

### RK3568 / RK3566（4 核 Mali-G52）

| 板子 | BOARD 参数 |
|------|-----------|
| Radxa Rock 3A | `rock-3a` |
| Radxa Rock 3C | `rock-3c` |
| Odroid M1 | `odroidm1` |
| Odroid M1S | `odroidm1s` |
| NanoPi R5S / R5C | `nanopi-r5s` / `nanopi-r5c` |
| Banana Pi R2 Pro | `bananapir2pro` |
| Banana Pi CM4 IO | `bananapicm4io` |
| BigTreeTech CB2 | `bigtreetech-cb2` |
| Quartz64 A / B | `quartz64a` / `quartz64b` |
| Orange Pi 3B | `orangepi3b` |
| 9Tripod X3568 v4 | `9tripod-x3568-v4` |
| LubanCat 2 | `lubancat2` |

### RK3528（4 核 Mali-450） 性能说明：建议配置为30fps

| 板子 | BOARD 参数 |
|------|-----------|
| Radxa Rock 2A | `rock-2a` |
| Radxa Rock 2F | `rock-2f` |
| Hinlink H28K | `hinlink-h28k` |

### RK3399 / RK3399Pro（6 核大小核 Mali-T860）

| 板子 | BOARD 参数 |
|------|-----------|
| RockPi 4 A/B/B+/C/C+ | `rockpi-4a` / `rockpi-4b` 等 |
| RockPro 64 | `rockpro64` |
| Pinebook Pro | `pinebook-pro` |
| NanoPC T4 | `nanopct4` |
| NanoPi M4 / M4V2 | `nanopim4` / `nanopim4v2` |
| NanoPi R4S / R4SE | `nanopi-r4s` / `nanopi-r4se` |
| Orange Pi 4 / 4 LTS | `orangepi4` / `orangepi4-lts` |
| Khadas Edge | `khadas-edge` |
| Tinker Edge R | `tinker-edge-r` |
| Tinker Board 2 | `tinkerboard-2` |
| Station P1 / M1 | `station-p1` / `station-m1` |
| Helios64 | `helios64` |
| Firefly RK3399 | `firefly-rk3399` |
| Renegade Elite | `roc-rk3399-pc` |

### RK3328 性能说明：建议配置为30fps

| 板子 | BOARD 参数 |
|------|-----------|
| RockPi E | `rockpi-e` |
| Renegade | `renegade` |
| Rock 64 | `rock64` |
| NanoPi R2S / R2S Plus / R2C | `nanopi-r2s` 等 |
| Orange Pi R1 Plus / LTS | `orangepi-r1plus` / `orangepi-r1plus-lts` |

> 完整板子列表见 `config/boards/`，文件名（去掉后缀）就是 `BOARD=` 参数。后缀 `.conf` 为 STABLE，`.csc` 为社区维护，`.tvb` 为电视盒子（不推荐用于瘦客户机）。

## 自动构建

fork 本项目，然后去ci里面，使用pxvdi-build 填写自己的板子和内核。

## 手动构建
Linux 上的依赖

```bash
sudo apt-get install -y git docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER  # 需要重新登录
```

## 构建命令
如果要改成自己的，把下面命令改成 BOARD=nanopct4 这样

以 Radxa Rock 2F 为例：

```bash

# Linux
sudo ./compile.sh \
    BOARD=rock-2f \
    BRANCH=vendor \
    RELEASE=trixie \
    BUILD_MINIMAL=yes \
    BUILD_DESKTOP=no \
    KERNEL_CONFIGURE=no \
    SHARE_LOG=yes
```

### 构建参数说明

| 参数 | 含义 | 推荐值 |
|------|------|--------|
| `BOARD` | 板子名（见上方表格） | 必填 |
| `BRANCH` | 内核分支：`current` / `edge` / `vendor` | RK3528/RK3576 用 `vendor`，其他用 `current` |

其他均不可以改动！

### 切换板子

构建命令完全一致，只换 `BOARD=`：

```bash
# Rock 5B
sudo ./compile.sh BOARD=rock-5b BRANCH=current RELEASE=trixie BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_CONFIGURE=no

# Orange Pi 5
sudo ./compile.sh BOARD=orangepi5 BRANCH=current RELEASE=trixie BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_CONFIGURE=no

# Khadas Edge2
sudo ./compile.sh BOARD=khadas-edge2 BRANCH=current RELEASE=trixie BUILD_MINIMAL=yes BUILD_DESKTOP=no KERNEL_CONFIGURE=no
```

## 构建产物

```
output/images/
├── Armbian-unofficial_<version>_<Board>_trixie_<branch>_<kernel>_minimal.img
├── ...img.sha
└── ...img.txt
```

镜像约 **4 GB**，烧到 SD / eMMC / NVMe 后**首次开机会自动扩展 rootfs 到整盘**。

### 烧录

```bash
# Linux / macOS
sudo dd if=output/images/Armbian-unofficial_*_minimal.img \
       of=/dev/sdX bs=4M status=progress conv=fsync

# 推荐 GUI 工具
# - Balena Etcher
# - Raspberry Pi Imager
# - Rockchip RKDevTool（直刷 eMMC）
```

## 自定义

构建框架的所有 PXVDI 定制都在 [`pxvdi/`](pxvdi/) 下：

```
pxvdi/
├── customize-image.sh           # 主定制脚本（在 chroot 里跑）
└── overlay/                     # 自动 bind-mount 到 /tmp/overlay
    ├── bin/                     # → /usr/bin/
    │   ├── langsetting
    ├── openbox/                 # → /etc/xdg/openbox/ 和 /root/.config/openbox/
    │   ├── autostart
    │   ├── menu.xml
    │   ├── menu-en.xml
    │   ├── menu-jp.xml
    │   ├── menu-zh.xml
    │   └── rc.xml
    ├── config/                  # → /root/.lierfang/
    │   ├── pxvdithinclientconfig.json
    │   └── pxvdistream.conf
    └── wallpaper/
        └── bizhi.jpg            # → /usr/share/bizhi.jpg
```

修改对应文件即可，不需要动 `customize-image.sh`。

### 改默认壁纸

替换 `pxvdi/overlay/wallpaper/bizhi.jpg` 即可。

```bash
cp /path/to/your-wallpaper.jpg pxvdi/overlay/wallpaper/bizhi.jpg
```

要求：JPG 格式（必须叫 `bizhi.jpg`），分辨率建议 1920×1080 或更高，文件 < 5 MB。

### 改默认 PXVDI 配置

PXVDI 客户端有两个配置文件：

配置文件的含义请前往https://docs.pxvdi.lierfang.com/client/ThinClient.html

#### 1. `pxvdithinclientconfig.json` —— PXVDI 主连接配置

文件：`pxvdi/overlay/config/pxvdithinclientconfig.json`
镜像内路径：`/root/.lierfang/pxvdithinclientconfig.json`

#### 2. `pxvdistream.conf` —— PXVDI 流媒体后端配置

文件：`pxvdi/overlay/config/pxvdistream.conf`
镜像内路径：`/root/.lierfang/pxvdistream.conf`

## 缓存与速度

- **第一次构建**：拉取 Docker 镜像 + 下载 deb + debootstrap + 跑 customize，约 **30–60 分钟**
- **第二次起**：rootfs / 内核 / U-Boot 全部走缓存，**约 5 分钟**
- **换 BOARD（同 SoC family）**：U-Boot 重下，rootfs 复用，**约 10 分钟**

强制清缓存重新构建：

```bash
rm -rf cache/ output/
```

## 反馈与问题

构建失败、特定板子无法启动、PXVDI 客户端报错等问题，请提交 Issue：

- 描述使用的 `BOARD=` `BRANCH=` `RELEASE=` 参数
- 附上 `output/logs/log-build-*.log.ans` 的关键片段
- 如果 `SHARE_LOG=yes`，附上自动上传的 paste.armbian.com URL
- 注明 host 系统（macOS / Ubuntu / 其他）

## 许可证

构建框架沿用 [Armbian 上游 GPL-2.0](LICENSE)。
PXVDI构建配置 使用AGPL 3.0