#!/bin/bash

# Refresh the ARP table used to look up IP from MAC address by pinging the network
IP_AND_MASK=`ifconfig | grep "inet addr" | head -n1 | sed 's|.*addr:\([0-9\.]*\).*Mask:\([0-9\.]*\)|\1/\2|g'`
NETWORK=`ipcalc "$IP_AND_MASK" | grep "Network:" | sed 's|^Network:\s*\([0-9/\.]*\).*|\1|g'`
# Backgrounding speed hack to speed up results if arp table is full, may cause issues when run the first time showing null IPs
(nmap -sP "$NETWORK" &> /dev/null)&

# Get a list of all of the guest names from virsh
VIRTUAL_MACHINES=(`virsh list | tail -n+3 | sed '/^$/d' | sed 's/ *[0-9]\+ *\([A-Za-z0-9]\+\) .*/\1/'`)

# Print out the table headers for the network table
printf " %-32s %-20s %-15s\n" "Machine" "Mac Address" "IP Address"
s=$(printf "%-70s" "-")
echo "${s// /-}"

# Print out each line of the machine table
for MACHINE in ${VIRTUAL_MACHINES[@]}; do
	#printf "%s\n" $MACHINE
	MAC_ADDRESS=`virsh dumpxml $MACHINE | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/"`
        IPADDRESS=`arp -en | grep $MAC_ADDRESS | sed 's/^\([0-9.]\+\).*/\1/'`
        printf  " %-32s %-20s %-15s\n" "$MACHINE" "$MAC_ADDRESS" "$IPADDRESS"
done
exit 0
