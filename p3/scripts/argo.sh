#! /bin/bash


argocd app create wil-app \
    --repo https://github.com/lockdoor/42_inception_of_thing \
    --path ./confs/wil_app.yaml \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev