#!/bin/bash
source func_upd_inst_pckg.sh
source menu_cfg_ssh.sh
call_main_menu(){
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
$DIALOG --clear --title "Roger configure"  \
	--menu "Everybody loves" 20 50 4 \
	"1" "Update && install required packages" \
	"2" "Configure SSH" \
	"3" "Configure KNOCKD" \
	"4" "Set color prompt" 2> $tempfile
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
				echo "Cofigure KNOCKD";;
			4)
				echo "Set color prompt";;
			255)
				echo "ESC pressed";;
		esac
		call_main_menu;;
	1)
		echo "No"
		clear;;
	255)
		echo "ESC pressed"
		clear;;
esac
}
call_main_menu
