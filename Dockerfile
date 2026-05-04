# Stage 1: Build (copy assets, optimize if needed)
FROM alpine:3.20 AS builder

WORKDIR /build
COPY site/ .

# Could add minification here in future
# RUN apk add --no-cache node npm && npm run build

# Stage 2: Runtime
FROM nginx:alpine

# Update packages to patch vulnerabilities
RUN apk update && apk upgrade --no-cache && \
    rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy site files
COPY --from=builder /build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=5s \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
