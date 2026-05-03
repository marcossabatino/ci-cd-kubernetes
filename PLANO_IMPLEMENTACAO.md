# 📋 PLANO DE IMPLEMENTAÇÃO — DevOps Agent Orchestrator

**Repositório:** `git@github.com:marcossabatino/ci-cd-kubernetes.git`  
**Data:** Maio 2026  
**Status:** Pronto para Início

---

## 🎯 Visão Geral do Projeto

Um sistema de orquestração inteligente multi-agentes para automação DevOps/SRE. A aplicação roda localmente em Docker + Kubernetes (minikube), com simulação de infraestrutura AWS via Localstack, CI/CD via GitHub Actions, e observabilidade com Prometheus/Grafana.

**Diferencial:** Completamente executável localmente — zero custo AWS, 100% educacional e portfolio-ready.

---

## 📦 Estrutura de Fases

```
┌─────────────────────────────────────────────────────────────┐
│ FASE 1: Foundation                                          │
│ └─ Setup repositório, estrutura, backend base + frontend    │
├─────────────────────────────────────────────────────────────┤
│ FASE 2: Containerização Docker                              │
│ └─ Dockerfiles backend/frontend, docker-compose             │
├─────────────────────────────────────────────────────────────┤
│ FASE 3: Kubernetes Local                                    │
│ └─ Minikube, manifests YAML, Deployments, Services          │
├─────────────────────────────────────────────────────────────┤
│ FASE 4: Helm Chart                                          │
│ └─ Parametrização dos manifests, values por ambiente        │
├─────────────────────────────────────────────────────────────┤
│ FASE 5: GitHub Actions CI/CD                                │
│ └─ Workflows de build, test, push de imagens Docker         │
├─────────────────────────────────────────────────────────────┤
│ FASE 6: Terraform + Localstack                              │
│ └─ IaC simulada (EKS, RDS, IAM) sem AWS real                │
├─────────────────────────────────────────────────────────────┤
│ FASE 7: Observabilidade                                     │
│ └─ Prometheus, Grafana, alertas, logs estruturados          │
├─────────────────────────────────────────────────────────────┤
│ FASE 8: Portfolio Final                                     │
│ └─ Documentação, diagrama arquitetura, demo pronta          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 FASE 1: Foundation (Commits 1-5)

### Objetivo
Criar a estrutura do projeto, repositório Git, aplicação backend + frontend rodando localmente.

### Entregáveis

#### 1.1 Setup Inicial do Repositório
```bash
# No repositório git@github.com:marcossabatino/ci-cd-kubernetes.git
# ✓ Clone do repositório
# ✓ Criar estrutura de pastas base
# ✓ Commit inicial com .gitignore (Node, Docker, Terraform)
```

**Commit 1:** "chore: initialize project structure with foundational directories"

Estrutura criada:
```
.
├── src/
│   ├── frontend/              # React app
│   ├── backend/               # Node.js backend
│   │   ├── src/
│   │   │   ├── agents/        # Classes de agentes
│   │   │   ├── routes/        # Endpoints da API
│   │   │   ├── middleware/    # Logger, error handling
│   │   │   └── metrics/       # Métricas Prometheus
│   │   ├── tests/
│   │   └── package.json
│   └── shared/                # Tipos compartilhados
├── kubernetes/                # Manifests K8s (Deployment, Service, etc)
├── helm/                      # Helm Charts
├── terraform/                 # IaC (EKS, VPC, IAM simulados)
│   ├── modules/
│   │   ├── eks/
│   │   ├── vpc/
│   │   └── iam/
│   └── environments/          # dev, staging, prod
├── .github/
│   ├── workflows/             # CI/CD pipelines
│   └── ISSUE_TEMPLATE/
├── monitoring/                # Prometheus, Grafana
│   ├── prometheus/
│   └── grafana/
├── docs/
│   └── architecture-decisions/
├── .gitignore
├── README.md
└── docker-compose.yml         # Para rodar tudo localmente
```

**Commit 2:** "feat: create backend skeleton with Express and core agents"

Backend inicial:
- `src/backend/src/server.js` — Entry point Express
- `src/backend/src/middleware/logger.js` — Structured JSON logging com Pino
- `src/backend/src/agents/base.agent.js` — Template Method base class
- `src/backend/src/agents/orchestrator.agent.js` — Agente roteador central
- `src/backend/package.json` — Dependências (express, cors, helmet, pino, jest)

#### 1.2 Agentes Backend Implementados
```bash
# 3 agentes especializados + orquestrador central
```

**Commit 3:** "feat: implement specialist agents (Kubernetes, Terraform, Health)"

Agentes criados:
- `KubernetesAgent` — Interpreta comandos kubectl, explica recursos K8s
- `TerraformAgent` — Ajuda com planejamento Terraform, state management
- `HealthAgent` — Monitora saúde do cluster e aplicação

Cada agente:
```javascript
class SpecialistAgent extends BaseAgent {
  async process(message, context) {
    // Lógica específica do domínio
    // Retorna resposta formatada
  }
  
  calculateRelevance(message) {
    // Score 0-1 baseado em palavras-chave
  }
}
```

#### 1.3 Rotas da API
```bash
# Backend pronto para ser chamado pelo frontend
```

**Commit 4:** "feat: implement API routes for agents and health checks"

Rotas criadas:
- `GET /api/agents` — Lista agentes disponíveis
- `POST /api/agents/:agentId/message` — Envia mensagem a agente específico
- `GET /health/live` — Liveness check (Kubernetes)
- `GET /health/ready` — Readiness check (Kubernetes)
- `GET /metrics` — Métricas Prometheus (format padrão)

#### 1.4 Frontend React Básico
```bash
# Interface para conversar com agentes
```

**Commit 5:** "feat: create React frontend with agent UI and chat interface"

Frontend:
- `src/frontend/package.json` — React, Vite, axios
- `src/frontend/src/App.jsx` — Layout principal
- `src/frontend/src/components/AgentChat.jsx` — Chat com agentes
- `src/frontend/src/services/api.js` — Cliente HTTP para backend

Funcionalidades:
- ✓ Listar agentes disponíveis
- ✓ Enviar mensagens para agente específico
- ✓ Histórico de conversa
- ✓ Indicador de status (online/offline)

---

## 🐳 FASE 2: Containerização Docker (Commits 6-9)

### Objetivo
Empacotar backend e frontend em imagens Docker otimizadas para produção.

#### 2.1 Backend Dockerfile (multi-stage)
```bash
# Dockerfile otimizado com Alpine Linux
```

**Commit 6:** "feat: add multi-stage Dockerfile for backend"

`src/backend/Dockerfile`:
- **Stage 1 (deps):** node:20-alpine, `npm ci --only=production`
- **Stage 2 (production):** copia apenas código + node_modules
- **Result:** ~150MB final (vs ~500MB sem otimização)
- Health checks inclusos

#### 2.2 Frontend Dockerfile (SPA otimizado)
```bash
# Build estático + nginx
```

**Commit 7:** "feat: add Dockerfile for frontend with nginx"

`src/frontend/Dockerfile`:
- **Build stage:** `npm run build` → dist/
- **Runtime:** `nginx:alpine` servindo arquivos estáticos
- **Size:** ~30MB
- Nginx configurado para SPA routing

#### 2.3 Docker Compose para Desenvolvimento
```bash
# Orquestrar todos os containers localmente
```

**Commit 8:** "feat: add docker-compose.yml for local development"

`docker-compose.yml`:
```yaml
services:
  backend:
    build: ./src/backend
    ports: ["3001:3001"]
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    volumes:
      - ./src/backend/src:/app/src
    networks: [devops]

  frontend:
    build: ./src/frontend
    ports: ["3000:3000"]
    depends_on:
      - backend
    networks: [devops]

  # Posterior (Fase 3+):
  # postgres, prometheus, grafana

networks:
  devops:
    driver: bridge
```

#### 2.4 Build Automation
```bash
# Scripts para construir e testar imagens
```

**Commit 9:** "feat: add build and test scripts for Docker images"

`scripts/build.sh`:
```bash
#!/bin/bash
docker build -t devops-orchestrator-backend:latest ./src/backend
docker build -t devops-orchestrator-frontend:latest ./src/frontend
docker-compose -f docker-compose.yml up --build
```

---

## ☸️ FASE 3: Kubernetes Local (Commits 10-15)

### Objetivo
Rodar a aplicação em cluster Kubernetes com minikube, entendendo cada recurso.

#### 3.1 Namespace e ConfigMap
```bash
# Isolar recursos da aplicação
```

**Commit 10:** "feat: create Kubernetes namespace and ConfigMaps"

`kubernetes/namespace.yaml`:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: devops-orchestrator
  labels:
    environment: development
```

`kubernetes/configmap.yaml`:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: devops-orchestrator
data:
  LOG_LEVEL: "info"
  NODE_ENV: "production"
```

#### 3.2 Deployments (Backend + Frontend)
```bash
# Gerenciar réplicas de containers
```

**Commit 11:** "feat: create Deployment manifests for backend and frontend"

`kubernetes/backend-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: devops-orchestrator
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: devops-orchestrator-backend:latest
        ports:
        - containerPort: 3001
        env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: LOG_LEVEL
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3001
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3001
          initialDelaySeconds: 5
          periodSeconds: 5
```

`kubernetes/frontend-deployment.yaml`:
- Similar ao backend, mas porta 80 (nginx)
- Sem livenessProbe complexa (apenas readiness)

#### 3.3 Services (Exposição Interna)
```bash
# Endereço fixo para acessar pods
```

**Commit 12:** "feat: create Service manifests for network exposure"

`kubernetes/backend-service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: devops-orchestrator
spec:
  selector:
    app: backend
  type: ClusterIP
  ports:
  - port: 3001
    targetPort: 3001
```

`kubernetes/frontend-service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: devops-orchestrator
spec:
  selector:
    app: frontend
  type: LoadBalancer  # minikube expõe com IP externo
  ports:
  - port: 80
    targetPort: 80
```

#### 3.4 Ingress (Roteamento Externo)
```bash
# Acessar via domínio localhost
```

**Commit 13:** "feat: add Ingress configuration for local development"

`kubernetes/ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: devops-ingress
  namespace: devops-orchestrator
spec:
  ingressClassName: nginx
  rules:
  - host: devops.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3001
```

#### 3.5 HPA (Auto-scaling)
```bash
# Escalonar automaticamente baseado em CPU
```

**Commit 14:** "feat: add Horizontal Pod Autoscaler for backend"

`kubernetes/hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: devops-orchestrator
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### 3.6 Setup Script
```bash
# Automatizar aplicação de manifests
```

**Commit 15:** "docs: add Kubernetes setup and deployment guide"

`kubernetes/README.md` + `scripts/k8s-deploy.sh`:
```bash
#!/bin/bash
set -e

echo "🚀 Starting minikube..."
minikube start --cpus=2 --memory=4096

echo "📦 Enabling addons..."
minikube addons enable ingress
minikube addons enable metrics-server

echo "🔧 Building Docker images inside minikube..."
eval $(minikube docker-env)
docker build -t devops-orchestrator-backend:latest ./src/backend
docker build -t devops-orchestrator-frontend:latest ./src/frontend

echo "📝 Applying Kubernetes manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/backend-service.yaml
kubectl apply -f kubernetes/frontend-service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml

echo "✅ Deployment complete!"
echo "🌐 Access frontend at: http://devops.local"
echo "📊 Minikube dashboard: minikube dashboard"
```

---

## 📦 FASE 4: Helm Chart (Commits 16-18)

### Objetivo
Parametrizar todos os manifests Kubernetes para reutilização em dev/staging/prod.

#### 4.1 Chart Structure
```bash
# Criar templates Helm
```

**Commit 16:** "feat: initialize Helm chart for application"

`helm/devops-orchestrator/`:
```
Chart.yaml              # Metadados do chart
values.yaml             # Valores padrão
values-dev.yaml         # Overrides para dev
values-prod.yaml        # Overrides para prod
templates/
  ├── deployment-backend.yaml
  ├── deployment-frontend.yaml
  ├── service-backend.yaml
  ├── service-frontend.yaml
  ├── ingress.yaml
  ├── hpa.yaml
  ├── configmap.yaml
  ├── _helpers.tpl       # Funções reutilizáveis
  └── NOTES.txt          # Instruções pós-install
```

#### 4.2 Values e Templates
```bash
# Parametrizar imagens, replicas, domínios
```

**Commit 17:** "feat: create Helm templates and values for all resources"

`helm/devops-orchestrator/values.yaml`:
```yaml
backend:
  image:
    repository: devops-orchestrator-backend
    tag: latest
    pullPolicy: IfNotPresent
  replicas: 2
  port: 3001
  logLevel: info
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

frontend:
  image:
    repository: devops-orchestrator-frontend
    tag: latest
    pullPolicy: IfNotPresent
  replicas: 1
  port: 80
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 250m
      memory: 256Mi

ingress:
  enabled: true
  host: devops.local
  ingressClassName: nginx

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPU: 70
```

Template exemplo (`templates/deployment-backend.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "devops-orchestrator.fullname" . }}-backend
  namespace: {{ .Release.Namespace }}
spec:
  replicas: {{ .Values.backend.replicas }}
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
        ports:
        - containerPort: {{ .Values.backend.port }}
        env:
        - name: LOG_LEVEL
          value: "{{ .Values.backend.logLevel }}"
        resources: {{ toYaml .Values.backend.resources | nindent 10 }}
```

#### 4.3 Environment-Specific Deployments
```bash
# valores por ambiente
```

**Commit 18:** "feat: add environment-specific Helm values for dev and production"

`helm/devops-orchestrator/values-dev.yaml`:
```yaml
backend:
  replicas: 1
  logLevel: debug
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 250m
      memory: 256Mi

frontend:
  replicas: 1

autoscaling:
  enabled: false  # dev não precisa de autoscale
```

`helm/devops-orchestrator/values-prod.yaml`:
```yaml
backend:
  replicas: 3
  logLevel: info
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

Deploy commands:
```bash
# Dev
helm install devops-dev ./helm/devops-orchestrator -f ./helm/devops-orchestrator/values-dev.yaml -n devops-dev --create-namespace

# Prod
helm install devops-prod ./helm/devops-orchestrator -f ./helm/devops-orchestrator/values-prod.yaml -n devops-prod --create-namespace
```

---

## 🔄 FASE 5: GitHub Actions CI/CD (Commits 19-23)

### Objetivo
Automatizar build, testes, push de imagens Docker, e deploy automático.

#### 5.1 CI Workflow (Lint, Test, Build)
```bash
# Roda em todo push e PR
```

**Commit 19:** "feat: add GitHub Actions workflow for CI (lint, test, build)"

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main, develop]

jobs:
  # Backend tests
  backend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: 'src/backend/package-lock.json'
      
      - run: cd src/backend && npm ci
      - run: cd src/backend && npm run lint
      - run: cd src/backend && npm test
      - run: cd src/backend && npm run build
  
  # Frontend tests
  frontend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: 'src/frontend/package-lock.json'
      
      - run: cd src/frontend && npm ci
      - run: cd src/frontend && npm run lint
      - run: cd src/frontend && npm run build
  
  # Docker build (sem push no CI)
  docker-build:
    needs: [backend-test, frontend-test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: docker/setup-buildx-action@v3
      
      - uses: docker/build-push-action@v6
        with:
          context: ./src/backend
          push: false
          tags: devops-orchestrator-backend:${{ github.sha }}
      
      - uses: docker/build-push-action@v6
        with:
          context: ./src/frontend
          push: false
          tags: devops-orchestrator-frontend:${{ github.sha }}
```

#### 5.2 CD Workflow (Push para Docker Hub)
```bash
# Roda apenas em main/develop
```

**Commit 20:** "feat: add CD workflow for Docker image push to Docker Hub"

`.github/workflows/cd.yml`:
```yaml
name: CD

on:
  push:
    branches: [main, develop]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: docker/setup-buildx-action@v3
      
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      
      - uses: docker/build-push-action@v6
        with:
          context: ./src/backend
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/devops-orchestrator-backend:latest
            ${{ secrets.DOCKER_USERNAME }}/devops-orchestrator-backend:${{ github.sha }}
      
      - uses: docker/build-push-action@v6
        with:
          context: ./src/frontend
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/devops-orchestrator-frontend:latest
            ${{ secrets.DOCKER_USERNAME }}/devops-orchestrator-frontend:${{ github.sha }}
```

#### 5.3 Secrets Configuration
```bash
# Configurar no GitHub
```

**Commit 21:** "docs: add GitHub Actions secrets setup guide"

Secrets a configurar:
- `DOCKER_USERNAME` — Docker Hub username
- `DOCKER_TOKEN` — Docker Hub access token
- `KUBECONFIG` — (opcional, para deploy automático)

`.github/SECRETS.md`:
```markdown
# GitHub Actions Secrets Setup

1. Go to repository Settings → Secrets and variables → Actions
2. Create these secrets:

| Secret | Value | Source |
|--------|-------|--------|
| DOCKER_USERNAME | seu-username | Docker Hub |
| DOCKER_TOKEN | seu-token | Docker Hub (Settings → Security) |

Para obter Docker Token:
1. Docker Hub → Account settings → Security → New Access Token
2. Copiar o token e guardar em local seguro
```

#### 5.4 Testing Setup
```bash
# Configurar Jest, fixtures, fixtures
```

**Commit 22:** "feat: add unit and integration tests for backend"

`src/backend/tests/agents.test.js`:
```javascript
describe('OrchestratorAgent', () => {
  let orchestrator;
  
  beforeEach(() => {
    orchestrator = new OrchestratorAgent();
  });
  
  test('should route kubernetes messages to KubernetesAgent', () => {
    const relevance = orchestrator.calculateRelevance('kubectl get pods');
    expect(relevance).toBeGreaterThan(0);
  });
  
  test('should format response correctly', () => {
    const response = orchestrator.formatResponse('test content', { foo: 'bar' });
    expect(response).toHaveProperty('agent');
    expect(response).toHaveProperty('timestamp');
  });
});
```

`src/backend/tests/api.test.js`:
```javascript
const request = require('supertest');
const app = require('../src/server');

describe('GET /health/live', () => {
  test('should return 200 OK', async () => {
    const res = await request(app).get('/health/live');
    expect(res.statusCode).toBe(200);
  });
});
```

Adicionar ao `package.json`:
```json
{
  "scripts": {
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "lint": "eslint src/ tests/",
    "lint:fix": "eslint src/ tests/ --fix"
  }
}
```

#### 5.5 Pre-commit Hooks
```bash
# Lint antes de commitar
```

**Commit 23:** "chore: add husky pre-commit hooks for code quality"

`.husky/pre-commit`:
```bash
#!/bin/sh
npm run lint
npm run test
```

Instalar:
```bash
npm install husky lint-staged --save-dev
npx husky install
```

---

## 🏗️ FASE 6: Terraform + Localstack (Commits 24-28)

### Objetivo
Provisionar infraestrutura como código — EKS, RDS, IAM, S3 — com Localstack (sem AWS real).

#### 6.1 Terraform Backend (Local)
```bash
# State management
```

**Commit 24:** "feat: initialize Terraform with local backend"

`terraform/main.tf`:
```hcl
terraform {
  required_version = ">= 1.7"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Local backend para desenvolvimento
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  # Localstack configuration
  region = var.aws_region
  
  endpoints {
    ec2             = var.localstack_endpoint
    eks             = var.localstack_endpoint
    rds             = var.localstack_endpoint
    s3              = var.localstack_endpoint
    iam             = var.localstack_endpoint
    logs            = var.localstack_endpoint
  }
  
  # Dummy credentials para Localstack
  access_key = "test"
  secret_key = "test"
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
```

`terraform/variables.tf`:
```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "app_name" {
  type    = string
  default = "devops-orchestrator"
}
```

#### 6.2 VPC Module
```bash
# Rede virtual (VPC, subnets, security groups)
```

**Commit 25:** "feat: add Terraform VPC module with networking"

`terraform/modules/vpc/main.tf`:
```hcl
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone = var.availability_zones[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.app_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_security_group" "main" {
  name        = "${var.app_name}-sg"
  description = "Security group for ${var.app_name}"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-sg"
  }
}
```

#### 6.3 EKS Module
```bash
# Cluster Kubernetes simulado
```

**Commit 26:** "feat: add Terraform EKS module with IAM roles"

`terraform/modules/eks/main.tf`:
```hcl
resource "aws_eks_cluster" "main" {
  name    = "${var.app_name}-cluster"
  version = var.kubernetes_version
  
  role_arn = aws_iam_role.eks_cluster.arn
  
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  
  tags = {
    Name = "${var.app_name}-cluster"
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.app_name}-eks-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.app_name}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids
  
  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count + 2
    min_size     = 1
  }
  
  instance_types = ["t3.medium"]
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.app_name}-eks-nodes-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  
  policy_arn = each.value
  role       = aws_iam_role.eks_nodes.name
}
```

#### 6.4 Root Configuration
```bash
# Compor módulos
```

**Commit 27:** "feat: compose Terraform modules in root configuration"

`terraform/environments/dev.tfvars`:
```hcl
aws_region           = "us-east-1"
localstack_endpoint  = "http://localhost:4566"
environment          = "dev"
app_name             = "devops-orchestrator"
cidr_block           = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
kubernetes_version   = "1.28"
node_count           = 2
```

`terraform/main.tf` (root):
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  app_name           = var.app_name
  environment        = var.environment
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source = "./modules/eks"
  
  app_name           = var.app_name
  environment        = var.environment
  kubernetes_version = "1.28"
  node_count         = 2
  subnet_ids         = module.vpc.public_subnet_ids
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}
```

#### 6.5 Localstack Docker Compose Integration
```bash
# Adicionar Localstack ao docker-compose
```

**Commit 28:** "feat: integrate Localstack into docker-compose for local AWS simulation"

Atualizar `docker-compose.yml`:
```yaml
services:
  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"  # All AWS services on single port
    environment:
      - SERVICES=eks,rds,s3,iam,ec2,logs
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "${TMPDIR:-.}:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks: [devops]

  # Após Localstack estar pronto:
  terraform:
    build:
      context: .
      dockerfile: Dockerfile.terraform
    working_dir: /terraform
    environment:
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_REGION=us-east-1
    volumes:
      - ./terraform:/terraform
      - ./terraform.tfstate:/terraform/terraform.tfstate
    depends_on:
      - localstack
    networks: [devops]
    command: > 
      sh -c "terraform init &&
             terraform plan -var-file=environments/dev.tfvars &&
             terraform apply -auto-approve -var-file=environments/dev.tfvars"
```

`Dockerfile.terraform`:
```dockerfile
FROM hashicorp/terraform:1.7

RUN apk add --no-cache bash curl

WORKDIR /terraform

ENV TF_LOG=INFO
ENV TF_LOG_PATH=/tmp/terraform.log
```

---

## 📊 FASE 7: Observabilidade (Commits 29-33)

### Objetivo
Implementar Prometheus, Grafana, logs estruturados e alertas.

#### 7.1 Prometheus Setup
```bash
# Scraping de métricas
```

**Commit 29:** "feat: add Prometheus configuration for metrics collection"

`monitoring/prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'devops-orchestrator'

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:3001']
    metrics_path: '/metrics'
    
  - job_name: 'kubernetes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

rule_files:
  - '/etc/prometheus/rules/*.yml'
```

`monitoring/prometheus/rules/alerts.yml`:
```yaml
groups:
  - name: devops.rules
    interval: 30s
    rules:
      - alert: BackendDown
        expr: up{job="backend"} == 0
        for: 2m
        annotations:
          summary: "Backend service is down"
          
      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        annotations:
          summary: "High CPU usage detected"
          
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[1h]) > 5
        annotations:
          summary: "Pod is crash looping"
```

#### 7.2 Grafana Dashboards
```bash
# Visualização de métricas
```

**Commit 30:** "feat: add Grafana dashboards for application and infrastructure monitoring"

`monitoring/grafana/provisioning/dashboards/backend.json`:
```json
{
  "dashboard": {
    "title": "DevOps Orchestrator Backend",
    "tags": ["backend", "nodejs"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{path}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds)",
            "legendFormat": "p95"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~'5..'}[5m])",
            "legendFormat": "{{status}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Pod Status",
        "targets": [
          {
            "expr": "count by (pod) (kube_pod_status_phase{namespace='devops-orchestrator'})",
            "legendFormat": "{{pod}}"
          }
        ],
        "type": "table"
      }
    ]
  }
}
```

#### 7.3 Logging com Structured Logging
```bash
# Logs em JSON
```

**Commit 31:** "feat: implement structured logging with Loki integration"

Backend já tem Pino (JSON logs). Adicionar Loki no stack:

`docker-compose.yml`:
```yaml
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./monitoring/loki/loki-config.yml:/etc/loki/local-config.yaml
    command: -config.file=/etc/loki/local-config.yaml
    networks: [devops]

  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./src/backend/logs:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/config.yml
    networks: [devops]
```

#### 7.4 Alert Manager
```bash
# Roteamento de alertas
```

**Commit 32:** "feat: configure AlertManager for alert routing and notifications"

`monitoring/alertmanager/alertmanager.yml`:
```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default-receiver'
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
    - match:
        severity: warning
      receiver: 'slack'

receivers:
  - name: 'default-receiver'
    # Email, Webhook, etc.
  
  - name: 'slack'
    slack_configs:
      - api_url: $SLACK_WEBHOOK_URL
        channel: '#alerts'
        
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: $PAGERDUTY_SERVICE_KEY
```

#### 7.5 Observability Documentation
```bash
# Como usar e estender
```

**Commit 33:** "docs: add comprehensive observability and monitoring guide"

`monitoring/README.md`:
```markdown
# Observabilidade — DevOps Orchestrator

## Stack

- **Prometheus:** Coleta de métricas (15s scrape interval)
- **Grafana:** Visualização (dashboards interativos)
- **Loki:** Agregação de logs (JSON estruturado)
- **AlertManager:** Roteamento de alertas

## Acessar

- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Loki: http://localhost:3100

## Adicionar Métrica Customizada

No backend, use Pino:

\`\`\`javascript
logger.info(
  { 
    userId: req.user.id, 
    agentName: agent.name,
    responseTime: duration 
  },
  'Agent processed message'
);
\`\`\`

Prometheus irá agregar automaticamente em:
- `agent_messages_total` (counter)
- `agent_response_time_seconds` (histogram)

## Criar Dashboard

1. Grafana → Create → Dashboard
2. Add panel
3. Data source: Prometheus
4. Query: `rate(http_requests_total[5m])`
5. Save
```

---

## 🎁 FASE 8: Portfolio Final (Commits 34-36)

### Objetivo
Documentação profissional, diagrama de arquitetura, README polido, demo pronto.

#### 8.1 Architecture Decision Records (ADRs)
```bash
# Decisões técnicas documentadas
```

**Commit 34:** "docs: add architecture decision records (ADRs) for key technical choices"

`docs/architecture-decisions/adr-001-nodejs-backend.md`:
```markdown
# ADR 001: Use Node.js for Backend

## Status
Accepted

## Context
- Need event-driven API for LLM responses
- Team familiar with JavaScript ecosystem
- Fast iteration and prototyping

## Decision
Use Express.js + Node.js 20 for backend

## Consequences
- ✓ Non-blocking I/O ideal for streaming responses
- ✓ Single language (JS) for frontend + backend
- ✓ Rich npm ecosystem for DevOps tooling
- ✗ Less suitable for CPU-intensive tasks
- ✗ Single-threaded event loop needs careful handling at scale

## Alternatives Considered
- **Python + FastAPI:** Would be heavier, slower iteration
- **Go:** Would require team learning curve
```

`docs/architecture-decisions/adr-002-kubernetes-local.md`:
```markdown
# ADR 002: Use Minikube for Local Development

## Status
Accepted

## Decision
Develop and test with minikube instead of full AWS EKS

## Consequences
- ✓ Zero AWS costs
- ✓ Instant feedback loop (~1 min deploy vs ~5 min on cloud)
- ✓ Can include K8s work in portfolio
- ✗ Edge cases in EKS might not surface locally
- ✗ Resource-constrained (2 CPU, 4GB RAM)

## Transition to Production
When deploying to AWS:
1. Change image registry from local Docker to ECR
2. Switch Helm values to production settings
3. Enable HPA with realistic scaling metrics
4. Use RDS instead of local PostgreSQL
```

#### 8.2 Complete README
```bash
# Documentação principal do projeto
```

**Commit 35:** "docs: write comprehensive README with setup and usage guide"

`README.md`:
```markdown
# DevOps Agent Orchestrator

A portfolio-grade DevOps/SRE multi-agent system demonstrating enterprise-scale Kubernetes, CI/CD, and infrastructure automation.

## 🎯 Highlights

- **Agent-based routing:** Intelligent dispatcher routes messages to specialist agents (Kubernetes, Terraform, Health)
- **Local K8s:** Run full Kubernetes cluster locally with minikube — zero AWS costs
- **Infrastructure as Code:** Terraform modules for VPC, EKS, IAM, with Localstack simulation
- **GitOps CI/CD:** GitHub Actions automate lint, test, build, push, deploy
- **Observability:** Prometheus, Grafana, structured logs, alerts
- **Production-ready:** Health checks, metrics, error handling, security headers

## 🚀 Quick Start

### Prerequisites
- Docker Desktop 24+
- Node.js 20+
- kubectl 1.28+, minikube 1.32+, Helm 3.14+, Terraform 1.7+

### Local Development (5 minutes)

\`\`\`bash
# Clone and setup
git clone https://github.com/seu-usuario/ci-cd-kubernetes.git
cd ci-cd-kubernetes

# Start everything locally
docker-compose up --build

# In another terminal: Deploy to minikube
./scripts/k8s-deploy.sh

# Access
# Frontend: http://localhost:3000
# Backend API: http://localhost:3001/api/agents
# Grafana: http://localhost:3000
# Prometheus: http://localhost:9090
\`\`\`

### Architecture

\`\`\`
┌────────────────────┐
│   Frontend React   │
│   (port 3000)      │
└────────┬───────────┘
         │ HTTP
         ▼
┌────────────────────┐
│  Backend Express   │
│  (port 3001)       │
└────────┬───────────┘
         │
    ┌────┴──────┬──────────┐
    ▼            ▼           ▼
┌──────────┐ ┌────────┐ ┌────────┐
│Orchestr- │ │Kubern- │ │Terraf- │
│ator      │ │etes    │ │orm     │
│Agent     │ │Agent   │ │Agent   │
└──────────┘ └────────┘ └────────┘

Deployed on:
- Local: Docker + docker-compose
- K8s: minikube + Helm
- IaC: Terraform + Localstack (AWS simulation)
- CI/CD: GitHub Actions

Monitored by:
- Prometheus (metrics)
- Grafana (dashboards)
- Loki (logs)
\`\`\`

## 📁 Project Structure

```
.
├── src/frontend/              # React UI
├── src/backend/               # Express API + agents
├── kubernetes/                # K8s YAML manifests
├── helm/devops-orchestrator/  # Helm chart
├── terraform/                 # IaC modules
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   └── iam/
│   └── environments/
├── .github/workflows/         # CI/CD
├── monitoring/                # Prometheus, Grafana, Loki
└── docs/                      # ADRs, architecture
```

## 🔧 Available Commands

\`\`\`bash
# Local development
docker-compose up --build
docker-compose down

# Kubernetes (minikube)
./scripts/k8s-deploy.sh              # Deploy to minikube
./scripts/k8s-destroy.sh             # Clean up K8s

# Terraform
cd terraform
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# CI/CD
npm run lint
npm run test
npm run build
docker build -t devops-orchestrator-backend:latest ./src/backend
```

## 📊 Monitoring

Access dashboards:
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090
- **Logs:** Loki integrated into Grafana

Key metrics:
- `http_requests_total` — API request volume
- `http_request_duration_seconds` — Response time
- `kubernetes_pod_status` — Pod health
- Log streaming with Loki

## 🔐 Security

- ✓ Helmet.js HTTP headers
- ✓ CORS configured
- ✓ No secrets in code (using .env + K8s Secrets)
- ✓ Structured logging for audit
- ✓ Health checks for security scanning

## 📈 Scaling to Production

1. **Container Registry:** Push images to ECR
2. **Kubernetes:** Deploy to AWS EKS instead of minikube
3. **Database:** Use RDS instead of local Postgres
4. **State:** Switch Terraform backend to S3
5. **Secrets:** Use AWS Secrets Manager
6. **Logging:** Use CloudWatch instead of Loki
7. **Monitoring:** Use CloudWatch/Datadog instead of Prometheus

All configurations prepared in `values-prod.yaml` and `environments/prod.tfvars`.

## 📚 Learning Resources

- [Architecture Decisions (ADRs)](docs/architecture-decisions/)
- [Kubernetes Guide](kubernetes/README.md)
- [Terraform Modules](terraform/README.md)
- [Monitoring Setup](monitoring/README.md)

## 📝 License

MIT — See LICENSE file

## 🤝 Feedback

Found issues? Star ⭐ this repo and open an issue!

---

**Built by:** Marcos Sabatino  
**Portfolio:** [LinkedIn](https://linkedin.com/in/msabatino) | [GitHub](https://github.com/marcossabatino)
\`\`\`

#### 8.3 Demo & Final Polish
```bash
# Scripts e guias finais
```

**Commit 36:** "docs: add demo guide and production deployment checklist"

`DEMO.md`:
```markdown
# Demo Guide — DevOps Agent Orchestrator

## Prerequisites
- All Phase 7 done (observability running)
- Browser with 2+ tabs

## 5-Minute Demo Flow

### 1. Show Frontend (1 min)
- Open http://localhost:3000
- Point out agent list (Orchestrator, Kubernetes, Terraform, Health)
- Show UI components

### 2. Agent Conversation (2 min)
- Type: "how do I create a kubernetes deployment?"
- Show Orchestrator routing to KubernetesAgent
- Point out response with formatted output

- Type: "show me kubernetes pods"
- Agent queries minikube and returns results
- Highlight structured response format

### 3. Monitoring Dashboard (1 min)
- Open Grafana http://localhost:3000 (admin/admin)
- Click "DevOps Orchestrator Backend" dashboard
- Show:
  - Request rate graph
  - Response time percentiles (p50, p95, p99)
  - Error rate (should be 0)
  - Pod status table

### 4. Infrastructure as Code (1 min)
- Show `terraform/environments/dev.tfvars`
- Run: `terraform plan`
- Explain how same code scales to prod (just change values)

## Q&A Talking Points

**Q: Why agents and not monolithic AI?**
A: Agents allow composition of specialized domain knowledge. Orchestrator routes to expert. Easy to add new agents (Ansible, Docker, Prometheus).

**Q: How does this work on AWS?**
A: Helm values switch to ECR image registry. Terraform targets real EKS. Exact same codebase, zero changes.

**Q: What makes this production-ready?**
A: Health checks, metrics, structured logs, error boundaries, security headers, RBAC-ready.

**Q: Timeline to build?**
A: ~80 hours total (40h if parallelizing). Broken into 8 phases so you can stop earlier if time-constrained.
```

`DEPLOYMENT.md`:
```markdown
# Production Deployment Checklist

## Pre-Deployment

- [ ] All tests passing (`npm run test`)
- [ ] Linting clean (`npm run lint`)
- [ ] Images built and tested locally
- [ ] Terraform plan reviewed (no surprises)
- [ ] Environment variables verified (no dev secrets)
- [ ] Database migrations prepared
- [ ] Backup procedures documented

## AWS Setup (One-time)

- [ ] AWS account created
- [ ] IAM user with Terraform permissions created
- [ ] AWS credentials in CI/CD secrets (GITHUB_ACTIONS)
- [ ] S3 bucket for Terraform state
- [ ] ECR repositories created
- [ ] RDS subnet group configured
- [ ] VPC security groups reviewed by security team

## Deployment

\`\`\`bash
# 1. Push docker images to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

docker tag devops-orchestrator-backend:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/devops-orchestrator-backend:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/devops-orchestrator-backend:latest

# 2. Provision infrastructure
cd terraform
terraform init -backend-config="bucket=YOUR_STATE_BUCKET"
terraform apply -var-file=environments/prod.tfvars

# 3. Deploy application
helm install devops-prod ./helm/devops-orchestrator \
  -f helm/devops-orchestrator/values-prod.yaml \
  -n devops-prod \
  --create-namespace

# 4. Verify
kubectl -n devops-prod get pods
kubectl -n devops-prod logs -f deployment/backend
\`\`\`

## Post-Deployment

- [ ] Health checks passing
- [ ] Logs flowing to CloudWatch
- [ ] Metrics visible in CloudWatch
- [ ] Alarms triggered and routing correctly
- [ ] DNS/Route53 configured
- [ ] SSL certificate provisioned
- [ ] Load test performed (k6, wrk)
- [ ] On-call runbook prepared

## Rollback Procedure

\`\`\`bash
# Quick rollback to previous version
helm rollback devops-prod -n devops-prod

# Or rollback infrastructure
terraform apply -var-file=environments/prod.tfvars -refresh=true
\`\`\`
```

---

## 🎯 Summary by Phase

| Phase | Commits | Time | Deliverable |
|-------|---------|------|-------------|
| 1: Foundation | 1-5 | 8h | Backend + Frontend running |
| 2: Docker | 6-9 | 4h | Images + docker-compose |
| 3: K8s | 10-15 | 8h | minikube cluster with manifests |
| 4: Helm | 16-18 | 3h | Parametrized helm chart |
| 5: CI/CD | 19-23 | 5h | GitHub Actions pipelines + tests |
| 6: Terraform | 24-28 | 12h | IaC modules + Localstack |
| 7: Observability | 29-33 | 6h | Prometheus + Grafana + Loki |
| 8: Portfolio | 34-36 | 4h | Docs, ADRs, demo guide |
| **TOTAL** | **36** | **~50h** | **Production-ready portfolio project** |

---

## 🚦 Getting Started

### Today: Start Phase 1
```bash
cd /home/sabatino/projetos/portfolio/ci-cd-kubernetes

# Initialize git (if not done)
git init
git remote add origin git@github.com:marcossabatino/ci-cd-kubernetes.git
git branch -M main

# Create structure (Phase 1.1)
mkdir -p src/{frontend,backend/src/{agents,routes,middleware,metrics},backend/tests}
mkdir -p kubernetes helm/devops-orchestrator/{templates,charts}
mkdir -p terraform/{modules/{eks,vpc,iam},environments}
mkdir -p .github/{workflows,ISSUE_TEMPLATE} monitoring/{prometheus,grafana} docs

# First commit
git add .
git commit -m "chore: initialize project structure with foundational directories"
git push -u origin main
```

### Next: Continue with Phase 1.2-1.5
Implement backend skeleton, agents, routes, frontend UI — all covered in PLANO_IMPLEMENTACAO.md section by section.

---

## 📞 Questions During Implementation?

Refer back to this plan. Each phase has:
1. **Why:** Context and motivation
2. **What:** Exact files and structure
3. **How:** Code snippets ready to use
4. **When:** Commit message and commit order

**Repository:** `git@github.com:marcossabatino/ci-cd-kubernetes.git`  
**All commits are well-organized and portfolio-ready.**

Good luck! 🚀
