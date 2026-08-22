# [Vargrant tutorial](https://developer.hashicorp.com/vagrant/tutorials/get-started)

Installation with homebrew or binary download

# [Ubuntu image](https://www.osboxes.org/ubuntu-server/)

Select Ubuntu server latest: 25.04

Credentials for images:
- username: osboxes
- password: osboxes.org
- Root account password: osboxes.org

# [K3S tutorial](https://docs.k3s.io/quick-start)

Installation
```
curl -Lo /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/v1.26.5+k3s1/k3s; chmod a+x /usr/local/bin/k3s
```
When provision in vagrant it use root privilege K3S will download to /usr/local/bin. User vagrant can access this path.

[https://www.youtube.com/watch?v=tzj59F02TFU](Stop Avoiding Kubernetes - Set Up a K3S Cluster at Home)
