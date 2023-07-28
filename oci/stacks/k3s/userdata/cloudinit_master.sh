#!/bin/bash 

NETWORK_ADAPTER=$(ip -o -4 route show to default|awk '{print $5}'|uniq)
IP_ADDRESS=$(ip -o -4 addr show $NETWORK_ADAPTER | awk '{print $4}' | cut -d "/" -f 1)

echo "Waiting for all VCN resources to be ready"
sleep 60

echo "Add 6443 to firewall"
sudo iptables -I INPUT -p tcp -m tcp --dport 6443 -j ACCEPT

echo "Update all packages"
sudo apt-get update -y

echo "Install K3s"
curl -sfL https://get.k3s.io | sh -s - server --advertise-address $IP_ADDRESS