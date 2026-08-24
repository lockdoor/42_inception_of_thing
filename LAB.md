# Part I

First Vagrant Script in Vagrantfile
```
Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-16.04"

    config.vm.define "pnamnilS" do |pnamnilS|
        pnamnilS.vm.hostname = "pnamnilS"
        pnamnilS.vm.network "private_network", ip: "192.168.56.110"
        pnamnilS.vm.provider "virtualbox" do |vb|
            vb.cpus = "2"
            vb.memory = "2048"
        end
    end
end
```

Then run VM with command
```
vagrant up
```

Access to Guest VM
```
vagrant ssh
```

Check number of CPU core expected 2
```
nproc
```

Check RAM available expected 2048
```
free
```

# Provision 

When provision in vagrant it use root privilege to manage script 


# Install k3s

Install k3s on server
```
curl -sfL https://get.k3s.io | sh -
```

On server find token at
```
sudo cat /var/lib/rancher/k3s/server/node-token
```
K10d5ab4962b9b98cf6af9d252da2060380b51d2ece3b14afbbf9428d45424678a9::server:3984e98470cc08959de295eda4d7770a

Install k3s on agent 
```
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=K10d5ab4962b9b98cf6af9d252da2060380b51d2ece3b14afbbf9428d45424678a9::server:3984e98470cc08959de295eda4d7770a sh -
```

# Full Vagrant Script for Path I
```
Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-24.04"
    # config.vm.box_version = "202212.11.0"

    config.vm.define "pnamnilS" do |pnamnilS|
        pnamnilS.vm.hostname = "pnamnilS"
        pnamnilS.vm.network "private_network", ip: "192.168.56.110"
        pnamnilS.vm.provider "virtualbox" do |vb|
            vb.cpus = "2"
            vb.memory = "2048"
        end
        pnamnilS.vm.synced_folder "./node-token", "/home/vagrant/node-token", create:true

        pnamnilS.vm.provision "shell", inline: <<-SHELL
            # ติดตั้ง K3s Server โดยผูกเข้ากับ eth1 และ IP 192.168.56.110
            curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --flannel-iface=eth1" sh -s -

            # ตั้งค่าให้ user vagrant รัน kubectl ได้โดยตรง
            mkdir -p /home/vagrant/.kube
            sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
            sudo chown -R vagrant:vagrant /home/vagrant/.kube
            echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

            # copy node token
            if [ ! -f /home/vagrant/node-token/token ]; then
                cat /var/lib/rancher/k3s/server/node-token >> /home/vagrant/node-token/token;
            fi
        SHELL
    end

    config.vm.define "pnamnilSW" do |pnamnilSW|
        pnamnilSW.vm.hostname = "pnamnilSW"
        pnamnilSW.vm.network "private_network", ip: "192.168.56.111"
        pnamnilSW.vm.provider "virtualbox" do |vb|
            vb.cpus = "1"
            vb.memory = "1024"
        end
        pnamnilSW.vm.synced_folder "./node-token", "/home/vagrant/node-token", create:true
        pnamnilSW.vm.provision "shell", name: "init-server-worker", inline: <<-SHELL
            while [ ! -f /home/vagrant/node-token/token ]; do
                echo "Waiting for K3s token from server..."
                sleep 5
            done
            curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(cat /home/vagrant/node-token/token) sh -
            rm /home/vagrant/node-token/token
        SHELL
    end
end
```

# Check connection between control-plain node and worker node
```
vagrant@pnamnilS:~$ kubectl get nodes
NAME        STATUS   ROLES           AGE     VERSION
pnamnils    Ready    control-plane   2m31s   v1.36.3+k3s1
pnamnilsw   Ready    <none>          76s     v1.36.3+k3s1
```
