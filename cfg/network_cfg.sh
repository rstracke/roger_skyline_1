#!/bin/bash
source ./utils/str_processing.sh
IP="192.168.99.3"
NETMASK="255.255.255.252"
IFACE="enp0s8"
CONTENT="\n
auto lo\n
iface lo inet loopback\n
\n
auto enp0s3\n
iface enp0s3 inet dhcp\n
\n
allow-hotplug $IFACE\n
iface $IFACE inet static\n
address $IP\n
netmask $NETMASK"

make_tmp() {
	echo -e $CONTENT >./res/tmp
}