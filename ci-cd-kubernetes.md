# Guia de Implementação — DevOps Agent Orchestrator

**Versão:** 3.0  
**Data:** Maio 2026  
**Tipo:** Guia Prático Passo a Passo  

> Este guia foi escrito para quem já tem experiência com tecnologia mas precisa de um **refresh prático e aplicado**. Cada etapa explica **o que é**, **por que fazemos** e **como fazer** — com comandos prontos para executar.

> **Sem AWS, sem custo.** Todo o guia roda 100% local usando Docker e minikube. A Fase 6 usa Localstack para simular infraestrutura cloud sem criar nada real na AWS.

---

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Fase 1 — Foundation](#fase-1--foundation)
- [Fase 2 — Containerização com Docker](#fase-2--containerização-com-docker)
- [Fase 3 — Kubernetes Local](#fase-3--kubernetes-local)
- [Fase 4 — Helm Chart](#fase-4--helm-chart)
- [Fase 5 — GitHub Actions CI/CD](#fase-5--github-actions-cicd)
- [Fase 6 — Terraform com Localstack (sem AWS)](#fase-6--terraform-com-localstack-sem-aws)
- [Fase 7 — Observabilidade](#fase-7--observabilidade)
- [Fase 8 — Portfolio Final](#fase-8--portfolio-final)

---

## Pré-requisitos

### O que você precisa ter instalado

| Ferramenta | Versão Mínima | Para que serve | Instalar |
|---|---|---|---|
| Node.js | 20+ | Rodar backend e frontend | https://nodejs.org |
| Docker Desktop | 24+ | Containerizar a aplicação | https://docker.com |
| kubectl | 1.28+ | Interagir com Kubernetes | via Docker Desktop |
| minikube | 1.32+ | Kubernetes local | https://minikube.sigs.k8s.io |
| Helm | 3.14+ | Gerenciar deploys K8s | https://helm.sh |
| Terraform | 1.7+ | Infraestrutura como código | https://terraform.io |
| Git | 2.x | Versionamento | https://git-scm.com |

> **AWS CLI não é necessário.** A Fase 6 usa Localstack, que emula serviços AWS localmente. Nenhuma conta ou credencial real da AWS é exigida.

### Verificando instalações

```bash
node --version        # v20.x.x
docker --version      # Docker version 24.x.x
kubectl version       # Client Version: v1.28.x
minikube version      # minikube version: v1.32.x
helm version          # version.BuildInfo{Version:"v3.14.x"}
terraform version     # Terraform v1.7.x
git --version         # git version 2.x.x
```

### Contas e acessos necessários

- **GitHub:** Conta pessoal com repositório criado
- **Docker Hub:** Conta gratuita para publicar imagens
- **AWS:** ~~não necessário~~ — a Fase 6 usa Localstack (emulação local gratuita)

---

## Fase 1 — Foundation

> **Objetivo:** Criar a estrutura do projeto, o repositório no GitHub e a aplicação base rodando localmente sem Docker.

### 1.1 Criando o repositório no GitHub

**Por que fazemos isso primeiro:**  
O repositório é a fundação de tudo. Criar ele antes do código garante que cada etapa seja commitada e o histórico fique limpo desde o início — isso impressiona recrutadores que olham o histórico de commits.

```bash
# 1. Crie o repositório no GitHub (pelo site) com:
#    - Nome: devops-agent-orchestrator
#    - Descrição: "Intelligent DevOps/SRE agent orchestrator with Kubernetes, Terraform, AWS, Ansible and GitHub Actions"
#    - Público
#    - Adicione README, .gitignore (Node) e licença MIT

# 2. Clone localmente
git clone https://github.com/SEU-USUARIO/devops-agent-orchestrator.git
cd devops-agent-orchestrator
```

### 1.2 Criando a estrutura de pastas

**Por que esta estrutura:**  
Separar `src/frontend`, `src/backend`, `kubernetes/`, `terraform/` etc. mostra organização profissional. Qualquer engenheiro que abrir o repositório sabe exatamente onde encontrar cada coisa sem precisar ler documentação.

```bash
# Criar toda a estrutura de uma vez
mkdir -p src/frontend
mkdir -p src/backend/src/agents
mkdir -p src/backend/src/routes
mkdir -p src/backend/src/middleware
mkdir -p src/backend/src/metrics
mkdir -p src/backend/tests
mkdir -p kubernetes
mkdir -p helm/devops-orchestrator/templates
mkdir -p terraform/modules/eks
mkdir -p terraform/modules/vpc
mkdir -p terraform/modules/iam
mkdir -p .github/workflows
mkdir -p .github/ISSUE_TEMPLATE
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/dashboards
mkdir -p docs/architecture-decisions

# Verificar estrutura criada
find . -type d | grep -v ".git" | sort
```

### 1.3 Criando o Backend (Node.js)

**Conceito — Por que Node.js:**  
Node.js é excelente para APIs de chat porque é event-driven e non-blocking — ideal para aguardar respostas de LLMs sem travar outras requisições. É também a escolha mais comum em times DevOps para tooling interno.

```bash
cd src/backend

# Inicializar projeto Node
npm init -y

# Instalar dependências de produção
npm install express cors helmet morgan pino pino-http dotenv

# Instalar dependências de desenvolvimento
npm install -D nodemon jest supertest eslint prettier

# O que cada pacote faz:
# express      → framework HTTP para criar as rotas da API
# cors         → permite o frontend React chamar o backend
# helmet       → adiciona headers de segurança automaticamente
# morgan       → log de requisições HTTP (desenvolvimento)
# pino         → log estruturado em JSON (produção)
# pino-http    → integra pino com express
# dotenv       → carrega variáveis de ambiente do arquivo .env
# nodemon      → reinicia o servidor ao salvar um arquivo
# jest         → framework de testes
# supertest    → testa endpoints HTTP nos testes
```

**Criar o arquivo principal do servidor:**

```bash
cat > src/server.js << 'EOF'
// src/server.js
// Entry point da aplicação backend

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const pinoHttp = require('pino-http');
const { logger } = require('./middleware/logger');

const agentRoutes = require('./routes/agents.routes');
const healthRoutes = require('./routes/health.routes');
const metricsRoutes = require('./routes/metrics.routes');

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares globais
// helmet: adiciona ~14 headers HTTP de segurança automaticamente
app.use(helmet());

// cors: permite requisições do frontend (porta 3000)
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type']
}));

// express.json: parseia body das requisições POST como JSON
app.use(express.json());

// pino-http: loga cada requisição em formato JSON estruturado
// Formato: { level, time, method, url, statusCode, responseTime }
app.use(pinoHttp({ logger }));

// Rotas
app.use('/api/agents', agentRoutes);
app.use('/health', healthRoutes);
app.use('/metrics', metricsRoutes);

// Handler de erros global
// Qualquer erro não tratado nas rotas cai aqui
app.use((err, req, res, next) => {
  logger.error({ err, path: req.path }, 'Unhandled error');
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

app.listen(PORT, () => {
  logger.info({ port: PORT, env: process.env.NODE_ENV || 'development' }, 'Server started');
});

module.exports = app; // exporta para testes
EOF
```

**Criar o middleware de log:**

```bash
cat > src/middleware/logger.js << 'EOF'
// src/middleware/logger.js
// Log estruturado em JSON — padrão SRE para facilitar parsing no Grafana/Loki

const pino = require('pino');

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  // Em produção: JSON puro para ser parseado por ferramentas
  // Em desenvolvimento: formato bonito e legível no terminal
  transport: process.env.NODE_ENV !== 'production'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined,
  base: {
    service: 'devops-orchestrator-backend',
    version: process.env.npm_package_version || '1.0.0'
  }
});

module.exports = { logger };
EOF
```

**Criar a classe base dos agentes:**

```bash
cat > src/agents/base.agent.js << 'EOF'
// src/agents/base.agent.js
// Classe base que todos os agentes herdam
// Padrão: Template Method Pattern — define o esqueleto, subclasses preenchem os detalhes

class BaseAgent {
  constructor({ name, description, keywords }) {
    this.name = name;
    this.description = description;
    // Palavras-chave usadas pelo orquestrador para roteamento
    this.keywords = keywords;
    this.status = 'active';
  }

  // Método principal — todo agente deve implementar
  async process(message, context = []) {
    throw new Error(`Agent ${this.name} must implement process()`);
  }

  // O orquestrador chama isso para saber se este agente entende a mensagem
  // Retorna um score de 0 a 1 (quanto maior, mais relevante)
  calculateRelevance(message) {
    const lowerMessage = message.toLowerCase();
    const matches = this.keywords.filter(kw => lowerMessage.includes(kw.toLowerCase()));
    return matches.length / this.keywords.length;
  }

  // Formata a resposta em padrão consistente
  formatResponse(content, metadata = {}) {
    return {
      agent: this.name,
      content,
      timestamp: new Date().toISOString(),
      metadata
    };
  }

  getInfo() {
    return {
      name: this.name,
      description: this.description,
      status: this.status,
      keywords: this.keywords
    };
  }
}

module.exports = BaseAgent;
EOF
```

**Criar o agente Orchestrator:**

```bash
cat > src/agents/orchestrator.agent.js << 'EOF'
// src/agents/orchestrator.agent.js
// Agente central: recebe qualquer mensagem e decide qual agente especialista chamar

const BaseAgent = require('./base.agent');

class OrchestratorAgent extends BaseAgent {
  constructor() {
    super({
      name: 'orchestrator',
      description: 'Routes messages to the most relevant specialist agent',
      keywords: []
    });
    // Registry de agentes — preenchido pelo servidor ao inicializar
    this.agents = new Map();
  }

  registerAgent(agent) {
    this.agents.set(agent.name, agent);
  }

  // Lógica de roteamento: quem tem o maior score de relevância recebe a mensagem
  selectAgent(message) {
    let bestAgent = null;
    let bestScore = 0;

    for (const [name, agent] of this.agents) {
      const score = agent.calculateRelevance(message);
      if (score > bestScore) {
        bestScore = score;
        bestAgent = agent;
      }
    }

    // Score mínimo de 0.1 para rotear — abaixo disso o orquestrador responde
    return bestScore >= 0.1 ? bestAgent : null;
  }

  async process(message, context = [], forcedAgent = null) {
    // Agente forçado pelo usuário via UI (clicou no agente)
    if (forcedAgent && this.agents.has(forcedAgent)) {
      const agent = this.agents.get(forcedAgent);
      return agent.process(message, context);
    }

    // Roteamento automático
    const selectedAgent = this.selectAgent(message);

    if (selectedAgent) {
      return selectedAgent.process(message, context);
    }

    // Nenhum agente detectado: orquestrador responde com ajuda
    return this.formatResponse(
      `I'm the orchestrator. I can route your request to the following specialists: ` +
      Array.from(this.agents.keys()).join(', ') +
      `. Try asking something specific about one of these topics.`
    );
  }
}

module.exports = OrchestratorAgent;
EOF
```

**Criar o agente Terraform (exemplo completo):**

```bash
cat > src/agents/terraform.agent.js << 'EOF'
// src/agents/terraform.agent.js

const BaseAgent = require('./base.agent');

class TerraformAgent extends BaseAgent {
  constructor() {
    super({
      name: 'terraform',
      description: 'Specialist in Infrastructure as Code with Terraform/HCL',
      keywords: [
        'terraform', 'hcl', 'infrastructure', 'provider', 'resource',
        'module', 'state', 'plan', 'apply', 'destroy', 'workspace',
        'backend', 'remote state', 'variable', 'output', 'tfvars'
      ]
    });
  }

  async process(message, context = []) {
    // Aqui você integraria com uma LLM real (Claude API, OpenAI, etc.)
    // Por ora, respostas simuladas para demonstração

    const responses = {
      plan: 'To run a Terraform plan: `terraform init && terraform plan -out=tfplan`. The plan shows what will be created, modified, or destroyed without making changes.',
      apply: 'To apply changes: `terraform apply tfplan`. Always review the plan output before confirming. Use `-auto-approve` only in CI/CD pipelines.',
      state: 'Terraform state tracks real infrastructure. Use `terraform state list` to see resources and `terraform state show <resource>` for details. Store state remotely in S3 with locking via DynamoDB.',
      module: 'Modules are reusable Terraform configurations. Create a `modules/` directory and reference with `module "name" { source = "./modules/vpc" }`.',
      default: `As your Terraform specialist, I can help with: HCL syntax, providers (AWS, Azure, GCP), modules, state management, workspaces, and best practices. What specifically are you working on?`
    };

    const lowerMessage = message.toLowerCase();
    let content = responses.default;

    if (lowerMessage.includes('plan')) content = responses.plan;
    else if (lowerMessage.includes('apply')) content = responses.apply;
    else if (lowerMessage.includes('state')) content = responses.state;
    else if (lowerMessage.includes('module')) content = responses.module;

    return this.formatResponse(content, { confidence: 0.9 });
  }
}

module.exports = TerraformAgent;
EOF
```

**Criar os demais agentes (padrão idêntico):**

```bash
# Faça o mesmo para cada agente, trocando nome, keywords e respostas:
# src/agents/kubernetes.agent.js  → keywords: pod, deployment, service, kubectl, ingress, helm...
# src/agents/aws.agent.js         → keywords: ec2, s3, iam, vpc, lambda, eks, rds...
# src/agents/ansible.agent.js     → keywords: playbook, role, inventory, task, handler, vault...
# src/agents/github-actions.agent.js → keywords: workflow, pipeline, action, job, step, runner...
```

**Criar as rotas da API:**

```bash
cat > src/routes/agents.routes.js << 'EOF'
// src/routes/agents.routes.js
// Define os endpoints que o frontend vai chamar

const express = require('express');
const router = express.Router();
const OrchestratorAgent = require('../agents/orchestrator.agent');
const TerraformAgent = require('../agents/terraform.agent');
// ... importe os demais agentes

// Inicializa o orquestrador e registra todos os agentes
const orchestrator = new OrchestratorAgent();
orchestrator.registerAgent(new TerraformAgent());
// orchestrator.registerAgent(new KubernetesAgent());
// orchestrator.registerAgent(new AwsAgent());
// ... etc

// GET /api/agents — lista todos os agentes disponíveis para a UI
router.get('/', (req, res) => {
  const agents = [orchestrator, ...orchestrator.agents.values()];
  res.json(agents.map(a => a.getInfo()));
});

// POST /api/agents/chat — endpoint principal de conversação
// Body: { message: string, agent?: string, context?: array }
router.post('/chat', async (req, res) => {
  const { message, agent, context } = req.body;

  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'message is required and must be a string' });
  }

  const response = await orchestrator.process(message, context || [], agent);
  res.json(response);
});

module.exports = router;
EOF
```

```bash
cat > src/routes/health.routes.js << 'EOF'
// src/routes/health.routes.js
// Health checks — usados pelo Kubernetes para saber se o pod está saudável

const express = require('express');
const router = express.Router();

// Liveness probe: "o processo está vivo?"
// Kubernetes reinicia o pod se isso retornar erro
router.get('/live', (req, res) => {
  res.status(200).json({ status: 'alive', timestamp: new Date().toISOString() });
});

// Readiness probe: "o pod está pronto para receber tráfego?"
// Kubernetes só envia requisições para pods ready
router.get('/ready', (req, res) => {
  // Aqui você verificaria conexões com banco, serviços externos, etc.
  res.status(200).json({ status: 'ready', timestamp: new Date().toISOString() });
});

module.exports = router;
EOF
```

**Configurar o package.json:**

```bash
# Editar package.json para adicionar scripts
cat > package.json << 'EOF'
{
  "name": "devops-orchestrator-backend",
  "version": "1.0.0",
  "description": "Backend API for DevOps Agent Orchestrator",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "lint": "eslint src/ --ext .js",
    "lint:fix": "eslint src/ --ext .js --fix"
  },
  "jest": {
    "testEnvironment": "node",
    "collectCoverageFrom": ["src/**/*.js", "!src/server.js"]
  }
}
EOF
```

**Criar arquivo .env para desenvolvimento:**

```bash
cat > .env << 'EOF'
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:3000
LOG_LEVEL=debug
EOF

# IMPORTANTE: adicionar .env ao .gitignore
echo ".env" >> ../../.gitignore
echo "node_modules/" >> ../../.gitignore
```

**Testar o backend:**

```bash
npm run dev
# Você deve ver: {"level":30,"msg":"Server started","port":3001}

# Em outro terminal, testar os endpoints:
curl http://localhost:3001/health/live
# {"status":"alive","timestamp":"..."}

curl http://localhost:3001/health/ready
# {"status":"ready","timestamp":"..."}

curl http://localhost:3001/api/agents
# Lista de agentes

curl -X POST http://localhost:3001/api/agents/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "how do I run terraform plan?"}'
# Resposta do agente Terraform
```

### 1.4 Criando o Frontend (React)

```bash
cd ../../  # volta para raiz do projeto

# Criar app React com Vite (mais rápido que Create React App)
npm create vite@latest src/frontend -- --template react
cd src/frontend
npm install

# Instalar dependências adicionais
npm install axios          # chamadas HTTP para o backend
npm install lucide-react   # ícones modernos
```

**Estrutura do frontend:**

```bash
# A estrutura do componente principal já foi criada na interface
# do Claude — use ela como base para o App.jsx

# Criar arquivo de serviço para chamar o backend
cat > src/services/api.js << 'EOF'
// src/services/api.js
// Centraliza todas as chamadas ao backend
// Bom padrão: nunca faça fetch diretamente nos componentes

import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3001/api',
  timeout: 30000, // 30s — LLMs podem ser lentas
  headers: { 'Content-Type': 'application/json' }
});

export const getAgents = () => api.get('/agents');

export const sendMessage = (message, agent = null, context = []) =>
  api.post('/agents/chat', { message, agent, context });

export default api;
EOF
```

**Testar o frontend:**

```bash
npm run dev
# Acesse http://localhost:5173
# O frontend deve aparecer e conseguir se comunicar com o backend
```

### 1.5 Primeiro commit no GitHub

**Por que fazer commits pequenos e semânticos:**  
Recrutadores olham o histórico de commits. Um histórico com commits pequenos e descritivos mostra disciplina de engenharia. Commits gigantes do tipo "add everything" não impressionam ninguém.

```bash
cd ../../  # raiz do projeto

git add .
git status  # revise o que vai ser commitado

# Seu primeiro commit — APENAS você como autor
git commit -m "feat: initial project structure with backend and frontend

- Add Node.js backend with Express and structured logging
- Add React frontend with Vite
- Add base agent class with routing logic
- Add orchestrator agent with keyword-based routing
- Add terraform agent as first specialist implementation
- Add health check endpoints for Kubernetes probes"

git push origin main
```

---

## Fase 2 — Containerização com Docker

> **Objetivo:** Empacotar frontend e backend em imagens Docker prontas para qualquer ambiente.

### 2.1 Conceito: O que é containerização e por que importa

**O problema que Docker resolve:**  
"Funciona na minha máquina" — Docker elimina esse problema. Um container empacota o código + runtime + dependências + configuração. O mesmo container que roda na sua máquina roda idêntico em staging e em produção no Kubernetes.

**Conceitos fundamentais:**
- **Imagem:** Template imutável (como uma classe em OOP)
- **Container:** Instância rodando de uma imagem (como um objeto)
- **Dockerfile:** Receita para construir uma imagem
- **Registry:** "GitHub para imagens Docker" (Docker Hub, ECR, GCR)
- **Layer cache:** Cada instrução `RUN`/`COPY` vira uma camada — camadas não alteradas são reutilizadas no rebuild

### 2.2 Dockerfile do Backend

**Conceito — Multi-stage build:**  
Em vez de uma imagem única com tudo (incluindo ferramentas de build), usamos múltiplos estágios. O estágio `builder` instala tudo e compila. O estágio `production` copia apenas o resultado final. A imagem final fica **muito menor** e sem ferramentas desnecessárias (menor superfície de ataque).

```bash
cat > src/backend/Dockerfile << 'EOF'
# ============================================================
# Stage 1: Dependencies
# Instala apenas dependências de produção
# ============================================================
FROM node:20-alpine AS deps

# alpine = imagem mínima do Linux (~5MB vs ~900MB do ubuntu)
# Motivo: imagem menor = deploy mais rápido + menos vulnerabilidades

WORKDIR /app

# Copia APENAS os arquivos de manifesto de dependências primeiro
# Por que? Docker cache: se package.json não mudou, npm install
# não roda de novo — economiza minutos no CI/CD
COPY package.json package-lock.json ./

# --only=production: não instala devDependencies (jest, nodemon, etc.)
# --frozen-lockfile: falha se package-lock.json estiver desatualizado
RUN npm ci --only=production --frozen-lockfile

# ============================================================
# Stage 2: Build (para projetos TypeScript — manter para aprendizado)
# ============================================================
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --frozen-lockfile
COPY . .

# Se fosse TypeScript: RUN npm run build
# Para JS puro, apenas copiamos os arquivos

# ============================================================
# Stage 3: Production
# Imagem final — apenas o que é necessário para rodar
# ============================================================
FROM node:20-alpine AS production

# Criar usuário não-root
# NUNCA rode containers como root — princípio de menor privilégio
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs

WORKDIR /app

# Copiar dependências de produção do stage "deps"
COPY --from=deps --chown=nodeuser:nodejs /app/node_modules ./node_modules

# Copiar código-fonte
COPY --chown=nodeuser:nodejs src/ ./src/
COPY --chown=nodeuser:nodejs package.json ./

# Mudar para usuário não-root
USER nodeuser

# Documentar qual porta o container expõe (não publica — apenas documenta)
EXPOSE 3001

# Verificação de saúde integrada ao Docker
# Docker reinicia o container se o health check falhar
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health/live || exit 1

# Comando para iniciar a aplicação
CMD ["node", "src/server.js"]
EOF
```

### 2.3 .dockerignore do Backend

```bash
cat > src/backend/.dockerignore << 'EOF'
# .dockerignore funciona como .gitignore mas para Docker
# Arquivos aqui NÃO são enviados para o build context
# Resultado: builds mais rápidos e imagens menores

node_modules        # será reinstalado no container
.env                # NUNCA incluir segredos na imagem
.env.*
*.test.js
tests/
coverage/
.git
.gitignore
README.md
Dockerfile
.dockerignore
EOF
```

### 2.4 Dockerfile do Frontend

```bash
cat > src/frontend/Dockerfile << 'EOF'
# ============================================================
# Stage 1: Build
# Compila o React em arquivos estáticos otimizados
# ============================================================
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --frozen-lockfile
COPY . .

# Build de produção: minifica JS, otimiza assets, gera hashes de nome
RUN npm run build
# Resultado: pasta dist/ com index.html + assets otimizados

# ============================================================
# Stage 2: Production
# NGINX serve os arquivos estáticos — muito mais eficiente que Node.js
# ============================================================
FROM nginx:1.25-alpine AS production

# Copiar apenas os arquivos compilados
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuração customizada do NGINX
# Necessário para React Router funcionar (todas as rotas retornam index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF
```

```bash
cat > src/frontend/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Todas as rotas retornam index.html (necessário para React Router)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache agressivo para assets com hash no nome
    # Ex: main.a1b2c3d4.js — o hash muda quando o código muda
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Sem cache para index.html — garante que o usuário sempre pega a versão nova
    location = /index.html {
        add_header Cache-Control "no-store";
    }
}
EOF
```

### 2.5 Docker Compose para desenvolvimento local

**Conceito — Docker Compose:**  
Orquestra múltiplos containers localmente. Em vez de subir backend e frontend manualmente em terminais separados, `docker-compose up` sobe tudo com um comando. Cada serviço fica isolado mas pode se comunicar pela rede interna do Compose.

```bash
cat > docker/docker-compose.yml << 'EOF'
# docker-compose.yml — Ambiente de desenvolvimento local
# Versão 3.8 é a mais atual com suporte a todas as features modernas

version: '3.8'

services:
  # ─── Backend ─────────────────────────────────────────────
  backend:
    build:
      context: ../src/backend
      dockerfile: Dockerfile
      # target: production  # descomente para testar imagem de produção
    container_name: orchestrator-backend
    ports:
      - "3001:3001"          # host:container
    environment:
      - NODE_ENV=development
      - PORT=3001
      - FRONTEND_URL=http://localhost:3000
      - LOG_LEVEL=debug
    volumes:
      # Hot reload: sincroniza código local com o container
      - ../src/backend/src:/app/src:ro
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3001/health/live"]
      interval: 30s
      timeout: 3s
      retries: 3
    restart: unless-stopped  # reinicia automaticamente se crashar

  # ─── Frontend ────────────────────────────────────────────
  frontend:
    build:
      context: ../src/frontend
      dockerfile: Dockerfile
    container_name: orchestrator-frontend
    ports:
      - "3000:80"
    environment:
      - VITE_API_URL=http://localhost:3001/api
    depends_on:
      backend:
        condition: service_healthy  # só sobe quando backend estiver healthy
    restart: unless-stopped

# Rede interna: serviços se comunicam pelo nome (ex: http://backend:3001)
networks:
  default:
    name: orchestrator-network
EOF
```

**Testar com Docker Compose:**

```bash
cd docker/

# Build das imagens e subir containers
docker-compose up --build

# Em segundo plano
docker-compose up --build -d

# Ver logs
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f backend

# Verificar containers rodando
docker-compose ps

# Parar tudo
docker-compose down

# Parar e remover volumes
docker-compose down -v
```

### 2.6 Build e push para Docker Hub

```bash
# Login no Docker Hub
docker login

# Build manual das imagens
docker build -t SEU-USUARIO/devops-orchestrator-backend:latest src/backend/
docker build -t SEU-USUARIO/devops-orchestrator-frontend:latest src/frontend/

# Testar localmente
docker run -p 3001:3001 SEU-USUARIO/devops-orchestrator-backend:latest

# Push para Docker Hub (será feito automaticamente pelo GitHub Actions depois)
docker push SEU-USUARIO/devops-orchestrator-backend:latest
docker push SEU-USUARIO/devops-orchestrator-frontend:latest
```

```bash
git add .
git commit -m "feat: add Docker multi-stage builds for backend and frontend

- Add multi-stage Dockerfile for backend (deps/builder/production stages)
- Add multi-stage Dockerfile for frontend with NGINX serving
- Add docker-compose for local development with health checks
- Add .dockerignore to optimize build context
- Add nginx.conf for React Router support and cache headers
- Use non-root user in all production containers"

git push origin main
```

---

## Fase 3 — Kubernetes Local

> **Objetivo:** Rodar a aplicação em Kubernetes local com minikube, entendendo cada recurso.

### 3.1 Conceito: O que é Kubernetes e por que ele existe

**O problema que K8s resolve:**  
Docker roda containers. Mas em produção você precisa de: alta disponibilidade (se um container morrer, outro sobe), balanceamento de carga, atualizações sem downtime, escalonamento automático, gerenciamento de configurações e segredos. Kubernetes faz tudo isso.

**Analogia:**  
Docker é como contratar funcionários. Kubernetes é o RH que cuida de férias, substitutos, promoções e demissões automaticamente.

**Objetos fundamentais do Kubernetes:**

| Objeto | O que é | Analogia |
|---|---|---|
| Pod | Menor unidade — 1 ou mais containers | Um processo rodando |
| Deployment | Gerencia réplicas de pods | Gerente que garante N funcionários sempre ativos |
| Service | Endereço fixo para acessar pods | Número de telefone fixo (os pods têm IPs que mudam) |
| ConfigMap | Configurações não-sensíveis | Arquivo .env público |
| Secret | Configurações sensíveis | Arquivo .env privado (base64) |
| Ingress | Roteamento de tráfego externo | Recepcionista que direciona visitas |
| HPA | Escalonamento automático | Contratação automática em pico de demanda |
| Namespace | Isolamento lógico | Departamento dentro da empresa |

### 3.2 Iniciando o minikube

```bash
# Iniciar cluster local com 2 CPUs e 4GB RAM
minikube start --cpus=2 --memory=4096

# Verificar que está rodando
kubectl get nodes
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   1m    v1.28.x

# Habilitar addons necessários
minikube addons enable ingress      # NGINX Ingress Controller
minikube addons enable metrics-server  # Necessário para HPA

# Ver todos os addons disponíveis
minikube addons list

# Dashboard visual (abre no browser — ótimo para aprender)
minikube dashboard
```

### 3.3 Criando o Namespace

**Conceito — Namespace:**  
Isola recursos logicamente dentro do cluster. Em empresas, times diferentes usam namespaces diferentes no mesmo cluster. Aqui usamos para separar nossa aplicação dos componentes do sistema (`kube-system`).

```bash
cat > kubernetes/namespace.yaml << 'EOF'
# namespace.yaml
# Todo recurso do nosso projeto pertence a este namespace
# Vantagem: kubectl delete namespace devops-orchestrator remove TUDO de uma vez

apiVersion: v1
kind: Namespace
metadata:
  name: devops-orchestrator
  labels:
    # Labels são pares chave-valor para organizar e filtrar recursos
    app.kubernetes.io/managed-by: kubectl
    environment: development
EOF

kubectl apply -f kubernetes/namespace.yaml
kubectl get namespaces
```

### 3.4 ConfigMap

**Conceito — ConfigMap:**  
Armazena configurações não-sensíveis (URLs, feature flags, etc.) separadas do código. Vantagem: mudar uma configuração não requer rebuildar a imagem Docker.

```bash
cat > kubernetes/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: orchestrator-config
  namespace: devops-orchestrator
  labels:
    app: devops-orchestrator
data:
  # Cada chave vira uma variável de ambiente no container
  NODE_ENV: "production"
  PORT: "3001"
  LOG_LEVEL: "info"
  FRONTEND_URL: "http://orchestrator-frontend-service"
EOF

kubectl apply -f kubernetes/configmap.yaml
kubectl get configmap -n devops-orchestrator
kubectl describe configmap orchestrator-config -n devops-orchestrator
```

### 3.5 Secret

**Conceito — Kubernetes Secret:**  
Similar ao ConfigMap mas para dados sensíveis. Os valores são armazenados em **base64** (ATENÇÃO: isso é encoding, não criptografia). Em produção real use HashiCorp Vault ou AWS Secrets Manager.

```bash
# secrets.example.yaml — template para commitar (SEM valores reais)
cat > kubernetes/secrets.example.yaml << 'EOF'
# ESTE ARQUIVO É UM TEMPLATE — não contém valores reais
# Copie para secrets.yaml e preencha os valores antes de aplicar
# secrets.yaml está no .gitignore

apiVersion: v1
kind: Secret
metadata:
  name: orchestrator-secrets
  namespace: devops-orchestrator
type: Opaque
data:
  # Valores devem estar em base64: echo -n "valor" | base64
  API_KEY: BASE64_ENCODED_VALUE_HERE
  DATABASE_URL: BASE64_ENCODED_VALUE_HERE
EOF

# Para desenvolvimento: criar secret com valores reais (NÃO commitar)
kubectl create secret generic orchestrator-secrets \
  --from-literal=API_KEY=dev-key-123 \
  --namespace=devops-orchestrator \
  --dry-run=client -o yaml > kubernetes/secrets.yaml

# Adicionar secrets.yaml ao .gitignore
echo "kubernetes/secrets.yaml" >> .gitignore

kubectl apply -f kubernetes/secrets.yaml
kubectl get secrets -n devops-orchestrator
```

### 3.6 Deployment do Backend

**Conceito — Deployment:**  
Descreve o estado desejado: "quero 2 réplicas do backend, com esta imagem, com estes recursos". O Kubernetes trabalha continuamente para manter esse estado. Se um pod morrer, ele cria outro automaticamente.

**Resource limits:**  
Define CPU e memória mínimas (requests) e máximas (limits). O agendador usa requests para decidir em qual nó colocar o pod. Se o container exceder o limit de memória, ele é reiniciado (OOMKilled).

```bash
cat > kubernetes/deployment.yaml << 'EOF'
# ─── Backend Deployment ───────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orchestrator-backend
  namespace: devops-orchestrator
  labels:
    app: orchestrator-backend
    version: "1.0.0"
spec:
  replicas: 2  # 2 pods para alta disponibilidade

  # Como o Kubernetes encontra os pods que este Deployment gerencia
  selector:
    matchLabels:
      app: orchestrator-backend

  # Estratégia de atualização: zero downtime
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0   # nunca deixa 0 pods disponíveis
      maxSurge: 1         # pode ter 1 pod a mais durante a atualização

  template:
    metadata:
      labels:
        app: orchestrator-backend
    spec:
      # SecurityContext: configurações de segurança do pod
      securityContext:
        runAsNonRoot: true      # proíbe rodar como root
        runAsUser: 1001         # mesmo UID definido no Dockerfile
        fsGroup: 1001

      containers:
        - name: backend
          image: SEU-USUARIO/devops-orchestrator-backend:latest

          # imagePullPolicy: quando puxar nova versão da imagem
          # Always = sempre verifica o registry (use em produção com tags fixas)
          imagePullPolicy: Always

          ports:
            - containerPort: 3001
              name: http

          # Injetar variáveis do ConfigMap
          envFrom:
            - configMapRef:
                name: orchestrator-config

          # Variáveis específicas de secrets
          env:
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: orchestrator-secrets
                  key: API_KEY

          # Resource requests e limits
          resources:
            requests:
              # Mínimo garantido: agendador reserva isso no nó
              memory: "128Mi"   # 128 megabytes
              cpu: "100m"       # 100 milicores = 0.1 CPU
            limits:
              # Máximo permitido: se ultrapassar, container é reiniciado/throttled
              memory: "256Mi"
              cpu: "250m"

          # Liveness probe: "o processo está funcionando?"
          # Kubernetes reinicia o container se falhar
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3001
            initialDelaySeconds: 15   # espera 15s após iniciar
            periodSeconds: 30         # verifica a cada 30s
            failureThreshold: 3       # reinicia após 3 falhas

          # Readiness probe: "o container está pronto para receber tráfego?"
          # Kubernetes remove do load balancer se falhar
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3001
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 3

---
# ─── Frontend Deployment ──────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orchestrator-frontend
  namespace: devops-orchestrator
  labels:
    app: orchestrator-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orchestrator-frontend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: orchestrator-frontend
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 101   # UID do nginx no alpine
      containers:
        - name: frontend
          image: SEU-USUARIO/devops-orchestrator-frontend:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 80
              name: http
          resources:
            requests:
              memory: "64Mi"
              cpu: "50m"
            limits:
              memory: "128Mi"
              cpu: "100m"
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
EOF

kubectl apply -f kubernetes/deployment.yaml

# Verificar que os pods estão rodando
kubectl get pods -n devops-orchestrator
kubectl get pods -n devops-orchestrator -w  # -w = watch (atualiza em tempo real)

# Ver detalhes de um pod específico
kubectl describe pod <nome-do-pod> -n devops-orchestrator

# Ver logs de um pod
kubectl logs -f <nome-do-pod> -n devops-orchestrator
```

### 3.7 Service

**Conceito — Service:**  
Pods têm IPs efêmeros — quando um pod morre e nasce outro, o IP muda. O Service tem um IP fixo (ClusterIP) e balanceia o tráfego entre os pods saudáveis usando labels como seletor.

```bash
cat > kubernetes/service.yaml << 'EOF'
# ─── Backend Service ──────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: orchestrator-backend-service
  namespace: devops-orchestrator
spec:
  # ClusterIP: acessível apenas dentro do cluster
  # NodePort: expõe em uma porta do nó (desenvolvimento)
  # LoadBalancer: cria um load balancer externo (cloud provider)
  type: ClusterIP

  # Seleciona pods com este label — se um pod morrer e nascer novo com o mesmo label,
  # o Service automaticamente roteia para ele
  selector:
    app: orchestrator-backend

  ports:
    - name: http
      port: 80          # porta que outros serviços usam para acessar
      targetPort: 3001  # porta que o container expõe

---
# ─── Frontend Service ─────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: orchestrator-frontend-service
  namespace: devops-orchestrator
spec:
  type: ClusterIP
  selector:
    app: orchestrator-frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
EOF

kubectl apply -f kubernetes/service.yaml
kubectl get services -n devops-orchestrator
```

### 3.8 Ingress

**Conceito — Ingress:**  
O Service ClusterIP é acessível apenas dentro do cluster. O Ingress recebe tráfego externo e roteia para o Service correto baseado em host ou path. Pense nele como o Nginx/proxy reverso do cluster.

```bash
cat > kubernetes/ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: orchestrator-ingress
  namespace: devops-orchestrator
  annotations:
    # Especifica que usamos o NGINX Ingress Controller
    kubernetes.io/ingress.class: nginx

    # Redireciona HTTP para HTTPS automaticamente
    nginx.ingress.kubernetes.io/ssl-redirect: "false"  # false para dev local

    # Rate limiting: máximo de 100 req/s por IP
    nginx.ingress.kubernetes.io/limit-rps: "100"
spec:
  rules:
    - host: orchestrator.local   # domínio local (adicionar ao /etc/hosts)
      http:
        paths:
          # /api/* vai para o backend
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: orchestrator-backend-service
                port:
                  number: 80

          # /health/* vai para o backend
          - path: /health
            pathType: Prefix
            backend:
              service:
                name: orchestrator-backend-service
                port:
                  number: 80

          # /* vai para o frontend
          - path: /
            pathType: Prefix
            backend:
              service:
                name: orchestrator-frontend-service
                port:
                  number: 80
EOF

kubectl apply -f kubernetes/ingress.yaml
kubectl get ingress -n devops-orchestrator

# Configurar /etc/hosts para apontar para minikube
echo "$(minikube ip) orchestrator.local" | sudo tee -a /etc/hosts

# Testar
curl http://orchestrator.local/health/live
```

### 3.9 HPA — Horizontal Pod Autoscaler

**Conceito — HPA:**  
Monitora métricas (CPU, memória, customizadas) e escala automaticamente o número de pods. Se CPU > 70%, cria mais pods. Se CPU < 70% por 5 minutos, remove pods extras.

```bash
cat > kubernetes/hpa.yaml << 'EOF'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orchestrator-backend-hpa
  namespace: devops-orchestrator
spec:
  # Qual Deployment gerenciar
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: orchestrator-backend

  minReplicas: 2   # nunca menos que 2 (alta disponibilidade)
  maxReplicas: 10  # nunca mais que 10

  metrics:
    # Escala quando CPU média dos pods ultrapassa 70%
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

    # Escala quando memória média ultrapassa 80%
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

  behavior:
    scaleUp:
      # Escala rápido quando há pico
      stabilizationWindowSeconds: 60
      policies:
        - type: Pods
          value: 2          # adiciona até 2 pods por vez
          periodSeconds: 60
    scaleDown:
      # Escala devagar para evitar flapping
      stabilizationWindowSeconds: 300  # espera 5 min antes de remover
      policies:
        - type: Pods
          value: 1          # remove 1 pod por vez
          periodSeconds: 120
EOF

kubectl apply -f kubernetes/hpa.yaml
kubectl get hpa -n devops-orchestrator

# Ver HPA em ação (requer metrics-server habilitado)
kubectl describe hpa orchestrator-backend-hpa -n devops-orchestrator
```

```bash
git add .
git commit -m "feat: add Kubernetes manifests for full application deployment

- Add namespace for resource isolation
- Add ConfigMap and Secret for configuration management
- Add Deployments with rolling update strategy and security contexts
- Add Services for internal cluster communication
- Add Ingress with path-based routing
- Add HPA with CPU and memory scaling policies
- Add liveness and readiness probes to all containers"

git push origin main
```

---

## Fase 4 — Helm Chart

> **Objetivo:** Empacotar todos os manifests Kubernetes em um Helm Chart reutilizável e parametrizável.

### 4.1 Conceito: Por que Helm?

**O problema:**  
Temos vários arquivos YAML de Kubernetes. Para rodar em diferentes ambientes (dev, staging, prod), precisamos mudar valores como: nome da imagem, número de réplicas, domínio do Ingress, resource limits. Sem Helm, teríamos que manter múltiplas cópias de todos os arquivos.

**Helm resolve isso com:**  
- **Templates:** arquivos YAML com variáveis `{{ .Values.backend.replicas }}`
- **Values:** arquivo único com os valores por ambiente
- **Releases:** Helm rastreia o que foi instalado/atualizado no cluster
- **Rollback:** `helm rollback` desfaz um deploy com um comando

**Analogia:** Helm está para Kubernetes assim como `apt`/`brew` está para pacotes de software.

### 4.2 Estrutura do Chart

```bash
# Inicializar estrutura do chart
helm create helm/devops-orchestrator

# Isso cria uma estrutura padrão — vamos customizar
ls helm/devops-orchestrator/
# Chart.yaml      → metadados do chart
# values.yaml     → valores padrão
# templates/      → templates YAML com variáveis
# charts/         → dependências (subcharts)
```

### 4.3 Chart.yaml

```bash
cat > helm/devops-orchestrator/Chart.yaml << 'EOF'
apiVersion: v2
name: devops-orchestrator
description: A Helm chart for DevOps Agent Orchestrator — intelligent multi-agent system for DevOps/SRE automation

# Chart type: application (tem pods) vs library (apenas helpers)
type: application

# Versão do CHART (muda quando você altera o chart)
version: 0.1.0

# Versão da APLICAÇÃO (muda quando o código muda)
appVersion: "1.0.0"

keywords:
  - devops
  - sre
  - ai
  - orchestrator
  - kubernetes

maintainers:
  - name: Seu Nome
    email: seu@email.com

home: https://github.com/SEU-USUARIO/devops-agent-orchestrator
EOF
```

### 4.4 values.yaml

```bash
cat > helm/devops-orchestrator/values.yaml << 'EOF'
# values.yaml — Valores padrão do chart
# Todos os valores podem ser sobrescritos via:
#   helm install ... --set backend.replicas=3
#   helm install ... -f values-prod.yaml

# ─── Backend ──────────────────────────────────────────────
backend:
  image:
    repository: SEU-USUARIO/devops-orchestrator-backend
    tag: latest
    pullPolicy: Always

  replicas: 2

  service:
    type: ClusterIP
    port: 80
    targetPort: 3001

  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "250m"

  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80

  env:
    NODE_ENV: production
    LOG_LEVEL: info
    PORT: "3001"

  probes:
    liveness:
      path: /health/live
      initialDelaySeconds: 15
      periodSeconds: 30
    readiness:
      path: /health/ready
      initialDelaySeconds: 5
      periodSeconds: 10

# ─── Frontend ─────────────────────────────────────────────
frontend:
  image:
    repository: SEU-USUARIO/devops-orchestrator-frontend
    tag: latest
    pullPolicy: Always

  replicas: 2

  service:
    type: ClusterIP
    port: 80

  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"

# ─── Ingress ──────────────────────────────────────────────
ingress:
  enabled: true
  host: orchestrator.local
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"

# ─── Namespace ────────────────────────────────────────────
namespace:
  create: true
  name: devops-orchestrator

# ─── Monitoring ───────────────────────────────────────────
monitoring:
  prometheus:
    enabled: true
    port: 9090
    path: /metrics
EOF
```

```bash
# values-prod.yaml — sobrescreve apenas o que muda em produção
cat > helm/devops-orchestrator/values-prod.yaml << 'EOF'
backend:
  replicas: 3
  image:
    tag: "1.0.0"   # tag fixa em prod — nunca use "latest" em produção
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  env:
    LOG_LEVEL: warn

frontend:
  replicas: 3
  image:
    tag: "1.0.0"

ingress:
  host: orchestrator.seudominio.com
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
    - secretName: orchestrator-tls
      hosts:
        - orchestrator.seudominio.com
EOF
```

### 4.5 Templates com Helpers

```bash
cat > helm/devops-orchestrator/templates/_helpers.tpl << 'EOF'
{{/*
_helpers.tpl — Funções reutilizáveis dentro dos templates

Estas funções evitam repetição nos templates.
São chamadas com {{ include "nome-da-funcao" . }}
*/}}

{{/* Nome completo do release */}}
{{- define "devops-orchestrator.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Labels padrão aplicados a todos os recursos */}}
{{- define "devops-orchestrator.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/* Selector labels — usados nos matchLabels dos Deployments */}}
{{- define "devops-orchestrator.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
EOF
```

```bash
# Template do Deployment do backend usando values
cat > helm/devops-orchestrator/templates/backend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "devops-orchestrator.fullname" . }}-backend
  namespace: {{ .Values.namespace.name }}
  labels:
    app: orchestrator-backend
    {{- include "devops-orchestrator.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.backend.replicas }}
  selector:
    matchLabels:
      app: orchestrator-backend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: orchestrator-backend
        {{- include "devops-orchestrator.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
      containers:
        - name: backend
          image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
          imagePullPolicy: {{ .Values.backend.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.backend.service.targetPort }}
          env:
            {{- range $key, $value := .Values.backend.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          resources:
            {{- toYaml .Values.backend.resources | nindent 12 }}
          livenessProbe:
            httpGet:
              path: {{ .Values.backend.probes.liveness.path }}
              port: {{ .Values.backend.service.targetPort }}
            initialDelaySeconds: {{ .Values.backend.probes.liveness.initialDelaySeconds }}
            periodSeconds: {{ .Values.backend.probes.liveness.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.backend.probes.readiness.path }}
              port: {{ .Values.backend.service.targetPort }}
            initialDelaySeconds: {{ .Values.backend.probes.readiness.initialDelaySeconds }}
            periodSeconds: {{ .Values.backend.probes.readiness.periodSeconds }}
EOF
```

### 4.6 Testando o Helm Chart

```bash
# Verificar sintaxe dos templates
helm lint helm/devops-orchestrator/

# Renderizar templates sem aplicar (dry-run de visualização)
helm template my-release helm/devops-orchestrator/ | head -100

# Renderizar com values de produção
helm template my-release helm/devops-orchestrator/ -f helm/devops-orchestrator/values-prod.yaml

# Instalar no cluster
helm install devops-orchestrator helm/devops-orchestrator/ \
  --namespace devops-orchestrator \
  --create-namespace

# Ver releases instaladas
helm list -n devops-orchestrator

# Atualizar com nova versão
helm upgrade devops-orchestrator helm/devops-orchestrator/ \
  --namespace devops-orchestrator \
  --set backend.image.tag=v1.1.0

# Histórico de deploys
helm history devops-orchestrator -n devops-orchestrator

# Rollback para versão anterior
helm rollback devops-orchestrator 1 -n devops-orchestrator

# Remover release
helm uninstall devops-orchestrator -n devops-orchestrator
```

```bash
git add .
git commit -m "feat: add Helm chart for parameterized Kubernetes deployments

- Add Chart.yaml with metadata and versioning
- Add values.yaml with defaults for all environments
- Add values-prod.yaml override for production settings
- Add template helpers for DRY label management
- Add backend and frontend deployment templates
- Support autoscaling, resource limits, and probes via values"

git push origin main
```

---

## Fase 5 — GitHub Actions CI/CD

> **Objetivo:** Automatizar completamente o fluxo de build, teste e deploy a cada push.

### 5.1 Conceito: GitHub Actions

**Por que CI/CD:**  
Continuous Integration (CI) garante que o código novo não quebra o existente — roda testes, lint, build automaticamente. Continuous Delivery (CD) faz o deploy automático quando o CI passa.

**Anatomia de um workflow GitHub Actions:**
```
Workflow (.github/workflows/ci.yml)
└── Job (build)
    └── Step 1: Checkout código
    └── Step 2: Setup Node.js
    └── Step 3: npm install
    └── Step 4: npm test
    └── Step 5: Build Docker
```

**Conceitos-chave:**
- **Trigger:** o que dispara o workflow (`push`, `pull_request`, `schedule`)
- **Runner:** onde o código roda (`ubuntu-latest`, `windows-latest`, `self-hosted`)
- **Step:** cada ação dentro de um job
- **Action:** bloco reutilizável (`actions/checkout@v4`)
- **Secret:** variável de ambiente criptografada (`${{ secrets.DOCKER_TOKEN }}`)

### 5.2 Workflow de CI (Lint, Test, Build)

```bash
cat > .github/workflows/ci.yml << 'EOF'
# ci.yml — Roda em QUALQUER push ou Pull Request
# Garante que o código está sempre saudável

name: CI

on:
  push:
    branches: ["**"]        # qualquer branch
  pull_request:
    branches: [main, develop]

jobs:
  # ─── Job 1: Lint e Testes do Backend ────────────────────
  backend-test:
    name: Backend — Lint & Tests
    runs-on: ubuntu-latest

    steps:
      # 1. Baixa o código do repositório para o runner
      - name: Checkout code
        uses: actions/checkout@v4

      # 2. Configura a versão correta do Node
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"                    # cacheia node_modules entre runs
          cache-dependency-path: src/backend/package-lock.json

      - name: Install dependencies
        working-directory: src/backend
        run: npm ci                        # ci = instalação limpa e determinística

      - name: Run linter
        working-directory: src/backend
        run: npm run lint

      - name: Run tests with coverage
        working-directory: src/backend
        run: npm test -- --coverage

      # Publica o relatório de cobertura como artefato para visualizar depois
      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        if: always()                       # roda mesmo se os testes falharem
        with:
          name: backend-coverage
          path: src/backend/coverage/
          retention-days: 7

  # ─── Job 2: Build do Docker ─────────────────────────────
  docker-build:
    name: Docker — Build & Scan
    runs-on: ubuntu-latest
    needs: backend-test                    # só roda se backend-test passar

    steps:
      - uses: actions/checkout@v4

      # Configura BuildKit (builder moderno do Docker — mais rápido)
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Build sem push — apenas verifica se a imagem constrói
      - name: Build backend image
        uses: docker/build-push-action@v5
        with:
          context: src/backend
          push: false
          tags: devops-orchestrator-backend:test
          cache-from: type=gha            # cacheia layers entre runs no GitHub
          cache-to: type=gha,mode=max

      # Scan de vulnerabilidades com Trivy
      # Falha se encontrar vulnerabilidade CRITICAL
      - name: Scan for vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: devops-orchestrator-backend:test
          format: table
          exit-code: "1"
          severity: CRITICAL

  # ─── Job 3: Helm Lint ────────────────────────────────────
  helm-lint:
    name: Helm — Lint Chart
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Helm
        uses: azure/setup-helm@v3
        with:
          version: "3.14.0"

      - name: Lint Helm chart
        run: helm lint helm/devops-orchestrator/

      - name: Template rendering test
        run: helm template test-release helm/devops-orchestrator/ > /dev/null
        # Se o template tiver erro de sintaxe, isso falha
EOF
```

### 5.3 Workflow de Build e Push

```bash
cat > .github/workflows/build-push.yml << 'EOF'
# build-push.yml — Roda APENAS em push na main
# Constrói as imagens Docker e publica no registry

name: Build and Push

on:
  push:
    branches: [main]
    paths:
      # Só roda se arquivos relevantes mudaram
      # Evita rebuild quando apenas docs são atualizados
      - "src/**"
      - "docker/**"
      - ".github/workflows/build-push.yml"

env:
  REGISTRY: docker.io
  BACKEND_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/devops-orchestrator-backend
  FRONTEND_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/devops-orchestrator-frontend

jobs:
  build-and-push:
    name: Build and Push Docker images
    runs-on: ubuntu-latest

    # Outputs permitem que jobs subsequentes usem esses valores
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Login no Docker Hub usando secrets do repositório
      # Configurar em: Settings → Secrets → Actions
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Gera tags automáticas:
      # - SHA do commit: abc1234 (imutável, rastreável)
      # - latest (para branch main)
      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.BACKEND_IMAGE }}
          tags: |
            type=sha,prefix=sha-,format=short
            type=raw,value=latest,enable={{is_default_branch}}

      # Build e push do backend com cache entre runs
      - name: Build and push backend
        uses: docker/build-push-action@v5
        with:
          context: src/backend
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      # Mesmo processo para frontend
      - name: Build and push frontend
        uses: docker/build-push-action@v5
        with:
          context: src/frontend
          push: true
          tags: |
            ${{ env.FRONTEND_IMAGE }}:sha-${{ github.sha }}
            ${{ env.FRONTEND_IMAGE }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
EOF
```

### 5.4 Configurando Secrets no GitHub

```
1. Acesse: github.com/SEU-USUARIO/devops-agent-orchestrator
2. Settings → Secrets and variables → Actions
3. Clique "New repository secret" e adicione:

   DOCKERHUB_USERNAME   → seu usuário no Docker Hub
   DOCKERHUB_TOKEN      → token de acesso (Docker Hub → Account Settings → Security)
   KUBECONFIG           → conteúdo do seu kubeconfig (para deploy)
```

```bash
git add .
git commit -m "feat: add GitHub Actions workflows for CI/CD pipeline

- Add ci.yml with lint, test, coverage upload and Docker build
- Add build-push.yml for automated Docker image publishing
- Add vulnerability scanning with Trivy on every build
- Add Helm chart linting in CI pipeline
- Use SHA-based image tags for traceability
- Cache npm and Docker layers for faster builds"

git push origin main
# Acesse github.com/SEU-USUARIO/devops-agent-orchestrator/actions
# Você verá os workflows rodando!
```

---

## Fase 6 — Terraform com Localstack (sem AWS)

> **Objetivo:** Aprender Infrastructure as Code com Terraform usando Localstack — uma emulação completa de serviços AWS que roda 100% no seu computador, sem conta, sem custo e sem risco de cobranças acidentais.

### 6.1 Conceito: O que é Terraform e por que IaC importa

**O problema que IaC resolve:**  
Criar infraestrutura pelo console da AWS (clicando em botões) é rápido para aprender, mas é um problema sério em times: não tem histórico, não é reproduzível, não dá para revisar em PR, e é fácil de esquecer o que foi criado. Terraform resolve tudo isso — você descreve a infraestrutura em código HCL, versiona no Git como qualquer outro código, e o Terraform garante que o ambiente real corresponde ao que está descrito.

**Fluxo de trabalho do Terraform:**
```
terraform init    → baixa providers e módulos do registry
terraform plan    → calcula a diferença entre o estado atual e o desejado
terraform apply   → executa apenas as mudanças necessárias
terraform destroy → remove tudo que foi criado
```

**State file — o coração do Terraform:**  
O arquivo `terraform.tfstate` registra tudo que foi criado. É como o "inventário" do Terraform. Ele permite que na próxima execução o Terraform saiba o que já existe e calcule apenas o diff. Em times reais, esse arquivo fica em um bucket S3 (nunca no Git) com locking via DynamoDB para evitar dois engenheiros aplicando ao mesmo tempo.

**Conceito — Provider:**  
Um provider é o plugin que traduz o HCL em chamadas de API reais. O provider `aws` transforma `resource "aws_s3_bucket" "meu-bucket"` em uma chamada para a API da AWS. Com Localstack, apontamos o provider para `http://localhost:4566` em vez da AWS real — o código HCL é idêntico.

### 6.2 Conceito: O que é Localstack

**Localstack** é um container Docker que emula dezenas de serviços da AWS localmente: S3, EC2, Lambda, DynamoDB, IAM, SQS, SNS e muito mais. Você escreve e testa Terraform exatamente como faria com a AWS real — a diferença é que tudo roda no seu laptop.

```
Sem Localstack:     Terraform → AWS API (real)  → cria recursos reais → pode gerar custo
Com Localstack:     Terraform → Localstack API  → simula recursos     → zero custo
```

**O que o Localstack emula nesta fase:**
- S3: para armazenar o state file remotamente (como seria em produção)
- EC2: para simular instâncias
- VPC: para simular redes privadas
- IAM: para simular permissões

### 6.3 Subindo o Localstack

```bash
# Localstack roda como container Docker — sem instalação extra

# Subir o Localstack
docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e SERVICES=s3,ec2,iam,vpc \
  -e DEFAULT_REGION=us-east-1 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  localstack/localstack:latest

# Verificar que está rodando
docker logs localstack --follow
# Você verá: "Ready." quando estiver pronto (~30 segundos)

# Testar se os serviços respondem
curl http://localhost:4566/_localstack/health | python3 -m json.tool
# Deve retornar: { "services": { "s3": "running", "ec2": "running", ... } }
```

**Instalar o awslocal (wrapper do AWS CLI para Localstack):**

```bash
# awslocal é um wrapper que aponta automaticamente para localhost:4566
pip install awscli-local

# Testar: criar um bucket S3 no Localstack
awslocal s3 mb s3://meu-bucket-teste
# make_bucket: meu-bucket-teste

awslocal s3 ls
# 2026-05-01 10:00:00 meu-bucket-teste

# Funciona exatamente como o AWS CLI real, mas tudo é local
```

### 6.4 Estrutura do Terraform

```bash
# Criar arquivos de configuração do Terraform

echo "terraform.tfvars" >> .gitignore
echo ".terraform/" >> .gitignore
echo "*.tfstate" >> .gitignore
echo "*.tfstate.backup" >> .gitignore
echo ".terraform.lock.hcl" >> .gitignore
```

```bash
cat > terraform/versions.tf << 'EOF'
# versions.tf — Fixa as versões dos providers
# CRÍTICO: sem versionamento fixo, um upgrade de provider pode quebrar tudo

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 — aponta para o Localstack em vez da AWS real
  # Isso simula exatamente o que você faria em produção com S3 real
  backend "s3" {
    bucket                      = "terraform-state-local"
    key                         = "devops-orchestrator/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    access_key                  = "test"
    secret_key                  = "test"
  }
}
EOF
```

```bash
cat > terraform/variables.tf << 'EOF'
# variables.tf — Define as entradas do módulo
# Cada variável pode ser sobrescrita via terraform.tfvars ou -var flag

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "devops-orchestrator"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  # Validação: garante que só valores válidos são aceitos
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "region" {
  description = "AWS region (or Localstack region)"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.medium"
}
EOF
```

```bash
cat > terraform/main.tf << 'EOF'
# main.tf — Recursos de infraestrutura
# Provider configurado para usar Localstack em vez da AWS real

provider "aws" {
  region = var.region

  # Credenciais fictícias — Localstack não valida
  access_key = "test"
  secret_key = "test"

  # Aponta todas as chamadas de API para o Localstack local
  # Em produção real: remova todos os blocos abaixo e use credenciais reais
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  # Endpoints: mapeiam cada serviço AWS para o Localstack
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
  }

  # Tags aplicadas a todos os recursos automaticamente
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      CreatedBy   = "localstack"
    }
  }
}

# ─── S3 Bucket: armazenamento de artefatos ────────────────
# Simula um bucket real para guardar configs ou backups

resource "aws_s3_bucket" "app_artifacts" {
  # Interpolação: usa variáveis para compor o nome
  bucket = "${var.project_name}-${var.environment}-artifacts"
}

# Bloqueia acesso público ao bucket (boa prática de segurança)
resource "aws_s3_bucket_public_access_block" "app_artifacts" {
  bucket = aws_s3_bucket.app_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versionamento: mantém histórico de arquivos no bucket
resource "aws_s3_bucket_versioning" "app_artifacts" {
  bucket = aws_s3_bucket.app_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ─── VPC: rede privada virtual ─────────────────────────────
# Em produção: os pods do Kubernetes rodariam nessa VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true   # necessário para resolver nomes internos
  enable_dns_hostnames = true   # atribui hostnames DNS aos recursos

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Subnets públicas: acessíveis pela internet (load balancers)
resource "aws_subnet" "public" {
  count  = 2   # 2 subnets = 2 zonas de disponibilidade
  vpc_id = aws_vpc.main.id

  # cidrsubnet calcula os CIDRs automaticamente:
  # cidrsubnet("10.0.0.0/16", 8, 0) = "10.0.0.0/24"
  # cidrsubnet("10.0.0.0/16", 8, 1) = "10.0.1.0/24"
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

# Subnets privadas: sem acesso direto à internet (servidores de aplicação)
resource "aws_subnet" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  # Offset de 10 para não conflitar com as subnets públicas
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
    Tier = "private"
  }
}

# Internet Gateway: conecta a VPC à internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ─── IAM Role: permissões para a aplicação ─────────────────
# Define o que a aplicação pode fazer na AWS (princípio de menor privilégio)

resource "aws_iam_role" "app_role" {
  name = "${var.project_name}-${var.environment}-app-role"

  # Trust policy: quem pode assumir esta role (EC2 instances neste caso)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy: permissões específicas que a role tem
resource "aws_iam_role_policy" "app_s3_policy" {
  name = "s3-access"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        # Permite acesso apenas ao bucket criado neste projeto
        Resource = [
          aws_s3_bucket.app_artifacts.arn,
          "${aws_s3_bucket.app_artifacts.arn}/*"
        ]
      }
    ]
  })
}
EOF
```

```bash
cat > terraform/outputs.tf << 'EOF'
# outputs.tf — Valores exportados após o apply
# Use: terraform output <nome>  ou  terraform output -json

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "s3_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = aws_s3_bucket.app_artifacts.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "app_iam_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "environment_summary" {
  description = "Summary of the created environment"
  value = {
    project     = var.project_name
    environment = var.environment
    vpc_cidr    = var.vpc_cidr
    bucket      = aws_s3_bucket.app_artifacts.id
  }
}
EOF
```

```bash
cat > terraform/terraform.tfvars.example << 'EOF'
# terraform.tfvars.example — Exemplo de variáveis
# Copie para terraform.tfvars e ajuste conforme necessário
# terraform.tfvars está no .gitignore

project_name      = "devops-orchestrator"
environment       = "dev"
region            = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
app_instance_type = "t3.medium"
EOF
```

### 6.5 Executando o Terraform com Localstack

```bash
cd terraform/

# Passo 0: criar o bucket S3 no Localstack para o backend remoto
# (em produção você criaria este bucket na AWS antes de rodar o Terraform)
awslocal s3 mb s3://terraform-state-local

# Passo 1: baixar providers e inicializar o backend
terraform init
# Você verá:
# - Downloading hashicorp/aws v5.x.x
# - Successfully configured the backend "s3"

# Passo 2: validar a sintaxe dos arquivos HCL
terraform validate
# Success! The configuration is valid.

# Passo 3: planejar — o mais importante para aprender
# Leia TUDO que aparece aqui antes de aplicar
terraform plan
# Terraform will perform the following actions:
#   + aws_iam_role.app_role         will be created
#   + aws_iam_role_policy.app_s3_policy will be created
#   + aws_internet_gateway.main     will be created
#   + aws_s3_bucket.app_artifacts   will be created
#   + aws_subnet.private[0]         will be created
#   + aws_subnet.private[1]         will be created
#   + aws_subnet.public[0]          will be created
#   + aws_subnet.public[1]          will be created
#   + aws_vpc.main                  will be created
# Plan: 9 to add, 0 to change, 0 to destroy.

# Passo 4: aplicar (cria os recursos no Localstack)
terraform apply
# Digite "yes" quando solicitado
# Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

# Passo 5: ver os outputs
terraform output
# s3_bucket_name = "devops-orchestrator-dev-artifacts"
# vpc_id         = "vpc-xxxxxxxxxx"
# ...

# Verificar no Localstack que os recursos foram criados
awslocal s3 ls
# devops-orchestrator-dev-artifacts

awslocal ec2 describe-vpcs --query 'Vpcs[*].{ID:VpcId,CIDR:CidrBlock}'
# [{ "ID": "vpc-xxx", "CIDR": "10.0.0.0/16" }]

# Passo 6: testar mudanças — altere uma variável e veja o diff
terraform plan -var="environment=staging"
# Terraform detecta o que mudaria se fosse aplicado em staging

# Passo 7: destruir tudo (sem medo — é tudo local)
terraform destroy
# Destroy complete! Resources: 9 destroyed.

# Verificar que foi destruído
awslocal s3 ls
# (lista vazia)
```

### 6.6 Entendendo o State File

```bash
# Ver o state atual em formato legível
terraform show

# Listar recursos no state
terraform state list
# aws_iam_role.app_role
# aws_s3_bucket.app_artifacts
# aws_vpc.main
# ...

# Ver detalhes de um recurso específico
terraform state show aws_vpc.main
# id     = "vpc-xxx"
# cidr_block = "10.0.0.0/16"
# ...

# Ver o state salvo no S3 do Localstack
awslocal s3 cp s3://terraform-state-local/devops-orchestrator/terraform.tfstate - | python3 -m json.tool
# Você verá o JSON completo com todos os recursos criados
# Em produção: este arquivo estaria criptografado no S3 real
```

### 6.7 Entendendo Modules

**Conceito — Módulos:**  
Módulos são blocos reutilizáveis de Terraform — como funções em programação. Em vez de copiar e colar 50 linhas de VPC em cada projeto, você cria um módulo `vpc` e chama com `module "vpc" { source = "./modules/vpc" }`.

```bash
mkdir -p terraform/modules/s3-bucket

cat > terraform/modules/s3-bucket/main.tf << 'EOF'
# modules/s3-bucket/main.tf
# Módulo reutilizável para criar buckets S3 padronizados

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_id"  { value = aws_s3_bucket.this.id }
output "bucket_arn" { value = aws_s3_bucket.this.arn }
EOF

# Usar o módulo no main.tf
cat >> terraform/main.tf << 'EOF'

# ─── Usando o módulo reutilizável ─────────────────────────
module "logs_bucket" {
  source      = "./modules/s3-bucket"
  bucket_name = "${var.project_name}-${var.environment}-logs"
  enable_versioning = false   # logs não precisam de versioning
}
EOF
```

```bash
git add .
git commit -m "feat: add Terraform IaC with Localstack for local cloud simulation

- Add provider configuration pointing to Localstack (no real AWS needed)
- Add S3 bucket with versioning and public access block
- Add VPC with public and private subnets using cidrsubnet()
- Add Internet Gateway for public subnet routing
- Add IAM Role and Policy with least-privilege S3 access
- Add reusable s3-bucket module
- Add state backend using Localstack S3 (mirrors real S3 workflow)
- Add outputs for all created resource IDs
- Add .tfvars.example without sensitive values"

git push origin main
```

---

## Fase 7 — Observabilidade

> **Objetivo:** Ter visibilidade completa do que acontece na aplicação em tempo real.

### 7.1 Conceito: Os 3 Pilares da Observabilidade

**Métricas (Prometheus):**  
Valores numéricos ao longo do tempo. Ex: "quantas requisições por segundo?", "qual é a latência?". Ótimo para alertas e dashboards de performance.

**Logs (Loki):**  
Eventos textuais em sequência. Ex: "erro ao processar mensagem do agente Terraform". Ótimo para debugging. Loki é o padrão open source que se integra nativamente com Grafana.

**Traces (Jaeger — fase futura):**  
Rastreia uma requisição por todos os serviços. Ex: "esta requisição levou 200ms — 50ms no frontend, 120ms no backend, 30ms no agente".

**A stack escolhida:**  
Prometheus + Grafana é o padrão open source da indústria para Kubernetes. Virtualmente toda empresa com K8s usa essa stack.

### 7.2 Métricas no Backend

```bash
# Instalar biblioteca Prometheus para Node.js
cd src/backend
npm install prom-client

cat > src/metrics/prometheus.js << 'EOF'
// src/metrics/prometheus.js
// Expõe métricas da aplicação para o Prometheus coletar

const client = require('prom-client');

// Habilita métricas padrão do Node.js (CPU, memória, event loop lag, etc.)
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// ─── Métricas customizadas da aplicação ──────────────────

// Counter: só sobe, nunca desce — ideal para contagens de eventos
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status_code'],
  registers: [register]
});

// Histogram: distribui valores em buckets — ideal para latência
// Os buckets definem os thresholds de SLO (ex: 95% das reqs < 500ms)
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],  // em segundos
  registers: [register]
});

// Counter por agente — mostra qual agente é mais usado
const agentRequestsTotal = new client.Counter({
  name: 'agent_requests_total',
  help: 'Total requests per agent',
  labelNames: ['agent_name'],
  registers: [register]
});

// Gauge: sobe e desce — ideal para valores que variam
const activeSessions = new client.Gauge({
  name: 'active_sessions',
  help: 'Number of active chat sessions',
  registers: [register]
});

// Middleware Express: registra métricas em cada requisição
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      path: req.route?.path || req.path,
      status_code: res.statusCode
    };

    httpRequestsTotal.inc(labels);
    httpRequestDuration.observe(labels, duration);
  });

  next();
};

module.exports = {
  register,
  metricsMiddleware,
  agentRequestsTotal,
  activeSessions
};
EOF
```

```bash
# Adicionar rota /metrics que o Prometheus vai chamar
cat > src/routes/metrics.routes.js << 'EOF'
const express = require('express');
const router = express.Router();
const { register } = require('../metrics/prometheus');

// GET /metrics — endpoint que o Prometheus coleta a cada 15s
router.get('/', async (req, res) => {
  res.set('Content-Type', register.contentType);
  const metrics = await register.metrics();
  res.end(metrics);
});

module.exports = router;
EOF
```

### 7.3 Prometheus no Kubernetes

```bash
# Instalar Prometheus e Grafana via Helm (jeito mais fácil e padrão)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# kube-prometheus-stack instala Prometheus + Grafana + AlertManager + dashboards pré-configurados
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

**Configurar ServiceMonitor para monitorar nossa aplicação:**

```bash
cat > monitoring/prometheus/service-monitor.yaml << 'EOF'
# ServiceMonitor: diz ao Prometheus onde coletar métricas da nossa app
# O Prometheus descobre automaticamente novos endpoints via este CRD (Custom Resource Definition)

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: orchestrator-metrics
  namespace: monitoring      # namespace do Prometheus
  labels:
    release: prometheus      # deve corresponder ao label do Prometheus
spec:
  namespaceSelector:
    matchNames:
      - devops-orchestrator  # namespace da nossa aplicação
  selector:
    matchLabels:
      app: orchestrator-backend
  endpoints:
    - port: http
      path: /metrics
      interval: 15s          # coleta a cada 15 segundos
EOF

kubectl apply -f monitoring/prometheus/service-monitor.yaml
```

### 7.4 Regras de Alerta

```bash
cat > monitoring/prometheus/alert-rules.yaml << 'EOF'
# alert-rules.yaml — Quando o Prometheus deve disparar alertas

apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: orchestrator-alerts
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
    - name: orchestrator.rules
      interval: 30s
      rules:
        # Alerta se taxa de erros HTTP > 5% por 5 minutos
        - alert: HighErrorRate
          expr: |
            sum(rate(http_requests_total{status_code=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
            > 0.05
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected"
            description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"

        # Alerta se P95 de latência > 2 segundos
        - alert: HighLatency
          expr: |
            histogram_quantile(0.95,
              sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
            ) > 2
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High latency detected"
            description: "P95 latency is {{ $value }}s (threshold: 2s)"

        # Alerta se não há pods disponíveis
        - alert: NoPodsAvailable
          expr: |
            kube_deployment_status_replicas_available{
              namespace="devops-orchestrator"
            } == 0
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "No pods available for {{ $labels.deployment }}"
EOF

kubectl apply -f monitoring/prometheus/alert-rules.yaml
```

### 7.5 Acessando o Grafana

```bash
# Fazer port-forward para acessar localmente
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

# Acesse: http://localhost:3000
# Usuário: admin
# Senha: admin123

# Dashboards pré-instalados pelo kube-prometheus-stack:
# - Kubernetes / Cluster Overview
# - Kubernetes / Pods
# - Node Exporter / Nodes
# Eles já mostram métricas de CPU, memória, rede do cluster

# Para ver métricas da SUA aplicação, crie um dashboard:
# 1. + → Dashboard → Add visualization
# 2. Selecione Prometheus como data source
# 3. Query: http_requests_total (suas métricas customizadas)
```

```bash
git add .
git commit -m "feat: add observability stack with Prometheus metrics

- Add prom-client for custom application metrics
- Add HTTP request counter and duration histogram
- Add per-agent request counter for usage analytics
- Add /metrics endpoint for Prometheus scraping
- Add ServiceMonitor for automatic metric discovery
- Add PrometheusRule with error rate and latency alerts
- Configure kube-prometheus-stack via Helm"

git push origin main
```

---

## Fase 8 — Portfolio Final

> **Objetivo:** Transformar o repositório em uma vitrine que impressiona recrutadores.

### 8.1 README principal

O README é a primeira coisa que qualquer pessoa vê. Deve comunicar em segundos: o que é, por que é relevante, como rodar.

```bash
cat > README.md << 'EOF'
# DevOps Agent Orchestrator

[![CI](https://github.com/SEU-USUARIO/devops-agent-orchestrator/actions/workflows/ci.yml/badge.svg)](https://github.com/SEU-USUARIO/devops-agent-orchestrator/actions/workflows/ci.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://hub.docker.com/r/SEU-USUARIO/devops-orchestrator-backend)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28-326CE5?logo=kubernetes)](kubernetes/)
[![Helm](https://img.shields.io/badge/Helm-Chart-0F1689?logo=helm)](helm/)
[![Terraform](https://img.shields.io/badge/Terraform-AWS_EKS-7B42BC?logo=terraform)](terraform/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Intelligent orchestration system for DevOps/SRE agents. Automatically routes user requests to specialized AI agents for Terraform, Kubernetes, AWS, Ansible, and GitHub Actions.

![Interface Screenshot](docs/screenshots/interface.png)

## Architecture

```
User → Orchestrator Agent → Terraform Agent
                         → Kubernetes Agent
                         → AWS Agent
                         → Ansible Agent
                         → GitHub Actions Agent
```

## Quick Start

### Option 1 — Docker Compose (recommended for local dev)
```bash
git clone https://github.com/SEU-USUARIO/devops-agent-orchestrator.git
cd devops-agent-orchestrator
docker-compose -f docker/docker-compose.yml up --build
# Open: http://localhost:3000
```

### Option 2 — Kubernetes (minikube)
```bash
minikube start
helm install devops-orchestrator helm/devops-orchestrator/ \
  --namespace devops-orchestrator --create-namespace
minikube service orchestrator-frontend-service -n devops-orchestrator
```

### Option 3 — AWS EKS (production)
```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init && terraform apply
aws eks update-kubeconfig --region us-east-1 --name devops-orchestrator-cluster
helm install devops-orchestrator helm/devops-orchestrator/ \
  -f helm/devops-orchestrator/values-prod.yaml \
  --namespace devops-orchestrator --create-namespace
```

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18, Vite |
| Backend | Node.js 20, Express |
| Containerization | Docker (multi-stage builds) |
| Orchestration | Kubernetes 1.28, minikube |
| Package Manager | Helm 3 |
| Infrastructure | Terraform 1.7, Localstack |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus, Grafana |

## Project Structure

```
devops-agent-orchestrator/
├── src/               # Application source code
├── kubernetes/        # K8s manifests
├── helm/              # Helm chart
├── terraform/         # IaC with Localstack (no real AWS needed)
├── .github/workflows/ # CI/CD pipelines
├── monitoring/        # Prometheus + Grafana
└── docs/              # Documentation
```

## Documentation

- [Setup Guide](docs/setup-local.md)
- [Kubernetes Deployment](docs/deployment-kubernetes.md)
- [Terraform Localstack](docs/terraform-localstack.md)
- [Helm Chart](docs/helm-chart.md)
- [Monitoring Setup](docs/monitoring-setup.md)
- [Architecture Decisions](docs/architecture-decisions/)
EOF
```

### 8.2 Checklist final de portfolio

```bash
# Verificações antes de divulgar o repositório:

echo "=== CHECKLIST FINAL ==="

# 1. Sem segredos expostos
git log --all --oneline | head -20
grep -r "password\|secret\|key\|token" . --include="*.yaml" --include="*.tf" \
  --include="*.js" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  --exclude="*.example" | grep -v "secretKeyRef\|secretName\|#"

# 2. README tem badges funcionando
# Verifique abrindo o GitHub no browser

# 3. GitHub Actions rodando
# github.com/SEU-USUARIO/devops-agent-orchestrator/actions

# 4. Histórico de commits limpo e semântico
git log --oneline

# 5. Todas as fases documentadas
ls docs/

# 6. docker-compose up funciona em máquina limpa
docker-compose -f docker/docker-compose.yml down -v
docker-compose -f docker/docker-compose.yml up --build
```

### 8.3 ADR — Architecture Decision Records

**Conceito — ADR:**  
Documenta decisões arquiteturais importantes: qual foi o contexto, quais opções foram consideradas, qual foi escolhida e por quê. Mostra maturidade de engenharia — você não apenas tomou decisões, mas as justificou.

```bash
cat > docs/architecture-decisions/ADR-001-kubernetes-over-ecs.md << 'EOF'
# ADR-001: Use Kubernetes (EKS) instead of ECS

**Status:** Accepted  
**Date:** 2026-05

## Context
We need a container orchestration platform to run the multi-agent application with auto-scaling, zero-downtime deployments, and production-grade reliability.

## Options Considered

| Option | Pros | Cons |
|---|---|---|
| **EKS (Kubernetes)** | Industry standard, portable, rich ecosystem, Helm support | More complex, steeper learning curve |
| **ECS (Fargate)** | Simpler, AWS-native, less operational overhead | AWS vendor lock-in, smaller ecosystem |
| **EC2 with Docker** | Full control, cheapest | Manual scaling, no orchestration |

## Decision
**EKS (Kubernetes)** was chosen.

## Rationale
- Kubernetes is the de facto standard for container orchestration — knowledge is transferable
- Helm charts enable clean environment promotion (dev → staging → prod)
- HPA provides automatic scaling without AWS-specific tooling
- The portfolio value of demonstrating Kubernetes proficiency outweighs ECS simplicity
- ECS knowledge is trivially transferable once Kubernetes is understood

## Consequences
- More initial setup complexity
- Requires understanding of Kubernetes concepts (Pods, Deployments, Services, etc.)
- Benefit: knowledge is directly applicable to GKE, AKS, and on-premises clusters
EOF
```

```bash
git add .
git commit -m "docs: finalize portfolio documentation and README

- Add comprehensive README with badges and quick start options
- Add architecture decision records (ADR-001, ADR-002, ADR-003)
- Add screenshots directory for interface documentation
- Add final portfolio checklist verification"

git push origin main
```

---

## Resumo das Fases

| Fase | O que você aprende | Resultado |
|---|---|---|
| 1 — Foundation | Node.js, Express, React, estrutura de projeto | App rodando localmente |
| 2 — Docker | Multi-stage builds, NGINX, Docker Compose | Containers isolados e portáteis |
| 3 — Kubernetes | Pods, Deployments, Services, Ingress, HPA | App orquestrada em K8s local |
| 4 — Helm | Templates, values, releases, rollback | Deploy parametrizável |
| 5 — GitHub Actions | CI/CD, jobs, steps, secrets, artifacts | Pipeline automático |
| 6 — Terraform + Localstack | HCL, providers, modules, state, backends | IaC sem custo e sem AWS real |
| 7 — Observabilidade | Métricas, alertas, dashboards, logs | Sistema completamente monitorado |
| 8 — Portfolio | README, ADRs, commits semânticos | Portfolio que impressiona |

---

*Documento vivo — atualizado conforme o projeto evolui.*  
*Última revisão: Maio 2026*
