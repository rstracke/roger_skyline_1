#!/bin/bash
CURRENT_INTERFACE="enp0s8"

source ./utils/str_processing.sh
source ./cfg/ssh_cfg.sh
source ./utils/colors.sh
ufw_allow_current_port() {
	ufw allow $1
}

ufw_deny_current_port() {
	ufw deny $1
}

ufw_enable() {
	ufw enable
}

ufw_disable() {
	ufw disable
}

iptables_set_rules() {
	get_current_port
	#iptables -A INPUT -i lo -j ACCEPT
	#iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport $CURRENT_PORT -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
	#iptables -A INPUT -p icmp -j ACCEPT
	#iptables -A INPUT -m recent --rcheck --seconds 86400 --name portscan --mask 255.255.255.255 --rsource -j DROP
	#iptables -A FORWARD -m recent --rcheck --seconds 86400 --name portscan --mask 255.255.255.255 --rsource -j DROP
	#iptables -A OUTPUT -p icmp -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j ACCEPT

	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	iptables -A INPUT -p tcp --dport $CURRENT_PORT -j ACCEPT
	iptables -A INPUT -p tcp -i enp0s8 --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp -i enp0s8 --dport 443 -j ACCEPT
	iptables -A OUTPUT -m conntrack ! --ctstate INVALID -j ACCEPT
	iptables -I INPUT -i lo -j ACCEPT
	iptables -A INPUT -j LOG
	iptables -A FORWARD -j LOG
	iptables -I INPUT -p tcp --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 20 -j DROP
	iptables -A INPUT -p TCP -m state --state NEW -m recent --set
	iptables -A INPUT -p TCP -m state --state NEW -m recent --update --seconds 1 --hitcount 10 -j DROP
	
	#echo -en "${RED}Protection against INVALID PACKETS${NORMAL}\n"
	#iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Blocking NOT SYN new PACKETS${NORMAL}\n"
	#iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Blocking flood by SYN${NORMAL}\n"
	#iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
	#echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Blocking bogus tcp${NORMAL}\n"
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Protection against spoofing${NORMAL}\n"
	iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP 
	iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP 
	iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP 
	iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP 
	iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP 
	iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP 
	iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP 
	iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP 
	iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP	
	echo -en "${GREEN}\u2713 SET\n"
	
	#echo -en "${RED}Ping of Death protection${NORMAL}\n"
	#iptables -t mangle -A PREROUTING -p icmp -j DROP
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Connection attack protection${NORMAL}\n"
	#iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Limit for TCP connection per second${NORMAL}\n"
	#iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT 
	#iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Limit for TCP RST packets${NORMAL}\n"
	#iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT 
	#iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP	
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}SSH Brute-force protection${NORMAL}\n"
	#iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set	
	#iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP  
	#echo -en "${GREEN}\u2713 SET\n"
	#echo -en "${RED}Port scanning protection${NORMAL}\n"
	#iptables -N port-scanning 
	#iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN 
	#iptables -A port-scanning -j DROP	
	#echo -en "${GREEN}\u2713 SET\n"
	sleep 3
	netfilter-persistent save
	netfilter-persistent reload
}

#knockd_configure() {
	
#}
