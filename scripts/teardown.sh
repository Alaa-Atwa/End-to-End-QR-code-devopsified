#!/bin/bash
# Tears down the QR code app infra safely.
# Order matters: anything that made AWS create a Load Balancer must go
# BEFORE terraform destroy, or Terraform will hang trying to delete a
# VPC that still has an ELB's network interfaces attached to it.
set -e

echo "==> Step 1: Removing ingress-nginx (this releases its AWS Load Balancer)"
kubectl delete -f argocd/ingress-nginx-application.yaml --ignore-not-found

echo "==> Waiting for the AWS Load Balancer to fully deprovision ..."
sleep 90

echo "==> Step 2: Removing remaining ArgoCD-managed apps"
kubectl delete -f argocd/monitoring-application.yaml --ignore-not-found
kubectl delete -f argocd/cert-manager-application.yaml --ignore-not-found
kubectl delete -f argocd/application.yaml --ignore-not-found

echo "==> Step 3: Uninstalling ArgoCD itself"
kubectl delete namespace argocd --ignore-not-found

echo "==> Step 4: Destroying Terraform-managed AWS infrastructure"
echo "    (VPC, EKS cluster + nodes, ECR, IAM, S3 bucket references)"
cd "$(dirname "$0")/../terraform/envs/prod"
terraform destroy

echo "==> Done. Confirm no orphaned resources are still billing:"
echo "    - EC2 instances / load balancers in the AWS console"
echo "    - EBS volumes (shouldn't be any - persistence was disabled)"
echo "    - NAT Gateway / Elastic IPs"
