# Build Stage
FROM node:20 as builder
WORKDIR /usr/app
COPY package.json pnpm-lock.yaml ./
COPY tsconfig*.json nest-cli.json ./
COPY ./src ./src
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile
RUN pnpm build

# Production Stage
FROM node:20-alpine
WORKDIR /usr/app
COPY --from=builder /usr/app/package.json /usr/app/pnpm-lock.yaml ./
COPY --from=builder /usr/app/dist ./dist
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile --prod
CMD ["pnpm", "run", "prod"]
