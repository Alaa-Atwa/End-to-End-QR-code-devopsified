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

# write the application.yaml under argocd dir.
# apply 
kubectl apply -f argocd/application.yaml 

# check 
k get application -n argocd 

# now you can remove the old deploy and make argocd is the single source of truth.

helm uninstall prod -n qr-code-app 

#===============================================================================
# Monitoring Stack 

# we use the community-maintained kube-prometheus-stack Helm chart

# what we will use as a stack:
----------------------------------------------------------
ArgoCD + an external Helm repo + your own custom values
----------------------------------------------------------
# This is a genuinely new pattern: ArgoCD needs to combine a chart from an external Helm repository (prometheus-community's) with your own values, yaml living in your git repo.
# That needs ArgoCD's multi-source Application feature — one source is the chart, 
# the other is your values file, tied together with a $values reference.



