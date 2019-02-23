	echo -en "${RED}Protection against INVALID PACKETS${NORMAL}\n"
	iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Blocking NOT SYN new PACKETS${NORMAL}\n"
	iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
	echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Blocking flood by SYN${NORMAL}\n"
	iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
	echo -en "${GREEN}\u2713 SET\n"