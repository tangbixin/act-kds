#!/bin/bash
#=================================================
echo
echo
echo
echo
echo
echo "common diy.................................."

# 检查并清理旧的 feeds 缓存
echo "清理旧的 feed 缓存"
if [ -f "./feeds.conf.default" ]; then
    echo "当前 feeds.conf.default 内容:"
    cat ./feeds.conf.default
    # 如果发现 feeds.conf.default 中有错误的 kiddin9 地址，修正它
    if grep -q "https://github.com/kiddin9/openwrt-packages.git" ./feeds.conf.default; then
        echo "发现错误的 kiddin9 地址，正在修复..."
        sed -i 's|https://github.com/kiddin9/openwrt-packages.git|https://github.com/kiddin9/openwrt.git|' ./feeds.conf.default
    else
        echo "kiddin9 地址没有问题。"
    fi
else
    echo "feeds.conf.default 文件不存在，正在创建..."
    echo 'src-git kiddin9 https://github.com/kiddin9/openwrt.git;master' > ./feeds.conf.default
fi

# 更新和安装 feeds
echo "更新 feeds"
./scripts/feeds update -a
./scripts/feeds install -a -p kiddin9 -f
./scripts/feeds install -a

echo "kidden9-111"
pwd
ls feeds/
echo "------------------------------------------"

cd feeds/kiddin9; git pull; cd -

mv -f feeds/kiddin9/r81* tmp/

sed -i "s/192.168.1/10.0.0/" package/feeds/kiddin9/base-files/files/bin/config_generate

(
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

sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' tools/Makefile
sed -i 's/\/cgi-bin\/\(luci\|cgi-\)/\/\1/g' `find package/feeds/kiddin9/luci-*/ -name "*.lua" -or -name "*.htm*" -or -name "*.js"` &
sed -i 's/Os/O2/g' include/target.mk
sed -i 's/$(TARGET_DIR)) install/$(TARGET_DIR)) install --force-overwrite --force-maintainer --force-depends/' package/Makefile
sed -i "/mediaurlbase/d" package/feeds/*/luci-theme*/root/etc/uci-defaults/*
sed -i 's/=bbr/=cubic/' package/kernel/linux/files/sysctl-tcp-bbr.conf

# find target/linux/x86 -name "config*" -exec bash -c 'cat kernel.conf >> "{}"' \;
sed -i '$a CONFIG_ACPI=y\nCONFIG_X86_ACPI_CPUFREQ=y\nCONFIG_NR_CPUS=128\nCONFIG_FAT_DEFAULT_IOCHARSET="utf8"\nCONFIG_CRYPTO_CHACHA20_NEON=y\n \
CONFIG_CRYPTO_CHACHA20POLY1305=y\nCONFIG_BINFMT_MISC=y' `find target/linux -path "target/linux/*/config-*"`
sed -i 's/max_requests 3/max_requests 20/g' package/network/services/uhttpd/files/uhttpd.config
#rm -rf ./feeds/packages/lang/{golang,node}
sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

date=`date +%m.%d.%Y`
sed -i -e "/\(# \)\?REVISION:=/c\REVISION:=$date" -e '/VERSION_CODE:=/c\VERSION_CODE:=$(REVISION)' include/version.mk

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
