#!/bin/bash
source ./cfg/admin_cfg.sh

tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
DIALOG=${DIALOG=dialog}

call_security_menu(){
$DIALOG --title "Set Security options"  --clear \
	--menu "Select an option:" 20 50 4 \
	"1" "Set Firewall rules" \
	"2" "Fail2Ban Settings" \
	"3" "Antiscan settings" 2> $tempfile
retval=$?
choise=`cat $tempfile`

case $retval in
	0)
		case $choise in
			1)
				iptables_set_rules;;
			2)echo "Fail2Ban";;				
			3)echo "Portsentry";;
			4);;
		esac
		call_security_menu;;
	1);;
	255);;
esac
}

call_msg_box() {
	dialog --title 'Done' --infobox "$1" 5 30
	sleep 1
}

