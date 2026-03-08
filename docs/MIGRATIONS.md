# Database migrations

Migrations for Supabase are stored in:

- `supabase/migrations/`
- `als_study_companion/supabase/migrations/`

Guidance to apply locally

1. Install the Supabase CLI: https://supabase.com/docs/guides/cli
2. Authenticate and set up a local project. Be careful — applying migrations can be destructive.

Common commands

```bash
# reset local DB and apply migrations (destructive)
supabase db reset

# push migrations to the connected DB
supabase db push
```

Validation

- Review migration filenames — they should be ordered by timestamp. The repo contains files like `20260306_grants.sql` and `20260310_missing_tables.sql`.
- Run `psql` or Supabase SQL editor to inspect schema after applying.

If you'd like, I can:

- Run a dry-check of the SQL files for obvious issues.
- Create a script that runs `supabase db push` for your local environment (requires CLI).
