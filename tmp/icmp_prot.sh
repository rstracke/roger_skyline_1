	echo -en "${RED}Ping of Death protection${NORMAL}\n"
	iptables -t mangle -A PREROUTING -p icmp -j DROP
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Connection attack protection${NORMAL}\n"
	iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Limit for TCP connection per second${NORMAL}\n"
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT 
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Limit for TCP RST packets${NORMAL}\n"
	iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT 
	iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP	
	echo -en "${GREEN}\u2713 SET\n"
	