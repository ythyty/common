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
if [[ -n "$(ls -A "openwrt/GengGai" 2>/dev/null)" ]]; then
	echo
	echo
	TIME z "警告：您确定需要更改源码重新编译?" && read -p " [Y/y确认，回车否定]： " GENG
	case $GENG in
		[Yy])
			echo
			echo="您已确定更改源码,请选择源码继续！"
		;;
		*)
			echo
			rm -rf openwrt/GengGai
			echo="您已放弃更换源码,请输入命令[ bash openwrt/recompile.sh ]继续编译！"
			exit 0
		;;
	esac
fi
if [ -z "$(ls -A "openwrt/recompile.sh" 2>/dev/null)" ]; then
	Apt_get="YES"
fi
rm -Rf openwrt
echo
echo
if [[ "$Apt_get" == "YES" ]]; then
	TIME z "|*******************************************|"
	TIME g "|                                           |"
	TIME r "|     本脚本仅适用于在Ubuntu环境下编译      |"
	TIME g "|                                           |"
	TIME y "|    首次编译,请输入Ubuntu密码继续下一步    |"
	TIME g "|                                           |"
	TIME g "|*******************************************|"
	echo
	echo
	sleep 2s

	sudo apt-get update -y
	sudo apt-get full-upgrade -y
	sudo apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig rsync
	sudo apt-get clean
	sudo timedatectl set-timezone Asia/Shanghai

	clear
	echo
	echo
	TIME g "|*******************************************|"
	TIME z "|                                           |"
	TIME b "|                                           |"
	TIME y "|           基本环境部署完成......          |"
	TIME z "|                                           |"
	TIME g "|                                           |"
	TIME z "|*******************************************|"
	echo
	echo
fi
if [ "$USER" == "root" ]; then
	TIME g "请勿使用root用户编译，换一个普通用户吧~~"
	echo
	sleep 3s
	exit 0
fi

Ubuntu_lv="$(df -h | grep "/dev/mapper/ubuntu--vg-ubuntu--lv" | awk '{print $4}' | awk 'NR==1')"
Ubuntu_kj="${Ubuntu_lv%?}"
if [[ "${Ubuntu_kj}" -lt "30" ]];then
	echo
	TIME z "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	TIME r "敬告：可用空间小于[ 30G ]编译容易出错,是否继续?" && read -p " [回车退出，Y/y确认继续]： " YN
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
TIME l " 1. Lede_source"
echo
TIME l " 2. Lienol_source"
echo
TIME l " 3. Project_source"
echo
TIME l " 4. Spirit_source"
echo
TIME r " 5. 退出编译程序"
echo
echo

while :; do

TIME g "请选择编译源码,输入[ 1、2、3、4、5 ]然后回车确认您的选择！" && read -p " 输入您的选择： " CHOOSE

case $CHOOSE in
	1)
		firmware="Lede_source"
		TIME y "您选择了：$firmware源码"
	break
	;;
	2)
		firmware="Lienol_source"
		TIME y "您选择了：$firmware源码"
	break
	;;
	3)
		firmware="Project_source"
		TIME y "您选择了：$firmware源码"
	break
	;;
	4)
		firmware="Spirit_source"
		TIME y "您选择了：$firmware源码"
	break
	;;
	5)
		rm -rf compile.sh
		TIME r "您选择了退出编译程序"
		exit 0
	;;
esac
done
echo
echo
TIME g "设置openwrt的IP地址[ 不输入IP,直接回车默认 192.168.1.1 ]" && read -p " 请输入后台IP地址：" ip
ip=${ip:-"192.168.1.1"}
TIME y "您的后台地址为：$ip"
echo
echo
TIME g "是否需要选择机型和增删插件?" && read -p " [Y/y确认，回车否定]： " MENU
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
TIME g "是否把定时更新插件编译进固件?"  && read -p " [Y/y确认，回车否定]： " RELE
case $RELE in
	[Yy])
		REG_UPDATE="true"
		echo "Compile_Date=$(date +%Y%m%d%H%M)" > Openwrt.info
		[ -f Openwrt.info ] && . Openwrt.info
		rm -rf openwrt/bin/Firmware
	;;
	*)
		TIME r "您已关闭把‘定时更新插件’编译进固件！"
		Github="https://github.com/281677160/AutoBuild-OpenWrt"
	;;
esac
if [[ "${REG_UPDATE}" == "true" ]]; then
	Git="https://github.com/281677160/AutoBuild-OpenWrt"
	TIME g "设置Github地址,定时更新固件需要把固件传至对应地址的Releases"
	TIME z "回车默认为：$Git"  && read -p " 请输入Github地址：" Github
	Github="${Github:-"$Git"}"
	TIME y "您的Github地址为：$Github"
	Apidz="${Github##*com/}"
	Author="${Apidz%/*}"
	CangKu="${Apidz##*/}"
fi
echo
Begin="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
echo
TIME g "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
          git clone -b master --single-branch https://github.com/coolsnowwolf/lede openwrt
	  ZZZ="package/lean/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
	  echo "ipdz=$ip" > openwrt/.Lede_core
	  echo "Git=$Github" >> openwrt/.Lede_core
elif [[ $firmware == "Lienol_source" ]]; then
          git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
	  ZZZ="package/default-settings/files/zzz-default-settings"
          OpenWrt_name="19.07"
	  echo "ipdz=$ip" > openwrt/.Lienol_core
	  echo "Git=$Github" >> openwrt/.Lienol_core
elif [[ $firmware == "Project_source" ]]; then
          git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="18.06"
	  echo "ipdz=$ip" > openwrt/.Project_core
	  echo "Git=$Github" >> openwrt/.Project_core
elif [[ $firmware == "Spirit_source" ]]; then
          git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	  ZZZ="package/emortal/default-settings/files/zzz-default-settings"
          OpenWrt_name="21.02"
	  echo "ipdz=$ip" > openwrt/.Spirit_core
	  echo "Git=$Github" >> openwrt/.Spirit_core
fi
svn co https://github.com/281677160/AutoBuild-OpenWrt/trunk/build openwrt/build
git clone --depth 1 -b main https://github.com/281677160/common openwrt/build/common
chmod -R +x openwrt/build/common
chmod -R +x openwrt/build/${firmware}
source openwrt/build/${firmware}/settings.ini
REGULAR_UPDATE="${REG_UPDATE}"
Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"

rm -rf compile.sh
mv -f openwrt/build/common/{Convert.sh,recompile.sh,compile.sh} openwrt
mv -f openwrt/build/common/*.sh openwrt/build/${firmware}
echo
TIME g "正在加载自定义文件,请耐心等候~~~"
echo
cd openwrt
./scripts/feeds clean && ./scripts/feeds update -a
if [[ "${REPO_BRANCH}" == "master" ]]; then
          source build/${firmware}/common.sh && Diy_lede
          cp -Rf build/common/LEDE/files ./
          cp -Rf build/common/LEDE/diy/* ./
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          source build/${firmware}/common.sh && Diy_lienol
          cp -Rf build/common/LIENOL/files ./
          cp -Rf build/common/LIENOL/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
          source build/${firmware}/common.sh && Diy_1806
          cp -Rf build/common/PROJECT/files ./
          cp -Rf build/common/PROJECT/diy/* ./
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
          source build/${firmware}/common.sh && Diy_2102
          cp -Rf build/common/SPIRIT/files ./
          cp -Rf build/common/SPIRIT/diy/* ./
fi
source build/$firmware/common.sh && Diy_all
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
cp -rf build/${firmware}/.config .config
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
TIME l "*****5秒后开始下载DL文件*****"
echo
TIME y "你可以随时按 Ctrl+C 强制终止编译"
echo
TIME g "大陆用户编译前请准备好梯子,使用大陆白名单或全局模式"
echo
echo
sleep 3s
TIME g "正在下载DL文件,请耐心等待..."
echo
make -j8 download V=s
echo
TIME y "DL文件下载完毕,重新下载一次检测是否有没下到的文件！"
TIME l "请留意以下下载是否出现一串白色英文带make -j1 V=s字样的，有就代表下载有错误了！"
TIME g "出现下载有错误的话，你就不需要下一步继续了，Ctrl+C终止重新再来吧，下载有错误是编译不成功的。"
sleep 3s
echo
make -j8 download
echo
TIME l "开始编译固件,预计要3-4小时,请耐心等待..."
echo
TIME g "你可以随时按 Ctrl+C 终止编译"
sleep 2s
echo
make -j1 V=s

if [ "$?" == "0" ]; then
	End="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
	echo
	TIME l "编译完成~~~"
	echo
	TIME y "后台地址: $ip"
	echo
	TIME y "用户名: root"
	echo
	TIME y "密 码: 无"
	echo
	TIME g "开始时间：${Begin}"
	echo
	TIME g "结束时间：${End}"
	echo
	if [[ "${REGULAR_UPDATE}" == "true" ]]; then
		rm -rf bin/Firmware
		source build/${firmware}/upgrade.sh && Diy_Part3
		rm -rf ../Openwrt.info
		TIME g "加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
		echo
	fi
else
	echo
	TIME r "编译失败，请再尝试编译~~~"
	echo
fi
