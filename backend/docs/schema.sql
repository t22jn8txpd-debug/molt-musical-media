-- Run in Supabase SQL editor
create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  username text unique not null,
  password_hash text,
  provider text not null,
  provider_id text,
  moltbook_handle text unique,
  type text not null check (type in ('human', 'molt')),
  bio text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_login_at timestamptz,
  molt_verified_at timestamptz
);

create index if not exists users_type_idx on public.users (type);
create index if not exists users_molt_verified_idx on public.users (molt_verified_at);
