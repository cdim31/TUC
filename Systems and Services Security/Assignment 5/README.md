# Lab Report: Network traffic monitoring tool.

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the 5th exercise, explaining the code implementation of a Network Monitoring tool
using the Packet Capture Library (libcap).

---

### Implementation
### 1. Packet Capture

- ##### Live Monitoring (pcap_open_live)
    The program monitors live network traffic by employing the `pcap_open_live` function, capturing packets directly from the network interface of user's choice.

- #### Offline Analysis (pcap_open_offline) 

    Additionally, the capability to read a specified pcap file is implemented using the `pcap_open_offline` function.

In both cases the tool provides user response directly in terminal and logs
the result either on online_output.txt or on offline_output.txt, dependant on user mode choice.


### 2. Packet Processing

The libpcap library functions `pcap_lookupnet`, `pcap_compile`, `pcap_setfilter` and `pcap_loop` are utilized for processing pcap file data. To track network flows generated during packet capture, a struct is introduced, encompassing the five fields defining a flow: 
* Source IP and Port
* Destination IP and Port
* Transfer Layer Protocol (TCP or UDP). 

This struct also contains 2 more fields, in order to check retransmission.
* Sequence
* Payload

A linked list of nodes is established, ensuring unique storage for later duplicate checks.

---
## Command-Line Parameters
The tool accepts the following command-line parameters:

| Parameter | Description                                                                 |
|-----------|-----------------------------------------------------------------------------|
| `-i`      | Select the network interface name (e.g., `eth0`, `wlo1`) to monitor live traffic.  |
| `-r`      | Specify the packet capture file name (e.g., `test.pcap`) for offline analysis. |
| `-f`      | Apply a filter expression in string format (e.g., `port 8080`) to refine captured packets. |
| `-h`      | Display a help message showing the usage and purpose of each parameter.    |

---

### Question 10. Can you tell if an incoming TCP packet is a retransmission? If yes, how? If not, why? 


Yes, it would be possible to determine if a TCP packet is a retransmission.
It could be identified by analyzing the sequence and acknowledgment numbers in the TCP header. 
If a packet has the same sequence number as of any previously received packet and the 
acknowledgment number does not reflect any progress in communication, that means the TCP packet is 
probably a retransmission.

---

### Question 11. Can you tell if an incoming UDP packet is a retransmission? If yes, how? If not, why?

Unlike TCP, UDP is a connectionless protocol and does not maintain state or include sequence numbers. 
Consequently, detecting retransmitted UDP packets is deemed 
close to an impossible task.

### 3. Build and run instructions

In order to build the tool, go to tool directory and execute the command:

```bash
make all
```
To remove tool:

```bash
make clean
```

To run the tool, ensure you have root permissions (libpcap needs them).


The commands you can run are:
```bash
./pcap_ex -i your_interface
./pcap_ex -i your_interface -f "your_filter"
./pcap_ex -r your_pcap.pcap
./pcap_ex -h
```
