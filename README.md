🏨 Project: The RedemptionBusiness Critical: High-performance point deduction microservice.SRE Status: Production-Ready | SLO: 99.99% | Auto-scaling: Enabled📖 OverviewThis repository contains the full stack for The Redemption. It is designed to survive a 10x traffic spike (Flash Sales) without manual intervention, using a self-healing EKS cluster spread across 3 Availability Zones.🗺️ Architecture PreviewPublic Layer: ALB + WAF (Traffic filtering).App Layer: EKS (Private Subnets) + Karpenter (Just-in-time compute).Data Layer: RDS Proxy + Multi-AZ Aurora (Connection pooling).🚀 Deployment Guide<details><summary><b>Step 1: Provision Infrastructure (Terraform)</b></summary>Bashcd terraform

# Init and choose workspace
terraform init

# Plan for Production
terraform plan -var-file="prod.tfvars" -out=prod.plan

# Apply if everything looks okay
terraform apply "prod.plan"
</details><details><summary><b>Step 2: Configure Kubernetes</b></summary>Bash# Connect to the new cluster
aws eks update-kubeconfig --region ap-southeast-1 --name redemption-prod-cluster

# Apply Karpenter Provisioner (The scaling brain)
kubectl apply -f k8s/karpenter-provisioner.yaml

# Deploy App & HPA
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
</details>🛠️ Lead SRE Design NotesWhy Karpenter?I ditched the standard Cluster Autoscaler. During a Flash Sale, we can't wait for ASGs to warm up. Karpenter talks directly to the EC2 Fleet API. It's faster. It's smarter. It saves us money by using Spot instances for the spikes.Security FirstZero Public IPs: No node is reachable from internet.Secrets: We use AWS Secrets Manager. No passwords in the YAML, ever.IRSA: Pods get temporary IAM tokens. If a pod is hacked, the attacker has zero access to the rest of the AWS account.📈 Monitoring & OpsMetrics: Prometheus scrapes /metrics endpoint every 15s.Alerts: If "Deduction Latency" > 200ms for 3 mins $\rightarrow$ PagerDuty call.Rollbacks: We use ArgoCD. If a deployment fails health checks, it auto-reverts to the previous hash.👥 The TeamLead SRE: Infrastructure core & Security.Junior A: K8s manifests & CI/CD.Junior B: Observability & Load Testing.

<img width="1032" height="721" alt="accor drawio" src="https://github.com/user-attachments/assets/6e79b8a3-73ec-476e-8470-725f3a5fe338" />
