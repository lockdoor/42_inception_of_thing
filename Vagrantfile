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
