#!/bin/bash
source ./cfg/admin_cfg.sh
source ./gui/ssh_menu.sh
source ./gui/security_menu.sh

DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

call_main_menu(){

$DIALOG --clear --title "Roger configure"  \
	--menu "Choose YOUR DESTINY" 20 50 5 \
	"0" "QUICK INSTALL" \
	"1" "Update && install required packages" \
	"2" "Configure SSH" \
	"3" "Configure Network" \
	"4" "Configure firewall"	\
	"5" "Cron configure"  2> $tempfile
retval=$?
choise=`cat $tempfile`

case $retval in
	0)
		case $choise in
			1)
				update_packages
				install_packages;;
			2)
				call_ssh_menu;;
			3)
				configure_network
				msg=$(echo -e "
				Your IP: $IP
				Netmask: $NETMASK
				IFACE: $IFACE")
				call_msgbox "$msg"
				sleep 2;;
			4)
				call_security_menu;;
			5)
				copy_scripts
				to_crontab;;	
			255)
				echo "ESC pressed";;
		esac
		call_main_menu;;
	1)
		clear;;
	255)
		clear;;
esac
}

call_msgbox() {
	dialog --title 'Done' --msgbox "$1" 8 40
	sleep 1
}
