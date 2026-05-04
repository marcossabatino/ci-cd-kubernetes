# GitHub Actions Workflows

CI/CD Pipelines for Observability Site using GitHub Actions.

## 📋 Workflows Overview

### 1. **CI Workflow** (`ci.yml`)
Runs on: Push to any branch + Pull Requests to main/develop

**Jobs:**
- `validate-html` - Validate HTML syntax
- `lint-css` - Lint CSS files
- `build-docker` - Build Docker image
- `test-build` - Run image and test endpoints
- `security-scan` - Trivy vulnerability scanning
- `ci-summary` - Overall status report

**Triggers:**
- Any push with changes to: `site/`, `Dockerfile`, `nginx.conf`
- Pull requests to `main` or `develop`

**Outputs:**
- ✅ All HTML/CSS validated
- ✅ Docker image built successfully
- ✅ Container tests passed (health, homepage, endpoints)
- ✅ Security scan completed

---

### 2. **CD Workflow** (`cd.yml`)
Runs on: Push to main/develop branches + Tags (v*.*.*)

**Jobs:**
- `build-and-push` - Build and push image to GitHub Container Registry
- `create-release` - Create GitHub Release with image details
- `notify` - Send notification

**Image Tags:**
- `branch-<sha>` - For branch pushes (e.g., `main-abc123def`)
- `v1.2.3` - For version tags
- `latest` - For main branch
- `develop-<sha>` - For develop branch

**Outputs:**
- ✅ Image pushed to GHCR
- ✅ GitHub Release created (for tags)
- ✅ Image digest available for traceability

---

### 3. **Deploy Workflow** (`deploy.yml`)
Runs on: Push to main/develop + Manual trigger + Tags

**Jobs:**
- `setup` - Determine environment and parameters
- `helm-deploy` - Helm validation and deployment
- `post-deploy-tests` - Smoke tests
- `notify-deployment` - Status report

**Environment Routing:**
- `main` branch → Production
- `develop` branch → Development
- `v*.*.*` tags → Production
- Manual workflow_dispatch → Configurable

**Outputs:**
- ✅ Helm chart validated
- ✅ Manifests rendered
- ✅ Dry-run output
- ✅ Deployment artifact available

---

## 🔐 Required Secrets

### For CD Pipeline

No additional secrets needed! Uses built-in `GITHUB_TOKEN` for:
- ✅ GitHub Container Registry (GHCR) authentication
- ✅ Release creation
- ✅ Artifact upload

### For Deploy Pipeline (Optional)

For actual cluster deployment, add:

```bash
# Base64-encoded kubeconfig file
KUBECONFIG=<base64-encoded-kubeconfig>

# Or use OIDC federation (recommended):
# Configure in: Settings → Security → Secrets and variables → Actions
```

**How to add secrets:**
1. Go to: `Settings` → `Secrets and variables` → `Actions`
2. Click `New repository secret`
3. Name: `KUBECONFIG`
4. Value: `echo $(cat ~/.kube/config) | base64`

---

## 🚀 How Workflows Trigger

### CI Triggers
```
Any branch → Push with site/ changes
  ↓
ci.yml runs
  ↓
Lint HTML/CSS → Build Docker → Test container → Security scan
```

### CD Triggers
```
main/develop → Push
  ↓
cd.yml runs
  ↓
Build & push image → Create release (if tag)
```

### Deploy Triggers
```
main/develop → Push OR Manual trigger
  ↓
deploy.yml runs
  ↓
Helm lint → Render templates → Dry-run → Post-deploy tests
```

---

## 📊 Viewing Workflow Status

### In GitHub UI
1. Go to: `Actions` tab
2. Select workflow in left sidebar
3. Click run to see logs
4. View individual job output

### In Terminal
```bash
# List workflow runs
gh run list

# View specific run
gh run view <run-id> -v

# Watch specific workflow
gh run watch <run-id> --exit-status

# View logs
gh run view <run-id> --log
```

---

## 🧪 Testing Workflows Locally

### Test with act (GitHub Actions locally)
```bash
# Install act
# macOS: brew install act
# Linux: https://github.com/nektos/act

# Run CI workflow locally
act push -j validate-html

# Run all CI jobs
act push

# Run with specific branch context
act -e event.json
```

### Test Helm templates locally
```bash
# Validate
helm lint helm/observability-site/

# Render
helm template observability-site helm/observability-site/ \
  -f helm/observability-site/values-prod.yaml

# Dry-run deploy
helm upgrade observability-site helm/observability-site/ \
  --dry-run --debug
```

---

## 🔄 Workflow Patterns

### Pattern 1: Push to develop
```
Push → CI (lint/build) → If pass → CD (push image) → Deploy (dev env)
```

### Pattern 2: Create release tag
```
git tag v1.0.0
git push --tags
  ↓
CI (validate)
  ↓
CD (push as v1.0.0)
  ↓
Deploy to prod (via manual approval)
```

### Pattern 3: Manual deploy
```
GitHub UI → Actions → Deploy → Run workflow
  ↓
Select environment (dev/prod)
  ↓
Deploy with Helm
```

---

## 📈 Artifact Management

Workflows create artifacts:

### CI Artifacts
- Docker image (cached in GHA)
- Built in: `docker.io` cache

### CD Artifacts
- Published image in: `ghcr.io/marcossabatino/ci-cd-kubernetes`
- GitHub Release (for tags)

### Deploy Artifacts
- Rendered Helm templates: `helm-rendered-manifests-[env].zip`
- Available in: `Actions` → Run details → Artifacts

---

## 🐛 Troubleshooting

### CI fails on HTML validation
```bash
# Check which file failed
gh run view <run-id> --log | grep "html-validate"

# Validate locally
html-validate site/index.html
```

### CD push fails
```bash
# Check authentication
gh auth status

# Re-authenticate
gh auth login
```

### Deploy fails
```bash
# Check kubeconfig
echo $KUBECONFIG | base64 -d | kubectl config view

# Test helm locally
helm template observability-site helm/observability-site/ --debug
```

---

## 📝 Modifying Workflows

### Add new job to CI
Edit `.github/workflows/ci.yml`:
```yaml
  new-job:
    runs-on: ubuntu-latest
    needs: [validate-html]  # Dependencies
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running custom job"
```

### Change deploy environment
Edit `.github/workflows/deploy.yml`:
```yaml
on:
  push:
    branches: [main, develop, staging]  # Add branch
```

### Modify image registry
Edit `cd.yml`:
```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: myname/observability-site
```

---

## 🎯 Best Practices

✅ **Do:**
- Run CI on all branches (catch errors early)
- Run CD only on main/develop (prevent accidents)
- Use semantic versioning for releases (v1.0.0)
- Pin action versions (e.g., `actions/checkout@v4`)
- Use concurrency groups (prevent overlapping deployments)
- Add environment approvals for prod

❌ **Don't:**
- Deploy from feature branches
- Use `latest` image tag for prod (use version tags)
- Store secrets in code/workflow files
- Skip tests/scans
- Use admin tokens for deployments

---

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
- [Act - Local Testing](https://github.com/nektos/act)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)

---

## 📋 Workflow Status Badges

Add to README.md:

```markdown
![CI Workflow](https://github.com/marcossabatino/ci-cd-kubernetes/actions/workflows/ci.yml/badge.svg)
![CD Workflow](https://github.com/marcossabatino/ci-cd-kubernetes/actions/workflows/cd.yml/badge.svg)
![Deploy Workflow](https://github.com/marcossabatino/ci-cd-kubernetes/actions/workflows/deploy.yml/badge.svg)
```

---

## ✨ Summary

| Workflow | Trigger | Purpose | Output |
|----------|---------|---------|--------|
| CI | Any push | Validate & test | Docker image cached |
| CD | main/develop push | Build & push | Image in GHCR |
| Deploy | Tag push | Deploy to K8s | Helm charts applied |

All workflows are production-ready and follow GitHub Actions best practices.
