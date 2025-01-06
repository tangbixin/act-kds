#!/bin/bash
shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))
bash $SHELL_FOLDER/../common/kernel_5.15.sh

REPO_URL="https://github.com/tangbixin/boos0629.git"
BRANCH="main"

# 克隆仓库到临时目录
TEMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}" "${TEMP_DIR}"

# 函数：复制目录
copy_dir() {
    local src=$1
    local dest=$2
    rm -rf "${dest}"
    cp -r "${TEMP_DIR}/${src}" "${dest}"
}

# 批量复制需要的目录
copy_dir "package/boot/uboot-envtools" "package/boot/uboot-envtools"
copy_dir "package/firmware/ipq-wifi" "package/firmware/ipq-wifi"
copy_dir "package/firmware/ath11k-board" "package/firmware/ath11k-board"
copy_dir "package/firmware/ath11k-firmware" "package/firmware/ath11k-firmware"
copy_dir "package/qca" "package/qca"
copy_dir "package/qat" "package/qat"
copy_dir "package/kernel/mac80211" "package/kernel/mac80211"
copy_dir "target/linux/generic/hack-5.15" "target/linux/generic/hack-5.15"
copy_dir "target/linux/generic/pending-5.15" "target/linux/generic/pending-5.15"
copy_dir "target/linux/ipq807x" "target/linux/ipq807x"

# 清理 .git 文件夹
rm -rf target/linux/ipq807x/.git target/linux/ipq807x/patches-5.15/.git

# 清理临时目录
rm -rf "${TEMP_DIR}"

# 修改 Makefile
sed -i 's/autocore-arm /autocore-arm /' target/linux/ipq807x/Makefile
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-turboacc/' target/linux/ipq807x/Makefile

# 添加配置项
cat <<EOF >> ./target/linux/ipq807x/config-5.15
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SIMD=y
CONFIG_REALTEK_PHY=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
EOF
