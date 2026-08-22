# First VM from Vagrant

First Vagrant Script in Vagrantfile
```
Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-16.04"
    config.vm.box_version = "202212.11.0"

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