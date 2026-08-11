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
In your repo: Settings → Secrets and variables → Actions → New repository secret. Add:
AWS_ACCESS_KEY_ID	 --> from the IAM user above
AWS_SECRET_ACCESS_KEY	 --> from the IAM user above
AWS_ACCOUNT_ID	 --> your 12-digit AWS account ID
AWS_REGION	 --> e.g. us-east-1