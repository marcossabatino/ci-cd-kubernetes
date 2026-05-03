# 📋 PLANO DE IMPLEMENTAÇÃO — Observability SRE Portal

**Repositório:** `git@github.com:marcossabatino/ci-cd-kubernetes.git`  
**Data:** Maio 2026  
**Versão:** 2.0 (Alterado para Site Educacional)  
**Status:** Pronto para Início

---

## 🎯 Visão Geral do Projeto

Um **portal educacional estático** sobre observabilidade em SRE — logs, traces e métricas — deployado com toda uma stack DevOps profissional (Kubernetes, Terraform, CI/CD, monitoramento).

**O diferencial:** O próprio site é observável. Enquanto você ensina sobre observabilidade, o site está sendo monitorado em tempo real com Prometheus, Grafana e logs estruturados.

**Stack completa:**
- **App:** Site estático (HTML/CSS/JS) com nginx
- **Container:** Docker multi-stage otimizado
- **Orquestração:** Kubernetes (minikube local)
- **IaC:** Terraform + Localstack (AWS simulado)
- **CI/CD:** GitHub Actions (lint, build, push, deploy)
- **Observabilidade:** Prometheus, Grafana, Loki (o site é monitorado)

---

## 📚 Conteúdo do Site

### Estrutura de Páginas

```
/
├── index.html              → Home + intro à observabilidade
├── logs/
│   ├── index.html          → O que são logs?
│   ├── structured.html     → Logs estruturados (JSON)
│   └── best-practices.html → Melhores práticas
├── metrics/
│   ├── index.html          → O que são métricas?
│   ├── prometheus.html     → Prometheus 101
│   └── dashboards.html     → Criando dashboards Grafana
├── traces/
│   ├── index.html          → O que é distributed tracing?
│   ├── jaeger.html         → Jaeger/Zipkin
│   └── instrumentation.html→ Instrumentar aplicações
├── sre/
│   ├── index.html          → O papel de um SRE
│   ├── alerts.html         → Alerting best practices
│   └── incident.html       → Resposta a incidentes
├── demo/
│   ├── index.html          → Live demo
│   └── dashboard.html      → Grafana dashboard embed
├── architecture/
│   ├── index.html          → Diagrama da arquitetura
│   └── deployment.html     → Como este site é deployado
└── about.html              → Sobre o autor

CSS/
├── style.css               → Estilos principais
├── prism.css               → Syntax highlighting
└── responsive.css          → Mobile first

JS/
├── main.js                 → Interatividade
├── charts.js               → Visualizações (Chart.js)
└── metrics-live.js         → Dashboard de métricas ao vivo
```

### Seções Principais

#### 1️⃣ **Logs**
- O que é um log?
- Estruturado vs. não-estruturado
- Exemplo: JSON logs com Pino
- Agregação com Loki
- Buscas e análise
- Live demo: tail de logs em tempo real

#### 2️⃣ **Métricas**
- O que é métrica?
- Tipos: counter, gauge, histogram, summary
- Prometheus exposition format
- PromQL queries
- Alerting rules
- Live demo: gráficos de métricas em tempo real

#### 3️⃣ **Traces**
- Distributed tracing concept
- Request flow visualization
- Jaeger/Zipkin
- Instrumentação
- Correlação entre logs, traces e métricas

#### 4️⃣ **SRE & Observabilidade**
- Por que SREs precisam de observabilidade
- Four Golden Signals (latência, tráfego, erros, saturação)
- Alerting baseado em SLOs
- Incident response com dados

#### 5️⃣ **Demo & Arquitetura**
- Dashboard Grafana embutido (live)
- Diagrama da infraestrutura (Kubernetes, Terraform)
- Como este site é deployado
- Logs, traces, métricas do próprio site

---

## 📦 Estrutura de Fases

```
┌─────────────────────────────────────────────────────────────┐
│ FASE 1: Foundation                                          │
│ └─ Estrutura HTML/CSS, conteúdo, assets                    │
├─────────────────────────────────────────────────────────────┤
│ FASE 2: Containerização Docker                              │
│ └─ Dockerfile nginx multi-stage, docker-compose             │
├─────────────────────────────────────────────────────────────┤
│ FASE 3: Kubernetes Local                                    │
│ └─ Minikube, manifests K8s, ConfigMaps, Ingress             │
├─────────────────────────────────────────────────────────────┤
│ FASE 4: Helm Chart                                          │
│ └─ Parametrização, values dev/prod                          │
├─────────────────────────────────────────────────────────────┤
│ FASE 5: GitHub Actions CI/CD                                │
│ └─ Workflows lint, build, push, deploy automático           │
├─────────────────────────────────────────────────────────────┤
│ FASE 6: Terraform + Localstack                              │
│ └─ IaC simulada (VPC, ECS/EKS, IAM, Route53)                │
├─────────────────────────────────────────────────────────────┤
│ FASE 7: Observabilidade                                     │
│ └─ Prometheus, Grafana, Loki (monitora o próprio site)      │
├─────────────────────────────────────────────────────────────┤
│ FASE 8: Portfolio Final                                     │
│ └─ Documentação, diagrama arquitetura, demo pronta          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 FASE 1: Foundation (Commits 1-4)

### Objetivo
Criar site estático educacional com conteúdo sobre observabilidade.

### Entregáveis

#### 1.1 Setup Inicial do Repositório
```bash
# Estrutura base (já feita no projeto anterior)
```

**Commit 1:** "chore: update project for static observability education site"

Mudanças:
- Remove agentes (backend anterior não vai ser usado)
- Limpa estrutura do backend (mantém apenas para helpers futuros)
- Adiciona diretório `site/` para conteúdo estático

#### 1.2 Home Page e Estrutura Base
```bash
# HTML/CSS responsivo, design moderno
```

**Commit 2:** "feat: create home page and main site structure"

`site/index.html`:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Observability Portal — Logs, Traces & Metrics para SRE</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <nav class="navbar">
    <div class="container">
      <div class="logo">📊 Observability Portal</div>
      <ul class="nav-links">
        <li><a href="/">Home</a></li>
        <li><a href="/logs/">Logs</a></li>
        <li><a href="/metrics/">Métricas</a></li>
        <li><a href="/traces/">Traces</a></li>
        <li><a href="/sre/">SRE</a></li>
        <li><a href="/architecture/">Arquitetura</a></li>
        <li><a href="/about.html">Sobre</a></li>
      </ul>
    </div>
  </nav>

  <header class="hero">
    <div class="container">
      <h1>Observabilidade em SRE</h1>
      <p class="subtitle">Entenda logs, métricas e traces — os pilares da observabilidade moderna</p>
      <div class="cta">
        <a href="/logs/" class="btn btn-primary">Comece com Logs</a>
        <a href="/architecture/" class="btn btn-secondary">Ver Arquitetura</a>
      </div>
    </div>
  </header>

  <main class="container">
    <section class="intro">
      <h2>Por que Observabilidade Importa?</h2>
      <p>
        Um SRE (Site Reliability Engineer) não é um DevOps que trabalha em operações.
        Um SRE é um engenheiro que acredita que operações problemas devem ser resolvidos
        com engenharia de software.
      </p>
      <p>
        E observabilidade é a base: você não consegue otimizar o que não pode medir.
      </p>
    </section>

    <section class="three-pillars">
      <div class="pillar">
        <h3>📝 Logs</h3>
        <p>Registros em tempo real do que acontece em suas aplicações.</p>
        <a href="/logs/">Saiba mais →</a>
      </div>
      <div class="pillar">
        <h3>📈 Métricas</h3>
        <p>Medidas quantitativas: latência, throughput, CPU, memória...</p>
        <a href="/metrics/">Saiba mais →</a>
      </div>
      <div class="pillar">
        <h3>🔗 Traces</h3>
        <p>Rastreamento de requisições através de microsserviços.</p>
        <a href="/traces/">Saiba mais →</a>
      </div>
    </section>

    <section class="this-site">
      <h2>Este Site é um Exemplo Vivo</h2>
      <p>
        Enquanto você aprende sobre observabilidade aqui, o próprio site está sendo
        monitorado com Prometheus, Grafana e Loki.
      </p>
      <a href="/architecture/">Ver dashboard ao vivo →</a>
    </section>
  </main>

  <footer class="footer">
    <p>© 2026 Marcos Sabatino | DevOps & SRE | GitHub | LinkedIn</p>
  </footer>

  <script src="/js/main.js"></script>
</body>
</html>
```

#### 1.3 Páginas de Conteúdo
```bash
# Logs, Métricas, Traces, SRE
```

**Commit 3:** "feat: add content pages for logs, metrics, and traces"

`site/logs/index.html`:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Logs — Observability Portal</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="stylesheet" href="/css/prism.css">
</head>
<body>
  <nav class="navbar">...</nav>

  <header class="section-hero">
    <h1>Logs: Os Olhos da Aplicação</h1>
  </header>

  <main class="container">
    <section>
      <h2>O que é um Log?</h2>
      <p>
        Um log é um registro de um evento que ocorreu em sua aplicação.
        Pode ser um erro, um aviso, uma informação, ou debug.
      </p>
      
      <h3>Exemplo de Log Não-Estruturado</h3>
      <pre><code class="language-bash">
2026-05-03 14:23:45 ERROR Failed to connect to database
      </code></pre>
      <p>❌ Difícil de parsear, buscar e analisar</p>

      <h3>Exemplo de Log Estruturado (JSON)</h3>
      <pre><code class="language-json">
{
  "timestamp": "2026-05-03T14:23:45.123Z",
  "level": "error",
  "service": "api-gateway",
  "message": "Failed to connect to database",
  "error": {
    "type": "ConnectionTimeout",
    "code": "ECONNREFUSED"
  },
  "context": {
    "userId": "usr_123",
    "requestId": "req_456",
    "duration_ms": 5000
  }
}
      </code></pre>
      <p>✅ Estruturado, queryável, correlacionável</p>
    </section>

    <section>
      <h2>Melhores Práticas</h2>
      <ul>
        <li>Use logs estruturados (JSON)</li>
        <li>Inclua contexto (requestId, userId, etc)</li>
        <li>Use níveis apropriados (DEBUG, INFO, WARN, ERROR)</li>
        <li>Agregue logs com Loki, ELK, ou Datadog</li>
        <li>Correlacione com traces e métricas</li>
      </ul>
    </section>

    <section>
      <h2>Ferramentas</h2>
      <ul>
        <li><strong>Logging:</strong> Pino, winston, Logback, log4j</li>
        <li><strong>Agregação:</strong> Loki, ELK Stack, Splunk</li>
        <li><strong>Análise:</strong> Grep, Loki QL, Kibana</li>
      </ul>
    </section>

    <section class="next-steps">
      <a href="/metrics/">Próximo: Métricas →</a>
    </section>
  </main>

  <footer>...</footer>
  <script src="/js/prism.js"></script>
</body>
</html>
```

(Similar para `/metrics/` e `/traces/`)

#### 1.4 Assets e Estilos
```bash
# CSS responsivo, assets, JavaScript
```

**Commit 4:** "feat: add styles, assets, and JavaScript interactivity"

Arquivos:
- `site/css/style.css` — Estilos principais (responsivo, gradientes, dark mode)
- `site/css/prism.css` — Syntax highlighting
- `site/js/main.js` — Menu mobile, tema escuro/claro
- `site/js/charts.js` — Gráficos com Chart.js (opcional)
- `site/assets/` — SVGs, ícones, imagens

---

## 🐳 FASE 2: Containerização Docker (Commits 5-7)

### Objetivo
Empacotar site em imagem Docker otimizada com nginx.

#### 2.1 Dockerfile e nginx.conf

**Commit 5:** "feat: add Dockerfile for static site with nginx optimization"

`Dockerfile`:
```dockerfile
# Stage 1: Builder (futuro — se adicionar build process)
FROM alpine:3.18 AS build

WORKDIR /build
COPY site/ .

# Otimizações futuras (minify, etc)
# Por enquanto, apenas cópia

# Stage 2: Runtime
FROM nginx:alpine

# Remove config padrão
RUN rm /etc/nginx/conf.d/default.conf

# Copia configuração customizada
COPY site/nginx.conf /etc/nginx/conf.d/default.conf

# Copia arquivos estáticos
COPY --from=build /build /usr/share/nginx/html

# Expõe porta 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

`site/nginx.conf`:
```nginx
server {
  listen 80;
  server_name _;
  
  root /usr/share/nginx/html;
  index index.html;
  
  # Gzip
  gzip on;
  gzip_types text/plain text/css application/json application/javascript;
  
  # SPA routing
  location / {
    try_files $uri $uri/ /index.html;
    add_header Cache-Control "no-cache, no-store, must-revalidate";
  }
  
  # Assets (cache long)
  location ~* \.(js|css|jpg|png|svg|woff)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
  }
  
  # Health check
  location /health {
    access_log off;
    return 200 "OK";
    add_header Content-Type text/plain;
  }
  
  # Metrics (nginx_exporter irá ler isso)
  location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
  }
}
```

#### 2.2 Docker Compose

**Commit 6:** "feat: add docker-compose for local development"

`docker-compose.yml`:
```yaml
version: '3.8'

services:
  website:
    build: .
    container_name: observability-site
    ports:
      - "8080:80"
    environment:
      - TZ=UTC
    networks:
      - observability
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s

  # Fase 7: Observabilidade (adicionar depois)
  # prometheus:
  #   image: prom/prometheus:latest
  #   ports:
  #     - "9090:9090"
  #
  # grafana:
  #   image: grafana/grafana:latest
  #   ports:
  #     - "3000:3000"

networks:
  observability:
    driver: bridge
```

#### 2.3 Build Scripts

**Commit 7:** "chore: add build and deployment scripts"

`scripts/build.sh`:
```bash
#!/bin/bash
set -e

echo "📦 Building Docker image..."
docker build -t observability-site:latest .
docker tag observability-site:latest observability-site:$(date +%s)

echo "✅ Build complete!"
echo "Run: docker run -p 8080:80 observability-site:latest"
```

---

## ☸️ FASE 3: Kubernetes Local (Commits 8-11)

### Objetivo
Deploy site em minikube com Ingress, ConfigMaps, etc.

#### 3.1 Manifests K8s

**Commit 8:** "feat: create Kubernetes deployment for static site"

`kubernetes/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: observability-site
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: observability-site
  template:
    metadata:
      labels:
        app: observability-site
    spec:
      containers:
      - name: nginx
        image: observability-site:latest
        imagePullPolicy: Never  # minikube local
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
          limits:
            cpu: 200m
            memory: 128Mi
```

**Commit 9:** "feat: add Kubernetes Service and Ingress"

`kubernetes/service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: observability-site-svc
spec:
  selector:
    app: observability-site
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
```

`kubernetes/ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: observability-site-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: observability.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: observability-site-svc
            port:
              number: 80
```

#### 3.2 HPA e recursos

**Commit 10:** "feat: add HPA and resource limits for scaling"

`kubernetes/hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: observability-site-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: observability-site
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### 3.3 Deploy Script

**Commit 11:** "docs: add Kubernetes deployment guide and scripts"

`scripts/k8s-deploy.sh`:
```bash
#!/bin/bash
set -e

echo "🚀 Starting minikube..."
minikube start --cpus=2 --memory=4096

echo "📦 Building image in minikube context..."
eval $(minikube docker-env)
docker build -t observability-site:latest .

echo "📝 Applying K8s manifests..."
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml

echo "⏳ Waiting for pods..."
kubectl wait --for=condition=ready pod -l app=observability-site --timeout=60s

echo "✅ Deployment complete!"
echo "🌐 Access at: http://observability.local"
echo "📊 Minikube dashboard: minikube dashboard"
```

---

## 📦 FASE 4: Helm Chart (Commits 12-13)

### Objetivo
Parametrizar K8s manifests para reutilização.

#### 4.1 Chart Structure

**Commit 12:** "feat: initialize Helm chart with templates"

`helm/observability-site/Chart.yaml`:
```yaml
apiVersion: v2
name: observability-site
description: Educational site on observability — Logs, Traces, Metrics
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - observability
  - sre
  - education
```

`helm/observability-site/values.yaml`:
```yaml
image:
  repository: observability-site
  tag: latest
  pullPolicy: IfNotPresent

replicaCount: 2

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  host: observability.local
  className: nginx

resources:
  requests:
    cpu: 50m
    memory: 32Mi
  limits:
    cpu: 200m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPU: 70

environment: dev
```

#### 4.2 Environment Values

**Commit 13:** "feat: add environment-specific Helm values"

`helm/observability-site/values-prod.yaml`:
```yaml
replicaCount: 3

resources:
  requests:
    cpu: 200m
    memory: 64Mi
  limits:
    cpu: 500m
    memory: 256Mi

autoscaling:
  minReplicas: 3
  maxReplicas: 20
  targetCPU: 60

environment: prod
```

---

## 🔄 FASE 5: GitHub Actions CI/CD (Commits 14-17)

### Objetivo
Automatizar build, teste e deploy.

#### 5.1 CI Workflow

**Commit 14:** "feat: add GitHub Actions CI workflow"

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main, develop]

jobs:
  lint-html:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g html-validate
      - run: html-validate site/**/*.html || true

  build-docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          push: false
          tags: observability-site:${{ github.sha }}
```

#### 5.2 CD Workflow

**Commit 15:** "feat: add GitHub Actions CD workflow for Docker push"

`.github/workflows/cd.yml`:
```yaml
name: CD

on:
  push:
    branches: [main, develop]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/observability-site:latest
            ${{ secrets.DOCKER_USERNAME }}/observability-site:${{ github.sha }}
```

#### 5.3 Security Scanning

**Commit 16:** "chore: add security scanning and dependency checks"

`.github/workflows/security.yml`:
```yaml
name: Security

on: [push, pull_request]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
```

#### 5.4 Documentation

**Commit 17:** "docs: add CI/CD setup and GitHub secrets guide"

`.github/DEPLOYMENT.md`:
```markdown
# CI/CD Setup

## GitHub Secrets

1. `DOCKER_USERNAME` — Docker Hub username
2. `DOCKER_TOKEN` — Docker Hub access token

## How it works

1. Push → GitHub Actions runs CI (lint, build)
2. Merge to main → CD pipeline runs
3. Docker image built and pushed to Docker Hub
4. (Fase 6) Terraform picks up new image
5. (Fase 7) New deployment, metrics updated
```

---

## 🏗️ FASE 6: Terraform + Localstack (Commits 18-21)

### Objetivo
Infrastructure as Code com AWS simulado.

#### 6.1 Terraform Setup

**Commit 18:** "feat: initialize Terraform with Localstack backend"

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
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  
  endpoints {
    ec2            = var.localstack_endpoint
    ecs            = var.localstack_endpoint
    ecr            = var.localstack_endpoint
    route53        = var.localstack_endpoint
    s3             = var.localstack_endpoint
  }
  
  access_key = "test"
  secret_key = "test"
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}
```

#### 6.2 VPC Module

**Commit 19:** "feat: add Terraform VPC module with networking"

`terraform/modules/vpc/main.tf`:
```hcl
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.app_name}-public-subnet"
  }
}

resource "aws_security_group" "main" {
  name   = "${var.app_name}-sg"
  vpc_id = aws_vpc.main.id
  
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
}
```

#### 6.3 ECS/ECR (Compute)

**Commit 20:** "feat: add Terraform ECR and ECS modules"

`terraform/modules/ecs/main.tf`:
```hcl
resource "aws_ecr_repository" "site" {
  name = "${var.app_name}-repo"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "site" {
  family       = var.app_name
  network_mode = "awsvpc"
  
  container_definitions = jsonencode([{
    name  = var.app_name
    image = "${aws_ecr_repository.site.repository_url}:latest"
    port_mappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "site" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.site.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
}
```

#### 6.4 Composição e Localstack

**Commit 21:** "feat: add Localstack integration and root Terraform configuration"

`docker-compose.yml` (atualizado):
```yaml
services:
  website:
    build: .
    ports:
      - "8080:80"
    networks:
      - observability

  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=ec2,ecr,ecs,route53,s3
    volumes:
      - "${TMPDIR}:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - observability

  # Prometheus e Grafana (Fase 7)

networks:
  observability:
```

---

## 📊 FASE 7: Observabilidade (Commits 22-26)

### Objetivo
**O PONTO ALTO:** Monitorar o próprio site com a stack que você está ensinando.

#### 7.1 Prometheus Setup

**Commit 22:** "feat: add Prometheus configuration for site monitoring"

`monitoring/prometheus/prometheus.yml`:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'nginx-site'
    static_configs:
      - targets: ['website:80']
    metrics_path: '/nginx_metrics'
    
  - job_name: 'kubernetes'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: observability-site
```

#### 7.2 Grafana Dashboards

**Commit 23:** "feat: add Grafana dashboards for site monitoring"

`monitoring/grafana/dashboards/observability-site.json`:
```json
{
  "dashboard": {
    "title": "Observability Site — Live Metrics",
    "tags": ["observability", "nginx"],
    "panels": [
      {
        "title": "HTTP Requests per Second",
        "targets": [{
          "expr": "rate(nginx_http_requests_total[1m])"
        }]
      },
      {
        "title": "Response Time (p95)",
        "targets": [{
          "expr": "histogram_quantile(0.95, nginx_request_duration_seconds)"
        }]
      },
      {
        "title": "Error Rate",
        "targets": [{
          "expr": "rate(nginx_http_requests_total{status=~'5..'}[5m])"
        }]
      },
      {
        "title": "Page Load Time by Page",
        "targets": [{
          "expr": "rate(nginx_request_duration_seconds_sum[5m]) / rate(nginx_request_duration_seconds_count[5m])"
        }]
      }
    ]
  }
}
```

#### 7.3 Loki para Logs

**Commit 24:** "feat: integrate Loki for log aggregation"

`monitoring/loki/loki-config.yml`:
```yaml
auth_enabled: false

ingester:
  chunk_idle_period: 3m
  max_chunk_age: 1h

schema_config:
  configs:
  - from: 2026-01-01
    store: boltdb-shipper
    object_store: filesystem
    schema:
      version: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /tmp/loki/boltdb-shipper-active
  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  max_cache_freshness_per_query: 10m
```

#### 7.4 Nginx Exporter

**Commit 25:** "feat: add nginx_exporter for Prometheus metrics"

`docker-compose.yml` (adicionar):
```yaml
services:
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    ports:
      - "9113:9113"
    command:
      - -nginx.scrape-uri=http://website/nginx_status
    depends_on:
      - website
    networks:
      - observability
```

#### 7.5 Observability Documentation

**Commit 26:** "docs: add observability setup and monitoring guide"

`monitoring/README.md`:
```markdown
# Observando o Observability Site

Este site é um exemplo vivo de observabilidade.
Enquanto você lê sobre logs, métricas e traces,
o próprio site está sendo monitorado.

## Stack de Monitoramento

- **Prometheus:** Coleta de métricas do nginx
- **Grafana:** Dashboard com métricas em tempo real
- **Loki:** Agregação de logs do nginx
- **nginx_exporter:** Exporta métricas do nginx para Prometheus

## Acessar Dashboards

- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Loki: Integrado no Grafana

## Métricas do Site

- HTTP requests per second
- Response time (p50, p95, p99)
- Error rate
- Bytes sent/received
- Active connections

## Logs

Nginx logs em tempo real em Loki.
Buscar por:
\`\`\`
{job="nginx-site"}
\`\`\`

## Traces (Futuro)

Adicionar distributed tracing com Jaeger
para correlacionar com logs e métricas.
```

---

## 🎁 FASE 8: Portfolio Final (Commits 27-29)

### Objetivo
Documentação, diagrama, e demo pronta.

#### 8.1 Architecture Decision Records

**Commit 27:** "docs: add architecture decisions and design rationale"

`docs/architecture-decisions/adr-001-static-site.md`:
```markdown
# ADR 001: Static Site Over Dynamic Backend

## Status
Accepted

## Decision
Build an educational static site instead of a dynamic application.

## Consequences
- ✅ Simpler to deploy and maintain
- ✅ Better performance (no server processing)
- ✅ Focus remains on DevOps/SRE skills
- ✅ Site can be CDN-cached
- ✗ No real-time interactivity
- ✗ Content updates require rebuild

## Alternatives
- Dynamic site with backend API
- Serverless functions
- Headless CMS
```

`docs/architecture-decisions/adr-002-observability-focus.md`:
```markdown
# ADR 002: Site as Observability Example

## Status
Accepted

## Decision
Make the site itself observable—demonstrating the concepts it teaches.

## Benefits
- ✅ Educational by example
- ✅ Realistic use case (monitoring a web service)
- ✅ Impressive portfolio (theory + practice)
- ✅ Can add real user analytics later
```

#### 8.2 Complete README

**Commit 28:** "docs: write comprehensive README with setup and architecture"

`README.md` (atualizado):
```markdown
# 📊 Observability Portal

Educational site on Logs, Traces & Metrics for SRE.
Deployed with Kubernetes, Terraform, CI/CD, and observability stack.

## 🎯 What You'll Learn

- **Logs:** Structured logging, aggregation with Loki
- **Metrics:** Prometheus, Grafana, alerting
- **Traces:** Distributed tracing fundamentals
- **SRE:** Observability-driven engineering

## 🚀 Quick Start

### With Docker Compose
\`\`\`bash
docker-compose up --build
# Site: http://localhost:8080
# Grafana: http://localhost:3000
\`\`\`

### With Kubernetes
\`\`\`bash
./scripts/k8s-deploy.sh
# Site: http://observability.local
\`\`\`

## 📁 Project Structure

\`\`\`
site/              → Static HTML/CSS/JS
kubernetes/        → K8s manifests
helm/              → Helm charts
terraform/         → Infrastructure as Code
.github/workflows/ → CI/CD pipelines
monitoring/        → Prometheus, Grafana, Loki
docs/              → ADRs and guides
\`\`\`

## 🏗️ Architecture

```
Internet
   ↓
Nginx (site)
   ↓
Kubernetes (minikube)
   ↓
Prometheus (scrapes metrics)
     ↓
Grafana (visualizes)
     ↓
Dashboard (live metrics)
```

## 📈 Live Monitoring

The site monitors itself!

- **Metrics:** HTTP requests, latency, errors
- **Logs:** Nginx access logs in Loki
- **Traces:** (Coming soon with Jaeger)

Access Grafana dashboard: http://localhost:3000/d/observability-site

## 🔧 Technologies

- **Frontend:** HTML5, CSS3, JavaScript
- **Container:** Docker, nginx
- **Orchestration:** Kubernetes, Helm
- **Infrastructure:** Terraform, Localstack
- **CI/CD:** GitHub Actions
- **Observability:** Prometheus, Grafana, Loki
- **IaC:** Terraform modules

## 📚 Phases

| Phase | Content | Commits |
|-------|---------|---------|
| 1 | Static site | 1-4 |
| 2 | Docker | 5-7 |
| 3 | Kubernetes | 8-11 |
| 4 | Helm | 12-13 |
| 5 | CI/CD | 14-17 |
| 6 | Terraform | 18-21 |
| 7 | Observability | 22-26 |
| 8 | Portfolio | 27-29 |

## 📝 License

MIT — Built for learning and portfolio purposes.
```

#### 8.3 Demo Guide

**Commit 29:** "docs: add live demo guide and production deployment checklist"

`DEMO.md`:
```markdown
# Demo Guide

## 5-Minute Live Demo

### 1. Show the Site (1 min)
Open http://localhost:8080
- Navigate through pages
- Show Logs section with examples
- Show Metrics section with Prometheus queries

### 2. Check Kubernetes (1 min)
\`\`\`bash
kubectl get pods
kubectl get svc
kubectl get ingress
\`\`\`

### 3. Live Metrics (2 min)
- Open Grafana: http://localhost:3000
- Click "Observability Site" dashboard
- Show:
  - HTTP requests/sec
  - Response time graph
  - Error rate

### 4. Infrastructure as Code (1 min)
- Show `terraform/main.tf`
- Explain: same code, different values → prod deployment

## Q&A Talking Points

**Q: Why static site?**
A: Focus is on DevOps. Site doesn't need complexity.
   Message: great infrastructure even for simple apps.

**Q: How is this observable?**
A: Nginx exports metrics. Prometheus scrapes. Grafana visualizes.
   Same setup you'd use for production microservices.

**Q: What makes this production-ready?**
A: Health checks, metrics, logs, alerting, IaC, CI/CD.
```

---

## 🎯 Summary

| Phase | Theme | Commits | Time |
|-------|-------|---------|------|
| 1 | Static Site | 1-4 | 4h |
| 2 | Docker | 5-7 | 2h |
| 3 | Kubernetes | 8-11 | 4h |
| 4 | Helm | 12-13 | 2h |
| 5 | CI/CD | 14-17 | 3h |
| 6 | Terraform | 18-21 | 6h |
| 7 | Observability | 22-26 | 4h |
| 8 | Portfolio | 27-29 | 2h |
| **TOTAL** | **Observability Portal** | **29 commits** | **~27h** |

---

## 🚀 Getting Started

```bash
cd /home/sabatino/projetos/portfolio/ci-cd-kubernetes

# Remove old backend code (optional)
rm -rf src/backend src/frontend

# OR keep it and start Phase 1 fresh with site structure
mkdir -p site/{css,js,assets}

# First commit coming next →
```

**Ready to start Phase 1?** I'll create the static site structure with all pages, styles, and first 4 commits.
