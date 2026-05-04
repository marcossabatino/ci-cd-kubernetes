# ADR-002: nginx:alpine as Web Server

**Status**: Accepted

## Context

Need a lightweight, secure, and production-ready web server to serve the static observability website. Primary options include nginx, Apache httpd, Caddy, and embedding a Node.js server.

## Decision

Use **nginx:alpine** as the base image for the Docker container, with a multi-stage build reducing the final image size to ~30MB.

## Rationale

1. **Minimal attack surface**: Alpine Linux is 5MB; nginx is 50MB. Combined: ~30MB final image (vs 400MB+ for Node.js).
2. **Security hardening**: Fewer packages = fewer CVEs. Multi-stage build excludes build tools from runtime image.
3. **Native static serving**: Nginx is purpose-built for static files. No overhead from application servers.
4. **Fast startup**: No runtime JIT compilation, no dependency resolution. Pod ready in <1 second.
5. **Industry standard**: Nginx powers 30%+ of the web. Widely understood and battle-tested.
6. **Kubernetes-friendly**: Small image = faster pulls, less storage, faster pod scheduling.
7. **Security headers**: Nginx config includes `X-Frame-Options`, `X-Content-Type-Options`, gzip compression.

## Consequences

- ✅ ~30MB Docker image (vs 400MB for Node.js)
- ✅ <1 second startup time
- ✅ Minimal CPU/memory footprint in Kubernetes
- ✅ Zero runtime vulnerabilities from application runtime
- ✅ Easy to audit and understand (Dockerfile is 20 lines)
- ❌ No dynamic features (but static site design intentional—ADR-001)
- ❌ Nginx configuration must be correct (no fallback error handling)

## Consequences — Security

- ✅ apk upgrade in multi-stage build patches known Alpine vulnerabilities
- ✅ Non-root user runs Nginx (USER nginx)
- ✅ Read-only root filesystem possible (with proper volume mounts)
- ✅ No privilege escalation from application code (Nginx only runs in container user context)

## Alternatives Considered

1. **Apache httpd** — Full-featured web server
   - Pros: Powerful mod system
   - Cons: Heavier (200MB+), more complex config, slower startup

2. **Caddy** — Modern HTTP server with auto-TLS
   - Pros: Zero-config HTTPS, built-in security
   - Cons: Larger Alpine image (~50MB), less familiar to team

3. **Node.js with express** — Application server
   - Pros: Can serve static files + add dynamic endpoints if needed
   - Cons: 400MB image, slower startup, runtime vulnerabilities, defeats the portfolio focus

4. **Python SimpleHTTPServer** — Minimal server
   - Pros: Tiny Python image
   - Cons: Not suitable for production; poor performance; no security headers

## Related Decisions

- ADR-001: Static HTML site (aligns with nginx strength)
- ADR-003: Minikube with QEMU driver (benefits from small image size)
