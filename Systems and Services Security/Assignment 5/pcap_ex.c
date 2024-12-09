#include <stdio.h>
#include <pcap.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <netinet/ether.h>
#include <netinet/ip6.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <openssl/sha.h>


#define DISPLAY_TIMEOUT 400
#define TCP_EXT_HEADER 6
#define UDP_EXT_HEADER 17
#define NO_NXT_IP6 59

typedef struct flow_packet flow_packet;
typedef struct node node;

typedef struct packet{
    char * src_ip;
    char * dst_ip;

    uint16_t src_prt;
    uint16_t dst_prt;

    uint8_t *payload_loc;

    int header_len;
    int payload_len;
    int retrans;
    unsigned int sequence;
    char payload[1024];
    char * protocol;
}packet_t;

struct flow_packet{
    char src_ip[INET6_ADDRSTRLEN];
    char dst_ip[INET6_ADDRSTRLEN];

    uint16_t src_prt;
    uint16_t dst_prt;

    char protocol[4];

    unsigned int sequence;
    char payload[1024];
};

struct node{
    flow_packet * packet;
    node * next;
};



void packet_handler(u_char *, const struct pcap_pkthdr *, const u_char *);
void nif_setup(const char *, const char *);
void parse_pcap(const char *, const char *);
void exit_parse(void);
void print_packet(packet_t *);
void handle_tcp_header(const struct tcphdr*, packet_t *, int);
void handle_udp_header(const struct udphdr*, packet_t *, int);
void print_help();
void add_node(node **, flow_packet *);
int exists(node *, flow_packet *);
flow_packet * create_flow_packet(packet_t *, int);
int check_flow(flow_packet *, flow_packet *);
void cleanup(void);
int is_retransmission(node *, flow_packet *);

int net_flows = 0;
int tcp_net_flows = 0;
int udp_net_flows = 0;
int packet_counter = 0;
int tcp_packs_recv = 0;
int udp_packs_recv = 0;
int tcp_bytes_recv = 0;
int udp_bytes_recv = 0;
char *output_file;
FILE *fp = NULL;
node * head = NULL;

int main(int argc, char* argv[]){

	int opt;
	char *interface = NULL;
	char *filename = NULL;
	char *filter_exp = NULL;

	fclose(fopen("online_output", "w"));
    struct sigaction sa;
    sa.sa_handler = (__sighandler_t) exit_parse;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGQUIT, &sa, NULL);

	while ((opt = getopt(argc, argv, "i:r:f:h")) != -1){
		switch (opt){
			case 'i':
				// Select the network interface name
				interface = optarg;
				break;
			case 'f':
				// Filter expression in string format
				filter_exp = optarg;
				break;
			case 'r':
				// Packet capture file name
				filename = optarg;
				break;
			case 'h':
				// Help message
				print_help();
				return 0;
			default:
				fprintf(stderr, "Error: Invalid option, use -h for help.\n");
				return 1;
		}
	}

		// Process based on the mode
    	if (interface && !filename){
        	output_file = "online_output.txt";
        	fp = fopen(output_file, "w"); 
			if (fp == NULL) {
			    fprintf(stderr, "Error: Could not open output file.\n");
			    exit(EXIT_FAILURE);
			}
        	nif_setup(interface, filter_exp);
        	if (fp){
		    	fclose(fp);
		    	fp = NULL;
		    }
    	} else if (!interface && filename){
        	output_file = "offline_output.txt";
        	fp = fopen(output_file, "w");
			if (fp == NULL) {
			    fprintf(stderr, "Error: Could not open output file.\n");
			    exit(EXIT_FAILURE);
			}
        	parse_pcap(filename, filter_exp);
        	if (fp){
		    	fclose(fp);
		    	fp = NULL;
		    }
    	} else if (interface && filename){
    		fprintf(stderr, "Error: Both modes can not be used");
    	} else {
    		fprintf(stderr, "Error: Mode must be specified");
    	}

    
    //free(output_file);

	return 0;
}

// Print help message
void print_help(){
	printf("Usage: ./pcap_ex [OPTIONS]\n");
    printf("Options:\n");
    printf("  -i <interface>    Capture live traffic from the specified network interface.\n");
    printf("  -r <file>         Read packets from a pcap file.\n");
    printf("  -f <filter>       Apply a filter expression (e.g., \"port 8080\").\n");
    printf("  -h                Display this help message.\n");
}

// int pcap_setfilter(pcap_t *p, struct bpf_program *fp)

// Function to setup network interface
void nif_setup(const char *interface, const char *filter_exp) {
    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle;
    struct bpf_program filter;  // Structure to store the compiled filter
    bpf_u_int32 net, mask;      // Network and mask for the interface

    // Retrieve network and mask for the interface
    if (pcap_lookupnet(interface, &net, &mask, errbuf) == -1) {
        fprintf(stderr, "Could not get network mask for device %s: %s\n", interface, errbuf);
        net = 0;
        mask = 0;
    }

    // Open the interface for live capture
    handle = pcap_open_live(interface, BUFSIZ, 0, DISPLAY_TIMEOUT, errbuf);
    if (handle == NULL) {
        fprintf(stderr, "Could not open device %s: %s\n", interface, errbuf);
        exit(EXIT_FAILURE);
    }

    // Compile and apply the filter, if provided
    if (filter_exp) {
        printf("Applying the given filter...\n");

        if (pcap_compile(handle, &filter, filter_exp, 1, mask) == -1) {
            fprintf(stderr, "Could not compile filter '%s': %s\n", filter_exp, pcap_geterr(handle));
            pcap_close(handle);  // Cleanup before exiting
            exit(EXIT_FAILURE);
        }

        if (pcap_setfilter(handle, &filter) == -1) {
            fprintf(stderr, "Could not apply filter '%s': %s\n", filter_exp, pcap_geterr(handle));
            pcap_freecode(&filter);  // Free the compiled filter
            pcap_close(handle);      // Cleanup
            exit(EXIT_FAILURE);
        }

        printf("Filter applied: %s\n", filter_exp);
        pcap_freecode(&filter);  // Free the compiled filter after applying
    }

    // Start the capture loop
    printf("Starting packet capture on interface: %s\n", interface);
    if (pcap_loop(handle, 0, packet_handler, NULL) == -1) {
        fprintf(stderr, "Failed to process packets: %s\n", pcap_geterr(handle));
        pcap_close(handle);  // Cleanup
        exit(EXIT_FAILURE);
    }

    // Close the pcap handle
    pcap_close(handle);
    printf("Packet capture complete.\n");
}

void parse_pcap(const char *dump, const char *filter_exp) {
    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *handle = NULL; // Initialize handle
    struct pcap_pkthdr *header;
    const u_char *packet;

    handle = pcap_open_offline(dump, errbuf);
    if (handle == NULL) {
        fprintf(stderr, "Error opening file: %s\n", errbuf);
        exit(EXIT_FAILURE);
    }

    // Process packets
    if (pcap_loop(handle, 0, packet_handler, NULL) < 0) {
        fprintf(stderr, "Error processing packets: %s\n", pcap_geterr(handle));
        pcap_close(handle);
        exit(EXIT_FAILURE);
    }
    pcap_close(handle);

    // Additional cleanup function if needed
    exit_parse();

    // Explicitly exit cleanly
    exit(EXIT_SUCCESS);
}


void handle_ipv4_packets(const u_char *packet){
	
	/* Buffers to store source and destination IP addresses */
	char src_IP[INET_ADDRSTRLEN] = {0};
	char dest_IP[INET_ADDRSTRLEN] = {0};

	packet_t packet_s;
    int payload_len;
    int header_len;
	const struct ip *ip_header;
	const struct tcphdr *tcp_header;
    const struct udphdr *udp_header;

    const struct ether_header *eth_header;

	/* Extract the header */
    ip_header = (struct ip *)(packet + sizeof(struct ether_header));

    if (!ip_header) {
	    fprintf(stderr, "Invalid IPv4 header\n");
	    return;
	}
    /* Make IPs readable */
    inet_ntop(AF_INET, &(ip_header->ip_src), src_IP, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &(ip_header->ip_dst), dest_IP, INET_ADDRSTRLEN);

    /* Calculate header and payload length*/
    header_len = 4 * ip_header->ip_hl;
    payload_len = ntohs(ip_header->ip_len) - header_len;

    if (payload_len < 0 || header_len < 0) {
	    fprintf(stderr, "Invalid header or payload length\n");
	    return;
	}
   	/* Store IPs into packet */
   	packet_s.src_ip = src_IP;
   	packet_s.dst_ip = dest_IP;

   	/* Check if packet is TCP */
   	if (ip_header->ip_p == IPPROTO_TCP) {

   		tcp_bytes_recv += payload_len;
   		packet_s.payload_len = payload_len;

   		tcp_header = (struct tcphdr *)(packet +sizeof(struct ether_header) + header_len);

   		handle_tcp_header(tcp_header, &packet_s, 0);
   	} /* Check if packet is UDP */
   	else if (ip_header->ip_p == IPPROTO_UDP){

   		udp_header = (struct udphdr *)(packet + sizeof(struct ether_header) + header_len);

   		udp_bytes_recv += ntohs(udp_header->len);

   		handle_udp_header(udp_header, &packet_s, 0);
   	} else{
    	return; // Skip this packet
    }
}


void handle_tcp_header(const struct tcphdr *tcp_header, packet_t *packet_s, int ipv6) {
    uint16_t source_port;
    uint16_t dest_port;
    flow_packet *packet;
    char protocol[4];

    tcp_packs_recv++; 

    // Extract source and destination ports
    source_port = ntohs(tcp_header->th_sport);
    dest_port = ntohs(tcp_header->th_dport);

    // Set protocol name
    strncpy(protocol, "TCP\0", 4);
    packet_s->protocol = protocol;

    // Validate TCP header length
    if (tcp_header->doff < 5) {
        fprintf(stderr, "Invalid TCP header length. Skipping...\n");
        return;
    }

    // Update packet metadata
    packet_s->src_prt = source_port;
    packet_s->dst_prt = dest_port;
    packet_s->header_len = tcp_header->doff * 4;
    packet_s->payload_len -= tcp_header->doff * 4;
    packet_s->sequence = ntohl(tcp_header->th_seq);
    packet_s->payload_loc = (uint8_t *)tcp_header + tcp_header->doff * 4;
    if (packet_s->payload_len < sizeof(packet_s->payload)) {
	    memcpy(packet_s->payload, packet_s->payload_loc, packet_s->payload_len);
	    packet_s->payload[packet_s->payload_len] = '\0';
	} else {
	    fprintf(stderr, "Payload length exceeds buffer size\n");
	    memcpy(packet_s->payload, packet_s->payload_loc, sizeof(packet_s->payload) - 1);
	    packet_s->payload[sizeof(packet_s->payload) - 1] = '\0';
	}	

    // Set retransmission flag
    packet_s->retrans = 0;

    // Create flow packet and check if it already exists
    packet = create_flow_packet(packet_s, ipv6);
    if (!exists(head, packet)) {
        net_flows++;
        tcp_net_flows++;
        add_node(&head, packet);
    } else {
        free(packet); // Free memory if flow already exists
    }

    if (is_retransmission(head, packet)) {
	    packet_s->retrans = 1;
	} 

    // Print packet details
    print_packet(packet_s);
}


void handle_udp_header(const struct udphdr * udp_header, packet_t * packet_s, int ipv6){

	flow_packet * packet;
    uint16_t source_port;
    uint16_t dest_port;
    char protocol[4];

    udp_packs_recv++;

    source_port = ntohs(udp_header->uh_sport);
    dest_port = ntohs(udp_header->uh_dport);
    strncpy(protocol, "UDP\0", 4);
    packet_s->src_prt = source_port;
    packet_s->dst_prt = dest_port;
    packet_s->protocol = protocol;
    packet_s->payload_len = ntohs(udp_header->len) - 8;
	packet_s->payload_loc = (uint8_t *)udp_header + 8;
    packet_s->retrans = 0;
    packet_s->header_len = 8;

    packet = create_flow_packet(packet_s, ipv6);

    if(!exists(head, packet)){
        net_flows++;
        udp_net_flows++;
        add_node(&head, packet);
    }else{
        free(packet);
    }

    print_packet(packet_s);
}

flow_packet *create_flow_packet(packet_t *packet, int ipv6) {
    // Allocate memory for a new flow_packet
    flow_packet *flow = (flow_packet *)malloc(sizeof(flow_packet));
    if (!flow) {
        fprintf(stderr, "Memory allocation failed.\n");
        exit(EXIT_FAILURE);
    }

    // Initialize the allocated memory
    memset(flow, 0, sizeof(flow_packet));

    // Copy source and destination IP addresses
    if (ipv6) {
        strncpy(flow->src_ip, packet->src_ip, INET6_ADDRSTRLEN - 1);
        strncpy(flow->dst_ip, packet->dst_ip, INET6_ADDRSTRLEN - 1);
    } else {
        strncpy(flow->src_ip, packet->src_ip, INET_ADDRSTRLEN - 1);
        strncpy(flow->dst_ip, packet->dst_ip, INET_ADDRSTRLEN - 1);
    }

    // Copy source and destination ports
    flow->src_prt = packet->src_prt;
    flow->dst_prt = packet->dst_prt;

    // Copy protocol (ensure null termination)
    strncpy(flow->protocol, packet->protocol, sizeof(flow->protocol) - 1);
    flow->protocol[sizeof(flow->protocol) - 1] = '\0';  // Explicit null termination

    // Initialize the sequence number (if applicable in your `packet_t` structure)
    flow->sequence = packet->sequence;

    // Copy the payload (if applicable)
    strncpy(flow->payload, packet->payload, sizeof(flow->payload) - 1);
    flow->payload[sizeof(flow->payload) - 1] = '\0';  // Explicit null termination

    return flow;  // Caller is responsible for freeing the allocated memory
}

void handle_ipv6_packets(const u_char *packet) {
    /* Buffers to store source and destination IP addresses */
    char src_IPv6[INET6_ADDRSTRLEN] = {0};
    char dest_IPv6[INET6_ADDRSTRLEN] = {0};

    packet_t packet_s = {0}; // Initialize to prevent undefined behavior
    uint8_t next_header;

    const struct ip6_hdr *ip_6_header;
    const struct tcphdr *tcp_header;
    const struct udphdr *udp_header;
    const struct ip6_ext *ext_header;

    /* Extract the IPv6 header */
    ip_6_header = (struct ip6_hdr *)(packet + sizeof(struct ether_header));

    /* Check if the packet length is valid */
    if (ip_6_header == NULL) {
        fprintf(stderr, "Invalid IPv6 header. Skipping...\n");
        return;
    }

    /* Make IPs readable */
    inet_ntop(AF_INET6, &(ip_6_header->ip6_src), src_IPv6, INET6_ADDRSTRLEN);
    inet_ntop(AF_INET6, &(ip_6_header->ip6_dst), dest_IPv6, INET6_ADDRSTRLEN);

    /* Store IPs into packet structure */
    packet_s.src_ip = src_IPv6;
    packet_s.dst_ip = dest_IPv6;

    /* Identify the payload length and next header */
    packet_s.payload_len = ntohs(ip_6_header->ip6_plen);
    next_header = ip_6_header->ip6_nxt;

    /* Loop to process extension headers */
    const u_char *current_position = packet + sizeof(struct ether_header) + sizeof(struct ip6_hdr);
    while (next_header != IPPROTO_TCP && next_header != IPPROTO_UDP && next_header != IPPROTO_NONE) {
        /* Ensure we don't go past the payload length */
        if (current_position - packet >= packet_s.payload_len) {
            fprintf(stderr, "Reached end of packet while parsing extension headers. Skipping...\n");
            return;
        }

        ext_header = (struct ip6_ext *)current_position;

        /* Move to the next extension header */
        next_header = ext_header->ip6e_nxt;
        current_position += (ext_header->ip6e_len + 1) * 8; // Extension header length is in 8-byte units
    }

    /* Check for TCP */
    if (next_header == IPPROTO_TCP) {
        tcp_header = (struct tcphdr *)current_position;

        tcp_bytes_recv += packet_s.payload_len; // Update global stats for TCP bytes
        handle_tcp_header(tcp_header, &packet_s, 1); // Process the TCP packet

    /* Check for UDP */
    } else if (next_header == IPPROTO_UDP) {
        udp_header = (struct udphdr *)current_position;

        udp_bytes_recv += packet_s.payload_len; // Update global stats for UDP bytes

        /* Update the actual payload length from the UDP header */
        packet_s.payload_len = ntohs(udp_header->len);

        /* Process the UDP packet */
        handle_udp_header(udp_header, &packet_s, 1);

    /* Unsupported protocol */
    } else if (next_header == IPPROTO_NONE) {
        fprintf(stderr, "No next header. Skipping packet.\n");
        return;

    /* If not TCP or UDP, skip the packet */
    } else {
        fprintf(stderr, "Unsupported protocol in IPv6: %d. Skipping packet.\n", next_header);
        return;
    }
}


void packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet) {

    const struct ether_header *eth_header;
    uint16_t etherType;

    if (header->len < sizeof(struct ether_header)) {
	    fprintf(stderr, "Packet too small to contain Ethernet header. Skipping...\n");
	    return;
	}

    /* Extract the Ethernet header from the packet */
    eth_header = (struct ether_header *)packet;
    etherType = ntohs(eth_header->ether_type);

    /* Check the EtherType and process accordingly */
    if (etherType == ETHERTYPE_IP) { // IPv4
        handle_ipv4_packets(packet);
    } else if (etherType == ETHERTYPE_IPV6) { // IPv6
        handle_ipv6_packets(packet);
    }

    packet_counter++;

}

void add_node(node **head_arg, flow_packet *packet) {
    node *new_node = (node *)malloc(sizeof(node));
	new_node->packet = packet; 
	new_node->next = (*head_arg);
	(*head_arg) = new_node;
}


void print_packet(packet_t *packet) {
    if (packet == NULL) {
        fprintf(stderr, "Error: Packet is NULL.\n");
        return;
    }

    fprintf(fp, "-------------------PACKET-------------------\n");
    fprintf(fp, "| SOURCE IP: %s\tPORT: %d\n", 
            packet->src_ip, packet->src_prt);
    fprintf(fp, "| DEST IP:  %s\tPORT: %d\n", 
            packet->dst_ip, packet->dst_prt);
    fprintf(fp, "| PROTOCOL: %s\n", 
            packet->protocol);
    fprintf(fp, "| HEADER SIZE: %d\n", packet->header_len);
    fprintf(fp, "| PAYLOAD SIZE: %d\n", packet->payload_len);
    fprintf(fp, "| PAYLOAD MEMORY LOCATION: %p\n", packet->payload_loc);
    fprintf(fp, "| RETRANSMITTED: %s\n", packet->retrans ? "Y" : "N");
    fprintf(stdout,"-------------------PACKET-------------------\n"
               "| SOURCE IP: %s\tPORT: %d\n"
               "| DEST IP:  %s\tPORT: %d\n"
               "| PROTOCOL: %s\n"
               "| HEADER SIZE: %d\n"
               "| PAYLOAD SIZE: %d\n"
               "| PAYLOAD MEMORY LOCATION: %p\n"
               "| RETRASMITTED: %s\n",
            packet->src_ip, packet->src_prt,
            packet->dst_ip, packet->dst_prt,
            packet->protocol,
            packet->header_len,
            packet->payload_len,
            packet->payload_loc,
            (packet->retrans)?"Y":"N");
}


/* Check duplicate */
int exists(node *head_arg, flow_packet *packet) {

    node *tmp = head_arg;
    if (head_arg == NULL) {
        return 0;
    }
    while (tmp != NULL) {
        if (check_flow(tmp->packet, packet)) {
            return 1; // Duplicate packet detected
        }
        tmp = tmp->next;
    }
    return 0; // No duplicates
}

void exit_parse(void){
    printf("----------------EXIT----------------\n"
           "Total network flows captured: %d\n"
           "TCP network flows: %d\n"
           "UDP network flows: %d\n"
           "Total packets received: %d\n"
           "TCP packets received: %d\n"
           "UDP packets received: %d\n"
           "Total TCP bytes received: %d\n"
           "Total UDP bytes received: %d\n"
           "----------------EXIT----------------\n",
            net_flows,
            tcp_net_flows,
            udp_net_flows,
            packet_counter,
            tcp_packs_recv,
            udp_packs_recv,
            tcp_bytes_recv,
            udp_bytes_recv);
    fprintf(fp, "----------------EXIT----------------\n");
    fprintf(fp, "Total network flows captured: %d\n", net_flows);
    fprintf(fp, "TCP network flows: %d\n", tcp_net_flows);
    fprintf(fp, "UDP network flows: %d\n", udp_net_flows);
    fprintf(fp, "Total packets received: %d\n", packet_counter);
    fprintf(fp, "TCP packets received: %d\n", tcp_packs_recv);
    fprintf(fp, "UDP packets received: %d\n", udp_packs_recv);
    fprintf(fp, "Total TCP bytes received: %d\n", tcp_bytes_recv);
    fprintf(fp, "Total UDP bytes received: %d\n", udp_bytes_recv);
    fprintf(fp, "----------------EXIT----------------\n");
    fflush(fp);
    cleanup();
    exit(EXIT_SUCCESS);
}


void cleanup(void) {
    node *tmp = head;
	while (tmp != NULL) {
	    node *next = tmp->next;

	    if (tmp->packet) {
	        free(tmp->packet); // Free the dynamically allocated packet
	    }
	    free(tmp); // Free the node itself

	    tmp = next;
	}
	head = NULL; // Ensure head is reset to NULL
}


int check_flow(flow_packet * a, flow_packet * b){

    if (strcmp(a->protocol, b->protocol) != 0) {
        return 0; // Protocols do not match
    }

    // Check forward direction
    if ((strcmp(a->src_ip, b->src_ip) == 0 && a->src_prt == b->src_prt) &&
        (strcmp(a->dst_ip, b->dst_ip) == 0 && a->dst_prt == b->dst_prt)) {
        return 1;
    }

    // Check reverse direction
    if ((strcmp(a->src_ip, b->dst_ip) == 0 && a->src_prt == b->dst_prt) &&
        (strcmp(a->dst_ip, b->src_ip) == 0 && a->dst_prt == b->src_prt)) {
        return 1;
    }

    return 0; 
}

int is_retransmission(node *head_arg, flow_packet *b) {

	flow_packet *a;
	node *tmp = head_arg;
    if (head_arg == NULL) {
        return 0;
    }
    while (tmp != NULL) {
    	a = tmp->packet;
        // Check if protocol, source, and destination match
    	if (strcmp(a->protocol, b->protocol) == 0 &&
	        strcmp(a->src_ip, b->src_ip) == 0 && a->src_prt == b->src_prt &&
	        strcmp(a->dst_ip, b->dst_ip) == 0 && a->dst_prt == b->dst_prt) {
	        
	        // Compare sequence numbers
	        if (a->sequence == b->sequence) {
	            // Check if payload matches
	            if (strcmp(a->payload, b->payload) == 0) {
	                return 1; // Retransmission detected
	            }
	        }
    	}
        tmp = tmp->next;
    }
    
    return 0; // Not a retransmission
}