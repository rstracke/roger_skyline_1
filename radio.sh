tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
radio_call() {
dialog --backtitle "Example" \
	--radiolist "Example" 10 40 3 \
	1 "Enable" off \
	2 "Disable" on 2> $tempfile
retval=$?
choise=`cat $tempfile`
case $retval in
	0)
		case $choise in
			1)result="yes";;
			2)result="no";;
		esac;;
	1);;
	255);;
esac
echo "retval=$retval"
echo "choise=$choise"
echo "result=$result"
}
radio_call
