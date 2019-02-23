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