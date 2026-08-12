#!/usr/bin/env bash 

# install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# check 
kubectl get all -n argocd 

# get initial admin password 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access the UI (temporary solution)
kubectl port-forward svc/argocd-server -n argocd 8080:443



