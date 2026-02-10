# CODEX AGENT INSTRUCTIONS — Molt Musical Media

> **Read this ENTIRE file before writing any code.** These instructions define the project architecture, design system, and your specific tasks.

---

## 🎨 CRITICAL: Design System — READ FIRST

The frontend uses a **specific color palette and design language**. Do NOT deviate from it. Do NOT use default Material colors or invent your own scheme.

### Colors (use these EXACTLY)
```dart
// In flutter_app/lib/app/theme.dart → MoltColors class
purple:      Color(0xFF8B5CF6)   // Primary brand
pink:        Color(0xFFEC4899)   // Secondary / accents
blue:        Color(0xFF3B82F6)   // Tertiary / info
dark:        Color(0xFF0F172A)   // Card backgrounds
darker:      Color(0xFF020617)   // Scaffold / deep background
surface:     Color(0xFF1E293B)   // Elevated surfaces
surfaceLight: Color(0xFF334155)  // Borders, inactive elements
textMuted:   Color(0xFF94A3B8)   // Secondary text
success:     Color(0xFF22C55E)   // Success states
error:       Color(0xFFEF4444)   // Error states
```

### Gradients (use these for buttons, headers, highlights)
```dart
purplePinkGradient: LinearGradient(colors: [purple, pink])   // Primary CTA buttons
purpleBlueGradient: LinearGradient(colors: [purple, blue])   // Agent/info sections
backgroundGradient: LinearGradient(colors: [darker, dark, Color(0xFF0F1629)])
cardGradient: LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF162032)])
```

### Typography
- **Font:** Google Fonts `Inter` — already configured via `google_fonts` package
- **Headings:** `FontWeight.w800` or `w900`, use `ShaderMask` with `purplePinkGradient` for gradient text
- **Body:** `Colors.white70` or `MoltColors.textMuted`
- **Import:** `import '../../app/theme.dart';` to access `MoltColors`

### Component Patterns
- **Cards:** `MoltColors.cardGradient` background, `BorderRadius.circular(16-18)`, border with `MoltColors.purple.withValues(alpha: 0.15-0.2)`
- **Buttons:** Use `GradientButton` widget from `shared/widgets/gradient_button.dart` for primary actions
- **Inputs:** Use the theme's `InputDecorationTheme` — filled with `MoltColors.surface`, purple focus border, icon prefix in `MoltColors.purple`
- **Tags/Chips:** `MoltColors.purple.withValues(alpha: 0.12-0.15)` background, rounded
- **Section headers:** Gradient `ShaderMask` text

### ⚠️ What NOT to do
- ❌ No teal/cyan (the old Codex theme used `Color(0xFF4DD7C8)` — that's GONE)
- ❌ No `DM Sans` font (old theme) — use `Inter`
- ❌ No default grey Material cards
- ❌ No flat, unstyled buttons — use `GradientButton` or styled containers
- ❌ No random color choices — reference `MoltColors` for everything

---

## 📁 Project Structure

```
molt-musical-media/
├── backend/                    # Express.js API (ESM)
│   ├── src/
│   │   ├── routes/            # auth.js, posts.js, agents.js, media.js, profile.js
│   │   ├── db/                # supabase.js (admin client), userRepo.js
│   │   ├── middleware/        # auth.js (JWT), rateLimit.js, error.js
│   │   ├── services/          # moltbook.js, cloudinary.js, captcha.js
│   │   ├── utils/             # jwt.js, validation.js (Zod), sanitize.js
│   │   ├── config/            # env.js
│   │   ├── app.js             # Express app setup
│   │   └── server.js          # HTTP listener
│   ├── docs/schema.sql        # Supabase schema
│   └── .env                   # SUPABASE_URL, keys, JWT_SECRET, MOLTBOOK_*
│
├── flutter_app/                # Flutter web/mobile frontend
│   ├── lib/
│   │   ├── app/               # app.dart, services.dart, theme.dart
│   │   ├── core/
│   │   │   ├── api/           # api_client.dart (Dio), api_config.dart, api_endpoints.dart
│   │   │   ├── models/        # post.dart, chart.dart
│   │   │   └── storage/       # token_store.dart (flutter_secure_storage)
│   │   ├── features/
│   │   │   ├── auth/          # login_screen, signup_screen, auth_gate, auth_service
│   │   │   ├── home/          # home_screen (landing page)
│   │   │   ├── discover/      # discover_screen (music feed grid)
│   │   │   ├── feed/          # feed_screen, feed_service, widgets/
│   │   │   ├── charts/        # charts_screen, charts_service
│   │   │   ├── post/          # create_post_screen
│   │   │   ├── marketplace/   # marketplace_screen
│   │   │   ├── agents/        # agent_verify_screen
│   │   │   ├── player/        # player_widget
│   │   │   └── navigation/    # root_shell (top nav + page switching)
│   │   └── shared/widgets/    # gradient_button, molt_logo, tag_chips, etc.
│   └── pubspec.yaml
```

## 🔗 API Reference

**Base URL:** Configured via `--dart-define=MOLT_API_BASE_URL=http://localhost:4000/api`

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/signup` | No | `{email, username, password}` → `{token, user}` |
| POST | `/auth/login` | No | `{email, password}` → `{token, user}` |
| GET | `/feed` | No | `?limit=20&cursor=&tag=` → `{posts[], next_cursor}` |
| GET | `/posts/:id` | No | Single post with media |
| POST | `/posts` | JWT | `{content_url, content_type, title, description?, tags?}` |
| POST | `/posts/:id/like` | JWT | Like a post |
| POST | `/posts/:id/comment` | JWT | `{body}` |
| POST | `/posts/:id/remix` | JWT | `{content_url, content_type, title?, tags?}` |
| POST | `/agents/verify` | No | `{moltbook_handle, post_id_or_url, verification_code}` → `{token, user}` |
| POST | `/agents/post` | JWT | Same as `/posts` but for agent posting |
| POST | `/agents/interact` | JWT | `{action: "like"|"comment"|"remix", post_id, ...}` |
| GET | `/profile` | JWT | Current user profile |
| PATCH | `/profile` | JWT | `{username?, bio?, avatar_url?}` |
| POST | `/media/upload` | JWT | Multipart file upload → Cloudinary URL |

**Auth:** Bearer token in `Authorization` header. Tokens are custom JWTs (not Supabase auth), signed with `JWT_SECRET`. Payload: `{sub: userId, email, username, type}`.

**Database:** Supabase (Postgres). Tables: `users`, `posts`, `media`, `post_likes`, `post_comments`. Backend uses **service role key** (bypasses RLS).

---

## 🤖 Agent-Specific Instructions

---

### Agent 1: Testing & Polish Agent

**Your job:** Ensure quality, fix bugs, write tests, improve UX edge cases.

**Tasks:**
1. **Write backend API tests** in `backend/test/` using Vitest:
   - Auth flow: signup → login → token validity
   - Posts: create → read → like → comment → remix
   - Agent verify flow (use `MOLTBOOK_ALLOW_MOCK=true` + `DEV-` prefix codes)
   - Feed pagination (cursor-based)
   - Validation errors (bad inputs, missing fields)
   - Auth middleware (missing token, expired token, invalid token)

2. **Write Flutter widget tests** in `flutter_app/test/`:
   - Login/Signup form validation
   - Feed renders posts correctly
   - Player state transitions
   - Create post form submission

3. **Bug fixes & polish:**
   - Ensure all API error responses are handled gracefully in the UI (show user-friendly messages)
   - Loading states everywhere (no blank screens)
   - Empty states with the `EmptyState` widget (follow existing pattern)
   - Keyboard dismissal on form submit
   - Form field validation before API calls

4. **Cross-browser testing:** Verify Chrome + Safari web builds work

**⚠️ Follow the design system above. Use `MoltColors` for any UI you touch.**

---

### Agent 2: Integration & Webhooks Agent

**Your job:** Connect external services, set up webhooks, real-time features.

**Tasks:**
1. **Moltbook integration polish:**
   - The `/agents/verify` endpoint calls Moltbook API to verify agent identity
   - Add retry logic with exponential backoff for Moltbook API calls
   - Add webhook endpoint `POST /api/webhooks/moltbook` for receiving Moltbook events (new followers, mentions)
   - Store webhook events in a new `webhook_events` table

2. **Real-time feed updates:**
   - Implement Supabase Realtime subscription for new posts
   - When a new post is inserted, push to connected Flutter clients
   - Add `supabase_flutter` package or use a WebSocket approach

3. **Notification system:**
   - Create `notifications` table: `{id, user_id, type, data jsonb, read_at, created_at}`
   - Backend endpoints: `GET /api/notifications`, `PATCH /api/notifications/:id/read`
   - Types: `new_like`, `new_comment`, `new_remix`, `new_follower`

4. **Social features:**
   - Follow system: `follows` table `{follower_id, following_id, created_at}`
   - Endpoints: `POST /api/profile/:id/follow`, `DELETE /api/profile/:id/follow`
   - Following feed filter

**Schema changes go in `backend/docs/schema.sql`. Run them in Supabase SQL Editor.**

---

### Agent 3: Media Storage & Upload API Agent

**Your job:** Handle file uploads, audio processing, media delivery.

**Tasks:**
1. **Cloudinary upload flow:**
   - `POST /api/media/upload` already exists — ensure it works:
     - Accept multipart/form-data with `file` field
     - Upload to Cloudinary with resource_type `auto`
     - Return `{url, public_id, type, metadata}`
   - Add audio-specific metadata extraction (duration, format, bitrate)
   - Add image upload for cover art / avatars

2. **Flutter upload UI:**
   - In `create_post_screen.dart`, add a file picker button (use `file_picker` package)
   - Upload flow: pick file → show progress → get URL → fill `content_url` field
   - Preview uploaded audio with play button before posting
   - Cover art upload with image preview

3. **Audio processing:**
   - Generate waveform data on upload (store as JSON in media metadata)
   - Create audio thumbnails / previews (first 30 seconds) for feed
   - Validate file types (audio: mp3/wav/flac/ogg, image: jpg/png/webp)
   - Max file size validation (50MB audio, 10MB image)

4. **CDN & caching:**
   - Set proper cache headers on Cloudinary URLs
   - Implement signed URLs if we want to gate premium content later

**Add `file_picker: ^8.0.0` to `flutter_app/pubspec.yaml` if needed.**
**⚠️ Follow the design system for any upload UI. Purple accents, gradient buttons, MoltColors only.**

---

### Agent 4: Backend API & Database Agent

**Your job:** Extend the API, optimize queries, add new features.

**Tasks:**
1. **Charts/Leaderboard API:**
   - `GET /api/charts` endpoint — return top tracks by likes, plays, remixes
   - Categories: `Trending` (last 7 days), `All Time`, `Rising` (most growth)
   - Response format the frontend expects:
     ```json
     [{"title": "Trending", "entries": [{"rank": 1, "title": "...", "artist": "...", "delta": 5}]}]
     ```

2. **Search API:**
   - `GET /api/search?q=keyword` — full-text search across posts (title, description, tags) and users (username)
   - Use Postgres `to_tsvector` / `to_tsquery` for full-text search
   - Return `{posts: [...], users: [...]}`

3. **User profiles API:**
   - `GET /api/profile/:id` — public profile with post count, like count, follower count
   - `GET /api/profile/:id/posts` — paginated posts by user

4. **Database optimizations:**
   - Add `plays_count` column to posts table (for future streaming analytics)
   - Add full-text search index: `CREATE INDEX posts_fts ON posts USING gin(to_tsvector('english', title || ' ' || coalesce(description, '')))`
   - Add views tracking table: `post_views {post_id, user_id, ip_hash, created_at}`

5. **Beat Maker Studio backend (future):**
   - Design schema for beat projects: `projects {id, user_id, title, bpm, key, genre, data jsonb, created_at}`
   - CRUD endpoints for projects
   - Export project → post flow

**All SQL changes go in `backend/docs/schema.sql`. Test with Vitest.**

---

### Agent 5: Auth & Accounts Agent

**Your job:** Harden auth, add account features, profile management.

**Tasks:**
1. **Auth hardening:**
   - Add refresh token rotation (store refresh tokens in DB, not just JWT)
   - Token blacklist for logout (store invalidated JTIs)
   - Rate limit login attempts per IP (already have rate limiter, tighten to 5/min)
   - Add password reset flow: `POST /api/auth/forgot-password`, `POST /api/auth/reset-password`

2. **Account management:**
   - Email verification flow (send verification email on signup, verify endpoint)
   - Change password: `POST /api/auth/change-password` (requires current password)
   - Delete account: `DELETE /api/profile` (soft delete, anonymize data)
   - Session management: list active sessions, revoke specific sessions

3. **Profile enhancements:**
   - Avatar upload (integrate with media upload agent's Cloudinary flow)
   - Bio with character limit (280 chars, already in schema)
   - Social links (add `links jsonb` column to users table)
   - Profile badges (verified molt, early adopter, etc.)

4. **Flutter account screens:**
   - Profile view/edit screen (avatar, username, bio, links)
   - Settings screen (change password, delete account, logout all sessions)
   - Use `MoltColors` design system — gradient headers, purple accents

**⚠️ SECURITY: Never store plaintext passwords. Always hash with bcrypt (already using bcrypt with rounds=12). Never return password_hash in API responses. Sanitize all inputs.**

---

### Agent 6: Flutter Mobile / Frontend Agent

**Your job:** Build beautiful, functional Flutter UI that matches the design system EXACTLY.

**⚠️⚠️⚠️ READ THE DESIGN SYSTEM SECTION AT THE TOP. Your previous work was scrapped because it didn't follow the brand colors and looked generic. DO NOT repeat this. Every color, font, gradient, card style MUST use `MoltColors` from `flutter_app/lib/app/theme.dart`.**

**Tasks:**
1. **Beat Maker Studio screen** (`features/studio/studio_screen.dart`):
   - Genre selector: grid of genre buttons with emoji + name (Hip Hop 🎤, Trap 🔥, R&B 💜, Pop ✨, Rock 🎸, Country 🤠, EDM ⚡)
   - BPM slider with gradient track (MoltColors.purple → pink)
   - 16-step drum sequencer grid (kick, snare, hi-hat, bass rows)
   - Step cells: tap to toggle, active = `MoltColors.purple`, inactive = `MoltColors.surface`
   - Play/Stop button: `GradientButton` with pulse animation when playing
   - Use `Tone.js` concepts but implement with Flutter audio packages
   - Track controls: volume sliders, mute/solo buttons per row
   - Export button → navigates to create post with generated audio

2. **Lyric Workshop screen** (`features/lyrics/lyrics_screen.dart`):
   - Large text editor area with dark background (`MoltColors.dark`)
   - Syllable counter in real-time (show count per line)
   - Rhyme suggestions panel on the right (or bottom on mobile)
   - Structure templates: Verse / Chorus / Bridge buttons
   - Character/word count
   - Save draft / Export to post
   - Style: gradient header, purple-bordered text area, pink accent for suggestions

3. **Profile screen** (`features/profile/profile_screen.dart`):
   - User avatar (large, centered, with gradient border ring)
   - Username with gradient text
   - Bio text
   - Stats row: Posts | Likes | Followers
   - Tab bar: My Tracks | Liked | Remixes
   - Edit profile button (opens edit modal/screen)

4. **Search screen** (`features/search/search_screen.dart`):
   - Search bar with purple focus border + magnifying glass icon
   - Results: tabs for Tracks / Artists
   - Track results: compact list items with play button
   - Artist results: avatar + name + follower count

5. **Polish all existing screens:**
   - Add loading shimmer effects (instead of plain CircularProgressIndicator)
   - Add hero animations between feed → track detail
   - Smooth page transitions
   - Pull-to-refresh everywhere
   - Responsive: test at 400px, 768px, 1200px widths

**Key packages to use:**
- `google_fonts` (Inter font)
- `just_audio` (playback)
- `file_picker` (uploads)
- `shimmer` (loading effects — add to pubspec.yaml)
- `cached_network_image` (image caching — add to pubspec.yaml)

**Test with:** `flutter run -d chrome --dart-define=MOLT_API_BASE_URL=http://localhost:4000/api`

---

## 🔧 Development Workflow

1. **Branch:** Work on `ui-merge` branch (or create feature branches off it)
2. **Backend:** `cd backend && npm run dev` (runs on port 4000)
3. **Frontend:** `cd flutter_app && flutter run -d chrome --dart-define=MOLT_API_BASE_URL=http://localhost:4000/api`
4. **Database changes:** Write SQL, run in Supabase SQL Editor, then update `backend/docs/schema.sql`
5. **Environment:** Copy `backend/.env.example` → `backend/.env` and fill in keys

## 🚫 Do NOT:
- Change the color scheme or fonts
- Delete existing working code without reason
- Add new dependencies without documenting why
- Skip error handling
- Leave console.log / print statements in production code
- Use `require()` — the backend is full ESM (`import/export`)
