#! /bin/bash

# Check if token is available
if [ ! -f /home/vagrant/confs/token ]; then
    echo "No token found, please check pnamnilS first"
    exit 1
fi

# Install k3s for worker node with bind interface eth1 and IP 192.168.56.111
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 \
    K3S_TOKEN=$(cat /home/vagrant/confs/token) \
    INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1" sh -s -

# Remove token file (not need anymore)
rm /home/vagrant/confs/token
