# Stage 1: Dependencies
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci --only=production --frozen-lockfile

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV LOG_LEVEL=info
ENV PORT=3001

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

EXPOSE 3001

HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=10s \
  CMD wget --quiet --tries=1 --spider http://localhost:3001/health/live || exit 1

CMD ["node", "src/server.js"]
