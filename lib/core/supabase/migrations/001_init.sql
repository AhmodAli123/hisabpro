-- Supabase schema for HisabPro Phase 5
-- Run these in the Supabase SQL editor or via psql connected to your project.

-- Transactions table
create table if not exists transactions (
  id text primary key,
  user_id uuid references auth.users on delete cascade,
  kind text not null,
  amount numeric not null,
  category_id text not null,
  date_time bigint not null,
  note text,
  payment_method text,
  receipt_path text,
  updated_at bigint,
  sync_status text,
  created_at timestamptz default now()
);

-- Budgets table
create table if not exists budgets (
  id text primary key,
  user_id uuid references auth.users on delete cascade,
  period_key text not null,
  amount numeric not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Recurring transactions
create table if not exists recurrings (
  id text primary key,
  user_id uuid references auth.users on delete cascade,
  kind text not null,
  amount numeric not null,
  category_id text not null,
  start_date bigint not null,
  frequency text not null,
  note text,
  next_occurrence bigint,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable row-level security
alter table transactions
  enable row level security;

alter table budgets
  enable row level security;

alter table recurrings
  enable row level security;

-- RLS policy: users can only access their own rows
create policy "users can manage their transactions" on transactions
  for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "users can manage their budgets" on budgets
  for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "users can manage their recurrings" on recurrings
  for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Indexes to speed up queries by user and date
create index if not exists idx_transactions_user_date on transactions (user_id, date_time desc);
