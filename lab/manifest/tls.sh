#! /bin/bash

openssl req -x509 -noenc -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=app.example.com/O=MyOrg" \
  -addext "subjectAltName=DNS:app.example.com"
kubectl delete secret app-tls 2>/dev/null
kubectl create secret tls app-tls --key tls.key --cert tls.crt
rm tls.key tls.crt
