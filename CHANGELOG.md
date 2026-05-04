# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [0.8.0] — 2026-05-03

### Phase 8: Portfolio Documentation

**Added**
- Complete root README.md with project overview, architecture diagram, technology stack justification
- 7 Architecture Decision Records (ADRs) in docs/architecture-decisions/:
  - ADR-001: Static HTML site vs dynamic application
  - ADR-002: nginx:alpine as web server choice
  - ADR-003: Minikube with QEMU driver for Kubernetes
  - ADR-004: Helm charts for Kubernetes parametrization
  - ADR-005: GitHub Actions for CI/CD platform
  - ADR-006: Terraform + Localstack for Infrastructure as Code
  - ADR-007: Community Helm charts for observability (kube-prometheus-stack, loki-stack)
- CHANGELOG.md documenting all 8 phases

**Documentation**
- Phase summary table (8 phases with status and deliverables)
- Technology stack justifications (Docker, Kubernetes, Helm, Terraform, GitHub Actions, GHCR, Prometheus, Grafana, Loki)
- 4 deployment options documented (Docker Compose, Kubernetes, Helm, Terraform+Localstack)
- Learning outcomes section for portfolio learners
- Links to all sub-README files

## [0.7.0] — 2026-04-29

### Phase 7: Observability Stack

**Added**
- helm/monitoring/ Helm chart with community dependencies:
  - kube-prometheus-stack (Prometheus, Grafana, AlertManager, kube-state-metrics)
  - loki-stack (Loki, Promtail, Minio storage)
- Prometheus configuration with 15s scrape interval, alerting rules
- Grafana provisioning via ConfigMap:
  - Datasources: Prometheus, Loki
  - 4 pre-built dashboards: Nginx Metrics, Kubernetes Pods, Logs Overview, Cluster Overview
- Loki configuration with log aggregation from Promtail DaemonSet
- Promtail configuration for Docker and Kubernetes log scraping
- Nginx exporter for metrics collection from web server
- 6 alert rules:
  - WebsiteDown: Nginx unreachable for 2 minutes
  - WebsiteHighErrorRate: Error rate > 5% for 5 minutes
  - HighLatency: P95 latency > 1s for 5 minutes
  - HighMemoryUsage: Available memory < 20%
  - UnusuallyHighTraffic: Requests > 100 RPS
  - NoTraffic: Zero requests for 10 minutes
- Prometheus and Grafana Ingress resources (dev: port-forward; prod: DNS)
- helm/monitoring/README.md with deployment guide and troubleshooting

**Documentation**
- Monitoring architecture diagram showing Prometheus → Grafana ← Loki ← Promtail
- Dashboard documentation (Nginx, Kubernetes, Logs, Cluster)
- Alert rules reference and customization guide
- Performance tuning section for high-volume environments

## [0.6.0] — 2026-04-24

### Phase 6: Terraform + Localstack (Infrastructure as Code)

**Added**
- terraform/ directory with Terraform configuration:
  - main.tf: Root config, AWS provider → Localstack endpoint
  - variables.tf: 8 configurable variables (region, endpoint, app_name, environment, vpc_cidr, AZs, port, image)
  - outputs.tf: Export ECR, ECS cluster, and IAM role ARNs
- terraform/modules/vpc/: VPC infrastructure
  - VPC with configurable CIDR
  - Internet Gateway for outbound traffic
  - Public/private subnets via cidrsubnet() across 2 AZs
  - Security groups allowing 80/443 (HTTP/HTTPS)
  - Network ACLs for ingress/egress
- terraform/modules/ecs/: Container orchestration (simulated)
  - ECR repository for container images
  - ECS cluster (integration point with Localstack)
  - IAM task execution role with permissions for ECR pull, CloudWatch logs
  - ECS task definition using Fargate launch type
  - ECS service with 2 replicas, load balancing
- terraform/environments/dev.tfvars: Dev environment variable overrides
- scripts/terraform-localstack.sh: Automation script with commands:
  - check: Verify Localstack health
  - start: Start Localstack containers
  - init: Terraform init
  - validate: Terraform validate
  - format: Terraform fmt
  - plan: Terraform plan
  - apply: Terraform apply
  - destroy: Terraform destroy
  - stop: Stop Localstack
  - all: Full lifecycle (start → init → validate → plan → apply)

**Documentation**
- terraform/README.md with deployment guide and troubleshooting
- Environment configuration strategy (dev.tfvars)
- IaC benefits and best practices

## [0.5.0] — 2026-04-19

### Phase 5: GitHub Actions CI/CD

**Added**
- .github/workflows/ci.yml: Continuous Integration pipeline (on every push)
  - HTML validation (html-validate, 6 pages)
  - CSS linting (stylelint)
  - Docker build (buildx, multi-stage)
  - Container tests: health check, page load, endpoint verification
  - Security scan (Trivy: HIGH/CRITICAL vulns fail build)
  - CodeQL static analysis (SARIF upload to GitHub Security tab)
  - FORCE_JAVASCRIPT_ACTIONS_TO_NODE24 for action compatibility
  - Environment: ubuntu-latest, docker/setup-buildx-action, sarif upload permissions
- .github/workflows/cd.yml: Continuous Deployment pipeline (on main/develop push, semver tags)
  - Docker buildx build and push to GHCR (ghcr.io/marcossabatino/)
  - Tagging strategy:
    - branch-<sha>: Branch pushes
    - v1.0.0: Semver tags
    - latest: Main branch
  - GitHub Release creation (for semver tags)
  - Secrets: GHCR token from GITHUB_TOKEN
- .github/workflows/deploy.yml: Kubernetes deployment (manual + tag-triggered)
  - Helm lint (chart validation)
  - Helm template (manifest rendering)
  - Dry-run deployment
  - Post-deploy smoke tests (curl health checks)
  - Manual approval gate

**Documentation**
- CI/CD pipeline architecture (3 workflows, trigger conditions, inputs/outputs)
- Security scanning rationale (Trivy, CodeQL)
- Tagging strategy for container images
- Release creation process

## [0.4.0] — 2026-04-14

### Phase 4: Helm Parametrization

**Added**
- helm/observability-site/: Main application Helm chart
  - Chart.yaml: Version, description, chart metadata
  - values.yaml: Dev defaults (1 replica, 512Mi memory, local image)
  - values-prod.yaml: Production overrides (3 replicas, 1Gi memory, image pull policy, resource limits)
  - templates/: Kubernetes manifests as Helm templates
    - deployment.yaml: Deployment with {{ .Values.replicaCount }} and resource templating
    - service.yaml: ClusterIP service with port templating
    - ingress.yaml: Ingress with host parametrization
    - configmap.yaml: Nginx configuration as config
    - hpa.yaml: HorizontalPodAutoscaler (dev/prod thresholds differ)
  - README.md: Chart usage, values customization, deployment commands
- helm/monitoring/: Observability stack Helm chart (Phase 7, dependency-based)
- Helm dependency management:
  - helm dependency update pulls kube-prometheus-stack, loki-stack
  - Chart.yaml specifies version constraints for reproducibility

**Documentation**
- Helm chart structure (templates/, values.yaml pattern)
- Dev/prod values override strategy
- HPA configuration (dev: 2 replicas at 70% CPU; prod: 3 replicas at 50%)

## [0.3.0] — 2026-04-09

### Phase 3: Kubernetes Deployment

**Added**
- kubernetes/ directory with raw Kubernetes manifests:
  - namespace.yaml: observability namespace
  - deployment.yaml: 3 pods with nginx image, health checks, resource limits (256Mi memory, 100m CPU)
  - service.yaml: ClusterIP service exposing port 80
  - ingress.yaml: Nginx ingress routing to service
  - configmap.yaml: Nginx config, gzip, security headers
  - hpa.yaml: HorizontalPodAutoscaler (2-4 pods, 70% CPU threshold)
  - README.md: Kubernetes deployment guide
- Minikube setup:
  - QEMU driver for VM isolation (no Docker-in-Docker)
  - Addons: ingress, metrics-server
  - Local image loading: minikube image load
- Health checks:
  - liveness probe: HTTP GET /health (nginx health endpoint)
  - readiness probe: HTTP GET / (home page load)
- Scripts:
  - scripts/k8s-deploy.sh: Full Kubernetes deployment automation

**Documentation**
- Kubernetes manifest reference (6 files, purpose of each)
- Minikube setup and teardown procedures
- kubectl commands for verification and troubleshooting

## [0.2.0] — 2026-04-04

### Phase 2: Docker Containerization

**Added**
- Dockerfile: Multi-stage build
  - Builder stage: Alpine 3.20, npm (if needed), build tools
  - Runtime stage: nginx:alpine, app files, non-root user (nginx)
  - Final image size: ~30MB
  - Security: apk upgrade (patch CVEs), read-only root filesystem support, USER nginx
  - Health check: nginx -t to verify config
- nginx.conf: Nginx configuration
  - Gzip compression (text, html, css, js)
  - Security headers: X-Frame-Options, X-Content-Type-Options, CSP
  - /health endpoint for liveness probes
  - Error pages with custom messages
  - Performance tuning: worker processes, keepalive
- docker-compose.yml: 7-service local dev environment
  - website: Nginx serving static site (port 8080)
  - prometheus: Metrics database (port 9090, volumes)
  - grafana: Visualization (port 3000, volume)
  - loki: Log aggregation (port 3100, volume)
  - promtail: Log shipper (Docker socket mount)
  - nginx-exporter: Metrics for Nginx (port 9113)
  - localstack: AWS simulation (port 4566)
- Makefile: Helper commands
  - make build: Docker build
  - make run: Docker run
  - make compose-up: docker-compose up
  - make compose-down: docker-compose down
- DOCKER.md: Docker and docker-compose guide

**Documentation**
- Multi-stage build benefits (security, size, speed)
- Dockerfile comments explaining each stage
- nginx.conf tuning for static files
- docker-compose service purpose and port mapping
- Local development workflow

## [0.1.0] — 2026-03-30

### Phase 1: Static Site Foundation

**Added**
- site/ directory with static HTML/CSS/JavaScript website
- Pages:
  - index.html: Home page with observability intro
  - logs/index.html: Logs concept guide (structured logging, aggregation)
  - metrics/index.html: Metrics concept guide (counters, gauges, histograms)
  - traces/index.html: Traces concept guide (distributed tracing, OpenTelemetry)
  - sre/index.html: SRE principles (SLOs, SLIs, incident response)
  - architecture/index.html: Portfolio architecture overview
- site/css/style.css: Responsive design
  - Utility classes for spacing, text styling
  - Mobile-first media queries (@media (max-width: 768px))
  - Color scheme (dark backgrounds, readable contrast)
  - Navigation bar styling with hover effects
- site/js/main.js: Interactivity
  - Smooth navigation
  - Interactive examples (toggle visibility)
  - Copy-to-clipboard code snippets

**Documentation**
- README.md (root): Project overview and quick start
- Site content covers observability fundamentals
- Educational focus on logs, metrics, traces, SRE

---

[Unreleased]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.8.0...HEAD
[0.8.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/marcossabatino/ci-cd-kubernetes/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/marcossabatino/ci-cd-kubernetes/releases/tag/v0.1.0
