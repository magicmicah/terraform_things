#!/bin/bash 

MASTER_NODE_IP=${k3s_master_ip}
MASTER_NODE_TOKEN=${k3s_master_token}

echo $MASTER_NODE_IP
echo $MASTER_NODE_TOKEN

echo "Waiting for all VCN resources to be ready"
sleep 60

echo "Update all packages"
sudo apt-get update -y

echo "Install K3s"
# curl -sfL https://get.k3s.io | sh - 
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_NODE_IP:6443 K3S_TOKEN=$MASTER_NODE_TOKEN sh -