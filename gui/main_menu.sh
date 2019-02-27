#!/bin/bash
source ./cfg/admin_cfg.sh
source ./gui/ssh_menu.sh
source ./gui/security_menu.sh

DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

call_main_menu(){

$DIALOG --clear --title "Roger configure"  \
	--menu "Choose YOUR DESTINY" 20 50 7 \
	"0" "QUICK INSTALL" \
	"1" "Update && install required packages" \
	"2" "Make user SUDO" \
	"3" "Configure SSH" \
	"4" "Configure Network" \
	"5" "Configure firewall"	\
	"6" "Cron configure" \
	"7" "SSL setup" 2> $tempfile
retval=$?
choise=`cat $tempfile`

case $retval in
	0)
		case $choise in
			1)
				update_packages
				install_packages;;
			2)	
				call_menu_set_sudoer
				is_user_exist $user_input
				if [ $result == 1 ]
				then
					usermod -aG sudo $user_input
				else
					call_msgbox "User does not exist!"
				fi;;

			3)
				call_ssh_menu;;
			4)
				configure_network
				msg=$(echo -e "
				Your IP: $IP
				Netmask: $NETMASK
				IFACE: $IFACE")
				call_msgbox "$msg"
				sleep 2;;
			5)
				call_security_menu;;
			6)
				copy_scripts
				to_crontab;;
			7)
				ssl_install;;	
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
}

call_menu_set_sudoer() {
  $DIALOG --title "Enter name to give sudo rights" \
         --inputbox "$1" 8 40 2> $tempfile
retval=$?
user_input=`cat $tempfile`
re='^[a-z]+$'
case $retval in
	0)
		if ! [[ $user_input =~ $re ]]
		then
			call_menu_set_port "Enter user name:" "WRONG NAME! Try Again"	
		fi;;
	1);;
	255);;
esac
}