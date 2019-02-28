#!/bin/bash
source ./cfg/admin_cfg.sh

tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
DIALOG=${DIALOG=dialog}

call_ssh_menu(){
$DIALOG --title "Set SSH port"  --clear \
	--menu "Select an option:" 20 50 4 \
	"1" "Use default port" \
	"2" "Set port" \
	"3" "Root LogIn permission" \
	"4" "Password Authentication" 2> $tempfile
retval=$?
choise=`cat $tempfile`

case $retval in
	0)
		case $choise in
			1)
				set_current_port 22
				call_infobox "SSH Port is 22";;
			2)
				call_menu_set_port "Enter SSH port number:"
				get_current_port
				ufw delete allow $CURRENT_PORT 
				set_current_port $user_input
				ufw allow $user_input
				ufw reload
				call_infobox "SSH Port is $user_input";;
			3)
				call_radio_menu "RootLogIn" ""
				if [ "$result" == "-" ]
				then
					call_infobox "Root LogIn not changed"
				else
					set_permission_root_login $result
					call_infobox "Root LogIn $result"
				fi;;
			4)
				call_radio_menu "PasswordAuthentication"
				check_authorized_keys
				if [ $res -eq 0 ] && [ "$result" == "no" ]
				then
					call_SSH_msgbox
				elif [ "$result" == "-" ]
				then
					call_infobox "Root LogIn not changed"
				else
					set_password_authentication $result
					call_infobox "Password Athentication $result"
				fi;;
		esac		
		call_ssh_menu;;
	1)restart_ssh_network;;
	255)restart_ssh_network;;
esac
}

call_menu_set_port() {
  $DIALOG --title "$2 $1" \
         --inputbox "$1" 8 40 2> $tempfile
retval=$?
user_input=`cat $tempfile`
re='^[0-9]+$'
case $retval in
	0)
		if ! [[ $user_input =~ $re ]]
		then
			call_menu_set_port "Enter SSH port number:" "WRONG Port! Try Again"	
		fi
		call_infobox "SSH Port is $user_input";;
	1);;
	255);;
esac
}

call_radio_menu() {
  $DIALOG --backtitle "$2 Configure $1 option" \
	 --radiolist "Enable/Diasble $1" 10 40 2\
	 1 "Enable" on \
	 2 "Disable" off 2>$tempfile
retval=$?
user_input=`cat $tempfile`

case $retval in
	0)
		case $user_input in
			1)result="yes";;
			2)result="no";;
		esac;;
	1)result="-";;
	255)result="-";;
esac
}

call_infobox() {
	$DIALOG --title 'Done' \
	--infobox "$1" 5 30
	sleep 1
}

call_SSH_msgbox() {
	$DIALOG --title 'WARNING!!!' \
	--msgbox "It seems you have no authorized keys in ~/.ssh directory. Perform ssh-keygen on your client. Then copy your id_rsa using ssh-copy-id -i <your_.ssh>/<your_key> <user_name>@<host_IP>" 10 50
}

restart_ssh_network() {
	call_infobox "Restarting SSH"
	sleep 1
	service ssh restart
	call_infobox "Complete"
	sleep 1	
}