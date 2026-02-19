Project: "The Redemption" Infrastructure (EKS)
This repository contains the Infrastructure-as-Code (Terraform) and Kubernetes manifests for The Redemption microservice. The goal here is a zero-downtime setup that can handle 10x traffic spikes automatically.

🏗 Repository Structure
/terraform: AWS Infrastructure (VPC, EKS, IAM, Security Groups).

/k8s: Application manifests (Deployments, HPA, Karpenter Provisioners).

🚀 Deployment Guide
1. Terraform (Infrastructure)
First, you need to initialize the backend and provider.

Bash
cd terraform
terraform init
We use .tfvars to keep environment separate. Always check the plan before you apply.

For Development:

Bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
For Production:

Bash
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
2. Kubernetes (Workload)
Once the cluster is up, update your local kubeconfig:

Bash
aws eks update-kubeconfig --region ap-southeast-1 --name redemption-prod-cluster
Apply the scaling and application configs:

Bash
kubectl apply -f k8s/karpenter-provisioner.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/deployment.yaml
🛠 Architecture Decisions (SRE Notes)
Karpenter vs Cluster Autoscaler: I chose Karpenter. Why? Because the standard autoscaler takes too much time to talk to ASGs. During a Flash Sale, we need nodes in <60s or we lose revenue. Karpenter is much faster.

Networking Isolation: No nodes have public IP. Everything is in Private Subnets. Traffic only comes through the ALB in the public subnet. This reduce the attack surface.

State Management: For this assessment I keep state local, but for real prod we should use an S3 Backend with DynamoDB locking.

High Availability: The VPC is spread across 3 AZs. If one AWS datacenter goes down, the cluster stay alive.

⚠️ Pre-requisites & Troubleshooting
EBS CSI Driver: If the app needs to write logs to a persistent volume, you MUST install the aws-ebs-csi-driver addon. I didn't add it to the basic TF code to keep it simple, but it is needed for stateful stuff.

Permissions: Make sure your CLI has AdministratorAccess or at least enough to create IAM Roles and VPCs.

<img width="1032" height="721" alt="accor drawio" src="https://github.com/user-attachments/assets/6e79b8a3-73ec-476e-8470-725f3a5fe338" />
