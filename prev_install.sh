#!/bin/bash

PACKAGES=(sudo openssh-server)

install_packages() {
	echo "APT update & upgrade"
	apt update && apt upgrade
	for x in ${PACKAGES[@]}
	do
		echo "APT install $x"
		apt install "$x"
	done
}

install_packages

#make user sudo
sudo_setup() {
read  -p "Enter username to give root" username
usermod -aG sudo $username
}

VAR=$(cat /etc/passwd | awk 'BEGIN{FS=":"}; {if (length($3) >= 4 && !index($3, "65534")){print $1}}')
USERS=(`echo $VAR | sed 's/ /\n/g'`)
BASHRC=".bashrc"
OPTION_FORCE_COLOR_PROMPT="force_color_prompt=yes"

#comment string
comment(){
	sed -i "/^$1/ c# $1" $2
}

#uncomment string
uncomment(){
	sed -i "/^# $1/ c$1" $2
}

#set color prompt for all users
set_color_prompt_for_all_users() {
	for x in ${USERS[@]}
	do
		uncomment $OPTION_FORCE_COLOR_PROMPT /home/$x/$BASHRC
	done
}

#set color prompt for specific user
set_color_prompt_for_specific_user(){
	uncomment $OPTION_FORCE_COLOR_PROMPT  /home/$1/$BASHRC
}

#Check users
is_user_exist(){
if grep $1 /etc/passwd  &> /dev/null
then
	result=1
else
	result=0
fi
}

#Setting up color prompt
color_prompt_setup(){
read -p "Would you like to set color prompt for all users? (y/n)" ans
echo "$ans"
if [[ "$ans" == *"y"* ]]; then
	set_color_prompt_for_all_users
else
	read -p "Would you like to set color prompt for specific user? (yes/no)" ans
	if [[ "$ans" == "yes" ]]; then
		read -p "Enter username to set color prompt:>> " USERNAME
		is_user_exist $USERNAME
		if [ $result -eq 1 ]; then
			set_color_prompt_for_specific_user $USERNAME
		else
			echo "This user does not exit on this System"
		fi
	fi
fi
}
