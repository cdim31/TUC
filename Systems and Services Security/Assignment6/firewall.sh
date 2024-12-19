#!/bin/bash
# You are NOT allowed to change the files' names!
config="config.txt"
rulesV4="rulesV4"
rulesV6="rulesV6"

function configure() {

    # Check if file exists
    if [[ ! -f $config ]]; then 
        echo "File ${config} not found!"
        exit 1
    fi
    
    # Read each line of the config file
    while IFS= read -r line; do

        # Check if IPv4
        if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then 
            echo "Blocking IPv4: $line"
            sudo /usr/sbin/iptables -A INPUT -s "$line" -j REJECT

        # Check if IPv6
        elif [[ $line =~ ^([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}$ ]]; then 
            echo "Blocking IPv6: $line"
            sudo /usr/sbin/ip6tables -A INPUT -s "$line" -j REJECT

        # Check if domain name 
        elif [[ $line =~ ^[a-zA-Z0-9.-]+$ ]]; then 
            # Resolve IPv4 addresses
            for ip in $(dig +short "$line" A); do
                if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo "Blocking IPv4: $ip for domain $line"
                    sudo iptables -A INPUT -s "$ip" -j REJECT
                else
                    echo "Invalid IPv4 address: $ip for domain $line"
                fi
	        done

            # Resolve IPv6 addresses
            for ip6 in $(dig +short "$line" AAAA); do
                if [[ $ip6 =~ ^([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}$ ]]; then
                    echo "Blocking IPv6: $ip6 for domain $line"
                    sudo ip6tables -A INPUT -s "$ip6" -j REJECT
                else
                    echo "Invalid IPv6 address: $ip6 for domain $line"
                fi
            done

        fi
    done < "$config"
}

function firewall() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-config"  ]; then
        
        configure
        true
        
    elif [ "$1" = "-save"  ]; then

        # Saving rules to the proper files
        echo "Saving IPv4 rules to $rulesV4"
        sudo /usr/sbin/iptables-save > "$rulesV4"

        echo "Saving IPv6 rules to $rulesV6" 
        sudo /usr/sbin/ip6tables-save > "$rulesV6"

        echo "Rules saved succesfully."
        true
        
    elif [ "$1" = "-load" ]; then
        
        # Loading rules from saved files
        if [[ -f $rulesV4 ]]; then 

            echo "Loading from: $rulesV4"
            sudo /usr/sbin/iptables-restore < "$rulesV4"
        else
            echo "File $rulesV4 not found"
        fi
        if [[ -f $rulesV6 ]]; then

            echo "Loading from: $rulesV6"
            sudo /usr/sbin/ip6tables-restore < "$rulesV6"
        else
            echo "File $rulesV6 not found"
        fi
        true

        
    elif [ "$1" = "-reset" ]; then

        # Reset IPv4/IPv6 rules to default settings (i.e. accept all).
        echo "Ressetting IPv4/IPv6 rules to default settings"

        # Remove all rules in the INPUT chain (we only make changes there)
        # and set the tables back to default settings (allow all incoming traffic)
        sudo /usr/sbin/iptables -F INPUT && sudo /usr/sbin/iptables -P INPUT ACCEPT 
        sudo /usr/sbin/ip6tables -F INPUT && sudo /usr/sbin/ip6tables -P INPUT ACCEPT

        echo "Rules are set back to default settings."
        true

        
    elif [ "$1" = "-list" ]; then

        # List IPv4/IPv6 current rules.
        echo "IPv4 Rules list:"
        sudo /usr/sbin/iptables -L -n -v

        echo ""

        echo "IPv6 Rules list:"
        sudo /usr/sbin/ip6tables -L -n -v

        true
        
    elif [ "$1" = "-help" ]; then
        printf "This script is responsible for creating a simple firewall mechanism. It rejects connections from specific domain names or IP addresses using iptables/ip6tables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -config\t  Configure adblock rules based on the domain names and IPs of '$config' file.\n"
        printf "  -save\t\t  Save rules to '$rulesV4' and '$rulesV6'  files.\n"
        printf "  -load\t\t  Load rules from '$rulesV4' and '$rulesV6' files.\n"
        printf "  -list\t\t  List current rules for IPv4 and IPv6.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

firewall $1
exit 0
