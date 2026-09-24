#! /bin/bash

argocd login localhost:8080 --insecure \
  --username admin \
  --password "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"

argocd app create wil-app \
    --repo https://github.com/lockdoor/42_inception_of_thing \
    --path ./confs/wil_app.yaml \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev
