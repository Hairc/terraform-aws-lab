# AWS EKS & DevSecOps Portfolio Project

Automated provisioning of a highly available Cloud infrastructure on AWS, based on **Kubernetes (Amazon EKS)** and managed via **Terraform**. This project simulates a complete enterprise environment, combining Infrastructure as Code, container orchestration, and security oriented CI/CD pipelines (DevSecOps)

## Objectives & Architecture
- **Infrastructure as Code (IaC):** Deterministic creation of the entire network (VPC, Subnets) and compute infrastructure (EKS Cluster, Node Groups) using HCL
- **Orchestration (Kubernetes):** Transitioned from a single-server setup to an EKS cluster to ensure high availability, scalability, and Self-Healing. Deployment of a web microservice (Nginx) replicated across multiple Pods
- **Dynamic Load Balancing:** Exposing the K8s service via a physical AWS Elastic Load Balancer. The application dynamically injects the Pod name (`$HOSTNAME`) into the HTML to visually demonstrate traffic balancing across the containers
- **Team Readiness:** Remote Backend hosted on AWS S3 to simulate a collaborative production environment
- **DevSecOps:** Static code analysis triggered on every push using `tfsec` integrated into GitHub Actions. Architectural exceptions (public IPs for nodes, lack of KMS encryption) required to keep the project within the AWS Free Tier are managed through *Risk Acceptance* in the codebase

## Technologies Used
- **Cloud Provider:** AWS (Amazon EKS, VPC, ELB, IAM, S3)
- **IaC & Orchestration:** Terraform (HCL), Kubernetes (`kubectl`, YAML Manifests)
- **CI/CD & Security:** GitHub Actions, `tfsec`
- **Application:** Docker, Nginx, Shell Scripting

## Load Balancing Demonstration

<img width="1851" height="1007" alt="WebSites working" src="https://github.com/user-attachments/assets/64b7d318-91a2-4e19-954c-a808e677216d" />

> **Architectural Note:** The image above demonstrates the correct traffic routing by the AWS Elastic Load Balancer to distinct Nginx Pods, which are distributed across the Worker Nodes created by the Auto Scaling Group.

## How to Replicate the Infrastructure

1. Ensure you have AWS credentials configured locally (`aws configure`).
2. Replace the S3 bucket name in the `backend` block of the `main.tf` file with your own bucket.
3. Initialize the environment and apply the Terraform configuration:
   ```bash
    terraform init
    terraform apply
    aws eks update-kubeconfig --region eu-north-1 --name portfolio-eks-cluster
    kubectl apply -f app.yaml
    kubectl get svc nginx-service
4. Once Testing is complete, destroy the resources
    kubectl delete -f app.yaml
    terraform destroy
