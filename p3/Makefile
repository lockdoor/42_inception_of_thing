ARGO_PORT = 8080
WIL_PORT = 8888

# https://argo-cd.readthedocs.io/en/stable/getting_started/

# subject want 1 cluster for 2 namespace argocd and dev

all: create-cluster dev argo
 
create-cluster:
	@ echo "Create K3d Cluster"
	@ k3d cluster create demo --servers 1 --agents 1 \
	--port "$(ARGO_PORT):$(ARGO_PORT)@loadbalancer" \
	--port "$(WIL_PORT):$(WIL_PORT)@loadbalancer" \
	--wait > /dev/null

argo:
	@ echo "Create namespace argocd"
	@ kubectl create namespace argocd > /dev/null 2>&1

	@ echo "Install Argo CD"
	@ kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null

	@ echo "Waiting for Argo CD Server to be ready..."
	@ kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s > /dev/null

	@ echo "Change nodeport to loadbalancer"
	@ kubectl patch svc argocd-server -n argocd --type merge -p '{"spec": {"type": "LoadBalancer", "ports": [{"name": "https", "port": 8080, "targetPort": 8080, "protocol": "TCP"}]}}'

	@ echo "Waiting for ArgoCD Server to be ready..."
	@ kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=90s
	@ until curl -sk https://localhost:8080 > /dev/null 2>&1; do sleep 1; done

	@ echo "Argocd Login"
	@ PASSWORD=$$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d); \
	argocd login localhost:8080 --insecure --username admin --password "$$PASSWORD"

	@ echo "Create Argocd wil-app"
	@ argocd app create wil-app \
		--repo https://github.com/lockdoor/42_inception_of_thing.git \
		--revision main
		--path p3/confs \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace dev

	@ echo "Wait for App become synchornized"
	@ kubectl wait --for=condition=synced app/wil-app -n dev --timeout=300s > /dev/null

#	use patch service loadbalancer instead port-forward
#	@ echo "Forward port $(ARGO_PORT) to Argo CD server"
#	@ kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 $(ARGO_PORT):443 > /dev/null 2>&1 &

argo_login:
	@ echo "Argo CD admin secret: "
	@ kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
	@ echo

dev:
	@ echo "Create namespace dev"
	@ kubectl create namespace dev > /dev/null 2>&1

clean_argo:
	@ echo "Delete all resouce with namespace argocd"
	@ kubectl delete all --all -n argocd > /dev/null 2>&1
	- kubectl delete ns argocd > /dev/null 2>&1

clean_dev:
	@ echo "Delete all resouce with namespace dev"
	@ kubectl delete all --all -n dev > /dev/null 2>&1
	- kubectl delete ns dev > /dev/null 2>&1

clean_all: clean_argo clean_dev
	@ echo "Delete K3d Cluster"
	@ k3d cluster delete demo > /dev/null
