# Part 3: K3d and Argo CD

## Requirement
- Docker
- k3d
- kubectl
- kubectx (kubens)
- argo cd
- github account
- docker hub account
- webserver image to test the deployment, it has at least two version
    

## Project Goal
- Use Argo CD to deploy the IoT application to the k3d cluster.
- Argo will watch github repository when push event, it will automatically deploy and update the application.
- Flow:
    - First app is deploy with image v1
    - Change image to v2 and push to github
    - Argo CD will detect the change and deploy the application with image v2
    - Check if the application is deployed with image v2
    - If wrong version, rollback to image last deploy

## Check list

Run project with Makefile. When everything successed we can use these command for check list

### K3d/K3s cluster

list cluster
```
k3d cluster list
```

### Kubectl context and cluster

When k3d created cluster it will merge kubectl config to ~/.kube/config automaticaly.

We can use kubectl for get cluster infomation
```
kubectl get node
```

We can use Cluster Infomation in ../p2/README.md for get information of cluster

Check namespace
```
kubens
```

We can check deployment from namespace like this
```
kubectl get deploy -n argocd
```

Change namespace with kubens
```
kubens argocd
```

Check argocd manage app
```
argocd app list
```

For default of argocd the app still status out of sync, first check namespace dev is empty deploy.
```
kubectl get deploy -n dev
```

We must manual sync for first of deployment
```
argocd app sync wil-app
```

let test app is run with version specific.
```
curl http://localhost:8888
```

We can update file in ./confs then push to branch spacific revision when use argocd app create will-app (can review code in Mackfile). Argocd will polling automatic by default 3 minutes estimate. 
