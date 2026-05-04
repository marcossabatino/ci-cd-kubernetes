# ADR-007: Community Helm Charts for Observability Stack

**Status**: Accepted

## Context

Portfolio should demonstrate observability (logs, metrics, traces) via Prometheus, Grafana, and Loki. These are industry-standard tools requiring:
- Prometheus: time-series database + scrape configs + alert rules
- Grafana: visualization server + datasource config + dashboards
- Loki: log aggregation + Promtail DaemonSet + log shipper config

Can either:
- Write raw Kubernetes manifests (100+ lines, error-prone)
- Use community Helm charts (battle-tested, production configurations)

## Decision

Use **community Helm charts** as dependencies in the `monitoring/` chart:
1. **kube-prometheus-stack** (Prometheus community) — Prometheus, Grafana, AlertManager, kube-state-metrics
2. **loki-stack** (Grafana community) — Loki, Promtail, Minio

These are pulled via `helm dependency update` in Chart.yaml.

## Rationale

1. **Battle-tested**: kube-prometheus-stack has 10,000+ GitHub stars; used by thousands of production clusters.
2. **Best practices**: Community maintainers have already solved edge cases, security, performance tuning.
3. **Zero reinvention**: No need to write Prometheus scrape configs, Grafana provisioning, Alertmanager rules from scratch.
4. **Operator pattern**: kube-prometheus-stack includes Prometheus Operator for declarative ServiceMonitor/PrometheusRule management.
5. **Dependencies**: loki-stack automatically includes Promtail DaemonSet, Minio storage; no manual coordination needed.
6. **Upgrades**: Charts are versioned; easy to pin versions and upgrade when needed.
7. **Dashboards included**: Grafana dashboards for node, pod, and cluster metrics are pre-built.

## Consequences

- ✅ Production-grade configuration (no shortcuts)
- ✅ Active community support (issues, PRs, releases)
- ✅ Automatic provisioning (ServiceMonitor, PrometheusRule via chart hooks)
- ✅ High availability ready (leader election, remote storage support)
- ✅ Pre-built dashboards (Nginx, Kubernetes, logs)
- ✅ Alert rules included (website down, high error rate, high latency)
- ❌ Learning curve: kube-prometheus-stack has 300+ configuration options
- ❌ Dependency on external repos (prometheus-community, grafana)
- ❌ Helm dependency updates required (helm dependency update)

## Consequences — Architecture

- ✅ Prometheus Operator manages Prometheus custom resources (ServiceMonitor, PrometheusRule)
- ✅ Promtail DaemonSet runs on every node, ships logs to Loki
- ✅ Grafana provisioned with datasources (Prometheus, Loki) via ConfigMap
- ✅ Custom dashboards added via ConfigMap (Nginx Metrics, Kubernetes Pods, Logs, Cluster Overview)
- ✅ Nginx exporter scrapes nginx metrics (requests, latency, connections)
- ✅ Ingress for Grafana/Prometheus (dev: port-forward; prod: DNS)
- ✅ 6 alert rules (website down, high error rate, high latency, high memory, unusual traffic, no traffic)

## Alternatives Considered

1. **Custom manifests** — Write all Prometheus/Grafana configs from scratch
   - Pros: Full control, minimal dependencies
   - Cons: 300+ lines of YAML, error-prone, missing edge cases, no community support

2. **Datadog** — Managed observability platform
   - Pros: SaaS (no ops), powerful features, support included
   - Cons: Paid ($$), closed ecosystem, not suitable for learning portfolio

3. **New Relic** — Managed APM platform
   - Pros: Easy setup, full-stack monitoring
   - Cons: Paid, closed ecosystem, overkill for this portfolio

4. **Victoria Metrics** — High-performance Prometheus alternative
   - Pros: Better performance and compression than Prometheus
   - Cons: Less ecosystem support than Prometheus; Helm chart less mature

5. **ELK Stack (Elasticsearch/Logstash/Kibana)** — For logs
   - Pros: Powerful log analysis
   - Cons: Heavier than Loki, requires more infrastructure, overkill for this portfolio

6. **Splunk** — Enterprise observability platform
   - Pros: Powerful, mature
   - Cons: Expensive, closed ecosystem, not educational

## Related Decisions

- ADR-004: Helm parametrization (monitoring is a Helm chart with dependencies)
- ADR-003: Minikube + QEMU (kube-prometheus-stack has pre-built values for Minikube)
