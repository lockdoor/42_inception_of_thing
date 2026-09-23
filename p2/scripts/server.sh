#! /bin/bash

# Install K3s Server with bind eth1 and ip 192.168.56.110
curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --flannel-iface=eth1" sh -s -

# set user vagrant can run kubectl
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc
echo 'alias k=kubectl' >> /home/vagrant/.bashrc
ln -s /mnt/confs /home/vagrant/confs

# Apply kustomaized manifest
kubectl apply -k ./confs