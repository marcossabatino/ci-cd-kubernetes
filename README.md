# DevOps Agent Orchestrator

A portfolio-grade DevOps/SRE multi-agent system demonstrating enterprise-scale Kubernetes, CI/CD, and infrastructure automation.

## 🎯 Project Overview

Intelligent multi-agent system for DevOps/SRE automation. Agents route messages based on domain expertise:
- **Orchestrator Agent:** Dispatcher that routes to specialists
- **Kubernetes Agent:** K8s commands and resource explanations
- **Terraform Agent:** IaC planning and state management  
- **Health Agent:** Cluster and application health monitoring

## 🚀 Quick Start

```bash
# Phase 1: Local development
docker-compose up --build

# Phase 3: Kubernetes
./scripts/k8s-deploy.sh
```

## 📁 Project Structure

```
src/
├── frontend/           # React UI
├── backend/            # Express API + agents
├── shared/             # Shared types
kubernetes/             # K8s manifests
helm/                   # Helm charts
terraform/              # Infrastructure as code
.github/workflows/      # CI/CD pipelines
monitoring/             # Observability stack
docs/                   # Architecture decisions
```

## 📖 Documentation

See [PLANO_IMPLEMENTACAO.md](PLANO_IMPLEMENTACAO.md) for detailed implementation guide (8 phases).

## 📝 License

MIT
