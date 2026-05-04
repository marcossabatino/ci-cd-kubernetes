# 📚 Observability Portal — DevOps Portfolio Project

![CI](https://img.shields.io/github/actions/workflow/status/marcossabatino/ci-cd-kubernetes/ci.yml?branch=main&logo=github&label=CI)
![CD](https://img.shields.io/github/actions/workflow/status/marcossabatino/ci-cd-kubernetes/cd.yml?branch=main&logo=github&label=CD)
![GitHub Release](https://img.shields.io/github/v/release/marcossabatino/ci-cd-kubernetes?logo=github)
![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue?logo=docker)
![License](https://img.shields.io/badge/license-MIT-green)

**A complete, production-ready DevOps portfolio demonstrating modern cloud-native practices with Kubernetes, Helm, Terraform, and CI/CD.**

## 🎯 Project Overview

An educational static website about **observability** (logs, metrics, traces) deployed using a complete DevOps stack. This portfolio showcases:

- ✅ **Static Site** — HTML/CSS/JavaScript site explaining observability concepts
- ✅ **Docker** — Multi-stage builds, security hardening, Alpine optimization
- ✅ **Kubernetes** — Local deployment via Minikube with health checks and auto-scaling
- ✅ **Helm** — Parametrized charts for dev/prod environments
- ✅ **GitHub Actions** — Full CI/CD pipeline with security scanning and GHCR integration
- ✅ **Terraform** — Infrastructure as Code with AWS simulation (Localstack)
- ✅ **Observability** — Prometheus, Grafana, Loki full monitoring stack
- ✅ **Documentation** — Architecture decisions, deployment guides, ADRs

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Source Code (GitHub)                      │
└──────────────────┬───────────────────────────────────────────┘
                   │
        ┌──────────▼──────────┐
        │  GitHub Actions CI  │ Validate → Build → Test → Scan
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │  GitHub Container   │ Push Docker image
        │  Registry (GHCR)    │
        └──────────┬──────────┘
                   │
    ┌──────────────┴───────────────────┐
    │                                  │
┌───▼────────────┐          ┌─────────▼─────────┐
│  Kubernetes    │          │   AWS (via        │
│  (Minikube)    │          │   Terraform +     │
│                │          │   Localstack)     │
│ ┌────────────┐ │          │                   │
│ │ Nginx Site │ │          │ ┌───────────────┐ │
│ │ Container  │ │          │ │ VPC           │ │
│ └────────────┘ │          │ │ ECS Cluster   │ │
│                │          │ │ ECR Registry  │ │
│ ┌────────────┐ │          │ └───────────────┘ │
│ │ Prometheus │ │          │                   │
│ │ Grafana    │ │          │ Simulated via     │
│ │ Loki       │ │          │ Localstack        │
│ └────────────┘ │          │                   │
└────────────────┘          └───────────────────┘
```

## 📊 8 Phases — Complete DevOps Portfolio

| Phase | Name | Status | Key Deliverables |
|-------|------|--------|------------------|
| 1️⃣ | **Static Site Foundation** | ✅ | 6 HTML pages (Logs, Metrics, Traces, SRE, Architecture) |
| 2️⃣ | **Docker Containerization** | ✅ | Multi-stage Dockerfile, docker-compose (7 services) |
| 3️⃣ | **Kubernetes Deployment** | ✅ | K8s manifests (6 files), Minikube QEMU setup |
| 4️⃣ | **Helm Parametrization** | ✅ | Helm chart with dev/prod values, templates |
| 5️⃣ | **GitHub Actions CI/CD** | ✅ | 3 workflows (ci/cd/deploy), GHCR, security scan |
| 6️⃣ | **Terraform + Localstack** | ✅ | VPC, ECS, ECR modules, AWS simulation |
| 7️⃣ | **Observability Stack** | ✅ | Monitoring Helm chart, Prometheus, Grafana, Loki |
| 8️⃣ | **Portfolio Documentation** | ✅ | ADRs, architecture guide, deployment automation |

## 🚀 Quick Start

### Option 1: Docker Compose (Fastest)
```bash
# Start all services locally
docker-compose up -d

# View logs
docker-compose logs -f website

# Access site
open http://localhost:8080

# Cleanup
docker-compose down
```

### Option 2: Kubernetes (Recommended)
```bash
# Deploy to Minikube
./scripts/k8s-deploy.sh

# View status
kubectl get all -n observability

# Access via port-forward
kubectl port-forward -n observability svc/observability-site 8080:80

# Open site
open http://localhost:8080

# View dashboards
kubectl port-forward -n observability svc/monitoring-grafana 3000:80
# Grafana: http://localhost:3000 (admin/admin)
```

### Option 3: Helm (Production-like)
```bash
# Deploy observability-site
helm install site helm/observability-site/ \
  -n observability --create-namespace

# Deploy monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install monitoring helm/monitoring/ \
  -n observability
```

### Option 4: Terraform + Localstack (IaC)
```bash
# Start Localstack and deploy infrastructure
./scripts/terraform-localstack.sh all

# View Terraform outputs
cd terraform && terraform output
```

## 📁 Directory Structure

```
.
├── site/                        # Static HTML/CSS/JS website
│   ├── index.html              # Home page
│   ├── logs/                   # Logs documentation
│   ├── metrics/                # Metrics documentation
│   ├── traces/                 # Traces documentation
│   ├── sre/                    # SRE concepts
│   ├── architecture/           # Architecture overview
│   ├── css/style.css           # Responsive design
│   └── js/main.js              # Interactivity
│
├── kubernetes/                  # Raw Kubernetes manifests
│   ├── namespace.yaml          # observability namespace
│   ├── deployment.yaml         # App, Prometheus, Grafana
│   ├── service.yaml            # ClusterIP services
│   ├── ingress.yaml            # Nginx ingress rules
│   ├── configmap.yaml          # Configuration
│   ├── hpa.yaml                # Auto-scaling policies
│   └── README.md
│
├── helm/                        # Helm charts
│   ├── observability-site/     # Main application chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml         # Dev defaults
│   │   ├── values-prod.yaml    # Production overrides
│   │   └── templates/
│   │
│   └── monitoring/             # Observability stack
│       ├── Chart.yaml          # Dependency: kube-prometheus-stack, loki-stack
│       ├── values.yaml         # Dev: 7d retention, basic storage
│       ├── values-prod.yaml    # Prod: 30d retention, TLS, Slack alerts
│       └── templates/          # Grafana dashboards, nginx-exporter, ingress
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Root config, AWS provider → Localstack
│   ├── variables.tf            # Region, endpoint, VPC CIDR
│   ├── outputs.tf
│   ├── environments/dev.tfvars # Dev environment
│   └── modules/
│       ├── vpc/                # VPC, subnets, security groups
│       └── ecs/                # ECS cluster, ECR, IAM roles
│
├── .github/workflows/          # GitHub Actions CI/CD
│   ├── ci.yml                  # Lint, build, test, security scan
│   ├── cd.yml                  # Push to GHCR, create releases
│   └── deploy.yml              # Helm deployment (gated)
│
├── monitoring/                  # Observability configs
│   ├── prometheus/prometheus.yml
│   ├── prometheus/rules/alerts.yml
│   ├── loki/loki-config.yml
│   └── promtail/promtail-config.yml
│
├── scripts/                     # Automation scripts
│   ├── k8s-deploy.sh           # Kubernetes deployment
│   ├── terraform-localstack.sh # IaC automation
│   └── build.sh
│
├── docs/                        # Documentation
│   └── architecture-decisions/  # ADRs (Architecture Decision Records)
│
├── Dockerfile                   # Multi-stage, ~30MB final image
├── docker-compose.yml           # Local dev: website, Prometheus, Grafana, Loki, etc
├── nginx.conf                   # Gzip, security headers, /health endpoint
├── Makefile                     # Helper commands
├── CHANGELOG.md                 # Version history
└── README.md                    # This file
```

## 🛠️ Technology Stack

| Category | Technology | Why Chosen |
|----------|-----------|-----------|
| **Web Server** | Nginx (Alpine) | Lightweight, native static serving, security hardened |
| **Container Runtime** | Docker | Industry standard, reproducible builds |
| **Container Orchestration** | Kubernetes | Production standard, auto-scaling, self-healing |
| **K8s Package Manager** | Helm | Dev/prod parametrization, dependency management |
| **Infrastructure as Code** | Terraform | Cloud-agnostic, AWS compatible, Localstack simulation |
| **Cloud Simulation** | Localstack | Portfolio without AWS costs, full AWS API simulation |
| **CI/CD Platform** | GitHub Actions | Native GitHub integration, GHCR, free for public repos |
| **Container Registry** | GitHub Container Registry (GHCR) | GitHub-native, free, no separate Docker Hub account |
| **Metrics Database** | Prometheus | Industry standard, PromQL, alerting |
| **Visualization** | Grafana | Beautiful dashboards, multi-datasource support |
| **Log Aggregation** | Loki | Lightweight, label-based searching, Grafana integration |
| **Security Scanning** | Trivy | Fast, comprehensive vulnerability scanning |

## 📚 Documentation

- **[docs/architecture-decisions/](docs/architecture-decisions/)** — ADRs explaining each major technology choice
- **[helm/observability-site/README.md](helm/observability-site/README.md)** — Application Helm chart usage
- **[helm/monitoring/README.md](helm/monitoring/README.md)** — Observability stack deployment
- **[kubernetes/README.md](kubernetes/README.md)** — Raw Kubernetes manifests
- **[terraform/README.md](terraform/README.md)** — IaC and Localstack setup
- **[DOCKER.md](DOCKER.md)** — Docker and docker-compose guide
- **[CHANGELOG.md](CHANGELOG.md)** — Per-phase version history

## 🔄 CI/CD Pipeline

### CI Workflow (on every push)
1. **HTML Validation** — html-validate all pages
2. **CSS Linting** — stylelint checks
3. **Docker Build** — Multi-stage build with caching
4. **Container Tests** — Health check, page load, endpoints
5. **Security Scan** — Trivy (HIGH/CRITICAL vulns fail build)
6. **CodeQL SARIF Upload** — Results to GitHub Security tab

### CD Workflow (on main/develop push or tags)
1. **Build & Push** — Docker buildx to GHCR
2. **Tagging Strategy**:
   - `branch-<sha>` — For branch pushes
   - `v1.0.0` — For semver tags
   - `latest` — For main branch
3. **Create Release** — GitHub Release for semver tags

### Deploy Workflow (manual + tags)
1. **Helm Lint** — Validate chart syntax
2. **Template Render** — Generate Kubernetes manifests
3. **Dry Run** — Preview changes (actual apply gated)
4. **Post-Deploy Tests** — Smoke tests

## 📊 Site Content

The site teaches observability concepts through interactive pages:

- **Logs** — When/why to use logs, structured logging patterns, aggregation tools
- **Metrics** — Quantitative measurements, Prometheus types (Counter, Gauge, Histogram)
- **Traces** — Distributed tracing, following requests across services, OpenTelemetry
- **SRE** — Site Reliability Engineering, SLOs/SLIs, incident response
- **Architecture** — How this entire portfolio is deployed across the stack

## 🎓 Learning Outcomes

By exploring this portfolio, you'll understand:

✅ How to containerize applications (Docker multi-stage builds)
✅ How to orchestrate containers at scale (Kubernetes)
✅ How to manage Kubernetes with templates (Helm)
✅ How to automate deployment pipelines (GitHub Actions)
✅ How to provision infrastructure as code (Terraform)
✅ How to monitor production systems (Prometheus, Grafana, Loki)
✅ How to secure the entire supply chain (CodeQL, Trivy)
✅ How to design for observability from day one

## 🚀 Deployment Environments

### Development
```bash
# Docker Compose (fastest iteration)
docker-compose up -d

# Minikube (K8s practice)
./scripts/k8s-deploy.sh

# Values: dev/small, quick startup, local storage
```

### Production
```bash
# Kubernetes in real cluster
kubectl config use-context production-cluster
helm upgrade --install site helm/observability-site/ \
  -n observability -f helm/observability-site/values-prod.yaml

# Values: prod/HA, TLS, larger storage, regional deployment
```

## 📈 Monitoring & Observability

The project practices what it teaches:

- **Prometheus** scrapes metrics from Nginx, Kubernetes, and the infrastructure
- **Grafana** visualizes dashboards (Nginx metrics, Pod CPU/memory, Logs overview)
- **Loki** aggregates logs from all containers via Promtail DaemonSet
- **5 Alert Rules** — downtime, high error rate, high latency, memory pressure, no traffic

Access monitoring:
```bash
# Grafana dashboards
kubectl port-forward -n observability svc/monitoring-grafana 3000:80
# http://localhost:3000 (admin/admin)

# Prometheus metrics
kubectl port-forward -n observability svc/monitoring-kube-prometheus-prometheus 9090:9090
# http://localhost:9090/metrics

# Loki logs
# Searchable in Grafana Explore section
```

## 🤝 Contributing

This is a portfolio project showcasing DevOps patterns. Feel free to fork and adapt for your own learning!

## 📝 License

MIT License — See LICENSE file for details.

## 🔗 Links

- **GitHub**: https://github.com/marcossabatino/ci-cd-kubernetes
- **Author**: Marcos Sabatino
- **Email**: msabatino@gmail.com

---

**Built as a comprehensive DevOps portfolio demonstrating production-ready patterns for containerization, orchestration, infrastructure automation, and observability. 🚀**
