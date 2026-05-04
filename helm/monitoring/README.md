# Monitoring Stack — Helm Chart

Complete observability stack for Kubernetes using Prometheus, Grafana, and Loki.

## 📊 Overview

This Helm chart deploys a production-ready monitoring stack with:

- **Prometheus** — Time-series metrics database
- **Grafana** — Visualization & dashboarding
- **Loki** — Log aggregation system
- **Promtail** — Log shipper (DaemonSet)
- **Nginx Exporter** — Metrics from nginx endpoints
- **Kube State Metrics** — Kubernetes object metrics
- **Node Exporter** — Hardware & OS metrics

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│         Kubernetes Cluster                          │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────┐       ┌──────────────┐          │
│  │ Applications │──────▶│   Promtail   │          │
│  │ (nginx, pods)│       │  (DaemonSet) │          │
│  └──────────────┘       └──────┬───────┘          │
│         ▲                       │                  │
│         │                       ▼                  │
│         │                  ┌──────────┐           │
│   [Nginx Exporter]────────▶│  Loki    │           │
│         │                  │ (Storage)│           │
│         │                  └──────────┘           │
│  ┌──────┴──────┐                │                 │
│  │ Prometheus  │                │                 │
│  │(Time-Series)│                │                 │
│  └──────┬──────┘                │                 │
│         │                       │                 │
│         └───────────┬───────────┘                 │
│                     ▼                             │
│                 ┌────────────┐                    │
│                 │  Grafana   │                    │
│                 │(Dashboards)│                    │
│                 └────────────┘                    │
│                                                   │
└─────────────────────────────────────────────────────┘
```

## 🚀 Installation

### Prerequisites
- Kubernetes 1.20+
- Helm 3.0+
- Nginx Ingress Controller (for Ingress access)

### Quick Start

1. **Add Helm repositories:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

2. **Update Helm dependencies:**
```bash
cd helm/monitoring
helm dependency update
```

3. **Install the chart (development):**
```bash
helm install monitoring . \
  -n observability --create-namespace \
  -f values.yaml
```

4. **Install the chart (production):**
```bash
helm install monitoring . \
  -n observability-prod --create-namespace \
  -f values-prod.yaml
```

## 📊 Access Dashboards

### Development

```bash
# Grafana (port-forward)
kubectl port-forward -n observability svc/monitoring-grafana 3000:80

# Prometheus (port-forward)
kubectl port-forward -n observability svc/monitoring-kube-prometheus-prometheus 9090:9090

# Access
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
```

### Production (via Ingress)

With nginx ingress configured:
- **Grafana**: https://grafana.observability.io
- **Prometheus**: https://prometheus.observability.io

## 🔍 Included Dashboards

### 1. **Nginx Metrics**
- Requests per second
- Response latency (p95)
- Status code distribution
- Active connections
- Error rate (5xx responses)

### 2. **Kubernetes Pods**
- Pod CPU usage
- Pod memory usage
- Pod restart count
- Pod status (Running, Pending, Failed, etc)

### 3. **Logs Overview**
- Real-time log streaming
- Log level distribution
- Error log filtering
- Search and explore capabilities

### 4. **Cluster Overview**
- Cluster-wide CPU usage
- Cluster-wide memory usage
- Node status and health
- PersistentVolume usage

## ⚙️ Configuration

### Prometheus

**Retention**: 
- Dev: 7 days
- Prod: 30 days

**Scrape Interval**: 15 seconds

**Alert Rules**: Configured via `prometheus-rules-configmap.yaml` with 5 default rules

### Grafana

**Default Credentials**:
- Dev: `admin` / `admin`
- Prod: Override via `GRAFANA_ADMIN_PASSWORD`

**Datasources**:
- Prometheus: `monitoring-kube-prometheus-prometheus:9090`
- Loki: `monitoring-loki:3100`

**Plugins**: (can be added via values)
- `grafana-piechart-panel` — Pie charts
- `grafana-worldmap-panel` — Geographic visualization

### Loki

**Retention**: 
- Dev: 24 hours
- Prod: 7 days

**Storage**: 
- Dev: 5Gi PVC
- Prod: 50Gi PVC

## 🔄 Helm Values Override

### Change Grafana password:
```bash
helm upgrade monitoring . \
  --set kubePrometheusStack.grafana.adminPassword=mySecurePassword
```

### Increase Prometheus retention:
```bash
helm upgrade monitoring . \
  --set kubePrometheusStack.prometheus.prometheusSpec.retention=30d
```

### Disable Loki:
```bash
helm upgrade monitoring . \
  --set lokiStack.enabled=false
```

## 🧪 Verification

Check pod status:
```bash
kubectl get pods -n observability -l app.kubernetes.io/instance=monitoring

# Output:
# monitoring-kube-prometheus-prometheus-0
# monitoring-grafana-xxxxx
# monitoring-loki-0
# monitoring-loki-promtail-xxxxx (DaemonSet pod per node)
# monitoring-nginx-exporter-xxxxx
```

Check if Prometheus scrapes are healthy:
```bash
kubectl port-forward -n observability svc/monitoring-kube-prometheus-prometheus 9090:9090
# Visit http://localhost:9090/targets
# All targets should show "UP"
```

Check Grafana datasources:
```bash
kubectl port-forward -n observability svc/monitoring-grafana 3000:80
# Visit http://localhost:3000/datasources
# Both Prometheus and Loki should be "healthy"
```

## 🔔 Alert Rules

Default alerts configured:

1. **WebsiteDown** (Critical) — Nginx endpoint unreachable for 2 minutes
2. **WebsiteHighErrorRate** (Warning) — Error rate > 5% for 5 minutes
3. **HighLatency** (Warning) — P95 latency > 1s for 5 minutes
4. **HighMemoryUsage** (Warning) — Available memory < 20%
5. **UnusuallyHighTraffic** (Info) — Requests > 100 RPS
6. **NoTraffic** (Warning) — Zero requests for 10 minutes

View alerts:
```bash
kubectl port-forward -n observability svc/monitoring-kube-prometheus-prometheus 9090:9090
# Visit http://localhost:9090/alerts
```

## 📈 Performance Tuning

### For high-volume environments:

1. **Increase PVC sizes:**
```bash
helm upgrade monitoring . \
  --set kubePrometheusStack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi
```

2. **Enable Prometheus remote storage:**
```yaml
kubePrometheusStack:
  prometheus:
    prometheusSpec:
      remoteWrite:
        - url: https://remote-prometheus-endpoint
```

3. **Configure Loki retention policies:**
```yaml
lokiStack:
  loki:
    limits_config:
      retention_period: 30d
```

## 🧹 Cleanup

```bash
# Uninstall monitoring stack
helm uninstall monitoring -n observability

# Delete namespace
kubectl delete namespace observability

# Delete PVCs (if not needed)
kubectl delete pvc -n observability --all
```

## 🐛 Troubleshooting

### Grafana won't start
```bash
kubectl logs -n observability -l app.kubernetes.io/name=grafana

# Check PVC
kubectl get pvc -n observability
```

### Prometheus not scraping targets
```bash
# Check scrape configs
kubectl exec -it monitoring-kube-prometheus-prometheus-0 -n observability -- cat /etc/prometheus/prometheus.yml

# Restart Prometheus
kubectl rollout restart statefulset monitoring-kube-prometheus-prometheus -n observability
```

### Loki not receiving logs
```bash
# Check Promtail logs
kubectl logs -n observability -l app.kubernetes.io/name=promtail

# Verify Loki is running
kubectl get pods -n observability -l app=loki
```

### Ingress not accessible
```bash
# Check Ingress status
kubectl describe ingress monitoring-prometheus -n observability

# Verify hostname resolves
nslookup prometheus.observability.local
```

## 📚 References

- [Prometheus Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Loki Helm Chart](https://github.com/grafana/loki/tree/main/production/helm)
- [Grafana Documentation](https://grafana.com/docs)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
