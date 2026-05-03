# Docker & Docker Compose Setup

Guia para rodar o Observability Portal com Docker e toda a stack de observabilidade localmente.

## 📋 Pré-requisitos

- Docker 24+
- Docker Compose 2.0+
- 4GB de RAM disponível
- ~2GB de espaço em disco

Verificar instalações:
```bash
docker --version
docker-compose --version
```

## 🚀 Início Rápido

### Opção 1: Um comando

```bash
./scripts/docker-compose-up.sh up
```

Isso vai:
1. Build a imagem Docker do site
2. Iniciar todos os containers (website, Prometheus, Grafana, Loki, Promtail, nginx-exporter)
3. Exibir URLs de acesso

### Opção 2: Passo a passo

```bash
# 1. Build imagem
./scripts/build.sh

# 2. Start services
docker-compose up -d

# 3. Verificar status
docker-compose ps
```

## 🌐 Acessar Serviços

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Website** | http://localhost:8080 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3000 | admin / admin |
| **Loki** | http://localhost:3100 | - |

## 📊 Arquitetura Local

```
┌─────────────────────────────────────┐
│   Docker Network (observability)    │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │  Website (nginx)             │  │
│  │  Port: 8080                  │  │
│  │  Health: /health             │  │
│  │  Metrics: /nginx_status      │  │
│  └──────────────────────────────┘  │
│              ↓                      │
│  ┌──────────────────────────────┐  │
│  │  Nginx Exporter              │  │
│  │  Scrapes /nginx_status       │  │
│  │  Exposes Prometheus metrics  │  │
│  └──────────────────────────────┘  │
│         ↙         ↓         ↘       │
│   Promtail     Loki     Prometheus │
│   (logs)       (store)   (metrics) │
│                   ↓                 │
│           ┌───────────────┐        │
│           │    Grafana    │        │
│           │  Dashboards   │        │
│           └───────────────┘        │
│                                     │
└─────────────────────────────────────┘
```

## 📝 Comandos Úteis

### Ver status
```bash
docker-compose ps
```

### Ver logs
```bash
# Website logs
docker-compose logs -f website

# Prometheus logs
docker-compose logs -f prometheus

# Grafana logs
docker-compose logs -f grafana

# All logs
docker-compose logs -f
```

### Parar/Reiniciar
```bash
# Parar
docker-compose down

# Parar e remover volumes
docker-compose down -v

# Reiniciar
docker-compose restart
```

### Executar comando em container
```bash
docker-compose exec website sh
docker-compose exec prometheus promtool query instant 'up'
```

## 🔍 Testar Observabilidade

### 1. Gerar tráfego no site
```bash
# Fazer várias requisições
for i in {1..100}; do curl -s http://localhost:8080/ > /dev/null; done

# Ver em Grafana → Dashboards → Observability Site
```

### 2. Ver métricas no Prometheus
```bash
# Abrir http://localhost:9090
# Executar queries:
- up{job="nginx-exporter"}
- rate(nginx_http_requests_total[5m])
- histogram_quantile(0.95, nginx_http_request_duration_seconds)
```

### 3. Ver logs no Grafana/Loki
```bash
# Abrir http://localhost:3000 (admin/admin)
# Explore → Loki
# Query: {job="nginx"}
```

### 4. Criar Dashboard no Grafana
```
1. Grafana → "+" → Dashboard
2. Add panel
3. Data source: Prometheus
4. Query: rate(nginx_http_requests_total[5m])
5. Visualize
```

## 🛠️ Troubleshooting

### Porta já em uso
```bash
# Encontrar container usando porta
lsof -i :8080

# Matar processo
kill -9 <PID>

# OU usar porta diferente no docker-compose.yml
```

### Imagem não builda
```bash
# Limpar e reconstruir
docker system prune -a
./scripts/build.sh
```

### Containers não iniciam
```bash
# Ver erro completo
docker-compose logs

# Reiniciar Docker daemon
systemctl restart docker

# OU no macOS
killall Docker && open -a Docker
```

### Prometheus não vê métricas
```bash
# Verificar se nginx-exporter está running
docker-compose ps nginx-exporter

# Verificar logs
docker-compose logs nginx-exporter

# Testar endpoint
curl http://localhost:9113/metrics
```

## 📦 Desenvolvendo Localmente

### Modificar site
```bash
# Edit site/index.html (ou qualquer outro arquivo)
# Reconstruir imagem
./scripts/build.sh

# Restart container
docker-compose restart website
```

### Adicionar nova métrica (Prometheus)
```bash
# Edit monitoring/prometheus/prometheus.yml
# Adicionar novo scrape_config

# Reconstruir sem rebuild imagem (é file mounting)
docker-compose restart prometheus
```

### Modificar dashboard (Grafana)
```bash
# Grafana edita em banco de dados (grafana_data volume)
# Mudanças são persistidas
```

## 🧹 Limpeza

### Remove apenas containers (keep volumes)
```bash
docker-compose down
```

### Remove containers + volumes (limpa tudo)
```bash
docker-compose down -v
```

### Remove imagens também
```bash
docker-compose down -v
docker rmi observability-site:latest
```

## 📊 Performance

### Limites de recursos

Por padrão, Docker usa 100% dos recursos. Para limitar:

Editar `docker-compose.yml`:
```yaml
services:
  website:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
```

## 🔒 Segurança

### Para desenvolvimento apenas!

**NÃO usar em produção:**
- Senhas padrão no Grafana (admin/admin)
- Sem autenticação em Prometheus/Loki
- Sem SSL/TLS
- Nenhum rate limiting

### Para produção:
```bash
# 1. Usar secrets (Docker Secrets ou Vault)
# 2. Habilitar autenticação em todos os serviços
# 3. Usar reverse proxy com SSL (Nginx, Traefik)
# 4. Limitar acesso com iptables/firewall
# 5. Regular backups de volumes
```

## 📚 Próximos Passos

Após rodar localmente com sucesso:

1. **Fase 3:** Deploy em Kubernetes (minikube)
2. **Fase 4:** Helm Chart para parametrização
3. **Fase 5:** GitHub Actions CI/CD
4. **Fase 6:** Terraform + Localstack para IaC
5. **Fase 7:** Observabilidade em produção

Veja `PLANO_IMPLEMENTACAO_V2.md` para detalhes completos.

## 🆘 Obter Ajuda

- Docker docs: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Prometheus: https://prometheus.io/docs/
- Grafana: https://grafana.com/docs/
- Loki: https://grafana.com/docs/loki/

## ✅ Checklist: Rodando Localmente

- [ ] Docker instalado e rodando
- [ ] Clonou o repositório
- [ ] Rodou `./scripts/build.sh` com sucesso
- [ ] `docker-compose up -d` iniciou sem erros
- [ ] `docker-compose ps` mostra 7 containers rodando
- [ ] http://localhost:8080 carrega o site
- [ ] http://localhost:3000 carrega Grafana
- [ ] http://localhost:9090 carrega Prometheus
- [ ] Gerou tráfego e viu métricas em Grafana

Parabéns! Sua stack de observabilidade está rodando! 🎉
