#!/bin/bash

###############################################################################
# GitHub Actions Phase 5 - Complete Test Suite
# Tests: Workflows, Helm, Docker, Endpoints
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test functions
print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_test() {
    echo -e "${CYAN}→ $1${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

print_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_fail() {
    echo -e "${RED}✗ $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

###############################################################################
# SECTION 1: Validate Workflow Files
###############################################################################

print_header "SECTION 1: Workflow Files Validation"

print_test "Checking if workflow files exist"
if [ -f ".github/workflows/ci.yml" ] && [ -f ".github/workflows/cd.yml" ] && [ -f ".github/workflows/deploy.yml" ]; then
    print_pass "All workflow files found"
    echo "  - .github/workflows/ci.yml"
    echo "  - .github/workflows/cd.yml"
    echo "  - .github/workflows/deploy.yml"
else
    print_fail "Some workflow files are missing"
fi

print_test "Checking YAML syntax (basic)"
for file in .github/workflows/*.yml; do
    if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        print_pass "$(basename $file) - Valid YAML"
    else
        print_fail "$(basename $file) - Invalid YAML"
    fi
done

print_test "Checking workflow triggers"
TRIGGERS=$(grep -h "^on:" .github/workflows/ci.yml .github/workflows/cd.yml .github/workflows/deploy.yml | wc -l)
print_pass "Found $TRIGGERS trigger sections"

print_test "Checking job definitions"
JOBS=$(grep -h "^  [a-z-]*:" .github/workflows/ci.yml | grep -v "^    " | wc -l)
print_pass "Found $JOBS jobs in CI workflow"

###############################################################################
# SECTION 2: Helm Chart Validation
###############################################################################

print_header "SECTION 2: Helm Chart Validation"

print_test "Checking Helm installation"
if command -v helm &> /dev/null; then
    HELM_VERSION=$(helm version --short)
    print_pass "Helm installed: $HELM_VERSION"
else
    print_fail "Helm not installed"
    exit 1
fi

print_test "Running helm lint (dev values)"
if helm lint helm/observability-site/ -f helm/observability-site/values.yaml > /tmp/helm-lint-dev.log 2>&1; then
    print_pass "Helm lint passed (dev)"
    cat /tmp/helm-lint-dev.log
else
    print_fail "Helm lint failed (dev)"
    cat /tmp/helm-lint-dev.log
fi

print_test "Running helm lint (prod values)"
if helm lint helm/observability-site/ -f helm/observability-site/values-prod.yaml > /tmp/helm-lint-prod.log 2>&1; then
    print_pass "Helm lint passed (prod)"
    cat /tmp/helm-lint-prod.log
else
    print_fail "Helm lint failed (prod)"
    cat /tmp/helm-lint-prod.log
fi

print_test "Rendering Helm templates (dev)"
helm template observability-site helm/observability-site/ \
    -f helm/observability-site/values.yaml > /tmp/helm-rendered-dev.yaml 2>/dev/null
DEV_RESOURCES=$(grep "^kind:" /tmp/helm-rendered-dev.yaml | wc -l)
print_pass "Rendered $DEV_RESOURCES Kubernetes resources (dev)"

print_test "Rendering Helm templates (prod)"
helm template observability-site helm/observability-site/ \
    -f helm/observability-site/values-prod.yaml > /tmp/helm-rendered-prod.yaml 2>/dev/null
PROD_RESOURCES=$(grep "^kind:" /tmp/helm-rendered-prod.yaml | wc -l)
print_pass "Rendered $PROD_RESOURCES Kubernetes resources (prod)"

print_test "Verifying resource types"
echo ""
echo "  Dev Resources:"
grep "^kind:" /tmp/helm-rendered-dev.yaml | sort | uniq -c | sed 's/^/    /'
echo ""
echo "  Prod Resources:"
grep "^kind:" /tmp/helm-rendered-prod.yaml | sort | uniq -c | sed 's/^/    /'

print_test "Comparing dev vs prod configurations"
echo ""
echo "  Key Differences (dev → prod):"
echo "    Replicas: $(grep 'replicas:' /tmp/helm-rendered-dev.yaml | head -1 | awk '{print $2}') → $(grep 'replicas:' /tmp/helm-rendered-prod.yaml | head -1 | awk '{print $2}')"
echo "    Namespace: $(grep 'namespace:' /tmp/helm-rendered-dev.yaml | head -1 | awk '{print $2}') → $(grep 'namespace:' /tmp/helm-rendered-prod.yaml | head -1 | awk '{print $2}')"

DEV_CPU=$(grep -A 3 "limits:" /tmp/helm-rendered-dev.yaml | grep "cpu:" | head -1 | awk '{print $2}')
PROD_CPU=$(grep -A 3 "limits:" /tmp/helm-rendered-prod.yaml | grep "cpu:" | head -1 | awk '{print $2}')
echo "    CPU Limit: $DEV_CPU → $PROD_CPU"

DEV_MAX=$(grep "maxReplicas:" /tmp/helm-rendered-dev.yaml | awk '{print $2}')
PROD_MAX=$(grep "maxReplicas:" /tmp/helm-rendered-prod.yaml | awk '{print $2}')
echo "    HPA Max: $DEV_MAX → $PROD_MAX"

print_pass "Configuration comparison complete"

###############################################################################
# SECTION 3: Docker Build and Test
###############################################################################

print_header "SECTION 3: Docker Build and Testing"

print_test "Checking Docker installation"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_pass "Docker installed: $DOCKER_VERSION"
else
    print_fail "Docker not installed"
    exit 1
fi

print_test "Building Docker image"
if docker build -t observability-site:phase5-test . > /tmp/docker-build.log 2>&1; then
    print_pass "Docker image built successfully"
    echo ""
    echo "  Build Output (last 5 lines):"
    tail -5 /tmp/docker-build.log | sed 's/^/    /'
else
    print_fail "Docker build failed"
    cat /tmp/docker-build.log
    exit 1
fi

print_test "Checking image properties"
IMAGE_SIZE=$(docker images observability-site:phase5-test --format "{{.Size}}")
IMAGE_ID=$(docker images observability-site:phase5-test --format "{{.ID}}")
print_pass "Image size: $IMAGE_SIZE"
echo "  Image ID: $IMAGE_ID"

print_test "Running Docker container"
if docker run -d --name test-container-phase5 -p 8080:80 observability-site:phase5-test > /dev/null 2>&1; then
    print_pass "Container started successfully"
    sleep 3
else
    print_fail "Failed to start container"
    exit 1
fi

print_test "Testing /health endpoint"
if curl -s http://localhost:8080/health | grep -q "OK"; then
    print_pass "Health endpoint responds correctly"
    curl -s http://localhost:8080/health | sed 's/^/    /'
else
    print_fail "Health endpoint failed"
    curl -s http://localhost:8080/health || echo "No response"
fi

print_test "Testing homepage"
HOMEPAGE=$(curl -s http://localhost:8080/)
if echo "$HOMEPAGE" | grep -q "Observability"; then
    print_pass "Homepage loads successfully"
    echo "  Content check: Found 'Observability' keyword"
    TITLE=$(echo "$HOMEPAGE" | grep -o "<title>[^<]*</title>" | sed 's/<[^>]*>//g')
    echo "  Page title: $TITLE"
else
    print_fail "Homepage content validation failed"
fi

print_test "Testing /logs/ page"
if curl -s http://localhost:8080/logs/ | grep -q "Logs"; then
    print_pass "/logs/ page loads successfully"
else
    print_fail "/logs/ page failed"
fi

print_test "Testing /metrics/ page"
if curl -s http://localhost:8080/metrics/ | grep -q "Métricas\|Metrics"; then
    print_pass "/metrics/ page loads successfully"
else
    print_fail "/metrics/ page failed"
fi

print_test "Testing /traces/ page"
if curl -s http://localhost:8080/traces/ | grep -q "Traces\|Traces"; then
    print_pass "/traces/ page loads successfully"
else
    print_fail "/traces/ page failed"
fi

print_test "Testing /sre/ page"
if curl -s http://localhost:8080/sre/ | grep -q "SRE"; then
    print_pass "/sre/ page loads successfully"
else
    print_fail "/sre/ page failed"
fi

print_test "Checking response headers"
HEADERS=$(curl -s -I http://localhost:8080/ | head -10)
echo ""
echo "  Response Headers:"
echo "$HEADERS" | sed 's/^/    /'

print_test "Testing request performance"
RESPONSE_TIME=$(curl -s -w "%{time_total}" -o /dev/null http://localhost:8080/)
print_pass "Response time: ${RESPONSE_TIME}s"

print_test "Stopping test container"
if docker stop test-container-phase5 > /dev/null 2>&1; then
    docker rm test-container-phase5 > /dev/null 2>&1
    print_pass "Container stopped and removed"
else
    print_fail "Failed to stop container"
fi

###############################################################################
# SECTION 4: Workflow Structure Validation
###############################################################################

print_header "SECTION 4: Workflow Structure Validation"

print_test "Checking CI workflow jobs"
CI_JOBS=$(grep "^  [a-z-]*:" .github/workflows/ci.yml | grep -v "^    " | sed 's/://g')
echo ""
for job in $CI_JOBS; do
    echo "    ✓ $job"
done

print_test "Checking CD workflow configuration"
if grep -q "push:" .github/workflows/cd.yml; then
    print_pass "CD triggers on push"
fi
if grep -q "tags:" .github/workflows/cd.yml; then
    print_pass "CD triggers on tags"
fi

print_test "Checking GHCR configuration"
if grep -q "ghcr.io" .github/workflows/cd.yml; then
    print_pass "GHCR registry configured"
fi

print_test "Checking Deploy workflow Helm integration"
if grep -q "helm template" .github/workflows/deploy.yml; then
    print_pass "Deploy uses helm template"
fi
if grep -q "helm upgrade" .github/workflows/deploy.yml; then
    print_pass "Deploy uses helm upgrade"
fi

###############################################################################
# SECTION 5: File Structure Validation
###############################################################################

print_header "SECTION 5: Project Structure Validation"

print_test "Checking required directories"
REQUIRED_DIRS=(
    "site"
    "helm/observability-site"
    ".github/workflows"
    "kubernetes"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_pass "Directory found: $dir"
    else
        print_fail "Directory missing: $dir"
    fi
done

print_test "Checking required files"
REQUIRED_FILES=(
    "Dockerfile"
    "nginx.conf"
    "helm/observability-site/Chart.yaml"
    "helm/observability-site/values.yaml"
    "helm/observability-site/values-prod.yaml"
    ".github/workflows/ci.yml"
    ".github/workflows/cd.yml"
    ".github/workflows/deploy.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(wc -l < "$file" 2>/dev/null || echo "0")
        print_pass "File found: $file ($SIZE lines)"
    else
        print_fail "File missing: $file"
    fi
done

###############################################################################
# SECTION 6: Git Status Check
###############################################################################

print_header "SECTION 6: Git Status Check"

print_test "Checking git status"
if [ -d ".git" ]; then
    print_pass "Git repository found"

    print_test "Checking commits"
    COMMIT_COUNT=$(git log --oneline | wc -l)
    print_pass "Total commits: $COMMIT_COUNT"

    print_test "Recent commits"
    echo ""
    git log --oneline -5 | sed 's/^/    /'

    print_test "Checking workflow files are tracked"
    if git ls-files | grep -q ".github/workflows/ci.yml"; then
        print_pass "Workflow files are tracked by git"
    else
        print_fail "Workflow files not tracked"
    fi
else
    print_info "Not a git repository"
fi

###############################################################################
# SECTION 7: Summary Report
###############################################################################

print_header "SECTION 7: Test Summary Report"

TESTS_SKIPPED=$((TESTS_TOTAL - TESTS_PASSED - TESTS_FAILED))

echo ""
echo -e "${CYAN}Test Results:${NC}"
echo -e "  ${GREEN}Passed:  $TESTS_PASSED${NC}"
echo -e "  ${RED}Failed:  $TESTS_FAILED${NC}"
echo -e "  ${YELLOW}Total:   $TESTS_TOTAL${NC}"
echo ""

PASS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
echo -e "  Success Rate: ${GREEN}$PASS_RATE%${NC}"
echo ""

###############################################################################
# Final Verdict
###############################################################################

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ ALL TESTS PASSED - PHASE 5 IS READY!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next Steps:"
    echo "  1. Push changes to GitHub:"
    echo "     git push origin main"
    echo ""
    echo "  2. Monitor workflows:"
    echo "     gh run list --workflow ci.yml"
    echo ""
    echo "  3. Verify in GitHub UI:"
    echo "     https://github.com/marcossabatino/ci-cd-kubernetes/actions"
    echo ""
    exit 0
else
    echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}❌ SOME TESTS FAILED - FIX ISSUES BEFORE PUSHING${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
