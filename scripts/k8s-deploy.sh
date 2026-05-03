#!/bin/bash

# ========================================
# Kubernetes Deployment Script for Observability Portal
# Deploys to minikube with complete observability stack
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
MINIKUBE_PROFILE=${MINIKUBE_PROFILE:-"minikube"}
MINIKUBE_CPUS=${MINIKUBE_CPUS:-"4"}
MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-"8192"}
MINIKUBE_DRIVER=${MINIKUBE_DRIVER:-"qemu"}

# Functions
print_header() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${CYAN}ℹ $1${NC}"
}

# Check prerequisites
print_header "Checking Prerequisites"

if ! command -v minikube &> /dev/null; then
  print_error "minikube is not installed"
  echo "Install from: https://minikube.sigs.k8s.io"
  exit 1
fi
print_success "minikube found: $(minikube version --short)"

if ! command -v kubectl &> /dev/null; then
  print_error "kubectl is not installed"
  exit 1
fi
print_success "kubectl found: $(kubectl version --client --short)"

if [ "$MINIKUBE_DRIVER" = "qemu" ]; then
  if ! command -v qemu-system-x86_64 &> /dev/null; then
    print_error "QEMU is not installed"
    echo "Install: sudo apt install qemu-system-x86-64 qemu-utils"
    exit 1
  fi
  print_success "QEMU found: $(qemu-system-x86_64 --version | head -1)"
fi

# Start minikube
print_header "Starting Minikube"

if minikube profile list | grep -q "^$MINIKUBE_PROFILE"; then
  print_info "Profile '$MINIKUBE_PROFILE' already exists"
else
  print_info "Creating new profile '$MINIKUBE_PROFILE'"
fi

echo "Starting minikube with:"
echo "  CPUs: $MINIKUBE_CPUS"
echo "  Memory: ${MINIKUBE_MEMORY}MB"
echo "  Driver: $MINIKUBE_DRIVER"

minikube -p "$MINIKUBE_PROFILE" start \
  --cpus="$MINIKUBE_CPUS" \
  --memory="$MINIKUBE_MEMORY" \
  --driver="$MINIKUBE_DRIVER" \
  --addons=ingress \
  --addons=metrics-server \
  --addons=default-storageclass

print_success "Minikube started"

# Setup kubectl context
print_header "Setting Kubernetes Context"

kubectl config use-context "$MINIKUBE_PROFILE"
print_success "Using context: $MINIKUBE_PROFILE"

# Build image in minikube
print_header "Building Docker Image in Minikube"

eval $(minikube -p "$MINIKUBE_PROFILE" docker-env)
print_info "Using minikube Docker daemon"

echo "Building image..."
docker build -t observability-site:latest .
print_success "Image built successfully"

# Create namespace
print_header "Creating Kubernetes Namespace"

kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
print_success "Namespace 'observability' ready"

# Apply Kubernetes manifests
print_header "Applying Kubernetes Manifests"

echo "Order of application:"
echo "  1. ConfigMaps"
echo "  2. Deployments"
echo "  3. Services"
echo "  4. Ingress"
echo "  5. HPA"

# Apply each manifest
for manifest in kubernetes/configmap.yaml kubernetes/deployment.yaml kubernetes/service.yaml kubernetes/ingress.yaml kubernetes/hpa.yaml; do
  if [ -f "$manifest" ]; then
    echo "Applying $manifest..."
    kubectl apply -f "$manifest"
    print_success "Applied $(basename $manifest)"
  fi
done

# Wait for deployments
print_header "Waiting for Deployments"

echo "Waiting for observability-site deployment..."
kubectl rollout status deployment/observability-site -n observability --timeout=300s
print_success "Deployment ready"

echo "Waiting for Prometheus deployment..."
kubectl rollout status deployment/prometheus -n observability --timeout=60s || print_warning "Prometheus taking longer"

echo "Waiting for Grafana deployment..."
kubectl rollout status deployment/grafana -n observability --timeout=60s || print_warning "Grafana taking longer"

# Get pod status
print_header "Pod Status"

kubectl get pods -n observability -o wide

# Show services
print_header "Services"

kubectl get svc -n observability

# Get Ingress info
print_header "Ingress Configuration"

kubectl get ingress -n observability -o wide

# Setup /etc/hosts entries (optional)
print_header "Setting up /etc/hosts entries"

MINIKUBE_IP=$(minikube -p "$MINIKUBE_PROFILE" ip)
print_info "Minikube IP: $MINIKUBE_IP"

echo "Add these to your /etc/hosts:"
echo "  $MINIKUBE_IP observability.local"
echo "  $MINIKUBE_IP prometheus.observability.local"
echo "  $MINIKUBE_IP grafana.observability.local"

# Try to add to /etc/hosts (requires sudo)
if grep -q "observability.local" /etc/hosts 2>/dev/null; then
  print_success "/etc/hosts already updated"
else
  print_warning "/etc/hosts not updated (requires sudo)"
  echo "Run: echo '$MINIKUBE_IP observability.local' | sudo tee -a /etc/hosts"
fi

# Port forwarding alternative
print_header "Port Forwarding (Alternative to Ingress)"

echo "If Ingress doesn't work, use port-forward:"
echo ""
echo "  kubectl port-forward -n observability svc/observability-site-svc 8080:80"
echo "  kubectl port-forward -n observability svc/prometheus-svc 9090:9090"
echo "  kubectl port-forward -n observability svc/grafana-svc 3000:3000"

# Get dashboard info
print_header "Access Information"

echo ""
echo -e "${CYAN}Website:${NC}"
echo "  http://observability.local (via Ingress)"
echo "  OR: kubectl port-forward -n observability svc/observability-site-svc 8080:80"
echo "  Then: http://localhost:8080"
echo ""
echo -e "${CYAN}Prometheus:${NC}"
echo "  http://prometheus.observability.local (via Ingress)"
echo "  OR: kubectl port-forward -n observability svc/prometheus-svc 9090:9090"
echo "  Then: http://localhost:9090"
echo ""
echo -e "${CYAN}Grafana:${NC}"
echo "  http://grafana.observability.local (via Ingress)"
echo "  OR: kubectl port-forward -n observability svc/grafana-svc 3000:3000"
echo "  Then: http://localhost:3000 (admin/admin)"
echo ""

# Show useful commands
print_header "Useful kubectl Commands"

echo "View pods:"
echo "  kubectl get pods -n observability"
echo "  kubectl get pods -n observability -w  # Watch"
echo ""
echo "View logs:"
echo "  kubectl logs -n observability deployment/observability-site -f"
echo "  kubectl logs -n observability pod/observability-site-xxxx -f"
echo ""
echo "Describe resources:"
echo "  kubectl describe deployment observability-site -n observability"
echo "  kubectl describe svc observability-site-svc -n observability"
echo ""
echo "Execute commands in pod:"
echo "  kubectl exec -it <pod-name> -n observability -- /bin/sh"
echo ""
echo "Scale deployment:"
echo "  kubectl scale deployment observability-site --replicas=5 -n observability"
echo ""
echo "Delete all:"
echo "  kubectl delete namespace observability"
echo ""

# Show Dashboard
print_header "Minikube Dashboard"

echo "Open Minikube Dashboard:"
echo "  minikube -p $MINIKUBE_PROFILE dashboard"
echo ""

# Final success message
echo ""
print_success "Kubernetes deployment completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Wait for all pods to be Ready (kubectl get pods -n observability -w)"
echo "  2. Configure /etc/hosts with Minikube IP"
echo "  3. Access services via Ingress or port-forward"
echo "  4. Generate traffic: for i in {1..100}; do curl http://observability.local/; done"
echo "  5. View metrics in Prometheus and Grafana"
echo ""
