#!/usr/bin/env bash 

#---------- Building ECR ----------------
aws ecr create-repository --repository-name qr-code-api --region us-east-1 
aws ecr create-repository --repository-name qr-code-fronted --region us-east-1 

# connect the CI github actions with the ECR
#------- Creating IAM user for the CI process ----------
aws iam create-user --user-name github-action-ci 

#------ attach policy to the CI user -----------------
aws iam attach-user-policy --user-name github-actions-ci \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

#---- create access key for the user 
aws iam create-access-key --user-name github-actions-ci  


# ---- add GitHub repo secrets -------
# In your repo: Settings → Secrets and variables → Actions → New repository secret. Add:
# AWS_ACCESS_KEY_ID	 --> from the IAM user above
# AWS_SECRET_ACCESS_KEY	 --> from the IAM user above
# AWS_ACCOUNT_ID	 --> your 12-digit AWS account ID
# AWS_REGION	 --> e.g. us-east-1

# terraform 
 # sanity check to see your VPC resources 
aws ec2 describe-subnets --filters "Name=tag:Name,Values=qr-code-app-*" --query "Subnets[].{Name:Tags[?Key=='Name']|[0].Value,AZ:AvailabilityZone,Public:MapPublicIpOnLaunch}" --output table

# Note on .tfstate file 
#-------------------------
# Right now terraform.tfstate sits on your laptop only. Two real risks with that, both worth understanding rather than just accepting on faith:
# You lose the file → Terraform "forgets" it built anything. The VPC, NAT Gateway, etc. still exist and still bill you, but Terraform has no record of them. Your only recovery is manually importing every resource back in, one by one — painful.
# No locking. If you ever ran terraform apply from two places at once (your laptop + a GitHub Actions runner, say), they could both write state simultaneously and corrupt it.
# The fix is a remote backend: state lives in an S3 bucket instead of your laptop, and a DynamoDB table handles locking (so only one apply can run at a time).
aws s3api create-bucket \
  --bucket qr-code-app-tfstate-alaa-2026 \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket qr-code-app-tfstate-alaa-2026 \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name qr-code-app-tf-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST


# EKS needs two separate IAM roles.

#------------------------------------------------------
# point kubectl at your new cluster: 

aws eks update-kubeconfig --region us-east-1 --name qr-code-app-cluster
kubectl get nodes

# list all ecr repos and thier urls 
aws ecr describe-repositories --query "repositories[*].[repositoryName,repositoryUri]" --output table


# switch namspace 

kubectl config set-context namespace=qr-app-code

#=========================================================
# =============== helm ============================
# ========================================================
# why helm ?
# Helm solves this by turning your manifests into a template with a single values.yaml 
# supplying the environment-specific numbers — one chart, many environments, no duplication. 
# It also gives you helm rollback (revert to a previous release in one command) and helm upgrade (apply changes as a tracked, named release) instead of a folder of loose kubectl apply commands with no history.












