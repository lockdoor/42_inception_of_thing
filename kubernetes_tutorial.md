# Deploy an app
```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

# Expose public app
```
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
```

# Scale app
```
kubectl get rs
kubectl scale deployments/kubernetes-bootcamp --replicas=4
```

# Update app
```
# set image to version 2
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=docker.io/jocatalin/kubernetes-bootcamp:v2

# check rollout status
kubectl rollout status deployments/kubernetes-bootcamp
```

# Clean up cluster
```
kubectl delete deployments/kubernetes-bootcamp services/kubernetes-bootcamp
```
