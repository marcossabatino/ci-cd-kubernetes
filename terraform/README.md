# Terraform — Infrastructure as Code

This directory contains Terraform configurations for deploying the observability stack using Infrastructure as Code (IaC).

## 📋 Overview

**Phase 6** demonstrates IaC patterns with a complete AWS infrastructure simulated by **Localstack**:

- **VPC Module** — Virtual Private Cloud with subnets, security groups, routing
- **ECS Module** — Elastic Container Service with ECR, task definitions, services
- **Localstack** — Local AWS services emulation (no real AWS account required)

## 🏗️ Architecture

```
terraform/
├── main.tf              # Root config, module calls
├── variables.tf         # Root variables
├── outputs.tf           # Root outputs
├── environments/
│   └── dev.tfvars       # Dev environment overrides
└── modules/
    ├── vpc/             # Networking
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/             # Container orchestration
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 🚀 Quick Start

### 1. Start Localstack

```bash
docker-compose up -d localstack
# Wait ~10s for health check to pass
docker ps | grep localstack
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Plan Deployment

```bash
terraform plan -var-file="environments/dev.tfvars"
```

### 4. Apply Configuration

```bash
terraform apply -var-file="environments/dev.tfvars"
```

### 5. Verify Resources

```bash
# Show all resources
terraform state list

# Show outputs (repository URL, cluster name, etc)
terraform output

# Check Localstack resources via awslocal CLI
docker exec observability-localstack awslocal ec2 describe-vpcs
docker exec observability-localstack awslocal ecs list-clusters
docker exec observability-localstack awslocal ecr describe-repositories
```

## 📦 What Gets Created

### VPC Module
- **VPC** — CIDR: 10.0.0.0/16
- **Subnets** — 2 across availability zones
- **Internet Gateway** — Public internet access
- **Security Group** — Allows HTTP/HTTPS (80, 443)
- **Route Table** — Routes public traffic to IGW

### ECS Module
- **ECR Repository** — Private container registry
- **ECS Cluster** — Container orchestration cluster
- **ECS Task Definition** — Container runtime specification
- **ECS Service** — Manages 2 replicas of tasks
- **CloudWatch Logs** — Container output logs
- **IAM Roles** — Task execution and container permissions

## 🔐 Security Notes

⚠️ **Development Only**
- Fake AWS credentials (`test`/`test`)
- Security group allows public HTTP/HTTPS
- No encryption at rest
- For production, use real AWS + KMS + secrets manager

## 🔄 Common Commands

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Destroy all resources
terraform destroy -var-file="environments/dev.tfvars"

# View specific output
terraform output ecr_repository_url

# Target specific resource
terraform apply -target=module.vpc.aws_vpc.main
```

## 📊 State Management

State is stored locally in `terraform.tfstate`:
- ✅ Suitable for local development
- ❌ Not suitable for teams (use S3 backend)
- ❌ Not suitable for CI/CD (use remote state)

To use remote state in future phases:
```hcl
backend "s3" {
  bucket         = "observability-site-terraform"
  key            = "dev/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

## 🐛 Troubleshooting

### `Error: failed to resolve source metadata for docker.io/library/localstack`
→ Ensure `docker-compose up -d localstack` succeeded

### `Error: 401 Unauthorized` when applying
→ Localstack likely not running; check docker logs

### Resources not appearing in Localstack
→ Verify Localstack health: `curl http://localhost:4566/_localstack/health`

### State file conflicts
→ Terraform is safe to run multiple times; it's idempotent

## 📚 Next Steps

**Phase 7** (Observability Integration) will:
- Deploy Prometheus/Grafana via ECS
- Configure dashboards
- Set up alerting rules

**Phase 8** (Portfolio Documentation) will:
- Create Architecture Decision Records (ADRs)
- Document all patterns and choices
- Create final README with deployment guide

## 🔗 References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Localstack Documentation](https://docs.localstack.cloud)
- [Terraform Modules Best Practices](https://developer.hashicorp.com/terraform/language/modules)
- [VPC Design Patterns](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [ECS Fargate Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html)
