
source ./utils/colors.sh
source ./utils/str_processing.sh
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
	ufw logging on
	ufw allow 22
	ufw limit 22/tcp
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
	cp -r ./res/html	/var/www/
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
	if !(grep "1" /root/toggle1)
	then
		echo "FIRST PART"
		update_packages
		echo -en "################${GREEN}Network configure${NORMAL}################\n"
		configure_network
		echo "1" > /root/toggle1
		secs=$((1 * 10))
		while [ $secs -gt 0 ]; do
   			echo -ne "${BLINK}${RED}COMPUTER WILL RESTART IN >>> $secs\033[0K\r"
   			sleep 1
   			: $((secs--))
		done
		reboot
		exit
	fi
	if !(grep "2" /root/toggle2)
	then
		echo "SECOND PART"
		echo "2" > /root/toggle2
		echo "#####################################################################"
		flag=1
		while [ $flag -eq 1 ]
		do
			check_authorized_keys
			if [ $res -eq 0 ]
			then
				echo -en "It seems you have no authorized keys in ${BOLD}${GREEN}~/.ssh ${NORMAL} directory.\n Perform ssh-keygen on your client. Then copy your id_rsa using ${BOLD}${GREEN}ssh-copy-id -i <your_.ssh>/<your_key> <user_name>@<host_IP>${NORMAL}"
				read -p "Press any key. And restart your machine"
			else
				flag=0
			fi
		done
		install_packages
		echo -en "################${GREEN}Making user sudoer${NORMAL}################\n"
		sudo_setup victor
		echo -en "################${GREEN}Setting SSH Port up${NORMAL}################\n"
		set_current_port 777
		set_permission_root_login no
		set_password_authentication no
		service ssh restart
		echo -en "${RED}${BLINK}Restarting SSH${NORMAL}"
		echo -en "################${GREEN}Security settings${NORMAL}################\n"
		iptables_set_rules
		ddos_protect
		portscan_protect
		echo -en "################${GREEN}SCHEDULE Configure${NORMAL}################\n"
		copy_scripts
		to_crontab
		echo -en "################${GREEN}SSL Installation${NORMAL}################\n"
		ssl_install
		reboot
		exit
	fi
	if !(grep "3" /root/toggle3)
	then
		echo "THIRD PART"
		echo "3" > /root/toggle3
		echo -en "				|DEPLOYMENT COMPLETE|		 \n"
		echo -en "|-----------------------------------------|\n"
		echo -en "| SUDO User               | victor 	    |\n"
		echo -en "| IP ADDRESS              | $IP 			|\n"
		echo -en "| NETMASK                 | $NETMASK 		|\n"
		echo -en "| INTERFACE               | $IFACE 		|\n"
		echo -en "| SSH PORT                | $CURRENT_PORT |\n"
		echo -en "| PERMIT ROOT LOGIN       | NO 			|\n"
		echo -en "| PASSWORD AUTHENTICATION | NO 			|\n"
		echo -en "------------------------------------------|\n"	
		echo -en "| UFW RULES: 				| ${GREEN}SET${NORMAL} 			|\n"
		echo -en "| PORTSENTRY 				| ${GREEN}SET${NORMAL} 			|\n"
		echo -en "| NGINX 					| ${GREEN}SET${NORMAL}  		|\n"
		echo -en "| SSL CERTIFICATES		| ${GREEN}SET${NORMAL}  		|\n"
		read -p "Press any key"
		rm -rf /root/toggle1
		rm -rf /root/toggle2
		rm -rf /root/toggle3
	fi
}