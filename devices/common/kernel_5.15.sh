#!/bin/bash

echo '进入 kernel_5.15.sh'

rm -rf target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk}

# 获取 latest commit hash
latest="$(curl -sfL https://github.com/openwrt/openwrt/commits/master/include | grep -o 'href=".*>kernel: bump 5.15' | head -1 | cut -d / -f 5 | cut -d '"' -f 1)"
mkdir new; cp -rf .git new/.git
echo 'bixyn latest------------'
echo $latest
latest='f1cd14448221d6114c6c150a8e78fa360bbb47dd'
echo "强制指定为 https://github.com/openwrt/openwrt/commit/f1cd14448221d6114c6c150a8e78fa360bbb47dd"

# 进入 new 目录
echo "[LOG] 尝试进入目录 'new'"
cd new || { echo "[ERROR] 无法进入目录 'new'，请检查目录是否存在"; exit 1; }

# 使用 latest 或切换到 origin/master
if [ "$latest" ]; then
    echo "[LOG] 执行 git reset --hard，使用哈希值: $latest"
    git reset --hard "$latest" || { echo "[ERROR] git reset --hard $latest 失败"; exit 1; }
else
    echo "[LOG] 执行 git reset --hard origin/master"
    git reset --hard origin/master || { echo "[ERROR] git reset --hard origin/master 失败"; exit 1; }
fi

# 切换到前一个提交
echo "[LOG] 执行 git checkout HEAD^ 切换到前一个提交"
git checkout HEAD^ || { echo "[ERROR] git checkout HEAD^ 失败"; exit 1; }

# 检查是否匹配 "kernel: bump 5.15"，如果匹配则切回 latest
echo "[LOG] 检查当前提交是否包含 'kernel: bump 5.15'"
if [ "$(echo $(git log -1 --pretty=short) | grep 'kernel: bump 5.15')" ]; then
    echo "[LOG] 匹配到 'kernel: bump 5.15'，切换回 latest: $latest"
    git checkout "$latest" || { echo "[ERROR] git checkout $latest 失败"; exit 1; }
ee
    echo "[LOG] 未匹配到 'kernel: bump 5.15'"
fi

# 复制指定目录和文件
echo "[LOG] 开始复制目标文件和目录到上一级"
cp -rf --parents target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk} ../ || {
    echo "[ERROR] 文件或目录复制失败"; exit 1;
}
echo "[LOG] 文件和目录复制成功 使用 curl 下载了 package/kernel/linux/modules/video.mk"


echo "[LOG] 1当前目录结构："
pwd
ls

# 返回上一级目录
echo "[LOG] 返回上一级目录"
cd - || { echo "[ERROR] 无法返回上一级目录"; exit 1; }
echo "[LOG] 1.5当前目录结构："
pwd
ls


# 获取 kernel_v 版本号
kernel_v="$(cat include/kernel-5.15 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo 'bixyn kernel_v------------'
echo $kernel_v

echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/.*'?targets/%S/$kernel_v'?" include/feeds.mk

rm -rf target/linux/generic/pending-5.15/444-mtd-nand-rawnand-add-support-for-Toshiba-TC58NVG0S3H.patch

sh -c "curl -sfL https://github.com/coolsnowwolf/lede/commit/06fcdca1bb9c6de6ccd0450a042349892b372220.patch | patch -d './' -p1 --forward"

# 下载 feeds/packages/kernel
echo "[LOG] 下载 feeds/packages/kernel"
rm -rf feeds/packages/kernel
mkdir -p feeds/packages && cd feeds/packages
git init kernel && cd kernel
git remote add origin https://github.com/openwrt/packages.git
git sparse-checkout set --cone kernel
git pull --depth=1 origin master
cd ../../../


echo "[LOG] 2当前目录结构："
pwd
ls

# 下载 feeds/packages/net/xtables-addons
echo "[LOG] 下载 feeds/packages/net/xtables-addons"
rm -rf feeds/packages/net/xtables-addons
mkdir -p feeds/packages/net && cd feeds/packages/net
git init xtables-addons && cd xtables-addons
git remote add origin https://github.com/openwrt/packages.git
git sparse-checkout set --cone net/xtables-addons
git pull --depth=1 origin master
cd ../../../../


echo "[LOG] 3当前目录结构："
pwd
ls

# 下载 target/linux/generic/hack-5.15
echo "[LOG] 下载 target/linux/generic/hack-5.15"
rm -rf target/linux/generic/hack-5.15
mkdir -p target/linux/generic && cd target/linux/generic
git init hack-5.15 && cd hack-5.15
git remote add origin https://github.com/coolsnowwolf/lede.git
git sparse-checkout set --cone target/linux/generic/hack-5.15
git pull --depth=1 origin master
cd ../../../../


echo "[LOG] 4当前目录结构："
pwd
ls

echo "[LOG] 下载完成"

rm -rf target/linux/generic/hack-5.15/{220-gc_sections*,781-dsa-register*,780-drivers-net*}
curl -sfL https://raw.githubusercontent.com/openwrt/openwrt/openwrt-22.03/package/kernel/linux/modules/video.mk -o package/kernel/linux/modules/video.mk


echo "[LOG] 5当前目录结构："
pwd
ls

echo "[LOG] 6   target/linux/目录结构："
ls target/linux/

sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

echo "
CONFIG_TESTING_KERNEL=y
CONFIG_PACKAGE_kmod-ipt-coova=n
CONFIG_PACKAGE_kmod-usb-serial-xr_usb_serial_common=n
CONFIG_PACKAGE_kmod-pf-ring=n
" >> devices/common/.config


echo "kidden9"
pwd
ls feeds/
