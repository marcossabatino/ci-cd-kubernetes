# ADR-001: Static HTML Site vs Dynamic Application

**Status**: Accepted

## Context

The portfolio project initially planned to showcase a multi-agent, Node.js/React application demonstrating observability concepts through code examples and interactive features. However, the core goal is to demonstrate **DevOps practices** (containerization, orchestration, CI/CD, infrastructure automation, monitoring), not application architecture.

## Decision

Build a static HTML/CSS/JavaScript website explaining observability concepts (logs, metrics, traces, SRE, architecture) rather than a dynamic Node.js application.

## Rationale

1. **Aligns with portfolio goal**: This is a DevOps portfolio, not an application architecture showcase. The website is just a vehicle to demonstrate the DevOps stack.
2. **Simpler CI/CD**: No build step, no Node.js/npm complexity, no database migrations. CI validates HTML/CSS only.
3. **Faster deployment**: No runtime dependencies. Nginx serves static files—instant startup, minimal attack surface.
4. **Easier scaling**: Static files scale trivially. No session management, no backend bottlenecks.
5. **Lower cost**: Minimal CPU/memory. Fits easily on free tier Kubernetes (Minikube) and AWS (Localstack simulation).
6. **Educational value**: The focus remains on observability concepts and DevOps deployment patterns, not application logic.

## Consequences

- ✅ Reduced complexity in every layer (Docker, Kubernetes, monitoring)
- ✅ Instant page loads, CDN-friendly
- ✅ No runtime errors (HTML/CSS only)
- ❌ No interactive backend features (but not needed for this portfolio)
- ❌ No dynamic data generation (tables, charts rendered at build time would require tooling—not worth adding)

## Alternatives Considered

1. **Node.js/Express backend** — Full-featured web app
   - Pros: More "realistic" for a portfolio
   - Cons: Adds complexity to Docker, K8s, CI/CD, and monitoring; distracts from DevOps focus

2. **React single-page app** — Client-side interactivity
   - Pros: Modern frontend framework experience
   - Cons: Requires build step (Webpack/Vite), npm dependencies, larger Docker image

3. **Hugo/Jekyll static site generator** — Template-driven static site
   - Pros: Reusable components, markdown authoring
   - Cons: Additional build tool; adds complexity to CI pipeline without clear benefit for this scope

## Related Decisions

- ADR-002: nginx:alpine as the web server (optimal for static file serving)
- ADR-005: GitHub Actions CI (validates HTML/CSS, skips runtime testing)
