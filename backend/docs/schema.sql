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

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  content_url text not null,
  title text not null,
  description text,
  tags text[] not null default '{}',
  likes_count integer not null default 0,
  remixes_count integer not null default 0,
  original_post_id uuid references public.posts(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists posts_user_idx on public.posts (user_id);
create index if not exists posts_created_at_idx on public.posts (created_at desc);
create index if not exists posts_tags_gin on public.posts using gin (tags);
create index if not exists posts_original_idx on public.posts (original_post_id);

create table if not exists public.media (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade,
  url text not null,
  type text not null check (type in ('audio', 'image')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists media_post_idx on public.media (post_id);

create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

create index if not exists post_likes_post_idx on public.post_likes (post_id);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists post_comments_post_idx on public.post_comments (post_id);

create or replace function public.like_post(p_post_id uuid, p_user_id uuid)
returns integer
language plpgsql
as $$
declare
  new_count integer;
begin
  insert into public.post_likes (post_id, user_id)
  values (p_post_id, p_user_id)
  on conflict do nothing;

  update public.posts
  set likes_count = (
    select count(*) from public.post_likes where post_id = p_post_id
  )
  where id = p_post_id;

  select likes_count into new_count from public.posts where id = p_post_id;
  return new_count;
end;
$$;

create or replace function public.refresh_remix_count(p_post_id uuid)
returns integer
language plpgsql
as $$
declare
  new_count integer;
begin
  update public.posts
  set remixes_count = (
    select count(*) from public.posts where original_post_id = p_post_id
  )
  where id = p_post_id;

  select remixes_count into new_count from public.posts where id = p_post_id;
  return new_count;
end;
$$;

-- Leaderboard prep: top tags by total likes on posts tagged
-- select tag, sum(likes_count) as like_score
-- from public.posts, unnest(tags) as tag
-- group by tag
-- order by like_score desc
-- limit 20;
