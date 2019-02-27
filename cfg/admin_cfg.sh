source ./utils/colors.sh
source ./utils/str_processing.sh
#==========================UPDATE, UPGRADE, INSTALL================================================
PACKAGES=(sudo openssh-server fail2ban nginx iptables-persistent net-tools)

update_packages() {
	echo -en "\n${RED}${BGGREEN}APT update & upgrade${NORMAL}\n"
	apt-get update -y && apt-get upgrade -y
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
			apt-get install -y "$x"
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
	ufw allow $CURRENT_PORT
	ufw allow $HTTP
	usw allow $HTTPS
	cp ./res/before.rules /etc/ufw/
	cp ./res/portsentry /etc/portsentry/

}
#==================================================================================================

#==========================DDoS PROTECTION=========================================================

#==================================================================================================

#==========================SET SCHEDULE============================================================
copy_scripts() {
	mkdir /root/scripts
	cp ./res/update_script.sh /root/scripts/
	cp ./res/cron_check.sh /root/scripts/
}

to_crontab() {
	crontab res/crontab.dat
}
#==================================================================================================