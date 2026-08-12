Supabase setup for HisabPro

1) Create a Supabase project at https://app.supabase.com/
2) In Project Settings -> API, copy the `URL` and `anon/public` key into
   `lib/core/constants/supabase_config.dart`.
3) Open SQL Editor and run the migration file:

   lib/core/supabase/migrations/001_init.sql

   This creates `transactions`, `budgets`, and `recurrings` tables and
   enables row-level security (RLS) policies.

4) In Supabase -> Authentication -> Settings, configure any required
   email templates or redirect URLs for password reset flows.

Notes:
- Do NOT commit production keys to source control; use environment
  variables for CI/deploys.
- The CloudTransactionDataSource is a lightweight skeleton stored at
  `lib/data/datasources/cloud_transaction_data_source.dart` and requires
  further work to implement robust sync, retries, and receipt storage.
