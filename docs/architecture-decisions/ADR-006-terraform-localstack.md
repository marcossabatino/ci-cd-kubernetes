# ADR-006: Terraform + Localstack for Infrastructure as Code

**Status**: Accepted

## Context

This project should demonstrate Infrastructure as Code (IaC) using Terraform. However, deploying to real AWS requires:
- AWS account (personal/educational accounts have limits)
- Ongoing costs (EC2, storage, data transfer)
- Risk of leaked credentials

Need a way to practice Terraform and AWS patterns without real cloud costs.

## Decision

Use **Terraform with Localstack** to simulate AWS infrastructure locally.

Terraform code is identical to real AWS; only the provider endpoint changes (localhost:4566 for Localstack).

Architecture simulated:
- VPC with subnets and security groups
- ECR (Elastic Container Registry) for images
- ECS (Elastic Container Service) for orchestration
- IAM roles and policies

## Rationale

1. **Production-grade IaC**: Demonstrates real Terraform modules, state management, and AWS patterns without real cloud costs.
2. **Cost-free**: Localstack runs in Docker; no AWS charges.
3. **Identical code**: Real Terraform code; only endpoint configuration differs. This approach demonstrates production-ready IaC patterns.
4. **Educational**: Learners can practice AWS without account/cost barriers.
5. **Fast iteration**: Local infrastructure is instant; no waiting for AWS API.
6. **Security**: No real AWS credentials needed; no risk of infrastructure leakage.
7. **Automation**: `terraform-localstack.sh` automates the full lifecycle (start Localstack, init, plan, apply, destroy).

## Consequences

- ✅ Production-grade Terraform code (portable to real AWS)
- ✅ Zero infrastructure costs
- ✅ Fast iteration (local execution)
- ✅ Modules for VPC, ECS, IAM (reusable, documented)
- ✅ Automation script handles all common tasks
- ✅ dev.tfvars for environment-specific variables
- ❌ Localstack is not 100% AWS-compatible (some services/features missing)
- ❌ Learning curve: Terraform + AWS concepts + Localstack quirks
- ❌ Performance bottleneck: ECS in Localstack not actually orchestrating containers

## Consequences — Architecture

- ✅ VPC module: VPC, Internet Gateway, subnets (via cidrsubnet()), security groups
- ✅ ECS module: ECR repository, ECS cluster, IAM task/service roles, Fargate launch type
- ✅ Configurable: region, endpoint, VPC CIDR, AZs, container image
- ✅ Automation: `terraform-localstack.sh` with check, start, init, validate, format, plan, apply, destroy, stop, all commands
- ❌ Localstack ECS doesn't actually run containers (simulates only); real Kubernetes used for actual workloads

## Alternatives Considered

1. **Real AWS (free tier)** — Use AWS free tier
   - Pros: Production-realistic, real services
   - Cons: Cost overruns risk, credential exposure risk, requires AWS account

2. **Pulumi** — Infrastructure as Code in Python/TypeScript
   - Pros: Full-featured, less verbose than Terraform
   - Cons: Different ecosystem, steeper learning curve, not as widely adopted as Terraform

3. **CloudFormation** — AWS-native IaC
   - Pros: Native AWS service, tight integration
   - Cons: AWS-only, verbose YAML, harder to version control

4. **CDK (Cloud Development Kit)** — AWS's modern IaC
   - Pros: TypeScript/Python, feels like normal code
   - Cons: AWS-only, learning curve, abstracts away Terraform/CloudFormation fundamentals

5. **Docker Compose only (no IaC)** — Skip Terraform entirely
   - Pros: Simpler, fewer tools to learn
   - Cons: Missing infrastructure automation (IaC is critical DevOps skill); doesn't demonstrate Terraform patterns

## Related Decisions

- ADR-005: GitHub Actions CI (cd.yml pushes images to GHCR; Terraform pulls from GHCR)
- ADR-003: Minikube + QEMU (used for actual workloads; Terraform simulates only)
