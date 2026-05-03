# Observability Site - Helm Chart

Educational site on Logs, Traces & Metrics for SRE professionals.

## Installation

### Add Helm Repository

```bash
helm repo add observability-site https://example.com/charts  # (Future)
helm repo update
```

### Install with Helm

**Development (default):**
```bash
helm install observability-site . -n observability --create-namespace
```

**Production:**
```bash
helm install observability-site . \
  -n observability-prod \
  --create-namespace \
  -f values-prod.yaml
```

### Upgrade Release

```bash
helm upgrade observability-site . -n observability
```

### Uninstall Release

```bash
helm uninstall observability-site -n observability
```

---

## Configuration

### Common Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environment` | Environment name | `dev` |
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Image repository | `observability-site` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Pull policy | `Never` (for minikube) |

### Resource Limits

```yaml
resources:
  requests:
    cpu: 50m
    memory: 32Mi
  limits:
    cpu: 200m
    memory: 128Mi
```

### Ingress Configuration

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: observability.local
      paths:
        - path: /
          pathType: Prefix
```

### Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  metrics:
    cpu:
      targetAverageUtilization: 70
    memory:
      targetAverageUtilization: 80
```

### Health Probes

```yaml
probes:
  liveness:
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
  readiness:
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3
  startup:
    failureThreshold: 6  # 30s max startup
```

---

## Usage Examples

### Deploy Development Environment

```bash
helm install observability-site . \
  -n observability \
  --create-namespace
```

### Deploy Production Environment

```bash
helm install observability-site . \
  -n observability-prod \
  --create-namespace \
  -f values-prod.yaml
```

### Override Specific Values

```bash
helm install observability-site . \
  -n observability \
  --create-namespace \
  --set replicaCount=5 \
  --set autoscaling.maxReplicas=20 \
  --set ingress.hosts[0].host=example.com
```

### Render Templates (Dry-run)

```bash
helm template observability-site . -f values-prod.yaml
```

### Validate Templates

```bash
helm lint .
```

### Get Current Release Values

```bash
helm get values observability-site -n observability
```

### Get Release History

```bash
helm history observability-site -n observability
```

### Rollback to Previous Release

```bash
helm rollback observability-site 1 -n observability
```

---

## Template Structure

```
observability-site/
├── Chart.yaml                 # Chart metadata
├── values.yaml                # Default values (dev)
├── values-prod.yaml           # Production overrides
├── README.md                  # This file
└── templates/
    ├── _helpers.tpl           # Template helpers
    ├── deployment.yaml        # Deployment template
    ├── service.yaml           # Service template
    ├── ingress.yaml           # Ingress template
    ├── hpa.yaml               # HPA template
    ├── configmap.yaml         # ConfigMap template
    └── NOTES.txt              # Post-install notes
```

---

## Variables

### Labels

| Variable | Description | Default |
|----------|-------------|---------|
| `labels.app` | App label | `observability-site` |
| `labels.component` | Component label | `web` |
| `labels.version` | Version label | `v1` |

### Namespace

```yaml
namespace: observability  # Dev
namespace: observability-prod  # Prod
```

### Security Context

```yaml
securityContext:
  pod:
    runAsNonRoot: false
  container:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: false
    runAsNonRoot: false
```

---

## Helm Values Merging Order

1. Default values from `values.yaml`
2. Environment-specific values from `values-prod.yaml` (if used)
3. Command-line `--set` flags
4. `--values` file specified at install time

Later values override earlier ones.

---

## Testing

### Lint Chart

```bash
helm lint . -f values.yaml
helm lint . -f values-prod.yaml
```

### Dry-run Install

```bash
helm install observability-site . \
  --dry-run \
  --debug \
  -n observability
```

### Template Rendering

```bash
# Dev environment
helm template observability-site . > rendered-dev.yaml

# Prod environment
helm template observability-site . -f values-prod.yaml > rendered-prod.yaml
```

---

## Troubleshooting

### Check Release Status

```bash
helm status observability-site -n observability
```

### List All Releases

```bash
helm list -n observability
helm list --all-namespaces
```

### Get Release Manifest

```bash
helm get manifest observability-site -n observability
```

### Inspect Values

```bash
helm get values observability-site -n observability
```

### Check for Helm Errors

```bash
helm lint . --strict
```

---

## Contributing

To modify the chart:

1. Update `Chart.yaml` for version changes
2. Modify `values.yaml` or `values-prod.yaml` for configuration
3. Update templates in `templates/` directory
4. Test with `helm lint` and `helm template`
5. Test deployment with `helm install --dry-run`

---

## License

Same as the parent project.

---

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
