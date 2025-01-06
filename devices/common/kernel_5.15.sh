#!/bin/bash

echo 'tbxbixyn kernel_5.15.sh'

rm -rf target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk}
latest="$(curl -sfL https://github.com/openwrt/openwrt/commits/master/include | grep -o 'href=".*>kernel: bump 5.15' | head -1 | cut -d / -f 5 | cut -d '"' -f 1)"
mkdir new; cp -rf .git new/.git
echo 'bixyn latest------------'
echo $latest
latest='f1cd14448221d6114c6c150a8e78fa360bbb47dd'



cd new
[ "$latest" ] && git reset --hard $latest || git reset --hard origin/master
git checkout HEAD^
[ "$(echo $(git log -1 --pretty=short) | grep "kernel: bump 5.15")" ] && git checkout $latest
cp -rf --parents target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk} ../
cd -

kernel_v="$(cat include/kernel-5.15 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo 'bixyn kernel_v------------'
echo $kernel_v

echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/.*'?targets/%S/$kernel_v'?" include/feeds.mk

rm -rf target/linux/generic/pending-5.15/444-mtd-nand-rawnand-add-support-for-Toshiba-TC58NVG0S3H.patch

sh -c "curl -sfL https://github.com/coolsnowwolf/lede/commit/06fcdca1bb9c6de6ccd0450a042349892b372220.patch | patch -d './' -p1 --forward"

# 克隆前清理现有目录
rm -rf feeds/packages target/linux/generic
# 克隆并只获取 kernel 和 xtables-addons 目录
git clone --depth=1 --filter=blob:none --sparse https://github.com/openwrt/packages.git
cd packages
git sparse-checkout init --cone
git sparse-checkout set kernel net/xtables-addons
cd ..

# 克隆并只获取 hack-5.15 目录
git clone --depth=1 --filter=blob:none --sparse https://github.com/coolsnowwolf/lede.git
cd lede
git sparse-checkout init --cone
git sparse-checkout set target/linux/generic/hack-5.15
cd ..


rm -rf target/linux/generic/hack-5.15/{220-gc_sections*,781-dsa-register*,780-drivers-net*}
curl -sfL https://raw.githubusercontent.com/openwrt/openwrt/openwrt-22.03/package/kernel/linux/modules/video.mk -o package/kernel/linux/modules/video.mk

sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

echo "
CONFIG_TESTING_KERNEL=y
CONFIG_PACKAGE_kmod-ipt-coova=n
CONFIG_PACKAGE_kmod-usb-serial-xr_usb_serial_common=n
CONFIG_PACKAGE_kmod-pf-ring=n
" >> devices/common/.config
