#!/bin/bash
call_ssh_menu(){
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
$DIALOG --title "Set SSH port"  --clear \
	--menu "Select an option:" 20 50 2 \
	"1" "Use default port" \
	"2" "Set port" 2> $tempfile
retval=$?
choise=`cat $tempfile`

case $retval in
	0)
		echo "$retval, $choise";;
	1)
		echo "No";;
	255)
		echo "ESC pressed"
esac
}
