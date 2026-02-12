-- schema-v2.sql — Molt Musical Media database migrations
-- Run against your Supabase project SQL editor

-- 1. Add encrypted API keys column to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS api_keys_encrypted jsonb;

-- 2. Lyric drafts
CREATE TABLE IF NOT EXISTS lyric_drafts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text,
  lyrics_json jsonb,
  genre text,
  mood text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_lyric_drafts_user ON lyric_drafts(user_id);

-- 3. Albums
CREATE TABLE IF NOT EXISTS albums (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  cover_url text,
  tags text[],
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_albums_user ON albums(user_id);

-- 4. Add album_id to posts
ALTER TABLE posts ADD COLUMN IF NOT EXISTS album_id uuid REFERENCES albums(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_posts_album ON posts(album_id) WHERE album_id IS NOT NULL;

-- 5. Followers
CREATE TABLE IF NOT EXISTS followers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(follower_id, following_id)
);
CREATE INDEX IF NOT EXISTS idx_followers_follower ON followers(follower_id);
CREATE INDEX IF NOT EXISTS idx_followers_following ON followers(following_id);

-- 6. Generation jobs
CREATE TABLE IF NOT EXISTS generation_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  prompt text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  result_url text,
  metadata jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);
CREATE INDEX IF NOT EXISTS idx_generation_jobs_user ON generation_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_generation_jobs_status ON generation_jobs(status) WHERE status = 'pending';

-- 7. Allow 'video' type in media table
ALTER TABLE media DROP CONSTRAINT IF EXISTS media_type_check;
ALTER TABLE media ADD CONSTRAINT media_type_check CHECK (type IN ('audio', 'image', 'video'));
