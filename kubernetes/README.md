# Kubernetes Deployment — Observability Portal

Guia para deployar o Observability Portal em Kubernetes local (minikube).

## 📋 Pré-requisitos

- Minikube 1.32+
- kubectl 1.28+
- Docker ou similar (minikube driver)
- 4+ CPUs disponíveis
- 8GB+ de RAM disponível

Verificar:
```bash
minikube version
kubectl version --client
docker version
```

## 🚀 Deployment Rápido (Um Comando)

```bash
./scripts/k8s-deploy.sh
```

Isso vai:
1. ✅ Iniciar minikube
2. ✅ Build imagem Docker em minikube
3. ✅ Create namespace
4. ✅ Apply all manifests
5. ✅ Wait for rollout
6. ✅ Show access information

## 📊 Arquitetura Kubernetes

```
┌─────────────────────────────────────────────────────┐
│  Minikube Cluster                                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Namespace: observability                           │
│  ┌──────────────────────────────────────────────┐  │
│  │  Ingress (nginx)                             │  │
│  │  ├─ observability.local → observability-site │  │
│  │  ├─ prometheus.observability.local → prom    │  │
│  │  └─ grafana.observability.local → grafana    │  │
│  └──────────────────────────────────────────────┘  │
│           ↓           ↓            ↓                │
│  ┌──────────────┐ ┌─────────┐ ┌────────────┐      │
│  │ Website Pods │ │Prom Pod │ │ Grafana Pod│      │
│  │   (x2-10)    │ │  (x1-2) │ │   (x1-2)   │      │
│  └──────────────┘ └─────────┘ └────────────┘      │
│       ↓               ↓             ↓               │
│  ┌──────────────┐ ┌─────────┐ ┌────────────┐      │
│  │ Service      │ │Service  │ │  Service   │      │
│  │(ClusterIP)   │ │(cluster)│ │ (cluster)  │      │
│  └──────────────┘ └─────────┘ └────────────┘      │
│                                                     │
│  HPA: Scales website 2-10 pods based on CPU/mem   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 📁 Manifests Organization

| Arquivo | Propósito | Tipo |
|---------|-----------|------|
| `namespace.yaml` | Isolamento de recursos | Namespace |
| `configmap.yaml` | Configuração compartilhada | ConfigMap |
| `deployment.yaml` | Deployments (website, prom, grafana) | Deployment |
| `service.yaml` | Exposição de pods | Service |
| `ingress.yaml` | Roteamento HTTP externo | Ingress |
| `hpa.yaml` | Auto-scaling | HPA |

## 🔍 Entendendo cada manifest

### 1. Namespace
```yaml
# Isolamento lógico de recursos
# Todos os recursos ficam em 'observability'
```

**Benefícios:**
- ✅ Isolação de recursos
- ✅ Resource quotas
- ✅ Network policies
- ✅ Multi-tenancy

### 2. Deployment
```yaml
# Cria e gerencia Pods
# ReplicaSet controla número de replicas
# Pods contêm containers
```

**Observability-site deployment:**
- 2+ replicas (HPA pode escalar até 10)
- Rolling update strategy (zero downtime)
- Health checks: liveness + readiness + startup
- Resource limits (50-200m CPU, 32-128Mi RAM)

**Prometheus deployment:**
- 1 replica (stateful, logs importantes)
- Scrapes nginx-exporter

**Grafana deployment:**
- 1 replica
- Conecta a Prometheus como datasource

### 3. Service
```yaml
# Descoberta de serviço
# Endereço estável para acessar pods
```

Tipos usados:
- `ClusterIP` — Acesso apenas interno (padrão)
- `Headless` — DNS SRV records (observability-site)

### 4. Ingress
```yaml
# Roteamento HTTP externo
# Substitui NodePort/LoadBalancer
```

Rotas configuradas:
- `observability.local` → website
- `prometheus.observability.local` → Prometheus
- `grafana.observability.local` → Grafana

### 5. HPA (Horizontal Pod Autoscaler)
```yaml
# Auto-scaling baseado em métricas
```

**Observability-site:**
- Min: 2 pods
- Max: 10 pods
- Trigger: CPU > 70% ou Memória > 80%

**Prometheus/Grafana:**
- Min: 1 pod
- Max: 2 pods
- Trigger: CPU > 80%

## 🎯 Manuseando Manifests

### Aplicar individualmente
```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml
```

### Aplicar tudo de uma vez
```bash
kubectl apply -f kubernetes/
```

### Remover tudo
```bash
kubectl delete namespace observability
```

## 📊 Monitorando Deployments

### Ver status em tempo real
```bash
# Watch deployments
kubectl get deployments -n observability -w

# Watch pods
kubectl get pods -n observability -w

# Watch HPA
kubectl get hpa -n observability -w
```

### Ver detalhes
```bash
# Describe deployment
kubectl describe deployment observability-site -n observability

# Describe pod (mais detalhes de erros)
kubectl describe pod <pod-name> -n observability
```

### Ver logs
```bash
# Logs do deployment (último)
kubectl logs -n observability deployment/observability-site -f

# Logs de um pod específico
kubectl logs -n observability pod/<pod-name> -f

# Logs de Prometheus
kubectl logs -n observability deployment/prometheus -f

# Logs de Grafana
kubectl logs -n observability deployment/grafana -f
```

## 🚀 Acessar Serviços

### Opção 1: Ingress (recomendado)
```bash
# Adicione ao /etc/hosts:
echo "$(minikube ip) observability.local" | sudo tee -a /etc/hosts

# Acesse:
http://observability.local
http://prometheus.observability.local
http://grafana.observability.local
```

### Opção 2: Port-forward
```bash
# Terminal 1: Website
kubectl port-forward -n observability svc/observability-site-svc 8080:80

# Terminal 2: Prometheus
kubectl port-forward -n observability svc/prometheus-svc 9090:9090

# Terminal 3: Grafana
kubectl port-forward -n observability svc/grafana-svc 3000:3000

# Acesse:
http://localhost:8080
http://localhost:9090
http://localhost:3000 (admin/admin)
```

### Opção 3: Minikube service
```bash
minikube service observability-site-svc -n observability
minikube service prometheus-svc -n observability
minikube service grafana-svc -n observability
```

## 📈 Teste de Carga

### Gerar tráfego para testar HPA
```bash
# Lote de requisições
for i in {1..100}; do curl -s http://observability.local/ > /dev/null; done

# Tráfego contínuo (ab — Apache Bench)
ab -n 10000 -c 100 http://observability.local/

# Tráfego contínuo (hey)
hey -n 10000 -c 100 http://observability.local/

# Watch HPA scaling
kubectl get hpa -n observability -w
```

Você verá:
- CPU aumentar
- HPA detectar
- Novos pods serem criados
- Load distribuir entre pods

## 🔧 Troubleshooting

### Pods não iniciam
```bash
# Ver erro
kubectl describe pod <pod-name> -n observability

# Ver logs
kubectl logs <pod-name> -n observability

# Erros comuns:
# - ImagePullBackOff: imagem não encontrada
# - CrashLoopBackOff: container crasha ao iniciar
# - Pending: recurso não disponível (CPU/memória)
```

### Imagem não found
```bash
# Se usou Docker externo, não minikube:
eval $(minikube docker-env)
docker build -t observability-site:latest .

# Verify:
kubectl get events -n observability
```

### Ingress não funciona
```bash
# Verificar se ingress addon está ativo
minikube addons list | grep ingress

# Ativar se necessário
minikube addons enable ingress

# Esperar controller ser criado
kubectl get pods -n ingress-nginx

# Testar:
curl -H "Host: observability.local" http://$(minikube ip)/
```

### Pode acessar via port-forward mas não ingress
```bash
# Adicione ao /etc/hosts com IP correto
cat /etc/hosts | grep observability
sudo nano /etc/hosts

# IP deve ser output de:
minikube ip
```

## 📚 Conceitos Kubernetes

### Pod
- Unidade mínima deployável
- 1+ containers (geralmente 1)
- Compartilha network namespace (mesmo IP)
- Efêmero (pode morrer/renascer)

### Deployment
- Define como Pod deve rodar
- Gerencia ReplicaSet
- Permite rolling updates
- Mantém desired state

### Service
- Descoberta de serviço
- IP estável (até deleção)
- Balanceia tráfego entre Pods
- Diferentes tipos (ClusterIP, NodePort, LoadBalancer)

### Ingress
- Roteamento HTTP/HTTPS
- Externo ao cluster
- Baseado em hostname/path
- Requer ingress controller (nginx)

### HPA
- Autoscaling horizontal
- Monitora métricas (CPU, memória)
- Escala up/down automaticamente
- Requer metrics-server

## 🎓 Aprendizado

Para entender melhor:

1. **Minikube Dashboard:**
   ```bash
   minikube dashboard
   ```

2. **Kubernetes Official Docs:**
   - https://kubernetes.io/docs/

3. **Deployments:**
   - https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

4. **Services:**
   - https://kubernetes.io/docs/concepts/services-networking/service/

5. **Ingress:**
   - https://kubernetes.io/docs/concepts/services-networking/ingress/

## ✅ Checklist: Pronto para Produção?

- [ ] Namespace criado
- [ ] Deployments rodando (kubectl get pods)
- [ ] Services acessíveis (kubectl get svc)
- [ ] Ingress configurado (kubectl get ingress)
- [ ] HPA ativo (kubectl get hpa)
- [ ] Health checks funcionando
- [ ] Pods escalando sob carga
- [ ] Logs visíveis (kubectl logs)
- [ ] Métricas em Prometheus
- [ ] Dashboard em Grafana

## 🚀 Próximas Fases

Após K8s funcionando:

1. **Fase 4:** Helm Chart (parametrização)
2. **Fase 5:** GitHub Actions (CI/CD)
3. **Fase 6:** Terraform (IaC)
4. **Fase 7:** Observabilidade completa
5. **Fase 8:** Portfolio final

Veja `PLANO_IMPLEMENTACAO_V2.md`.
