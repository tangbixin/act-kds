#!/bin/bash
shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))
bash $SHELL_FOLDER/../common/kernel_5.15.sh
echo "kernel_5.15.sh执行完成！！！！！"

echo "[log]10当前目录"
pwd



REPO_URL="https://github.com/tangbixin/boos0629.git"
BRANCH="master"

echo "开始克隆 repository ${REPO_URL} with branch ${BRANCH}"
# 克隆仓库并初始化稀疏检出
git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}"


# 启用稀疏检出
git sparse-checkout init --cone

# 配置要下载的特定目录
git sparse-checkout set package/boot/uboot-envtools
git sparse-checkout set package/firmware/ipq-wifi
git sparse-checkout set package/firmware/ath11k-board
git sparse-checkout set package/firmware/ath11k-firmware
git sparse-checkout set package/qca
git sparse-checkout set package/qat
git sparse-checkout set package/kernel/mac80211
git sparse-checkout set target/linux/generic/hack-5.15
git sparse-checkout set target/linux/generic/pending-5.15
git sparse-checkout set target/linux/ipq807x

# cd -

echo "[log]11当前目录 target/linux/"
pwd
ls target/linux/


# 清理 .git 文件夹
# rm -rf target/linux/ipq807x/.git target/linux/ipq807x/patches-5.15/.git



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
