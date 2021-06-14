#/bin/bash

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
echo
timedatectl set-timezone Asia/Shanghai
if [ "$USER" == "root" ]; then
	echo
	TIME r "请勿使用root用户编译，换一个普通用户吧~~"
	echo
	sleep 3s
	exit 0
fi
echo
if [[ -n "$(ls -A "openwrt/.Lede_core" 2>/dev/null)" ]]; then
          firmware="Lede_source"
          Core=".Lede_core"
	  ZZZ="package/lean/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ -n "$(ls -A "openwrt/.Lienol_core" 2>/dev/null)" ]]; then
          firmware="Lienol_source"
          Core=".Lienol_core"
	  ZZZ="package/default-settings/files/zzz-default-settings"
          OpenWrt_name="19.07"
elif [[ -n "$(ls -A "openwrt/.Project_core" 2>/dev/null)" ]]; then
          firmware="Project_source"
          Core=".Project_core"
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
elif [[ -n "$(ls -A "openwrt/.Spirit_core" 2>/dev/null)" ]]; then
          firmware="Spirit_source"
          Core=".Spirit_core"
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="21.02"
fi
chmod +x openwrt/${Core} && source openwrt/${Core}
if [[ `grep -c "CONFIG_TARGET_x86_64=y" openwrt/.bf_config` -eq '1' ]]; then
          TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" openwrt/.bf_config` -eq '1' ]]; then
          TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" openwrt/.bf_config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          TARGET_PROFILE="armvirt"
fi


TIME g "使用[${firmware}]源码编译[${TARGET_PROFILE}]固件,是否更换源码?"
echo
read -p " [Y/y确认，回车跳过]： " GHYM
case $GHYM in
	[Yy])
		echo "GengGai" > openwrt/GengGai
		bash openwrt/compile.sh
		exit 0
	;;
	*)
		TIME r "您已关闭更换源码编译选项！"
		
	;;
esac
echo
Ubuntu_lv="$(df -h | grep "/dev/mapper/ubuntu--vg-ubuntu--lv" | awk '{print $4}' | awk 'NR==1')"
Ubuntu_kj="${Ubuntu_lv%?}"
echo
if [[ "${Ubuntu_kj}" -lt "20" ]];then
	TIME z "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	TIME r "敬告：可用空间小于[ 20G ]编译容易出错,是否继续?"
	echo
	read -p " [回车退出，Y/y确认继续]： " YN
	case ${YN} in
		[Yy]) 
			TIME g  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
			echo
		;;
		*)
			TIME y  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
			echo ""
			sleep 2s
			exit 0
	esac
fi
echo
echo
TIME g "设置openwrt的IP地址[ 回车默认 $ipdz ]"
echo
read -p " 请输入后台IP地址：" ip
ip=${ip:-"$ipdz"}
TIME y "您的后台地址为：$ip"
sed -i '/ipdz/d' openwrt/$Core
echo "ipdz=$ip" >> openwrt/$Core
echo
echo
TIME g "是否需要选择机型和增删插件?"
echo
read -p " [Y/y确认，回车否定]： " MENU
case $MENU in
	[Yy])
		Menuconfig="YES"
		TIME y "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
	;;
	*)
		TIME r "您已关闭选择机型和增删插件设置！"
	;;
esac
echo
echo
TIME g "是否把定时更新插件编译进固件?"
echo
read -p " [Y/y确认，回车否定]： " RELE
case $RELE in
	[Yy])
		REG_UPDATE="true"
		rm -rf openwrt/bin/Firmware
		echo "Compile_Date=$(date +%Y%m%d%H%M)" > openwrt/Openwrt.info
		[ -f openwrt/Openwrt.info ] && . openwrt/Openwrt.info
		
	;;
	*)
		rm -rf bin/Firmware
		TIME r "您已关闭把‘定时更新插件’编译进固件！"
	;;
esac
if [[ "${REG_UPDATE}" == "true" ]]; then
	TIME g "设置Github地址,定时更新固件需要把固件传至对应地址的Releases"
	TIME z "回车默认为：$Git"
	echo
	read -p " 请输入Github地址：" Github
	Github="${Github:-"$Git"}"
	TIME y "您的Github地址为：$Github"
	Apidz="${Github##*com/}"
	Author="${Apidz%/*}"
	CangKu="${Apidz##*/}"
	sed -i '/Git/d' openwrt/$Core
	echo "Git=$Github" >> openwrt/$Core
fi
echo
Begin="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
cp -Rf ./openwrt/{dl,${Core},.bf_config,compile.sh,recompile.sh,Openwrt.info} ./
echo
TIME g "正在下载源码,请耐心等候~~~"
echo
rm -rf openwrt
if [[ $firmware == "Lede_source" ]]; then
          git clone -b master --single-branch https://github.com/coolsnowwolf/lede openwrt
	  echo "Git=$Github" >> openwrt/.Lede_core
elif [[ $firmware == "Lienol_source" ]]; then
          git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
elif [[ $firmware == "Project_source" ]]; then
          git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
elif [[ $firmware == "Spirit_source" ]]; then
          git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
fi
Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"
mv -f {dl,${Core},.bf_config,compile.sh,recompile.sh,Openwrt.info} $Home
echo
TIME g "正在加载自定义设置,请耐心等候~~~"
echo
svn co https://github.com/281677160/AutoBuild-OpenWrt/trunk/build $Home/build
git clone --depth 1 -b main https://github.com/281677160/common $Home/build/common
chmod -R +x $Home/build/common
chmod -R +x $Home/build/${firmware}
source $Home/build/${firmware}/settings.ini
REGULAR_UPDATE="${REG_UPDATE}"
mv -f $Home/build/common/{Convert.sh,recompile.sh,compile.sh} $Home
mv -f $Home/build/common/*.sh ./openwrt/build/${firmware}

cd openwrt
./scripts/feeds update -a
if [[ "${REPO_BRANCH}" == "master" ]]; then
          source build/${firmware}/common.sh && Diy_lede
          cp -Rf build/common/LEDE/files ./
          cp -Rf build/common/LEDE/diy/* ./
	  cp -Rf build/common/LEDE/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          source build/${firmware}/common.sh && Diy_lienol
          cp -Rf build/common/LIENOL/files ./
          cp -Rf build/common/LIENOL/diy/* ./
	  cp -Rf build/common/LIENOL/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
          source build/${firmware}/common.sh && Diy_1806
          cp -Rf build/common/PROJECT/files ./
          cp -Rf build/common/PROJECT/diy/* ./
	  cp -Rf build/common/PROJECT/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
          source build/${firmware}/common.sh && Diy_2102
          cp -Rf build/common/SPIRIT/files ./
          cp -Rf build/common/SPIRIT/diy/* ./
	  cp -Rf build/common/SPIRIT/patches/* "${PATH1}/patches"
fi
source build/${firmware}/common.sh && Diy_all
if [ -n "$(ls -A "build/$firmware/diy" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/files" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A "build/$firmware/patches" 2>/dev/null)" ]; then
          find "build/$firmware/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward"
fi
if [[ "${REPO_BRANCH}" =~ (21.02|openwrt-21.02) ]]; then
          source Convert.sh
fi
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
sed -i "/uci commit fstab/a\uci commit network" $ZZZ
sed -i "/uci commit network/i\uci set network.lan.ipaddr='$ip'" $ZZZ
sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ
echo
sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./feeds/luci/modules/luci-base`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./feeds/luci/applications`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./feeds/luci/applications`
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds install -a
cp -rf .bf_config .config
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
find . -name 'LICENSE' -o -name 'README' -o -name 'README.md' -o -name '*.git*' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'Convert.sh' | xargs -i rm -rf {}
if [ "${Menuconfig}" == "YES" ]; then
          make menuconfig
fi
make defconfig
cp -rf .config .bf_config
if [[ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]]; then
          TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]]; then
          TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
echo
TIME l "*****10秒后开始下载DL文件*****"
echo
TIME y "请留意以下下载是否出现一串白色英文，有就代表下载有错误了！"
echo
TIME y "出现下载有错误的话，你就不需要下一步继续了，Ctrl+C终止重新再来吧，下载有错误是编译不成功的。"
echo
sleep 10s
echo
make -j8 download
echo
TIME l "开始编译固件,预计需要3-4小时,请耐心等待..."
echo
sleep 2s

make -j$(($(nproc)+1)) || make -j1 V=s

if [ "$?" == "0" ]; then
	End="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
	echo
	TIME l "编译完成~~~"
	echo
	TIME g "开始时间：${Begin}"
	echo
	TIME g "结束时间：${End}"
	echo
	TIME l "固件已经存入openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}文件夹中"
	echo
	if [[ "${REGULAR_UPDATE}" == "true" ]]; then
		rm -rf bin/Firmware
		[ -f $Home/Openwrt.info ] && . $Home/Openwrt.info
		source build/${firmware}/upgrade.sh && Diy_Part3
		rm -rf $Home/Openwrt.info
		TIME g "加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
		echo
	fi

else
	echo
	TIME r "编译失败，请再尝试编译~~~"
	echo
fi
