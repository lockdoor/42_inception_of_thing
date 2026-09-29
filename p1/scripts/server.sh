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
# cat /var/lib/rancher/k3s/server/node-token >> /home/vagrant/confs/token

# รอให้ k3s สร้าง node-token ให้เสร็จ
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 2
done

# ก๊อปปี้ token ออกมาให้ user vagrant อ่านได้
cp /var/lib/rancher/k3s/server/node-token /home/vagrant/node-token
chmod 644 /home/vagrant/node-token

# อนุญาตให้เข้า ssh ด้วย password หรือใช้ ssh-key
echo "vagrant:vagrant" | chpasswd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
