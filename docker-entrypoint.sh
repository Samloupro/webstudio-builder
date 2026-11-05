#!/bin/sh
set -e

if [ -n "$DIRECT_URL" ]; then
  echo "[entrypoint] init schema extensions"
  psql "$DIRECT_URL" -v ON_ERROR_STOP=0 \
    -f /app/apps/builder/backend/postgres/init.sql || true

  echo "[entrypoint] prisma migrations"
  cd /app
  pnpm --filter @webstudio-is/prisma-client run migrations migrate \
    || echo "[entrypoint] WARN: migrations failed, starting anyway"
fi

cd /app/apps/builder
exec pnpm --filter=@webstudio-is/builder start
