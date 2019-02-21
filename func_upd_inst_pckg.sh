#!/bin/bash
source colors.sh
PACKAGES=(sudo openssh-server knockd fail2ban)

update_packages(){
	echo -en "${RED}${BGGREEN}APT update & upgrade${NORMAL}\n"
	apt update && apt upgrade
}

check_installed_packages(){
	if dpkg -l | grep $1 &> /dev/null
	then
		result=1
	else
		result=0
	fi
}

install_packages() {
	for x in ${PACKAGES[@]}
	do
		check_installed_packages $x
		if [ $result -eq 1 ]; then
			echo -en "${RED}Package ${GREEN}$x ${RED}already installed${NORMAL}\n"
			continue
		else
			echo -e "################${GREEN}APT install $x${NORMAL}################\n"
			apt install "$x"
		fi
	done
}
