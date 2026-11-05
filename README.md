# webstudio-builder

Image Docker de production pour le **Webstudio Builder** auto-hébergé,
construite depuis le monorepo [webstudio-is/webstudio](https://github.com/webstudio-is/webstudio).

## Contenu

| Fichier | Rôle |
| --- | --- |
| `Dockerfile` | Build multi-étapes (Node 22 + pnpm 9.14.4, `pnpm --filter=@webstudio-is/builder build`) |
| `docker-entrypoint.sh` | Applique `init.sql` (schéma `extensions`), lance les migrations Prisma, puis démarre le serveur Remix |
| `.github/workflows/build.yml` | Build + push vers `ghcr.io/samloupro/webstudio-builder:latest` |

## Variables d'environnement attendues au runtime

| Variable | Exemple |
| --- | --- |
| `DATABASE_URL` | `postgresql://webstudio:PASS@webstudio-db:5432/webstudio` |
| `DIRECT_URL` | idem sans paramètres de pooling |
| `POSTGREST_URL` | `http://webstudio-postgrest:3000` |
| `AUTH_SECRET` | chaîne aléatoire ≥ 32 caractères |
| `PORT` | `3000` |
| `BUILD_ORIGIN` | `https://builder.example.com` |
| `DEV_LOGIN` | `true` (première mise en route) |
| `FEATURE_FLAGS` | `*` |
| `TRPC_SERVER_API_TOKEN` | chaîne aléatoire |

## Déploiement

1. Le workflow pousse l'image sur GHCR.
2. Dans Coolify : nouvelle application, `build_pack: dockerimage`,
   image `ghcr.io/samloupro/webstudio-builder:latest`, port `3000`.
3. Postgres : `supabase/postgres:15.8.1.085`, base `webstudio`.
4. PostgREST : `postgrest/postgrest:v12.2.12`, `PGRST_DB_URI` vers Postgres.
