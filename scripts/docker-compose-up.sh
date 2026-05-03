#!/bin/bash

# ========================================
# Start Observability Stack with Docker Compose
# ========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Parse arguments
ACTION=${1:-up}
DETACH=${2:--d}

case "$ACTION" in
  up)
    print_header "Starting Observability Stack"

    # Build first
    echo "Building Docker image..."
    ./scripts/build.sh

    echo ""
    print_header "Starting services with docker-compose"

    docker-compose ${DETACH} up

    if [ "$DETACH" = "-d" ]; then
      sleep 3
      print_header "Services Started"

      echo -e "${GREEN}Observability Portal${NC}"
      echo "  Website:    http://localhost:8080"
      echo "  Health:     http://localhost:8080/health"
      echo ""

      echo -e "${GREEN}Observability Stack${NC}"
      echo "  Prometheus: http://localhost:9090"
      echo "  Grafana:    http://localhost:3000 (admin/admin)"
      echo "  Loki:       http://localhost:3100"
      echo ""

      echo -e "${YELLOW}Useful Commands:${NC}"
      echo "  View logs:      docker-compose logs -f website"
      echo "  Stop services:  docker-compose down"
      echo "  Clean up:       docker-compose down -v"
      echo "  Status:         docker-compose ps"
      echo ""

      print_success "Stack is ready!"
    fi
    ;;

  down)
    print_header "Stopping Services"
    docker-compose down
    print_success "Services stopped"
    ;;

  logs)
    SERVICE=${2:-website}
    docker-compose logs -f "$SERVICE"
    ;;

  restart)
    print_header "Restarting Services"
    docker-compose restart
    print_success "Services restarted"
    ;;

  ps)
    docker-compose ps
    ;;

  clean)
    print_header "Cleaning Up"
    print_warning "Removing all containers and volumes..."
    docker-compose down -v
    print_success "Cleanup complete"
    ;;

  *)
    echo "Usage: $0 {up|down|logs|restart|ps|clean} [options]"
    echo ""
    echo "Commands:"
    echo "  up [DETACH]     - Start all services (default: -d for detached)"
    echo "  down            - Stop all services"
    echo "  logs [SERVICE]  - View logs (default: website)"
    echo "  restart         - Restart all services"
    echo "  ps              - Show running containers"
    echo "  clean           - Stop and remove all containers/volumes"
    echo ""
    echo "Examples:"
    echo "  $0 up          # Start in background"
    echo "  $0 up ''       # Start in foreground"
    echo "  $0 logs prometheus"
    echo "  $0 down"
    exit 1
    ;;
esac
