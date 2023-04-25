#!/bin/bash


function pkg_exits_or_exit() {
    # shellcheck disable=SC2124
    local tools=$@
    for tool in ${tools}; do
        # shellcheck disable=SC214
        if rpm -q $tool &> /dev/null; then
            echo -e "\033[1;32m ${tool} present \033[0m"
        else
            echo -e "\033[1;31m ${tool} missing"
            EXIT_CODE=1
        fi
    done
    if [[ $EXIT_CODE -eq 1 ]]; then
        echo -e "\033[0;31m exiting due to package missing .."
        exit 1
    fi
}

DEV_NAME=$1
# TODO : make it dynamic
NM_NAME="Wired connection 1"

if [ -z "$DEV_NAME" ]; then
    echo "Usage: $0 <dev_name>"
    exit 1
elif [ $(ip addr show $DEV_NAME > /dev/null 2>&1) $? -ne 0 ]; then
    echo -e "\033[1;31m Device $DEV_NAME not found"
    exit 1
fi

pkg_exits_or_exit NetworkManager-ovs openvswitch

# https://blog.christophersmart.com/2020/07/27/how-to-create-linux-bridges-and-open-vswitch-bridges-with-networkmanager/
# https://www.redhat.com/sysadmin/networkmanager-ovs-bridges

echo -e "\n\n"
echo -e "\033[1;32m Creating ovs-bridge for $DEV_NAME"

# create ovs-bridge port and interface

nmcli con add type ovs-bridge conn.interface ovs-bridge con-name ovs-bridge
nmcli con add type ovs-port conn.interface port-ovs-bridge master ovs-bridge con-name ovs-bridge-port
nmcli con add type ovs-interface slave-type ovs-port conn.interface ovs-bridge master ovs-bridge-port con-name ovs-bridge-int

# create another port on the bridge and patch in our physical device as an Ethernet interface so that real traffic can flow across the network
nmcli con add type ovs-port conn.interface ovs-port-eth master ovs-bridge con-name ovs-port-eth
nmcli con add type ethernet conn.interface "${DEV_NAME}" master ovs-port-eth con-name ovs-port-eth-int

# By default the OVS bridge will be sending untagged traffic and requesting an IP address for ovs-bridge via DHCP.
# If you don’t want it to be on the network (you might have another dedicated interface) then disable DHCP on the interface.

#nmcli con modify ovs-bridge-int ipv4.method disabled ipv6.method disabled
#nmcli con modify ovs-bridge-int ipv4.method static ipv4.address 192.168.123.100/24

nmcli con down "${NM_NAME}" ; \
nmcli con up ovs-port-eth-int ; \
nmcli con up ovs-bridge-int
