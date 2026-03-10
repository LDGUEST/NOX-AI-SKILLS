---
name: migrate
description: Generates a database migration for a schema change, auto-detecting the ORM and migration framework. Use when adding columns, tables, indexes, or modifying the database schema.
---

Generate a database migration for the requested schema change. Auto-detect the ORM and migration framework.

## Step 1: Detect Stack

Scan the project for:
- `prisma/schema.prisma` → **Prisma**
- `drizzle.config.*` → **Drizzle**
- `knexfile.*` → **Knex**
- `alembic.ini` → **Alembic**
- `supabase/migrations/` → **Supabase**
- `django` in requirements → **Django**
- Raw SQL files → Generate timestamped `.sql` migration

## Step 2: Generate Migration

1. Write the UP migration (apply the change)
2. Write the DOWN migration (reverse the change)
3. Handle data migrations if existing data needs transforming
4. Add appropriate indexes for new columns

## Safety Rules

- Never drop a column/table without explicit confirmation
- Always generate both UP and DOWN migrations
- For large tables, suggest batched migrations to avoid locks
- Include a rollback plan for every migration

---
Nox