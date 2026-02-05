# 🎵 Suno API Setup Guide

**Status:** Researching unofficial wrappers (Feb 4, 2026)  
**Goal:** Use free tier Suno + unofficial wrapper for testing

---

## 🔍 Research: Popular Suno API Wrappers (GitHub)

### Top Candidates to Investigate:

1. **SunoAI-API/Suno-API** (Most mentioned)
   - Python/FastAPI wrapper
   - Uses browser session_id + cookie method
   - Supports both free and paid tiers
   - Features: Generate, fetch, extend clips

2. **gcui-art/suno-api**
   - Node.js wrapper
   - Session-based authentication
   - REST API endpoints

3. **Malith-Rukshan/Suno-API**
   - Python-based
   - Cookie authentication
   - Async support

---

## 📋 Setup Steps (Once Wrapper Chosen)

### Step 1: Get Suno Credentials (Free Tier)

1. Go to https://suno.com
2. Create free account / login
3. Open browser DevTools (F12)
4. Go to Application → Cookies
5. Copy these values:
   ```
   session_id: [YOUR_SESSION_ID]
   __client: [YOUR_CLIENT_COOKIE]
   ```

### Step 2: Install Wrapper

#### Option A: Python Wrapper (SunoAI-API)
```bash
cd molt-musical-media/agents/generation
git clone https://github.com/SunoAI-API/Suno-API.git suno-wrapper
cd suno-wrapper
pip install -r requirements.txt
```

#### Option B: Node.js Wrapper
```bash
cd molt-musical-media/agents/generation
npm install suno-api  # (if exists on npm)
```

### Step 3: Configure Environment

Create `.env` file in `agents/generation/`:
```env
SUNO_SESSION_ID=your_session_id_here
SUNO_CLIENT_COOKIE=your_client_cookie_here
SUNO_API_URL=https://api.suno.ai/v1
```

**Security:** `.env` is gitignored ✅

### Step 4: Update `suno.js` Integration

Replace mock API with real wrapper:

```javascript
// agents/generation/suno.js

import fetch from 'node-fetch';
import dotenv from 'dotenv';
dotenv.config();

const SUNO_SESSION_ID = process.env.SUNO_SESSION_ID;
const SUNO_CLIENT_COOKIE = process.env.SUNO_CLIENT_COOKIE;

async function callSunoAPI(prompt, duration, style) {
  const response = await fetch('https://api.suno.ai/v1/generate', {
    method: 'POST',
    headers: {
      'Cookie': `session_id=${SUNO_SESSION_ID}; __client=${SUNO_CLIENT_COOKIE}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      prompt: prompt,
      duration: duration,
      style: style || 'auto',
      wait: true
    })
  });
  
  if (!response.ok) {
    throw new Error(`Suno API error: ${response.status}`);
  }
  
  return await response.json();
}
```

### Step 5: Test Generation

```bash
cd molt-musical-media/agents/generation
node suno.js  # Run test function
```

Expected output:
```
🎵 Testing Suno Generation System:

=== Test 1: Random Track ===
🎵 Generating track with Suno...
Prompt: "upbeat country instrumental with acoustic guitar..."
✅ Track generated!
Tags: Genres: country | Moods: happy, upbeat | Tempo: medium | ...
```

---

## 🎮 GPU Check (MusicGen Fallback)

### Check if GPU Available:

```bash
# Check NVIDIA GPU
nvidia-smi

# Check Apple Silicon
system_profiler SPDisplaysDataType | grep Chipset
```

### If GPU Available: Install MusicGen

```bash
# Install Audiocraft
pip install audiocraft

# Test generation
python -c "from audiocraft.models import MusicGen; model = MusicGen.get_pretrained('small'); print('MusicGen ready!')"
```

---

## 📊 Free Tier Limits (Suno)

- **Credits per month:** ~50 generations
- **Track length:** Up to 2 minutes
- **Quality:** Standard (320kbps)
- **Commercial use:** Check TOS

**Strategy:** Use free tier for testing (Days 1-7), upgrade to paid ($10-30/mo) once platform launches

---

## 🚀 Next Steps

- [ ] Research best wrapper (test 2-3 options)
- [ ] Get Suno credentials (free account)
- [ ] Install wrapper + dependencies
- [ ] Update `suno.js` with real API
- [ ] Test 3-5 real generations
- [ ] Compare quality vs mock
- [ ] Set up MusicGen fallback (if GPU available)
- [ ] Document API response format

---

## 🔐 Security Checklist

- [ ] `.env` file created
- [ ] `.env` in `.gitignore` ✅
- [ ] Credentials never committed to Git
- [ ] Session cookies refreshed periodically
- [ ] Fallback to mock if API fails

---

**Status:** IN PROGRESS  
**Blocker:** Need to test 2-3 wrappers to find most reliable  
**ETA:** Tonight/tomorrow morning

**Will update this file once wrapper is working!** 🔥
