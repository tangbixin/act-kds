#!/bin/bash
shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))
bash $SHELL_FOLDER/../common/kernel_5.15.sh
echo "kernel_5.15.sh执行完成！！！！！"

echo "[log]10当前目录"
pwd




# 远程仓库 URL 和分支名
REPO_URL="https://github.com/tangbixin/boos0629.git"
BRANCH="master"

# 要下载的特定目录列表
TARGET_PATHS=(
  "package/boot/uboot-envtools"
  "package/firmware/ipq-wifi"
  "package/firmware/ath11k-board"
  "package/firmware/ath11k-firmware"
  "package/qca"
  "package/qat"
  "package/kernel/mac80211"
  "target/linux/generic/hack-5.15"
  "target/linux/generic/pending-5.15"
  "target/linux/ipq807x"
)

# 初始化一个临时目录
TEMP_DIR=$(mktemp -d)
echo "临时目录: $TEMP_DIR"

# 克隆仓库到临时目录
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR"

# 在当前目录拉取指定的文件或目录
for path in "${TARGET_PATHS[@]}"; do
  echo "正在覆盖文件或目录: $path"
  mkdir -p "$(dirname "$path")"  # 创建本地目录
  cp -r "$TEMP_DIR/$path" "$path" || echo "拉取失败: $path"
done

# 删除临时目录
rm -rf "$TEMP_DIR"
echo "操作完成！"





echo "[log]稀疏检出后，当前下载的目录"

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

echo "kidden9"
pwd
ls feeds/
