#!/bin/bash
# Rebuilds the QR code app infra from scratch after a teardown.
# Run from repo root: ./scripts/rebuild.sh
set -e

echo "==> Step 1: Provisioning AWS infrastructure with Terraform"
cd "$(dirname "$0")/../terraform/envs/prod"
terraform apply
cd - > /dev/null

echo "==> Step 2: Pointing kubectl at the new cluster"
aws eks update-kubeconfig --region us-east-1 --name qr-code-app-cluster

echo "==> Step 3: Recreating secrets (never stored in git - re-enter them now)"
kubectl create namespace qr-code-app --dry-run=client -o yaml | kubectl apply -f -
read -p "AWS Access Key: " AWS_KEY
read -sp "AWS Secret Key: " AWS_SECRET
echo
read -p "S3 Bucket Name: " BUCKET
kubectl create secret generic qr-app-secrets \
  --namespace qr-code-app \
  --from-literal=AWS_ACCESS_KEY="$AWS_KEY" \
  --from-literal=AWS_SECRET_KEY="$AWS_SECRET" \
  --from-literal=BUCKET_NAME="$BUCKET" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
read -sp "Grafana admin password: " GRAFANA_PW
echo
kubectl create secret generic grafana-admin-secret \
  --namespace monitoring \
  --from-literal=admin-password="$GRAFANA_PW" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Step 4: Installing ArgoCD"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "    Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "==> Step 5: Syncing everything via ArgoCD (order matters - ingress/cert-manager first)"
kubectl apply -f argocd/ingress-nginx-application.yaml
kubectl apply -f argocd/cert-manager-application.yaml
sleep 30
kubectl apply -f argocd/application.yaml
kubectl apply -f argocd/monitoring-application.yaml

echo "==> Done. Check status with:"
echo "    kubectl get applications -n argocd"
echo "    kubectl get pods -A"
