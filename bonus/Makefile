# Project to deploy Gitlab and Argocd

# Gitlab has many dependency following 
# - posgresql
# - redis
# - file storage like S3(AWS)



# Directory
GITLAB_CONFIGS_DIR = $(PWD)/confs/gitlab
MINIO_LICENSE_FILE = $(GITLAB_CONFIGS_DIR)/secrets/minio-license-key


.PHONY: all cluster gitlab-secrets gitlab-postgresql gitlab-pgweb \
gitlab-redis gitlab-minio gitlab-cert gitlab-ingress clean


all:
	$(MAKE) cluster
	$(MAKE) gitlab-secrets
	$(MAKE) gitlab-postgresql
	$(MAKE) gitlab-pgweb
	$(MAKE) gitlab-redis
	$(MAKE) gitlab-minio
	$(MAKE) gitlab-cert
	$(MAKE) gitlab-ingress


cluster:
	@ echo "Create K3d Cluster"
	@ k3d cluster create demo --servers 1 --agents 1 \
		--port "443:443@loadbalancer" \
		--port "80:80@loadbalancer" \
		--wait > /dev/null


gitlab-secrets:
	kubectl apply -f $(GITLAB_CONFIGS_DIR)/namespace.yaml
	@echo "Waiting for namespace to be Active..."
	kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/gitlab --timeout=30s
	kubectl apply -f $(GITLAB_CONFIGS_DIR)/secrets/secrets.yaml
	@echo "Waiting for secret to be created..."
	kubectl wait --for=create secret/postgresql-secret -n gitlab --timeout=30s
	kubectl wait --for=create secret/pgadmin-secret -n gitlab --timeout=30s


gitlab-postgresql:
	# This App required secret key, apply secret in "./confs/secrets" before start app
	# Install dependency
	helm repo add bitnami https://charts.bitnami.com/bitnami
	# postgresql
	helm upgrade --install postgresql bitnami/postgresql \
		--namespace gitlab --create-namespace \
		-f $(GITLAB_CONFIGS_DIR)/values/postgresql-values.yaml \
		--wait --timeout 5m


gitlab-pgweb:
	kubectl apply -f $(GITLAB_CONFIGS_DIR)/pgweb-deploy.yaml


gitlab-redis:
	# Install dependency
	helm repo add bitnami https://charts.bitnami.com/bitnami
	# redis
	helm upgrade --install gitlab-redis bitnami/redis \
		--namespace gitlab --create-namespace \
		--set auth.enabled=false \
		--wait --timeout 5m


gitlab-minio:
	# https://docs.min.io/aistor/installation/kubernetes/install/deploy-aistor-on-kubernetes/#configure-and-deploy-the-minioaistor-objectstore-chart
	helm repo add minio https://helm.min.io/
	# because 1 operator for control all cluster we should create operator seperate namespace
	helm install aistor minio/aistor-operator \
		-n aistor-operator --create-namespace \
		--set license=$(shell cat $(MINIO_LICENSE_FILE)) \
		--wait --timeout 5m
	# we can create objectstore for each namespace
	helm install objectstore minio/aistor-objectstore \
		-n gitlab --create-namespace \
		-f $(GITLAB_CONFIGS_DIR)/values/minio-values.yaml \
		-f $(GITLAB_CONFIGS_DIR)/secrets/minio-secrets.yaml \
		--wait --timeout 5m


gitlab-cert:
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout gitlab-tls.key \
		-out gitlab-tls.crt \
		-subj "/CN=cadet.in.th" \
		-addext "subjectAltName = DNS:minio-console.cadet.in.th, DNS:cadet.in.th"
	kubectl create secret tls gitlab-tls \
		--cert=gitlab-tls.crt \
		--key=gitlab-tls.key \
		--namespace=gitlab \
		--dry-run=client -o yaml | kubectl apply -f -
	kubectl wait --for=create secret/gitlab-tls -n gitlab --timeout=30s
	rm -f gitlab-tls.crt gitlab-tls.key

gitlab-ingress:
	kubectl apply -f $(GITLAB_CONFIGS_DIR)/ingress.yaml
	# test
	# curl -i --resolve gitlab-pgweb.cadet.in.th:80:127.0.0.1 http://gitlab-pgweb.cadet.in.th
	# curl -i -H "host: gitlab-pgweb.cadet.in.th" http://localhost
	# curl -ik --resolve minio-console.cadet.in.th:443:127.0.0.1 https://minio-console.cadet.in.th
	# curl -so /dev/null -w "%{http_code}" --resolve gitlab-pgweb.cadet.in.th:80:127.0.0.1 http://gitlab-pgweb.cadet.in.th
	# curl -so /dev/null -w "%{http_code}" --insecure --resolve minio-console.cadet.in.th:443:127.0.0.1 https://minio-console.cadet.in.th

clean:
	k3d cluster delete demo

# get secret
# kubectl get secret [secret-name] -n [namespace] -o jsonpath="{.data['config\.env']}" | base64 -d