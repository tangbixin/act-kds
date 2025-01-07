#!/bin/bash
#=================================================
echo
echo
echo
echo
echo
echo "common diy.................................."

shopt -s extglob

# 打印当前时间和 kernel 版本信息
kernel_v="$(cat include/kernel-5.10 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/packages?targets/%S/$kernel_v?" include/feeds.mk

# 打印版本时间
echo "$(date +"%s")" >version.date
sed -i '/$(curdir)\/compile:/c\$(curdir)/compile: package/opkg/host/compile' package/Makefile
sed -i "s/DEFAULT_PACKAGES:=/DEFAULT_PACKAGES:=luci-app-advanced luci-app-firewall luci-app-opkg luci-app-upnp luci-app-autoreboot \
luci-app-wizard luci-base luci-compat luci-lib-ipkg luci-lib-fs \
coremark wget-ssl curl htop nano zram-swap kmod-lib-zstd kmod-tcp-bbr bash openssh-sftp-server /" include/target.mk
sed -i "s/procd-ujail//" include/target.mk

sed -i '/	refresh_config();/d' scripts/feeds
[ ! -f feeds.conf ] && {
    echo "添加 kiddin9 feed 到 feeds.conf.default"
    sed -i '$a src-git kiddin9 https://github.com/kiddin9/openwrt.git;master' feeds.conf.default
}

# 清理缓存
echo "清理旧的 feed 缓存"
rm -rf feeds/

# 打印 feeds.conf 内容进行调试
echo "当前 feeds.conf.default 内容:"
cat feeds.conf.default

# 更新和安装 feeds
./scripts/feeds update -a
./scripts/feeds install -a -p kiddin9 -f
./scripts/feeds install -a

echo "kidden9-111"
pwd
ls feeds/
echo "------------------------------------------"

# 更新 kiddin9 feed
echo "更新 kiddin9 feed"
cd feeds/kiddin9; git pull; cd -

mv -f feeds/kiddin9/r81* tmp/

sed -i "s/192.168.1/10.0.0/" package/feeds/kiddin9/base-files/files/bin/config_generate

(

# 克隆 lede 仓库并设置 sparse-checkout
echo "克隆 lede 仓库"
git clone --depth=1 --filter=blob:none --sparse https://github.com/coolsnowwolf/lede.git
cd lede
git sparse-checkout set tools/upx
cd - 
git clone --depth=1 --filter=blob:none --sparse https://github.com/coolsnowwolf/lede.git
cd lede
git sparse-checkout set tools/ucl
cd - 
git clone --depth=1 --filter=blob:none --sparse https://github.com/coolsnowwolf/lede.git
cd lede
git sparse-checkout set target/linux/generic/hack-5.10
cd -

rm -rf target/linux/generic/hack-5.10/{220-gc_sections*,781-dsa-register*,780-drivers-net*}
) &

# 配置编译选项
sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
sed -i 's/\/cgi-bin\/\(luci\|cgi-\)/\/\1/g' `find package/feeds/kiddin9/luci-*/ -name "*.lua" -or -name "*.htm*" -or -name "*.js"` &
sed -i 's/Os/O2/g' include/target.mk
sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite --force-maintainer --force-depends/' package/Makefile
sed -i "/mediaurlbase/d" package/feeds/*/luci-theme*/root/etc/uci-defaults/*
sed -i 's/=bbr/=cubic/' package/kernel/linux/files/sysctl-tcp-bbr.conf

# 设置内核配置
sed -i '$a CONFIG_ACPI=y\nCONFIG_X86_ACPI_CPUFREQ=y\nCONFIG_NR_CPUS=128\nCONFIG_FAT_DEFAULT_IOCHARSET="utf8"\nCONFIG_CRYPTO_CHACHA20_NEON=y\n \
CONFIG_CRYPTO_CHACHA20POLY1305=y\nCONFIG_BINFMT_MISC=y' `find target/linux -path "target/linux/*/config-*"`
sed -i 's/max_requests 3/max_requests 20/g' package/network/services/uhttpd/files/uhttpd.config
#rm -rf ./feeds/packages/lang/{golang,node}
sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

# 更新版本信息
date=`date +%m.%d.%Y`
sed -i -e "/\(# \)\?REVISION:=/c\REVISION:=$date" -e '/VERSION_CODE:=/c\VERSION_CODE:=$(REVISION)' include/version.mk

# 更新 Python 版本
sed -i \
	-e 's/+python\( \|$\)/+python3/' \
	-e 's?../../lang?$(TOPDIR)/feeds/packages/lang?' \
	package/feeds/kiddin9/*/Makefile

(
if [ -f sdk.tar.xz ]; then
    sed -i 's,$(STAGING_DIR_HOST)/bin/upx,upx,' package/feeds/kiddin9/*/Makefile
    mkdir sdk
    tar -xJf sdk.tar.xz -C sdk
    cp -rf sdk/*/staging_dir/* ./staging_dir/
    rm -rf sdk.tar.xz sdk
    sed -i '/\(tools\|toolchain\)\/Makefile/d' Makefile
    if [ -f /usr/bin/python ]; then
        ln -sf /usr/bin/python staging_dir/host/bin/python
    else
        ln -sf /usr/bin/python3 staging_dir/host/bin/python
    fi
    ln -sf /usr/bin/python3 staging_dir/host/bin/python3
fi
) &

echo "kidden9-2"
pwd
ls feeds/
