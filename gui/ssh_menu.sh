#!/bin/bash
source ./cfg/ssh_cfg.sh

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
				call_msg_box "SSH Port is 22";;
			2)
				call_menu_set_port "Enter SSH port number:"
				set_current_port $user_input;;
			3)
				call_menu_set "RootLogIn"
				set_permission_root_login $user_input;;
			4)
				call_menu_set "PasswordAuthentication"
				set_password_autentication $user_input;;
		esac
		call_msg_box "Restarting SSH"
		sleep 1
		service ssh restart
		call_msg_box "Restarting network"
		sleep 1
		service networking restart
		call_msg_box "Complete"
		sleep 1			
		call_ssh_menu;;
	1);;
	255);;
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
		call_msg_box "SSH Port is $user_input";;
	1);;
	255);;
esac
}

call_menu_set() {
  $DIALOG --title "$2 Configure $1 option" \
	 --inputbox "Enable $1 yes/no" 8 40 2> $tempfile
retval=$?
user_input=`cat $tempfile`
case $retval in
	0)
		if ! [[ $user_input =~ ^(yes|no)$ ]]
		then
			call_menu_set $1 "WRONG option, Try again."
		fi
		call_msg_box "$1 option is set to $user_input";;
	1);;
	255);;
esac
}

call_msg_box() {
	dialog --title 'Done' --infobox "$1" 5 30
	sleep 1
}

