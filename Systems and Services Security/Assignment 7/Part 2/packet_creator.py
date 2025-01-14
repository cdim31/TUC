from scapy.all import *
import base64
from datetime import datetime

packets = []

def timestamp():
	return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	
packet = IP(src="10.0.0.1", dst="192.168.1.1")/TCP(dport=54321)/Raw(load=f"Christos-2021030183 {timestamp()}")
packets.append(packet)

services = [
		{"port": 80, "protocol": "TCP"}, #HTTP
	    	{"port": 443, "protocol": "TCP"}, #HTTPS
	    	{"port": 22, "protocol": "TCP"}, #SSH
	    	{"port":23, "protocol": "TCP"}, #TELNET
	    	{"port": 21, "protocol": "TCP"}, #FTP
	    	{"port": 53, "protocol": "UDP"}, #DNS 
	    	{"port": 554, "protocol": "TCP"}, #RTSP
	    	{"port": 3306, "protocol": "TCP"}, #SQL
	    	{"port": 3389, "protocol": "TCP"}, #RDP 
	    	{"port": 1883, "protocol": "TCP"} #MQTT
	   ]
for service in services:
	port = service["port"]
	if service["protocol"] == "TCP":
		packet = IP(src="10.0.0.2", dst="192.168.1.2")/TCP(dport=port)/Raw(load=f"Christos-2021030183 {timestamp()}")	
	else:
		packet = IP(src="10.0.0.2", dst="192.168.1.2")/UDP(dport=port)/Raw(load=f"Christos-2021030183 {timestamp()}")
	packets.append(packet)

for i in range (5):
	payload = base64.b64encode(b"2021030183").decode()
	packet = IP(src="10.0.0.3", dst="192.168.1.3")/TCP(dport=8080)/Raw(load=payload)
	packets.append(packet)

packet = IP(src="10.0.0.4", dst="127.0.0.53")/UDP(dport=53)/DNS(qd=DNSQR(qname="malicious.example.com"))
packets.append(packet)

packet = IP(src="10.0.0.5", dst="192.168.1.4")/ICMP()/Raw(load="PingTest-2024")
packets.append(packet)


wrpcap("my.pcap", packets)
print(f"SUCCESS: Packets saved to file -> my.pcap")
