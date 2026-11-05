# syntax=docker/dockerfile:1.7
# Webstudio Builder — image de production
# Construite depuis le monorepo webstudio-is/webstudio (branche main).
FROM node:22-bookworm-slim AS base
ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH \
    NODE_ENV=production
RUN corepack enable \
 && corepack prepare pnpm@9.14.4 --activate \
 && apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates openssl postgresql-client \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app

FROM base AS deps
ENV NODE_ENV=development
COPY . .
RUN pnpm install --frozen-lockfile

FROM deps AS build
ENV NODE_OPTIONS=--max-old-space-size=6144
RUN pnpm --filter=@webstudio-is/builder build

FROM base AS runtime
COPY --from=build /app /app
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
WORKDIR /app/apps/builder
EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
