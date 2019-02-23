	#echo -en "${RED}SSH Brute-force protection${NORMAL}\n"
	#iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set	
	#iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP  
	#echo -en "${GREEN}\u2713 SET\n"
	echo -en "${RED}Port scanning protection${NORMAL}\n"
	iptables -N port-scanning 
	iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN 
	iptables -A port-scanning -j DROP	
	echo -en "${GREEN}\u2713 SET\n"
