#!/bin/bash

echo 'tbxbixyn kernel_5.15.sh'

rm -rf target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk}
latest="$(curl -sfL https://github.com/openwrt/openwrt/commits/master/include | grep -o 'href=".*>kernel: bump 5.15' | head -1 | cut -d / -f 5 | cut -d '"' -f 1)"
mkdir new; cp -rf .git new/.git
echo 'bixyn latest------------'
echo $latest
latest='f1cd14448221d6114c6c150a8e78fa360bbb47dd'














#!/bin/bash

# 进入 new 目录
echo "[LOG] 尝试进入目录 'new'"
cd new || { echo "[ERROR] 无法进入目录 'new'，请检查目录是否存在"; exit 1; }

# 显示 latest 的值
echo "[LOG] latest 的值为: $latest"

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
else
    echo "[LOG] 未匹配到 'kernel: bump 5.15'"
fi

# 复制指定目录和文件
echo "[LOG] 开始复制目标文件和目录到上一级"
cp -rf --parents target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk} ../ || {
    echo "[ERROR] 文件或目录复制失败"; exit 1;
}
echo "[LOG] 文件和目录复制成功"

# 返回上一级目录
echo "[LOG] 返回上一级目录"
cd - || { echo "[ERROR] 无法返回上一级目录"; exit 1; }

















kernel_v="$(cat include/kernel-5.15 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo 'bixyn kernel_v------------'
echo $kernel_v

echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/.*'?targets/%S/$kernel_v'?" include/feeds.mk

rm -rf target/linux/generic/pending-5.15/444-mtd-nand-rawnand-add-support-for-Toshiba-TC58NVG0S3H.patch

sh -c "curl -sfL https://github.com/coolsnowwolf/lede/commit/06fcdca1bb9c6de6ccd0450a042349892b372220.patch | patch -d './' -p1 --forward"

git clone --depth=1 --single-branch --branch "main" https://github.com/openwrt/packages.git feeds/packages/kernel
git clone --depth=1 --single-branch --branch "main" https://github.com/openwrt/packages.git feeds/packages/net/xtables-addons
git clone --depth=1 --single-branch --branch "main" https://github.com/coolsnowwolf/lede.git target/linux/generic/hack-5.15



# 克隆前清理现有目录
rm -rf feeds/packages target/linux/generic








rm -rf target/linux/generic/hack-5.15/{220-gc_sections*,781-dsa-register*,780-drivers-net*}
curl -sfL https://raw.githubusercontent.com/openwrt/openwrt/openwrt-22.03/package/kernel/linux/modules/video.mk -o package/kernel/linux/modules/video.mk

sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

echo "
CONFIG_TESTING_KERNEL=y
CONFIG_PACKAGE_kmod-ipt-coova=n
CONFIG_PACKAGE_kmod-usb-serial-xr_usb_serial_common=n
CONFIG_PACKAGE_kmod-pf-ring=n
" >> devices/common/.config
