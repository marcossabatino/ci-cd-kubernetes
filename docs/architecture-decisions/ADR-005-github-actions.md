# ADR-005: GitHub Actions for CI/CD

**Status**: Accepted

## Context

Need automated CI/CD pipeline for:
- Validating code changes (HTML, CSS linting)
- Building Docker images
- Running security scans
- Publishing images to a registry
- Deploying to Kubernetes

Options include:
- GitHub Actions
- Jenkins
- GitLab CI
- CircleCI
- Drone

## Decision

Use **GitHub Actions** with three separate workflows:
1. **ci.yml** — Continuous Integration (on every push)
2. **cd.yml** — Continuous Deployment (push images to GHCR, create releases)
3. **deploy.yml** — Deploy to Kubernetes (manual trigger + on tags)

## Rationale

1. **Native GitHub integration**: Workflows live in `.github/workflows/`; no external service setup needed.
2. **Free for public repos**: Unlimited free minutes on public GitHub repositories.
3. **GHCR integration**: GitHub Container Registry is built-in; no separate Docker Hub account needed.
4. **Secrets management**: GitHub Secrets are simple and secure.
5. **Status badges**: Build status visible directly on README.
6. **Easy onboarding**: Team already uses GitHub; no new platform to learn.
7. **Marketplace**: 10,000+ pre-built actions (linters, security scanners, cloud SDKs).

## Consequences

- ✅ Zero infrastructure setup
- ✅ Tight GitHub integration (branch protection, PR status checks)
- ✅ Free for public repos (unlimited minutes)
- ✅ Built-in secrets and artifact storage
- ✅ Can trigger workflows from GitHub UI (manual deployment)
- ❌ Limited to GitHub ecosystem (can't use for non-GitHub repos)
- ❌ Actions can be slower than self-hosted CI (shared runners)
- ❌ Verbose YAML syntax (compared to some alternatives)

## Consequences — Security

- ✅ html-validate checks all HTML pages (validates structure)
- ✅ stylelint checks CSS (syntax, standards compliance)
- ✅ Trivy scans Docker image for vulnerabilities (fails on HIGH/CRITICAL)
- ✅ CodeQL static analysis (SARIF upload to GitHub Security tab)
- ✅ GHCR only stores images from passing CI runs
- ✅ Deploy workflow is manual-gated (prevents accidental deployments)

## CI/CD Pipeline Design

### CI Workflow (on every push)
1. HTML validation (html-validate)
2. CSS linting (stylelint)
3. Docker build (buildx multi-stage)
4. Container tests (health check, page load)
5. Trivy security scan (HIGH/CRITICAL vulns fail build)
6. CodeQL SARIF upload

### CD Workflow (on main/develop push or semver tags)
1. Build & push Docker image to GHCR (buildx)
2. Tagging strategy:
   - `branch-<sha>` for branch pushes
   - `v1.0.0` for semver tags
   - `latest` for main branch
3. Create GitHub Release (for semver tags)

### Deploy Workflow (manual + tag-triggered)
1. Helm lint (validate chart syntax)
2. Template render (dry-run)
3. Dry-run against cluster
4. Post-deploy smoke tests

## Alternatives Considered

1. **Jenkins** — Open-source CI/CD server
   - Pros: Full control, self-hosted, plugin ecosystem
   - Cons: Infrastructure overhead, maintenance burden, security patching required

2. **GitLab CI** — Native to GitLab
   - Pros: Powerful YAML syntax, built-in container registry
   - Cons: Requires GitLab (user prefers GitHub); different ecosystem

3. **CircleCI** — SaaS CI/CD
   - Pros: Fast runners, good documentation
   - Cons: Paid (free tier limited); external service; another account to manage

4. **Drone** — Container-native CI/CD
   - Pros: Lightweight, easy self-host
   - Cons: Smaller ecosystem, less adoption, requires separate infrastructure

## Related Decisions

- ADR-002: nginx:alpine (Docker build must be fast and secure)
- ADR-004: Helm parametrization (deploy workflow uses Helm lint + template)
