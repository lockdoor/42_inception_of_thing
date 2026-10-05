# Project to deploy Gitlab and Argocd

Gitlab has many dependency following 
- postgresql
- redis
- file storage like S3(AWS)

## Install postgresql
For this StatefulSets we wiil use helm chart from bitnami, can read [First With helm](#first-with-helm). 
Makefile with 
```
make postgresql
```

## First With helm
[Cheat Sheet](https://helm.sh/docs/intro/cheatsheet/)
We can find helm chart following these step

list hub of helm chart
```
helm search hub --list-repo-url "bitnami postgresql"
```
We can see a lot of hub as list 
I will use repo https://charts.bitnami.com/bitnami
let add repo to local repository
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```
let check list of ropository
```
helm repo list
```
let list charts in this ropository
```
helm search repo bitnami | grep postgresql
```
for now we can found chart name like bitnami/postgresql then we can install app from this chart
```
	helm upgrade --install gitlab-postgresql bitnami/postgresql \
		--namespace gitlab --create-namespace \
		-f ./confs/values/postgresql-values.yaml
```
when finished we can view chart install (release) 
```
helm list
```

*** Can Search repo / chart via [artifacthub.io](https://artifacthub.io/)

## Install redis
For redis, bitnami also have redis.
Makefile with 
```
make redis
```

## Install file storage
