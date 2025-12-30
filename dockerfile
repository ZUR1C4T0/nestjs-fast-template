# Base
FROM node:24-alpine AS base
WORKDIR /app
RUN apk add --no-cache libc6-compat
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install dependencies
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Build the app
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY package.json tsconfig*.json nest-cli.json ./
COPY src/ ./src
RUN pnpm run build

# run the app
FROM base AS runner
ENV NODE_ENV=production
ENV PORT=3000
RUN addgroup -S nodejs && adduser -S nestjs nodejs
USER nestjs:nodejs
COPY --from=deps --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY package.json ./

EXPOSE 3000
CMD ["pnpm", "run", "prod"]
