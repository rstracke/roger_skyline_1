#!/bin/bash

#comment string
comment() {
	get_line "$1" $2
	if echo $LINE | grep "^##* *$1" &> /dev/null
	then 
		exit
	else
		sed -i "/^$LINE/c# $LINE" $2
	fi
}

#uncomment string
uncomment() {
	get_line "$1" $2
	if echo $LINE | grep "^# *$1 *" &> /dev/null	
	then
		str1=$(awk '/^# *'"$1"' */ {gsub(/^#|^# +/,""); print; exit;}' $2)
		sed -i "s/^#\+ *$str1/$str1/" $2
	else
		exit
	fi
}

#get field value
get_field_value() {
	FIELD_VALUE=$(awk '/^#* *'"$1"' +/ {gsub(/^#|^# +/,""); print $2;exit;}' $2)
}

get_line() {
	LINE=$(awk '/^#* *'"$1"' */ {print;exit;}' $2)
}
#set field
set_field_value(){
	get_field_value "$1" $2
	get_line "$1" $2
	str=$(awk '/'"$LINE"'/ {gsub(/'"$FIELD_VALUE"'/,""); print; exit;}' $2)
	str=$(echo "$str $3")
	new_line=$(echo "$1 $3")
	sed -i "s/$LINE/$new_line/" $2
}

#replace field
replace_field(){
	sed "s/$1/$2/g"
}
