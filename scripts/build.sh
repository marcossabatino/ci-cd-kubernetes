#!/bin/bash

# ========================================
# Build Script for Observability Site
# ========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check prerequisites
print_header "Checking Prerequisites"

if ! command -v docker &> /dev/null; then
  print_error "Docker is not installed"
  exit 1
fi
print_success "Docker found: $(docker --version)"

if ! command -v docker-compose &> /dev/null; then
  print_error "Docker Compose is not installed"
  exit 1
fi
print_success "Docker Compose found: $(docker-compose --version)"

# Build Docker image
print_header "Building Docker Image"

TIMESTAMP=$(date +%s)
IMAGE_NAME="observability-site"
IMAGE_TAG="latest"
IMAGE_TAG_TIMESTAMP="${IMAGE_NAME}:${TIMESTAMP}"

echo "Building ${IMAGE_NAME}:${IMAGE_TAG}..."
docker build \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  --tag "${IMAGE_TAG_TIMESTAMP}" \
  --label "built.at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --label "git.commit=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
  .

print_success "Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
print_success "Tagged as: ${IMAGE_TAG_TIMESTAMP}"

# Verify image
print_header "Verifying Image"

IMAGE_SIZE=$(docker images "${IMAGE_NAME}" --format "{{.Size}}")
print_success "Image size: ${IMAGE_SIZE}"

# Quick test: run container briefly
print_header "Testing Image"

echo "Starting temporary container..."
CONTAINER_ID=$(docker run -d --rm -p 9999:80 "${IMAGE_NAME}:${IMAGE_TAG}")

sleep 2

if curl -sf http://localhost:9999/health > /dev/null 2>&1; then
  print_success "Health check passed"
else
  print_warning "Health check failed, but image may still work"
fi

if curl -sf http://localhost:9999/ | grep -q "Observability"; then
  print_success "Home page loads correctly"
else
  print_warning "Could not verify home page content"
fi

docker stop "${CONTAINER_ID}" > /dev/null 2>&1 || true

# Summary
print_header "Build Summary"

echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Size: ${IMAGE_SIZE}"
echo "Built at: $(date)"
echo ""
echo "Next steps:"
echo "  1. Run locally:  docker run -p 8080:80 ${IMAGE_NAME}:${IMAGE_TAG}"
echo "  2. With stack:   docker-compose up -d"
echo "  3. Push to registry: docker push <registry>/${IMAGE_NAME}:${IMAGE_TAG}"

print_success "Build completed successfully!"
