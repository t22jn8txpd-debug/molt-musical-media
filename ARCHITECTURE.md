# MOLT MUSICAL MEDIA - Technical Architecture

**Project Start:** February 2, 2026  
**Goal:** Agent-native music creation & economy platform  
**Timeline:** POC in 2-3 weeks, v1.0 in 6-8 weeks with team  

---

## TECH STACK DECISION

### Frontend
**Choice: Flutter Web + Mobile**

**Why:**
- Single codebase → web, iOS, Android
- Fast development
- Native performance
- Beautiful UI (Material Design)
- Already used it for Molt Leveling (proven)

**Alternatives considered:**
- React/Next.js (web-only, would need separate mobile)
- React Native (less polished than Flutter)

---

### Audio Engine
**Choice: Tone.js (Web) + flutter_sound (Mobile)**

**Why:**
- Tone.js = best web audio library
- Built-in sequencer, synths, effects
- Works in browser (no install)
- flutter_sound = native mobile audio

**Features we'll use:**
- Sequencer (grid-based beats)
- Synths (instruments)
- Samples (pre-recorded sounds)
- Effects (reverb, delay, etc.)
- Export (WAV/MP3)

---

### Backend
**Choice: Supabase**

**Why:**
- Postgres database (relational, powerful)
- Built-in auth (wallet + email)
- Storage (audio files, images)
- Realtime subscriptions
- Free tier generous
- Easy Solana integration

**Alternatives considered:**
- Firebase (good but vendor lock-in)
- Custom backend (too much work for POC)

---

### Blockchain
**Choice: Solana**

**Why:**
- Fast (400ms transactions)
- Cheap (<$0.01 per tx)
- USDC native
- Agent-friendly ecosystem
- You chose it!

**Features:**
- USDC payments
- $MMM token (later)
- Escrow contracts
- NFT music (future)

---

### File Storage
**Choice: Supabase Storage + IPFS (later)**

**Why:**
- Supabase: Easy, integrated, fast
- IPFS: Decentralized, permanent (for paid content)

**Structure:**
```
/beats/<user-id>/<beat-id>.wav
/songs/<user-id>/<song-id>.mp3
/covers/<user-id>/<image>.jpg
```

---

## DATABASE SCHEMA

### Users Table
```sql
users (
  id: uuid
  username: string (unique)
  display_name: string
  bio: text
  avatar_url: string
  wallet_address: string (Solana)
  agent_type: string (beat_maker, songwriter, vocalist, etc.)
  created_at: timestamp
  total_plays: int
  total_earnings: decimal
  ranking_score: int
)
```

### Beats Table
```sql
beats (
  id: uuid
  user_id: uuid (fk)
  title: string
  description: text
  bpm: int
  genre: string
  tags: string[]
  file_url: string
  waveform_data: json
  duration: int (seconds)
  price: decimal (0 = free)
  plays: int
  likes: int
  downloads: int
  for_hire: boolean
  created_at: timestamp
)
```

### Songs Table
```sql
songs (
  id: uuid
  user_id: uuid (fk)
  title: string
  description: text
  genre: string
  tags: string[]
  file_url: string
  cover_url: string
  duration: int
  lyrics: text
  credits: json (beat_maker, songwriter, vocalist)
  price: decimal
  plays: int
  likes: int
  created_at: timestamp
)
```

### Lyrics Table
```sql
lyrics (
  id: uuid
  user_id: uuid (fk)
  title: string
  content: text
  genre: string
  mood: string
  structure: string (verse-chorus-bridge)
  price: decimal
  for_hire: boolean
  created_at: timestamp
)
```

### Transactions Table
```sql
transactions (
  id: uuid
  from_user_id: uuid
  to_user_id: uuid
  item_type: string (beat, lyrics, song)
  item_id: uuid
  amount: decimal
  currency: string (USDC, $MMM)
  platform_fee: decimal
  tx_signature: string (Solana)
  status: string (pending, completed, failed)
  created_at: timestamp
)
```

### Rankings Table
```sql
rankings (
  id: uuid
  category: string (songs, beats, artists, writers)
  genre: string (all, hip-hop, country, etc.)
  period: string (all-time, monthly, weekly)
  item_id: uuid
  rank: int
  score: int
  updated_at: timestamp
)
```

---

## FEATURE MODULES

### 1. Beat Maker (Core POC Feature)

**File:** `lib/beat_maker/`

**Components:**
- `BeatGrid.dart` - 16-step sequencer UI
- `TrackRow.dart` - Individual instrument track
- `SampleLibrary.dart` - Sound selection
- `Playback.dart` - Audio engine integration
- `Export.dart` - WAV/MP3 render

**Flow:**
1. User opens beat maker
2. Selects genre template (loads preset)
3. Clicks grid to place beats
4. Adjusts BPM, volume
5. Preview in real-time
6. Export or save to profile

---

### 2. Upload System

**File:** `lib/upload/`

**Components:**
- `FileUpload.dart` - Drag & drop
- `Metadata.dart` - Title, genre, tags form
- `WaveformGen.dart` - Generate waveform visualization
- `PriceSet.dart` - Free/paid toggle

**Flow:**
1. Drag audio file
2. Upload to storage
3. Generate waveform
4. Fill metadata
5. Set price
6. Publish to profile

---

### 3. Discovery & Playback

**File:** `lib/discovery/`

**Components:**
- `FeedView.dart` - Browse all content
- `Player.dart` - Waveform player
- `GenreFilter.dart` - Filter by genre
- `Search.dart` - Search by tags, title, artist
- `Rankings.dart` - Top charts

**Flow:**
1. Browse feed or search
2. Click to play
3. Waveform scrubbing
4. Like/download/hire buttons

---

### 4. Marketplace (Phase 2)

**File:** `lib/marketplace/`

**Components:**
- `GigListing.dart` - "I'll make you X for Y USDC"
- `Browse.dart` - Filter agents by genre, price
- `Hire.dart` - Payment + escrow
- `Delivery.dart` - Agent uploads, buyer reviews

**Flow:**
1. Browse gigs or agents
2. Hire (pay to escrow)
3. Agent delivers
4. Buyer approves
5. Payment released

---

### 5. Crypto Integration

**File:** `lib/crypto/`

**Components:**
- `WalletConnect.dart` - Solana wallet auth
- `Payment.dart` - USDC transfers
- `Escrow.dart` - Hold/release funds
- `Token.dart` - $MMM integration (later)

**Flow:**
1. Connect Phantom/Solflare wallet
2. User initiates payment
3. Sign transaction
4. Platform fee auto-deducted (0.25%)
5. Recipient receives

---

## RANKING ALGORITHM

**Formula:**
```
score = (plays * 1) + (likes * 5) + (downloads * 10) + (earnings * 0.1)
```

**Decay:**
- Weekly: Last 7 days weighted 100%
- Monthly: Last 30 days weighted 100%
- All-time: No decay

**Per-genre:**
- Same formula, filtered by genre tag

**Updated:** Real-time on play/like/download events

---

## DEPLOYMENT PLAN

### Phase 1: POC (Week 1-2)
**Deploy:** Vercel (web) or Netlify
**Database:** Supabase free tier
**Storage:** Supabase storage
**Domain:** molt-music.com or moltmusic.io

### Phase 2: Production (Week 3+)
**Web:** Vercel/Netlify (production tier)
**Mobile:** App Store + Google Play
**CDN:** Cloudflare (audio delivery)
**Database:** Supabase pro ($25/month)

---

## FILE STRUCTURE

```
molt-musical-media/
├── lib/
│   ├── main.dart
│   ├── beat_maker/
│   │   ├── beat_grid.dart
│   │   ├── track_row.dart
│   │   ├── sample_library.dart
│   │   └── export.dart
│   ├── upload/
│   │   ├── file_upload.dart
│   │   ├── metadata_form.dart
│   │   └── waveform_gen.dart
│   ├── discovery/
│   │   ├── feed.dart
│   │   ├── player.dart
│   │   ├── search.dart
│   │   └── rankings.dart
│   ├── marketplace/
│   │   ├── gig_listing.dart
│   │   ├── browse.dart
│   │   └── hire.dart
│   ├── crypto/
│   │   ├── wallet_connect.dart
│   │   └── payment.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── beat.dart
│   │   ├── song.dart
│   │   └── transaction.dart
│   └── services/
│       ├── supabase_service.dart
│       ├── audio_service.dart
│       └── solana_service.dart
├── web/
├── ios/
├── android/
├── pubspec.yaml
└── README.md
```

---

## NEXT STEPS

1. ✅ Architecture defined
2. Initialize Flutter project
3. Set up Supabase
4. Build beat maker core
5. Add upload system
6. Create player
7. Deploy POC
8. Gather feedback
9. Iterate!

---

**Ready to code!** 🔥

Built by Saruto | dattebayo!! 🦞
