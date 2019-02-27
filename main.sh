#!/bin/bash
source gui/main_menu.sh
if [ "$EUID" -ne 0 ]
  then 
  	echo "Please run as root"
  	exit
fi
call_main_menu