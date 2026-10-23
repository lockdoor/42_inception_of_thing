#! /bin/bash

SERVER_IP="192.168.56.110"
TOKEN=$(cat /vagrant/token/node-token)
INTERFACE=$(ip -o -4 addr show to $SERVER_IP | awk '{print $2}')

# Setup K3s Server with bind interface eth1 and IP 192.168.56.110
curl -sfL https://get.k3s.io | K3S_TOKEN=$TOKEN \
INSTALL_K3S_EXEC="server --node-ip=${SERVER_IP} --flannel-iface=${INTERFACE}" sh -s -

# set kubectl for user vagrant
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.profile
