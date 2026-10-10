Gitlab will load image like this
```
pnamnil@cadet:~/workshop/42_inception_of_thing/bonus$ docker exec -it k3d-demo-server-0 crictl images
IMAGE                                                           TAG                            IMAGE ID            SIZE
docker.io/rancher/klipper-lb                                    v0.4.17                        eaa1212a2b456       5.28MB
docker.io/rancher/mirrored-coredns-coredns                      1.14.3                         f713ee04ec58a       23.5MB
docker.io/rancher/mirrored-library-busybox                      1.37.0                         ff7a7936e9306       2.15MB
docker.io/rancher/mirrored-metrics-server                       v0.8.1                         e76b3f3568b7f       22.6MB
docker.io/rancher/mirrored-pause                                3.6                            6270bb605e12e       301kB
quay.io/minio/aistor/minio-sidecar                              RELEASE.2026-09-18T00-46-19Z   83d41c38204b2       12.4MB
quay.io/minio/aistor/minio                                      RELEASE.2026-09-07T08-39-31Z   2cacca14bad45       130MB
quay.io/minio/aistor/operator                                   RELEASE.2026-09-18T18-03-16Z   70d5e3f8e2d93       39.9MB
registry-1.docker.io/bitnami/postgresql                         latest                         67595a28dcc9c       135MB
registry.gitlab.com/gitlab-org/build/cng/certificates           v19.4.1                        1f972ace8970a       68.6MB
registry.gitlab.com/gitlab-org/build/cng/cfssl-self-sign        v19.4.1                        c10342aadc70a       10.9MB
registry.gitlab.com/gitlab-org/build/cng/gitaly                 v19.4.1                        40da5d1277ae4       477MB
registry.gitlab.com/gitlab-org/build/cng/gitlab-base            v19.4.1                        ed9ae12af8a95       68.6MB
registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter        17.0.2                         2a88a59ebd701       130MB
registry.gitlab.com/gitlab-org/build/cng/gitlab-shell           v14.57.3                       18e64fbd8b16f       152MB
registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ce      v19.4.1                        f313457f1c926       1.16GB
registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ce      v19.4.1                        2f5829c0ea7bc       1.17GB
registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ce   v19.4.1                        102836020e99d       1.09GB
registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ce    v19.4.1                        8c91975788421       635MB
registry.gitlab.com/gitlab-org/build/cng/kubectl                v19.4.1                        0b4b14b5388b2       78.8MB
```

when helm chart install, a lot of images are load. It spend many time. we must setup cache for these registry. we can check cache work with
```
curl -s http://localhost:5001/v2/_catalog
```

maybe helm install chart gitlab failed cause reach time limit cause download a lot of images, we can use
```
kubecel delete job [all job of git lab]
```
then run again

we can view all image use in cluster
```
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```

## Gitlab root password
First time can get Gitlab root password by secret
```
k get secret gitlab-gitlab-initial-root-password  -n gitlab -o jsonpath="{.data['password']}" | base64 -d
YN06RO75QbNmvfsuU10PmpDfJnyrHtunWc7cngAvxmO4zyuHKEx4bBkveofrLiSj
```
after that password will seed into database 
if you delete cluster and create again 
gitlab will check if database exist it omit seed new
but secret password still generate
if you forget root password can reset by toolboxs
```
TOOLBOX_POD=$(kubectl get pod -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n gitlab $TOOLBOX_POD -- gitlab-rails runner "user = User.find_by_username('root'); user.password = 'MySecretGitLabPass123!'; user.password_confirmation = 'MySecretGitLabPass123!'; user.save!"
```
for init password when gitlab install create secret before install gitlab
```
kubectl create secret generic gitlab-gitlab-initial-root-password \
  -n gitlab \
  --from-literal=password='MySecretGitLabPass123!' \
  --dry-run=client -o yaml | kubectl apply -f -
```