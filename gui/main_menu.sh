#!/bin/bash
source ./cfg/upd_inst_pckg.sh
source ./cfg/network_cfg.sh
source ./gui/ssh_menu.sh
source ./gui/security_menu.sh

call_main_menu(){
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
$DIALOG --clear --title "Roger configure"  \
	--menu "Everybody loves" 20 50 4 \
	"1" "Update && install required packages" \
	"2" "Configure SSH" \
	"3" "Configure Network" \
	"4" "Configure firewall"	\
	"5" "Auto check & update"  2> $tempfile
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
				make_tmp
				cp res/tmp /etc/network/interfaces
				rm -rf  res/tmp
				msg=$(echo -e "
				Your IP: $IP
				Netmask: $NETMASK
				IFACE: $IFACE")
				call_msgbox "$msg"
				sleep 1;;
			4)
				call_security_menu;;
			5)
				cp res/upd.sh /root/scripts/
				cp res/cron_check.sh /root/scripts/;;
					
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
