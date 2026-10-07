# Project to deploy Gitlab and Argocd

# Gitlab has many dependency following 
# - posgresql
# - redis
# - file storage like S3(AWS)

-include secrets.env
export



# Directory
GITLAB_CONFIGS_DIR = $(PWD)/confs/gitlab
MINIO_LICENSE_FILE = $(GITLAB_CONFIGS_DIR)/secrets/minio-license-key


.PHONY: all cluster gitlab-secrets gitlab-postgresql gitlab-pgweb \
gitlab-redis gitlab-minio gitlab-cert gitlab-ingress clean


all:
	$(MAKE) check-secrets
	$(MAKE) cluster
	$(MAKE) gitlab-cert
	$(MAKE) gitlab-postgresql
	$(MAKE) gitlab-pgweb
	$(MAKE) gitlab-redis
	$(MAKE) gitlab-minio


# ตรวจสอบว่ามีตัวแปรครบก่อนเริ่มงาน
check-secrets:
	@if [ ! -f secrets.env ]; then \
		echo "ERROR: secrets.env not found! Please copy secrets.env.example to secrets.env"; \
		exit 1; \
	fi
	@if [ -z "$(MINIO_ROOT_USER)" ] ; then \
		echo "ERROR: MINIO_ROOT_USER is empty in secrets.env"; \
		exit 1; \
	elif [ -z "$(MINIO_ROOT_PASSWORD)" ] ; then \
		echo "ERROR: MINIO_ROOT_PASSWORD is empty in secrets.env"; \
		exit 1; \
	elif [ -z "$(MINIO_LICENSE)" ] ; then \
		echo "ERROR: MINIO_LICENSE is empty in secrets.env"; \
		exit 1; \
	elif [ -z "$(POSTGRES_PASSWORD)" ] ; then \
		echo "ERROR: POSTGRES_PASSWORD is empty in secrets.env"; \
		exit 1; \
	elif [ -z "$(REDIS_PASSWORD)" ] ; then \
		echo "ERROR: REDIS_PASSWORD is empty in secrets.env"; \
		exit 1; \
	fi

cluster:
	@ echo "Create K3d Cluster"
	@ k3d cluster create demo --servers 1 --agents 1 \
		--port "443:443@loadbalancer" \
		--port "80:80@loadbalancer" \
		--wait > /dev/null
	kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
	kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/gitlab --timeout=30s


gitlab-postgresql:
	# This App required secret key, apply secret in "./confs/secrets" before start app
	# helm repository
	helm repo add bitnami https://charts.bitnami.com/bitnami

	# 1. รหัสผ่าน PostgreSQL
	kubectl create secret generic postgresql-secret \
	--namespace gitlab \
	--from-literal=postgresql-password=$(POSTGRES_PASSWORD) \
	--from-literal=password=$(POSTGRES_PASSWORD) \
	--dry-run=client -o yaml | kubectl apply -f -
	kubectl wait --for=create secret/postgresql-secret -n gitlab --timeout=30s

	# postgresql
	helm upgrade --install postgresql bitnami/postgresql \
	--namespace gitlab --create-namespace \
	--set auth.database="gitlabhq_production" \
	--set auth.username="gitlab" \
	--set auth.existingSecret=postgresql-secret \
	-f $(GITLAB_CONFIGS_DIR)/values/postgresql-values.yaml \
	--wait --timeout 5m


gitlab-pgweb:
	kubectl apply -f $(GITLAB_CONFIGS_DIR)/pgweb-deploy.yaml

# Make scheme for authen
gitlab-pgweb-authen:
	@echo "postgres://gitlab:$(POSTGRES_PASSWORD)@postgresql:5432/gitlabhq_production?sslmode=disable"


gitlab-redis:
	# Install dependency
	helm repo add bitnami https://charts.bitnami.com/bitnami

	# 1. รหัสผ่าน Redis
	kubectl create secret generic redis-secret \
	--namespace gitlab \
	--from-literal=password=$(REDIS_PASSWORD) \
	--dry-run=client -o yaml | kubectl apply -f -
	kubectl wait --for=create secret/redis-secret -n gitlab --timeout=30s

	# redis
	helm upgrade --install gitlab-redis bitnami/redis \
		--namespace gitlab --create-namespace \
		--set auth.password=$(REDIS_PASSWORD) \
		--set replica.replicaCount=1 \
		--wait --timeout 5m


gitlab-minio:
	# https://docs.min.io/aistor/installation/kubernetes/install/deploy-aistor-on-kubernetes/#configure-and-deploy-the-minioaistor-objectstore-chart
	helm repo add minio https://helm.min.io/
	# because 1 operator for control all cluster we should create operator seperate namespace
	@helm upgrade --install aistor minio/aistor-operator \
		-n aistor-operator --create-namespace \
		--set license=$(MINIO_LICENSE) \
		--wait --timeout 5m
	# we can create objectstore for each namespace
	@helm upgrade --install objectstore minio/aistor-objectstore \
		-n gitlab --create-namespace \
		-f $(GITLAB_CONFIGS_DIR)/values/minio-values.yaml \
		--set secrets.accessKey=$(MINIO_ROOT_USER) \
		--set secrets.secretKey=$(MINIO_ROOT_PASSWORD) \
		--wait --timeout 5m
	# apply ingress
	@kubectl apply -f $(GITLAB_CONFIGS_DIR)/minio-ingress.yaml

bucket:
	@echo "Waiting for MinIO pod to be ready..."
	@kubectl wait --namespace gitlab \
		--for=condition=ready pod \
		-l aistor.min.io/objectStore=primary-object-store \
		--timeout=120s
	@echo "Creating GitLab buckets via MinIO pod exec..."
	@POD_NAME=$$(kubectl get pod -n gitlab -l aistor.min.io/objectStore=primary-object-store -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -n gitlab $$POD_NAME -- \
		mc alias set local https://localhost:9000 $(MINIO_ROOT_USER) $(MINIO_ROOT_PASSWORD) --insecure && \
	kubectl exec -n gitlab $$POD_NAME -- \
		mc --insecure mb --ignore-existing \
			local/gitlab-artifacts \
			local/gitlab-lfs \
			local/gitlab-packages \
			local/gitlab-uploads \
			local/runner-cache \
			local/registry
	@echo "All buckets created successfully!"

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


gitlab-secret:
	@printf "provider: AWS\nregion: us-east-1\naws_access_key_id: %s\naws_secret_access_key: %s\nendpoint: https://primary-object-store-hl.gitlab.svc.cluster.local:9000\npath_style: true\n" \
		"$(MINIO_ROOT_USER)" "$(MINIO_ROOT_PASSWORD)" | \
		kubectl create secret generic gitlab-s3-connection \
			--namespace gitlab \
			--from-file=connection=/dev/stdin \
			--dry-run=client -o yaml | kubectl apply -f -
	@echo "Secret gitlab-s3-connection created successfully!"

gitlab:
	helm repo add gitlab https://charts.gitlab.io/
	# helm repo update
	helm upgrade --install gitlab gitlab/gitlab \
	--timeout 600s --wait \
	-f $(GITLAB_CONFIGS_DIR)/values/gitlab-values.yaml \
	--set global.psql.password.secret=postgresql-secret \
	--set global.psql.password.key=password \
	--set global.redis.auth.secret=redis-secret \
	--set global.redis.auth.key=password \
	--set global.appConfig.object_store.connection.secret=gitlab-s3-connection \
	--set global.appConfig.object_store.connection.key=connection


clean:
	k3d cluster delete demo

# get secret
# kubectl get secret [secret-name] -n [namespace] -o jsonpath="{.data['config\.env']}" | base64 -d