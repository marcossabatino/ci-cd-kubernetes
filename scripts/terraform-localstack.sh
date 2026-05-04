#!/bin/bash

###############################################################################
# Terraform + Localstack Automation Script
# Purpose: Streamline Terraform operations with Localstack
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
LOCALSTACK_CONTAINER="observability-localstack"
LOCALSTACK_URL="http://localhost:4566"

# Functions
print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"

    local missing=0

    if ! command_exists docker; then
        print_error "Docker not installed"
        missing=1
    else
        print_success "Docker installed: $(docker --version)"
    fi

    if ! command_exists docker-compose; then
        print_error "Docker Compose not installed"
        missing=1
    else
        print_success "Docker Compose installed: $(docker-compose --version)"
    fi

    if ! command_exists terraform; then
        print_error "Terraform not installed"
        missing=1
    else
        print_success "Terraform installed: $(terraform --version | head -1)"
    fi

    if [ $missing -eq 1 ]; then
        print_error "Missing required dependencies"
        exit 1
    fi
}

# Start Localstack
start_localstack() {
    print_header "Starting Localstack"

    cd "$PROJECT_ROOT"

    if docker ps --format '{{.Names}}' | grep -q "^${LOCALSTACK_CONTAINER}$"; then
        print_info "Localstack already running"
        return 0
    fi

    print_info "Starting localstack service from docker-compose..."
    docker-compose up -d localstack

    print_info "Waiting for Localstack to be ready..."
    local max_retries=30
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if curl -s "${LOCALSTACK_URL}/_localstack/health" | grep -q '"services"'; then
            print_success "Localstack is healthy"
            return 0
        fi

        retry_count=$((retry_count + 1))
        echo -n "."
        sleep 1
    done

    print_error "Localstack failed to start within ${max_retries}s"
    docker logs $LOCALSTACK_CONTAINER | tail -20
    exit 1
}

# Initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"

    cd "$TERRAFORM_DIR"

    if [ -d ".terraform" ]; then
        print_info "Terraform already initialized"
        return 0
    fi

    print_info "Running terraform init..."
    terraform init
    print_success "Terraform initialized"
}

# Validate Terraform
validate_terraform() {
    print_header "Validating Terraform Configuration"

    cd "$TERRAFORM_DIR"

    print_info "Running terraform validate..."
    terraform validate
    print_success "Configuration is valid"
}

# Format Terraform
format_terraform() {
    print_header "Formatting Terraform Files"

    cd "$TERRAFORM_DIR"

    print_info "Running terraform fmt..."
    terraform fmt -recursive
    print_success "Files formatted"
}

# Plan Terraform
plan_terraform() {
    print_header "Planning Terraform Deployment"

    cd "$TERRAFORM_DIR"

    print_info "Running terraform plan..."
    terraform plan -var-file="environments/dev.tfvars" -out=tfplan
    print_success "Plan saved to tfplan"
}

# Apply Terraform
apply_terraform() {
    print_header "Applying Terraform Configuration"

    cd "$TERRAFORM_DIR"

    if [ ! -f "tfplan" ]; then
        print_error "No plan file found. Run plan first."
        exit 1
    fi

    print_warning "About to create resources in Localstack"
    read -p "Continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cancelled"
        return 1
    fi

    print_info "Applying terraform..."
    terraform apply tfplan
    print_success "Resources created"
}

# Show Terraform outputs
show_outputs() {
    print_header "Terraform Outputs"

    cd "$TERRAFORM_DIR"

    terraform output
}

# Destroy Terraform resources
destroy_terraform() {
    print_header "Destroying Terraform Resources"

    cd "$TERRAFORM_DIR"

    print_warning "About to destroy all resources"
    read -p "Are you sure? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cancelled"
        return 1
    fi

    print_info "Running terraform destroy..."
    terraform destroy -var-file="environments/dev.tfvars"
    print_success "Resources destroyed"
}

# Stop Localstack
stop_localstack() {
    print_header "Stopping Localstack"

    cd "$PROJECT_ROOT"

    print_info "Stopping localstack..."
    docker-compose down localstack
    print_success "Localstack stopped"
}

# Full workflow
full_workflow() {
    check_dependencies
    start_localstack
    init_terraform
    validate_terraform
    format_terraform
    plan_terraform
    apply_terraform
    show_outputs
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    check       Check dependencies
    start       Start Localstack
    init        Initialize Terraform
    validate    Validate Terraform configuration
    format      Format Terraform files
    plan        Plan Terraform deployment
    apply       Apply Terraform configuration
    outputs     Show Terraform outputs
    destroy     Destroy Terraform resources
    stop        Stop Localstack
    all         Full workflow (check → start → init → validate → format → plan → apply → outputs)

Examples:
    $0 all                  # Complete setup
    $0 plan                 # Preview changes
    $0 apply                # Apply changes
    $0 destroy && $0 stop   # Cleanup

EOF
    exit 0
}

# Main
main() {
    local command="${1:-all}"

    case "$command" in
        check)
            check_dependencies
            ;;
        start)
            start_localstack
            ;;
        init)
            init_terraform
            ;;
        validate)
            validate_terraform
            ;;
        format)
            format_terraform
            ;;
        plan)
            start_localstack
            init_terraform
            validate_terraform
            plan_terraform
            ;;
        apply)
            apply_terraform
            ;;
        outputs)
            show_outputs
            ;;
        destroy)
            destroy_terraform
            ;;
        stop)
            stop_localstack
            ;;
        all)
            full_workflow
            ;;
        -h|--help|help)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            ;;
    esac
}

# Run main
main "$@"
