# ADR-003: Minikube with QEMU Driver for Local Kubernetes

**Status**: Accepted

## Context

Need a local Kubernetes environment for development and testing. Primary options include:
- Minikube (with various drivers: Docker, QEMU, VirtualBox, Hyperkit)
- Kind (Kubernetes in Docker)
- k3s (lightweight Kubernetes)
- Docker Desktop Kubernetes (macOS/Windows only)

## Decision

Use **Minikube with QEMU driver** for local Kubernetes development.

## Rationale

1. **No Docker-in-Docker complexity**: QEMU driver runs Minikube in a proper VM, avoiding socket mounting and complexity of Kind.
2. **Better resource isolation**: QEMU provides true VM isolation. Running Kubernetes in Docker (Kind) introduces container-in-container complications.
3. **Native Linux support**: QEMU driver works seamlessly on Linux without Docker daemon setup.
4. **Easy startup/cleanup**: `minikube start` and `minikube delete` manage the full lifecycle.
5. **Kubectl compatibility**: Uses standard kubectl; no learning curve.
6. **Addon support**: Minikube addons provide Ingress, metrics-server, storage provisioning out-of-the-box.
7. **Sufficient for development**: Single-node cluster is adequate for development, testing, and demonstrating Kubernetes patterns; not intended for production-scale workloads.

## Consequences

- ✅ Isolated VM environment (cleaner than Docker-in-Docker)
- ✅ Proper kubectl experience (matches production Kubernetes)
- ✅ Easy to reset: `minikube delete` and start fresh
- ✅ Addon ecosystem (ingress, monitoring, metrics already available)
- ✅ No Docker socket mounting complexity
- ❌ Requires QEMU/KVM installed (not available on all systems)
- ❌ Single-node cluster (but sufficient for learning, not a blocker)
- ❌ VM overhead (~2GB memory minimum)

## Alternatives Considered

1. **kind (Kubernetes in Docker)** — K8s clusters in Docker containers
   - Pros: No VM required, instant startup
   - Cons: Requires Docker socket mounting, container-in-container complexity, addon support is limited

2. **k3s** — Lightweight Kubernetes distribution
   - Pros: Minimal resource usage, perfect for edge
   - Cons: Not a standard Kubernetes distribution; adds learning curve if unfamiliar with k3s specifics

3. **Docker Desktop Kubernetes** — Built-in K8s on macOS/Windows
   - Pros: Zero setup on Mac/Windows
   - Cons: macOS/Windows only; not portable; less control over cluster configuration

4. **VirtualBox driver with Minikube** — Heavier VM driver
   - Pros: Wide compatibility (macOS, Linux, Windows)
   - Cons: Slower than QEMU, more memory overhead, additional VirtualBox daemon

5. **Real AWS EKS (free tier)** — Managed Kubernetes on AWS
   - Pros: Production-realistic
   - Cons: Cost, network latency, requires AWS account; defeats the "local" dev goal

## Related Decisions

- ADR-002: nginx:alpine (small image = faster pull on Minikube)
- ADR-004: Helm for templating (works seamlessly with Minikube)
- ADR-007: kube-prometheus-stack for monitoring (has Minikube preset values)
