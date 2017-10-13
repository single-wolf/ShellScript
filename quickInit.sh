#!/bin/bash
#########################################################################
# File Name: quickInit.sh
# Author: single-wolf
# mail: root@mail.zmblog.org
# Created Time: 2017年10月12日 10:43:49
#########################################################################
#
#Auto init ECS or VPS include useradd ,install pakeage ,add sys-config
#
defaultUser='MyVPS'
defaultShell='bash'
initPakeage="sudo wget vim git dstat $defaultShell"
srcUrl='http://mirrors.aliyun.com/'

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version_jdk=9

[[ $EUID -ne 0 ]] && echo -e "${red}ERROR:${plain} This script must be run as root!" && exit 1

if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

get_version(){
	if [[ "$release" == "centos" ]];then
		[ -f /etc/os-release ] && awk -F'[="]+' '/VERSION_ID/{print $2}' /etc/os-release && return
	elif [[ "$release" == "debian" ]];then
		[ -f /etc/os-release ] && awk -F'[()]' '/VERSION=/{print $2}' /etc/os-release && return
	elif [[ "$release" == "ubuntu" ]];then
		[ -f /etc/lsb-release ] && awk -F'[="]+' '/DISTRIB_CODENAME/{print $2}' /etc/lsb-release && return
	else
		echo -e "${red}ERROR:${plain} OS is not be supported, please change to CentOS/Debian/Ubuntu and try again."
		exit 1
	fi
}

opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
version=$( get_version )

get_char() {
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

init_install(){
	if [[ "$release" == "debian" ]];then
		file="/etc/apt/sources.list"
		[[ ! -e $file ]] && echo -e "${red}ERROR:${plain}src file $file not exist,please check it!" && exit 1
		cp $file "$file.`date +%F`"
		echo "#Create By init.sh `date +%F`">$file
		for kind in "deb" "deb-src";do
			for sort in "" "-updates" ;do
				echo "$kind $srcUrl$release $version$sort main contrib non-free" >> $file
			done
			echo "$kind $srcUrl$release-security $version/updates main contrib non-free" >> $file
		done
		apt-get update
		apt-get -y install $initPakeage
		if [[ $? -ne 0 ]];then
			echo -e "${red}ERROR:${plain} Install InitPakeages failed, please check it."
			exit 1
		fi
	elif [[ "$release" == "ubuntu" ]];then
		file="/etc/apt/sources.list"
		[[ ! -e $file ]] && echo -e "${red}ERROR:${plain}src file $file not exist,please check it!" && exit 1
		cp $file "$file.`date +%F`"
		echo "#Create By init.sh `date +%F`">$file
		for kind in "deb" "deb-src";do
			for sort in "" "-updates" "-security";do
				for free in "main" "universe";do
					echo "$kind $srcUrl$release $version$sort $free" >> $file
				done
			done
		done
		apt-get update
		apt-get -y install $initPakeage
		if [[ $? -ne 0 ]];then
			echo -e "${red}ERROR:${plain} Install InitPakeages failed, please check it."
			exit 1
		fi
	elif [[ "$release" == "centos" ]];then
		file="/etc/yum.repos.d/CentOS-Base.repo"
		[[ ! -e $file ]] && echo -e "${red}ERROR:${plain}src file $file not exist,please check it!" && exit 1
		cp $file "$file.`date +%F`"
		if [[ ! -e "/usr/bin/wget" ]];then
			wget -O $file "http://mirrors.aliyun.com/repo/Centos-$version.repo"
		elif [[ -e "/usr/bin/curl" ]];then
			curl -o $file "http://mirrors.aliyun.com/repo/Centos-$version.repo"
		else 
			yum -y install wget && wget -O $file "http://mirrors.aliyun.com/repo/Centos-$version.repo"
		fi
		yum clean all && yum makecache
		yum -y install $initPakeage
		if [[ $? -ne 0 ]];then
			echo -e "${red}ERROR:${plain} Install InitPakeages failed, please check it."
			exit 1
		fi
	else
		echo -e "${red}ERROR:${plain} OS is not be supported, please change to CentOS/Debian/Ubuntu and try again."
		exit 1
	fi
	echo -e "${green}INFO:Init and install $initPakeage successfully."
}

adduser(){
	shell="/bin/$defaultShell"
	useradd $defaultUser -m -s $shell
	[ $? -ne 0 ] && echo -e "${red}ERROR:${plain} Add user $defaultUser failed,please check it" && exit 1
	echo -e "${green}INFO:${plain}Input password for your newUser"
	passwd $defaultUser
	while [ $? -ne 0 ]
	do
		passwd $defaultUser
	done
	echo -e "${green}INFO:${plain}Add user $defaultUser successfully"
	chmod +w /etc/sudoers
	echo "$defaultUser	ALL=(ALL)	ALL" >> /etc/sudoers
	[ $? -ne 0 ] && echo -e "${red}ERROR:${plain} Give user $defaultUser failed" && chmod -w /etc/sudoers && exit 1
	chmod -w /etc/sudoers
	echo -e "${green}INFO:${plain}Give user $defaultUser Rootright successfully"
}
userconfig(){
	home="/home/$defaultUser/"
	cd $home
	wget -O .profile "http://cloud.zmblog.org:8000/f/c92022b083/?raw=1" && wget -O .bashrc "http://cloud.zmblog.org:8000/f/e933c3dcf0/?raw=1" && wget -O .vimrc "http://cloud.zmblog.org:8000/f/1cecaee058/?raw=1" && echo -e "${green}INFO:${plain}Download userconfig successfully,relogin in to use it."
	chown $defaultUser:$defaultUser .*
	[ $? -ne 0 ] && echo -e "${red}ERROR:${plain}User config failed!"
}

disableRootLogin(){
	config="/etc/ssh/sshd_config"
	if [[ -e  $config ]];then
		if [[ -w $config ]];then
			chmod +w $config
		fi
		sed -i '/^PermitRootLogin/'d $config && echo "PermitRootLogin no">>$config
		[ $? -ne 0 ] && echo -e "${red}ERROR:${plain} Disable RootLogin failed" && exit 1
	else
		echo -e "${red}ERROR:${plain}config file $config not exist,please check it!" && exit 1
	fi
	echo -e "${green}INFO:${plain}Disable RootLogin successfully"
}

#install_java(){
#	if [ -n `which java` ];then
#		version_local=`java -version>version.tmp 2>&1 && awk -F'["]' '/java version/{print $2}' version.tmp && rm version.tmp`
#		if [ $version_local -eq $version_jdk ];then
#			echo -e "${green}INFO:${plain}JDK$version_jdk alreadly exists!"
#			return
#		else 
#			echo -e "${yellow}INFO:${plain}Prepare to remove local JDK$version_local,and install JDK$version_jdk"
#		fi
#	else
#	fi
#}

install_ss(){
	wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
	chmod +x shadowsocks-all.sh
	./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log
}

install_bbr(){
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
	chmod +x bbr.sh
	./bbr.sh
}

clear
echo "---------- System Information ----------"
echo " OS      : $opsy"
echo " Arch    : $arch ($lbit Bit)"
echo " Kernel  : $kern"
echo " Version : $version"
echo "----------------------------------------"
echo
echo "Press any key to start...or Press Ctrl+C to cancel"
char=`get_char`
init_install
adduser
userconfig
disableRootLogin
install_ss
exit 1
