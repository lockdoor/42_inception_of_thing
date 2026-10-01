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

list deploy
```
kubectl get deploy
```

list pod
```
kubectl get pod -o wide
```

list service
```
kubectl get service
```

list ingres
```
kubectl get ingress
```

list configmap
```
kubectl get configmap
kubectl describe cm iot-configmap
```

## Test App
```
curl http://192.168.56.110
curl -H "Host: app1.com" http://192.168.56.110
curl http://app2.com --resolve app2.com:80:192.168.56.110
curl http://app3.com --connect-to app3.com:80:192.168.56.110:80
```

## Clear kubectl config
```
unset KUBECONFIG
```
