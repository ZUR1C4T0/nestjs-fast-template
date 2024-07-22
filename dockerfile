# Base
FROM node:20-alpine AS base

# Install dependencies
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /usr/app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# Build the app
FROM base AS builder
WORKDIR /usr/app
COPY --from=deps /usr/app/node_modules ./node_modules
COPY package.json ./
COPY tsconfig*.json nest-cli.json ./
COPY ./src ./src
RUN corepack enable pnpm && pnpm run build

# run the app
FROM base AS runner
WORKDIR /usr/app
ENV NODE_ENV=production
ENV PORT=3000
COPY package.json ./
COPY --from=deps /usr/app/node_modules ./node_modules
COPY --from=builder /usr/app/dist ./dist
RUN corepack enable pnpm

EXPOSE 3000
CMD ["pnpm", "run", "prod"]
