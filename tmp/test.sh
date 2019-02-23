user_input=$(\
   dialog --title "Input SSH port number" \
          --inputbox "Enter SSH port number:" 8 40 \
   3>&1 1>&2 2>&3 3>&- \
 )
        re='^[0-9]+$'
        if ! [[ $user_input =~ $re ]]
        then
                echo "Not a number"
	fi
