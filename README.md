The Redemption - Infrastructure
This repo contains the IaC and K8s setup for the point deduction service.

How to Deploy
Initialize Terraform:
terraform init

Deploy to Dev:
terraform apply -var-file="dev.tfvars"

Deploy to Prod:
terraform apply -var-file="prod.tfvars"

Design Choice
I chose Karpenter over the old Cluster Autoscaler because during our Flash Sales, we need nodes ready in <60 seconds. Also, the networking is setup with Public/Private isolation. Nodes have NO public IPs for security.

Note: Make sure you install the aws-ebs-csi-driver if the app needs persistent storage for logs.

<img width="1032" height="721" alt="accor drawio" src="https://github.com/user-attachments/assets/6e79b8a3-73ec-476e-8470-725f3a5fe338" />
