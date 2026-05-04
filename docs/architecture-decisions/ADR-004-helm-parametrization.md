# ADR-004: Helm Charts for Kubernetes Parametrization

**Status**: Accepted

## Context

Kubernetes deployments require different configurations for dev and production environments (replicas, resource limits, image tags, storage, TLS). Need a templating/parametrization mechanism to manage these variations without duplicating manifests.

Options include:
- Raw Kubernetes manifests + envsubst
- Kustomize
- Helm
- Pulumi
- CDK

## Decision

Use **Helm** with two separate charts:
1. **observability-site/** — Main application (website + related services)
2. **monitoring/** — Observability stack (Prometheus, Grafana, Loki)

Each chart uses `values.yaml` (dev) and `values-prod.yaml` (production overrides).

## Rationale

1. **Industry standard**: Helm is the de facto package manager for Kubernetes. Every production K8s shop uses it.
2. **Dependency management**: Helm charts can depend on other charts (e.g., monitoring chart depends on kube-prometheus-stack and loki-stack from community repos).
3. **Dev/prod separation**: Two values files cleanly separate environments without code duplication.
4. **Release management**: Helm releases provide versioning, rollback, and upgrade tracking.
5. **Parametrization clarity**: values.yaml is a single source of truth for all configurable parameters.
6. **Community ecosystem**: Public Helm chart repos (prometheus-community, grafana) provide battle-tested charts.

## Consequences

- ✅ Production-ready templating approach
- ✅ Easy dev/prod promotion: `helm install ... -f values-prod.yaml`
- ✅ Helm hooks for pre/post deployment tasks
- ✅ Built-in rollback: `helm rollback <release> <revision>`
- ✅ Chart dependencies are versioned and tracked
- ✅ Easily extensible (new charts, subcharts)
- ❌ Small learning curve (Helm DSL, chart structure)
- ❌ Two dependency charts means two separate repos to maintain (prometheus-community, grafana)

## Consequences — Dependency Management

- ✅ kube-prometheus-stack as dependency (Prometheus, Grafana, AlertManager included)
- ✅ loki-stack as dependency (Loki, Promtail, MinIO included)
- ✅ Chart versions pinned in Chart.yaml for reproducibility
- ❌ Community chart updates are external; requires helm dependency update

## Alternatives Considered

1. **Kustomize** — Native Kubernetes templating
   - Pros: Lightweight, no new language, built into kubectl
   - Cons: Harder to manage large parametrization; less support for dependencies; less widely adopted than Helm

2. **Raw manifests + envsubst** — Shell-based templating
   - Pros: Simple, no new tools
   - Cons: Brittle (escaping issues), no dependency management, no release tracking

3. **Pulumi** — Infrastructure as Code in Python/TypeScript
   - Pros: Full-featured IaC, can manage entire stack
   - Cons: Steeper learning curve, overkill for Kubernetes templating alone

4. **Kpt** — Declarative KRM tool by Google
   - Pros: KRM-native, no templating language
   - Cons: Newer, smaller ecosystem, less adoption

## Related Decisions

- ADR-005: GitHub Actions CI (Helm lint in pipeline)
- ADR-007: kube-prometheus-stack (pulled in via Helm dependency)
