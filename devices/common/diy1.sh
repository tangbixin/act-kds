#!/bin/bash
#=================================================
echo "bixyn diy1.sh.............................."
sed -i "s/10.0.0/192.168.31/" package/feeds/kiddin9/base-files/files/bin/config_generate
# cat feeds/kiddin9/base-files/files/etc/openwrt_release
# sed -i 's/'"'"/'/g' feeds/kiddin9/base-files/files/etc/openwrt_release
pwd
ls -l
cat feeds/kiddin9/base-files/files/etc/openwrt_release
echo 'tbx tag......................'
TAG=`cat tbx.tag`
echo $TAG
sed -i 's/by Kiddin/'$TAG' by tangbixin/g' feeds/kiddin9/base-files/files/etc/openwrt_release
echo "---openwrt_release----------------"
cat feeds/kiddin9/base-files/files/etc/openwrt_release
echo "--edit links.htm-----------------"
sed -i 's/"https:\/\/supes.top\/"/"https:\/\/www.google.com\/"/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/"https:\/\/supes.top\/fadian\/"/"https:\/\/www.baidu.com\/"/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/"https:\/\/t.me\/opwrt"/"https:\/\/www.youtube.com\/"/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/"https:\/\/github.com\/kiddin9\/OpenWrt_x86-r2s-r4s"/"https:\/\/github.com\/tangbixin\/act-kd"/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/固件下载与定制/谷歌/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/赞助/百度/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/TG频道/油管/' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/与反馈//' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
sed -i 's/ style="color:orangered"//' feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm
cat feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm

echo '-----清空links.htm----------------'
echo ''>feeds/kiddin9/my-default-settings/files/usr/lib/lua/luci/view/admin_status/index/links.htm



#其他软件包安装，可以指定版本指定目录（经验证clash出问题）
##svn是分支类别+分支名，例如trunk、branches/2.x、tags/2.0。
# git clone https://github.com/vernesong/OpenClash.git package/OpenClash
# svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
########## svn co https://github.com/vernesong/OpenClash/tags/v0.45.22-beta/luci-app-openclash  package/luci-app-openclash
#删除重复的软件包
########## rm -rf feeds/kiddin9/luci-app-openclash
#rm -rf feeds/kiddin9/luci-app-opkg
#svn co https://github.com/openwrt/luci/branches/openwrt-22.03/applications/luci-app-opkg package/luci-app-opkg

