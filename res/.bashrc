# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

clear    # Очистка экрана

#Памятка, Таблица цветов и фонов
#Цвет           код       код фона

#black    30  40    \033[30m  \033[40m
#red      31  41    \033[31m  \033[41m
#green    32  42    \033[32m  \033[42m
#yellow    33  43    \033[33m  \033[43m
#blue    34  44    \033[34m  \033[44m
#magenta    35  45    \033[35m  \033[45m
#cyan    36  46    \033[36m  \033[46m
#white    37  47    \033[37m  \033[47m

# Дополнительные свойства для текта:
BOLD='\033[1m'       #  ${BOLD}      # жирный шрифт (интенсивный цвет)
DBOLD='\033[2m'      #  ${DBOLD}    # полу яркий цвет (тёмно-серый, независимо от цвета)
NBOLD='\033[22m'      #  ${NBOLD}    # установить нормальную интенсивность
UNDERLINE='\033[4m'     #  ${UNDERLINE}  # подчеркивание
NUNDERLINE='\033[4m'     #  ${NUNDERLINE}  # отменить подчеркивание
BLINK='\033[5m'       #  ${BLINK}    # мигающий
NBLINK='\033[5m'       #  ${NBLINK}    # отменить мигание
INVERSE='\033[7m'     #  ${INVERSE}    # реверсия (знаки приобретают цвет фона, а фон -- цвет знаков)
NINVERSE='\033[7m'     #  ${NINVERSE}    # отменить реверсию
BREAK='\033[m'       #  ${BREAK}    # все атрибуты по умолчанию
NORMAL='\033[0m'      #  ${NORMAL}    # все атрибуты по умолчанию

# Цвет текста: 
BLACK='\033[0;30m'     #  ${BLACK}    # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}      # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}    # зелёный цвет знаков
YELLOW='\033[0;33m'     #  ${YELLOW}    # желтый цвет знаков
BLUE='\033[0;34m'       #  ${BLUE}      # синий цвет знаков
MAGENTA='\033[0;35m'     #  ${MAGENTA}    # фиолетовый цвет знаков
CYAN='\033[0;36m'       #  ${CYAN}      # цвет морской волны знаков
GRAY='\033[0;37m'       #  ${GRAY}      # серый цвет знаков

# Цветом текста (жирным) (bold) :
DEF='\033[0;39m'       #  ${DEF}
DGRAY='\033[1;30m'     #  ${DGRAY}
LRED='\033[1;31m'       #  ${LRED}
LGREEN='\033[1;32m'     #  ${LGREEN}
LYELLOW='\033[1;33m'     #  ${LYELLOW}
LBLUE='\033[1;34m'     #  ${LBLUE}
LMAGENTA='\033[1;35m'   #  ${LMAGENTA}
LCYAN='\033[1;36m'     #  ${LCYAN}
WHITE='\033[1;37m'     #  ${WHITE}

# Цвет фона 
BGBLACK='\033[40m'     #  ${BGBLACK}
BGRED='\033[41m'       #  ${BGRED}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGBROWN='\033[43m'     #  ${BGBROWN}
BGBLUE='\033[44m'     #  ${BGBLUE}
BGMAGENTA='\033[45m'     #  ${BGMAGENTA}
BGCYAN='\033[46m'     #  ${BGCYAN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BGDEF='\033[49m'      #  ${BGDEF}

#comment string
comment() {
	get_line "$1" $2
	if echo $LINE | grep "^##* *$1" &> /dev/null
	then 
		exit
	else
		sed -i "/^$LINE/c# $LINE" $2
	fi
}

#uncomment string
uncomment() {
	get_line "$1" $2
	if echo $LINE | grep "^# *$1 *" &> /dev/null	
	then
		str1=$(awk '/^# *'"$1"' */ {gsub(/^#|^# +/,""); print; exit;}' $2)
		sed -i "s/^#\+ *$str1/$str1/" $2
	else
		exit
	fi
}

#get field value
get_field_value() {
	FIELD_VALUE=$(awk '/^#* *'"$1"' +/ {gsub(/^#|^# +/,""); print $2;exit;}' $2)
}

get_line() {
	LINE=$(awk '/^#* *'"$1"' */ {print;exit;}' $2)
}
#set field
set_field_value(){
	get_field_value "$1" $2
	get_line "$1" $2
	str=$(awk '/'"$LINE"'/ {gsub(/'"$FIELD_VALUE"'/,""); print; exit;}' $2)
	str=$(echo "$str $3")
	new_line=$(echo "$1 $3")
	sed -i "s/$LINE/$new_line/" $2
}

#replace field
replace_field(){
	sed "s/$1/$2/g"
}

#==========================UPDATE, UPGRADE, INSTALL================================================
PACKAGES=(sudo net-tools ufw portsentry nginx mailutils)

update_packages() {
	echo -en "\n${RED}${BGGREEN}APT update & upgrade${NORMAL}\n"
	apt update -y && apt upgrade -y
}

check_installed_packages() {
	if dpkg -l | grep $1 &> /dev/null
	then
		result=1
	else
		result=0
	fi
}

install_packages() {
	for x in ${PACKAGES[@]}
	do
		check_installed_packages $x
		if [ $result -eq 1 ]; then
			echo -en "${RED}Package ${GREEN}$x ${RED}already installed${NORMAL}\n"
			continue
		else
			echo -en "################${GREEN}APT install $x${NORMAL}################\n"
			apt install "$x" -y
		fi
	done
}
#==================================================================================================

#==========================SET USER SUDO===========================================================
is_user_exist() {
user=$(cat /etc/passwd | awk -v user="$1" 'BEGIN {FS=":"}; {if (index($1,user) && index($6, "home") && length($3) >= 4){print $1}}')
if [ "$user" == "$1" ]
then
	result=1
else
	result=0
fi
}

sudo_setup() {
#is_user_exist $1
#if [ $result -eq 1]
#then
usermod -aG sudo $1
echo -en "${RED}User ${GREEN}$1 ${RED} get SUDO rights${NORMAL}\n"
#else
#	msg="User doesn't exit! Would you like to create one and make sudo?"
}
#==================================================================================================

#==========================SET NETWORK=============================================================
IP="192.168.99.2"
NETMASK="255.255.255.252"
IFACE="enp0s8"
CONTENT="# This file describes the network interfaces available on your system\n
# and how to activate them. For more information, see interfaces(5).\n
\n
source /etc/network/interfaces.d/*\n
\n
# The loopback network interface\n
auto lo\n
iface lo inet loopback\n
\n
# The primary network interface\n
allow-hotplug enp0s3\n
iface enp0s3 inet dhcp\n
\n
allow-hotplug $IFACE\n
iface $IFACE inet static\n
address $IP\n
netmask $NETMASK"



configure_network() {
	echo -e $CONTENT > /etc/network/interfaces
	echo -en "${RED}/etc/network/interfaces ${GREEN} configured ${NORMAL}\n"
}
#==================================================================================================

#==========================SSH SETTINGS============================================================
SSH_CFG_FILE=$"/etc/ssh/sshd_config"
get_current_port() {
	get_field_value Port $SSH_CFG_FILE
	CURRENT_PORT=$FIELD_VALUE
}

set_current_port() {
	set_field_value Port $SSH_CFG_FILE $1
}

set_permission_root_login() {
	set_field_value PermitRootLogin $SSH_CFG_FILE $1
}

set_password_authentication() {
	set_field_value PasswordAuthentication $SSH_CFG_FILE $1
}

check_authorized_keys() {
	res=0
	if (find /home -iname "authorized_keys" | grep "authorized_keys")
	then
		res=1
	fi
}
#==================================================================================================

#==========================FIREWALL SETTINGS=======================================================
HTTP="80"
HTTPS="443"
iptables_set_rules() {
	get_current_port
	ufw enable
	ufw allow $CURRENT_PORT
	echo "$CURRENT_PORT allowed"
	ufw allow $HTTP
	echo "$HTTP allowed"
	ufw allow $HTTPS
	echo "$HTTPS allowed"
	ufw reload	
}
#==================================================================================================

#==========================DDoS PROTECTION=========================================================
ddos_protect() {
	cp ./res/before.rules /etc/ufw/
	ufw reload
}
#==================================================================================================

#==========================PORT SCAN PROTECTION====================================================
portscan_protect() {
	cp ./res/portsentry.conf /etc/portsentry/	
	service portsentry restart	
}
#==================================================================================================

#==========================SET SCHEDULE============================================================
copy_scripts() {
	mkdir /root/scripts
	cp ./res/update_script.sh /root/scripts/
	cp ./res/cron_check.sh /root/scripts/
	cp ./res/aliases /etc/aliases
	cp -r ./res/html	/var/www/html
}

to_crontab() {
	crontab res/crontab.dat
}
#==================================================================================================

#==========================SSL INSTALL=============================================================
ssl_install() {
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
cp res/self-signed.conf /etc/nginx/snippets/self-signed.conf
cp res/default /etc/nginx/sites-enabled/default
}
#==================================================================================================
deploy() {
	if !(grep "1" toggle1)
	then
		echo "FIRST PART"
		sleep 5
		update_packages
		echo -en "################${GREEN}Network configure${NORMAL}################\n"
		configure_network
		echo "1" > toggle1
		secs=$((1 * 10))
		while [ $secs -gt 0 ]; do
   			echo -ne "${BLINK}${RED}COMPUTER WILL RESTART IN >>> $secs\033[0K\r"
   			sleep 1
   			: $((secs--))
		done
		reboot
		exit
	fi
	if !(grep "2" toggle2)
	then
		echo "SECOND PART"
		sleep 5
		echo "2" > toggle2
		echo "#####################################################################"
		check_authorized_keys
		if [ $res -eq 0 ]
		then
			echo -en "It seems you have no authorized keys in ${BOLD}${GREEN}~/.ssh ${NORMAL} directory.\n Perform ssh-keygen on your client. Then copy your id_rsa using ${BOLD}${GREEN}ssh-copy-id -i <your_.ssh>/<your_key> <user_name>@<host_IP>${NORMAL}"
			read -p "Press any key. And restart your machine"
			rm -rf toggle2
			exit 1
		fi
		install_packages
		echo -en "################${GREEN}Making user sudoer${NORMAL}################\n"
		sudo_setup victor
		sleep 5
		echo -en "################${GREEN}Setting SSH Port up${NORMAL}################\n"
		set_current_port 777
		set_permission_root_login no
		set_password_authentication no
		service ssh restart
		echo -en "${RED}${BLINK}Restarting SSH${NORMAL}"
		sleep 5
		echo -en "################${GREEN}Security settings${NORMAL}################\n"
		iptables_set_rules
		ddos_protect
		portscan_protect
		sleep 5
		echo -en "################${GREEN}SCHEDULE Configure${NORMAL}################\n"
		copy_scripts
		to_crontab
		sleep 5
		echo -en "################${GREEN}SSL Installation${NORMAL}################\n"
		ssl_install
		sleep 5
		reboot
		exit
	fi
	if !(grep "3" toggle3)
	then
		echo "THIRD PART"
		sleep 5
		echo "3" > toggle3
		echo -en "				|DEPLOYMENT COMPLETE|		 "
		echo -en "|-----------------------------------------|"
		echo -en "| SUDO User               | victor 	    |"
		echo -en "| IP ADDRESS              | $IP 			|"
		echo -en "| NETMASK                 | $NETMASK 		|"
		echo -en "| INTERFACE               | $IFACE 		|"
		echo -en "| SSH PORT                | $CURRENT_PORT |"
		echo -en "| PERMIT ROOT LOGIN       | NO 			|"
		echo -en "| PASSWORD AUTHENTICATION | NO 			|"
		echo -en "------------------------------------------|"	
		echo -en "| UFW RULES: 				| ${GREEN}SET${NORMAL} 			|"
		echo -en "| PORTSENTRY 				| ${GREEN}SET${NORMAL} 			|"
		echo -en "| NGINX 					| ${GREEN}SET${NORMAL}  		|"
		echo -en "| SSL CERTIFICATES		| ${GREEN}SET${NORMAL}  		|"
		read -p "Press any key"
		rm -rf toggle
	fi
}