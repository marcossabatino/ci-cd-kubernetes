.PHONY: help build docker-up docker-down docker-logs \
        k8s-deploy k8s-down k8s-logs k8s-scale k8s-shell \
        test-site test-perf clean

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)Observability Portal — Make Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# ========================================
# Docker Commands
# ========================================

build: ## Build Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	./scripts/build.sh

docker-up: build ## Start services with docker-compose
	@echo "$(BLUE)Starting docker-compose stack...$(NC)"
	docker compose up -d
	@echo "$(GREEN)✓ Stack started$(NC)"
	@echo ""
	@echo "Access:"
	@echo "  Website:   http://localhost:8080"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana:    http://localhost:3000 (admin/admin)"

docker-down: ## Stop docker-compose services
	@echo "$(BLUE)Stopping services...$(NC)"
	docker compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

docker-logs: ## View docker-compose logs
	docker compose logs -f $(service)

docker-ps: ## Show running containers
	docker compose ps

# ========================================
# Kubernetes Commands
# ========================================

k8s-deploy: ## Deploy to Kubernetes (minikube)
	@echo "$(BLUE)Deploying to Kubernetes...$(NC)"
	chmod +x scripts/k8s-deploy.sh
	./scripts/k8s-deploy.sh

k8s-down: ## Remove all Kubernetes resources
	@echo "$(YELLOW)Deleting namespace observability...$(NC)"
	kubectl delete namespace observability --ignore-not-found
	@echo "$(GREEN)✓ Resources deleted$(NC)"

k8s-status: ## Show Kubernetes status
	@echo "$(BLUE)Namespace: observability$(NC)"
	@kubectl get ns observability -o wide 2>/dev/null || echo "Namespace not found"
	@echo ""
	@echo "$(BLUE)Deployments:$(NC)"
	@kubectl get deployments -n observability -o wide 2>/dev/null || echo "No deployments"
	@echo ""
	@echo "$(BLUE)Pods:$(NC)"
	@kubectl get pods -n observability -o wide 2>/dev/null || echo "No pods"
	@echo ""
	@echo "$(BLUE)Services:$(NC)"
	@kubectl get svc -n observability -o wide 2>/dev/null || echo "No services"
	@echo ""
	@echo "$(BLUE)Ingress:$(NC)"
	@kubectl get ingress -n observability -o wide 2>/dev/null || echo "No ingress"
	@echo ""
	@echo "$(BLUE)HPA:$(NC)"
	@kubectl get hpa -n observability 2>/dev/null || echo "No HPA"

k8s-logs: ## View Kubernetes logs
	@read -p "Pod name (or leave empty for observability-site): " POD; \
	if [ -z "$$POD" ]; then POD="deployment/observability-site"; fi; \
	kubectl logs -f -n observability $$POD

k8s-shell: ## Get shell access to a pod
	@read -p "Pod name (or leave empty for observability-site): " POD; \
	if [ -z "$$POD" ]; then POD=$$(kubectl get pods -n observability -o jsonpath='{.items[0].metadata.name}'); fi; \
	kubectl exec -it -n observability $$POD -- /bin/sh

k8s-scale: ## Scale a deployment
	@read -p "Deployment name (default: observability-site): " DEPLOY; \
	DEPLOY=$${DEPLOY:-observability-site}; \
	read -p "Number of replicas: " REPLICAS; \
	kubectl scale deployment $$DEPLOY --replicas=$$REPLICAS -n observability

k8s-describe: ## Describe a resource
	@read -p "Resource type (pod/deployment/service): " TYPE; \
	read -p "Resource name: " NAME; \
	kubectl describe $$TYPE $$NAME -n observability

k8s-port-forward: ## Start port forwarding
	@echo "Starting port forwarding..."
	@echo "Website: http://localhost:8080"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000"
	@echo ""
	(kubectl port-forward -n observability svc/observability-site-svc 8080:80 &)
	(kubectl port-forward -n observability svc/prometheus-svc 9090:9090 &)
	(kubectl port-forward -n observability svc/grafana-svc 3000:3000 &)
	@echo "$(GREEN)✓ Port forwarding active$(NC)"
	@wait

# ========================================
# Testing Commands
# ========================================

test-site: ## Test site accessibility
	@echo "$(BLUE)Testing site...$(NC)"
	@curl -s -w "Status: %{http_code}\n" http://localhost:8080/health
	@curl -s -w "Status: %{http_code}\n" http://localhost:8080/

test-perf: ## Performance test (100 parallel requests)
	@echo "$(BLUE)Running performance test...$(NC)"
	@echo "100 parallel requests to http://localhost:8080"
	@time (for i in {1..100}; do curl -s http://localhost:8080/ > /dev/null & done; wait)
	@echo "$(GREEN)✓ Test complete$(NC)"

test-load: ## Load test with increasing concurrency
	@echo "$(BLUE)Running load test...$(NC)"
	@for conc in 10 50 100; do \
		echo "Concurrency: $$conc"; \
		time (for i in $$(seq 1 $$conc); do curl -s http://localhost:8080/ > /dev/null & done; wait); \
	done

# ========================================
# Utility Commands
# ========================================

minikube-status: ## Show minikube status
	minikube status

minikube-ip: ## Get minikube IP
	@echo "Minikube IP: $$(minikube ip)"

minikube-dashboard: ## Open minikube dashboard
	minikube dashboard

minikube-logs: ## View minikube logs
	minikube logs

clean: ## Clean up all (docker + kubernetes)
	@echo "$(YELLOW)Cleaning up...$(NC)"
	make docker-down
	make k8s-down
	docker system prune -f
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

# ========================================
# Development Commands
# ========================================

dev-docker: ## Development: Docker compose with live updates
	docker compose up --build

dev-k8s-watch: ## Development: Watch Kubernetes resources
	@watch -n 2 'kubectl get all -n observability'

dev-k8s-logs-watch: ## Development: Watch all logs
	kubectl logs -f -n observability deployment/observability-site &
	kubectl logs -f -n observability deployment/prometheus &
	kubectl logs -f -n observability deployment/grafana &
	wait

# ========================================
# Info Commands
# ========================================

info-docker: ## Show Docker info
	@echo "$(BLUE)Docker Information:$(NC)"
	@docker version --format "Client: {{.Client.Version}} | Server: {{.Server.Version}}"
	@docker compose version
	@docker images observability-site

info-k8s: ## Show Kubernetes info
	@echo "$(BLUE)Kubernetes Information:$(NC)"
	@kubectl version --short
	@echo "Minikube: $$(minikube version --short)"
	@echo "Minikube IP: $$(minikube ip)"
	@echo "Minikube Driver: $$(minikube config view driver)"

info-all: info-docker info-k8s ## Show all info

# ========================================
# Default targets
# ========================================

.PHONY: all
all: build docker-up ## Build and start everything
