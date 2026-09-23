#! /bin/bash

# Setup K3s Server with bind interface eth1 and IP 192.168.56.110
curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --flannel-iface=eth1" sh -s -

# set kubectl for user vagrant
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

# copy node token
cat /var/lib/rancher/k3s/server/node-token >> /home/vagrant/confs/token
