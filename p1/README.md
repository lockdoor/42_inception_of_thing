# Preparing
This project will deploy on ubuntu server
app requirement
- vagrant
- libvirt

[Install Vagrant](https://developer.hashicorp.com/vagrant/install)
```
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

Install libvirt
```
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libvirt-dev build-essential
sudo usermod -aG libvirt,kvm $USER
newgrp libvirt
```

Set up vagrant plugin
```
vagrant plugin install vagrant-libvirt
```

# Testing

## Copy kubectl config

รันบนเครื่อง Host เพื่อดึง config ออกมา
```
vagrant ssh pnamnilS -c "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config-k3s
```

แก้ไข Server IP ข้างใน จาก 127.0.0.1 ให้เป็น IP ของ Server VM
```
sed -i 's/127.0.0.1/192.168.56.110/g' ~/.kube/config-k3s
```

ตั้่งค่า ENV KUBECONFIG ถ้าไม่มีค่านี้ kubectl จะถือเอา ~/.kube/config เป็นค่าเริ่มต้น
```
export KUBECONFIG=~/.kube/config-k3s
```

list context
```
kubectl config get-contexts
```

## Cluster infomation
list node
```
kubectl get node -o wide
```

## Clear kubectl config
```
unset KUBECONFIG
```