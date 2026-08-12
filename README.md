# devops-qr-code

## project structure 
``` 
devops-qr-code/
├── api/                      # FastAPI backend (from original repo)
│   ├── Dockerfile
│   └── ...
├── front-end-nextjs/         # Next.js frontend (from original repo)
│   ├── Dockerfile
│   └── ...
├── docker-compose.yml        # Local dev environment
├── k8s/                      # Raw Kubernetes manifests (learning stage)
│   ├── base/
│   └── overlays/
├── helm/                     # Helm chart (packaged version of k8s/)
│   └── qr-code-app/
├── terraform/                # AWS infra as code
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ecr/
│   │   ├── eks/
│   │   ├── ec2/
│   │   └── s3/
│   └── envs/
│       └── prod/
├── argocd/                   # GitOps app definitions
├── monitoring/                # Prometheus/Grafana values & dashboards
├── .github/workflows/        # CI/CD pipelines
└── docs/                     # Architecture diagram, runbook, resume notes

```
This is the sample application for the DevOps Capstone Project.
It generates QR Codes for the provided URL, the front-end is in NextJS and the API is written in Python using FastAPI.

## Application

**Front-End** - A web application where users can submit URLs.

**API (backend)**: API that receives URLs and generates QR codes. The API stores the QR codes in cloud storage(AWS S3 Bucket).

## Running locally

### API (backend)

The API code exists in the `api` directory. You can run the API server locally:

*Uvicorn is a lightning-fast ASGI (Asynchronous Server Gateway Interface) web server implementation for Python*

- Clone this repo
- Make sure you are in the `api` directory
- Create a virtualenv by typing in the following command: `python -m venv .venv`
- Install the required packages: `pip install -r requirements.txt`
- Create a `.env` file, and add you AWS Access and Secret key, check  `.env.example`
- Also, change the BUCKET_NAME to your S3 bucket name in `main.py`
- Run the API server: `uvicorn main:app --reload`
- Your API Server should be running on port `http://localhost:8000`

### Front-end

The front-end code exits in the `front-end-nextjs` directory. You can run the front-end server locally:

- Clone this repo
- Make sure you are in the `front-end-nextjs` directory
- Install the dependencies: `npm install`
- Run the NextJS Server: `npm run dev`
- Your Front-end Server should be running on `http://localhost:3000`

---
## Docker

- after creating docker files and docker-compose you need to tag and push docker images to docker hub

```bash
docker tag ...
docker push ...
```
**note on frontend Dockerfile**
Why three stages: the deps and builder stages contain the full node_modules (including dev dependencies like tailwindcss), source files, and build cache — none of that needs to exist in the image that actually runs in production. Only the compiled .next output and runtime node_modules get copied into the final runner stage, reducing image size and more.


## terraform 
**EKS** needs two separate IAM roles, and mixing them up is the single most common EKS setup mistake, so let's be precise about which is which:

1. Cluster role — assumed by the EKS control plane itself (the managed API server AWS runs for you) so it can manage AWS resources on your behalf (like creating load balancers later).
2. Node role — assumed by the EC2 instances that become your worker nodes, so they can register with the cluster, pull images from ECR, and let the CNI plugin assign pod networking.

Different identities, different jobs — the control plane never runs your pods, and the nodes never manage the API serve

