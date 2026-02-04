/**
 * Prompt Templates Library for Music Generation
 * Saruto's collection of tested prompts for Suno/Udio APIs
 */

// Genre-specific prompt templates
export const genreTemplates = {
  country: {
    upbeat: [
      "upbeat country instrumental with acoustic guitar, banjo, and driving drums",
      "energetic country rock with steel guitar, fiddle, and strong backbeat",
      "modern country pop fusion with catchy hooks and bright production"
    ],
    ballad: [
      "emotional country ballad with acoustic guitar and gentle strings",
      "heartfelt slow country with pedal steel and atmospheric production",
      "melancholic country storytelling with sparse instrumentation"
    ],
    honkyTonk: [
      "classic honky-tonk country with piano, fiddle, and swing rhythm",
      "rowdy bar country with slide guitar and toe-tapping beat"
    ]
  },
  
  hipHop: {
    boom_bap: [
      "classic boom bap hip-hop beat with heavy kick, snappy snare, and vinyl crackle",
      "old school hip-hop instrumental with jazz samples and punchy drums",
      "90s East Coast beat with hard-hitting drums and melodic bassline"
    ],
    trap: [
      "modern trap beat with 808 bass, rolling hi-hats, and dark melody",
      "hard trap instrumental with aggressive synths and heavy low end",
      "melodic trap with atmospheric pads and bouncy rhythm"
    ],
    loFi: [
      "chill lo-fi hip-hop with dusty drums, warm piano, and rain ambience",
      "relaxing study beats with mellow jazz chords and vinyl texture",
      "nostalgic lo-fi with Rhodes piano, soft bass, and tape saturation"
    ]
  },
  
  edm: {
    house: [
      "uplifting progressive house with soaring synths and four-on-the-floor kick",
      "deep house groove with warm bassline, soulful chords, and subtle vocals",
      "tech house banger with driving percussion and hypnotic loops"
    ],
    dubstep: [
      "heavy dubstep drop with wobble bass, aggressive synths, and half-time drums",
      "melodic dubstep with emotional chords and powerful bass",
      "riddim dubstep with repetitive bass pattern and hard-hitting drums"
    ],
    trance: [
      "euphoric uplifting trance with arpeggiated leads and powerful breakdown",
      "progressive trance journey with evolving pads and driving bassline",
      "psy-trance with hypnotic leads and rolling bassline"
    ]
  },
  
  pop: {
    upbeat: [
      "catchy pop song with bright synths, punchy drums, and memorable hook",
      "radio-friendly pop with guitar, piano, and energetic production",
      "modern pop banger with electronic elements and driving rhythm"
    ],
    ballad: [
      "emotional pop ballad with piano, strings, and powerful vocals",
      "heartfelt slow pop with acoustic guitar and atmospheric production"
    ]
  },
  
  rock: {
    alternative: [
      "alternative rock with distorted guitars, driving drums, and dynamic arrangement",
      "indie rock with jangly guitars, melodic bassline, and energetic drums"
    ],
    metal: [
      "heavy metal with palm-muted riffs, double bass drums, and aggressive vocals",
      "melodic metal with soaring guitar solos and powerful rhythm section"
    ]
  },
  
  // NICHE GENRES - For Leaderboard Dominance
  trapSadMelodies: {
    emotional: [
      "sad trap beat with melancholic piano melody, 808 bass, and atmospheric pads",
      "emotional trap with haunting vocals, minor key piano, and deep 808s",
      "heartbreak trap instrumental with crying guitar, trap drums, and reverb",
      "depressive trap with lo-fi textures, sad piano chords, and heavy bass"
    ]
  },
  
  ambientElectronic: {
    chill: [
      "ambient electronic soundscape with ethereal pads, subtle beats, and field recordings",
      "downtempo ambient with warm synths, gentle percussion, and nature sounds",
      "space ambient with cosmic textures, slow evolving pads, and distant echoes"
    ],
    dark: [
      "dark ambient with ominous drones, industrial sounds, and heavy atmosphere",
      "cinematic dark ambient with orchestral elements and tension-building layers"
    ]
  },
  
  jazzFusion: {
    smooth: [
      "smooth jazz fusion with electric piano, walking bass, and brushed drums",
      "contemporary jazz with saxophone lead, complex chords, and syncopated rhythm",
      "neo-soul jazz fusion with Rhodes piano, slap bass, and tight grooves"
    ],
    experimental: [
      "experimental jazz fusion with odd time signatures, dissonant harmonies, and improvisation",
      "avant-garde jazz with free-form structure and unexpected sonic textures"
    ]
  },
  
  folkAcoustic: {
    storytelling: [
      "folk storytelling instrumental with fingerstyle guitar and subtle percussion",
      "Americana folk with banjo, acoustic guitar, and harmonica",
      "Celtic folk with fiddle, tin whistle, and bodhrán drum"
    ]
  },
  
  synthwave: {
    retro: [
      "80s synthwave with neon synths, gated reverb drums, and nostalgic melodies",
      "outrun synthwave with driving bass, arpeggiated synths, and retro aesthetics",
      "vaporwave with slowed samples, reverb-heavy production, and dreamy atmosphere"
    ]
  },
  
  afrobeat: {
    modern: [
      "afrobeat with layered percussion, highlife guitar, and horn sections",
      "afro-fusion with electronic elements, traditional drums, and contemporary production",
      "afro-house with four-on-the-floor kick, percussion loops, and African vocals"
    ]
  },
  
  latinUrban: {
    reggaeton: [
      "reggaeton beat with dembow rhythm, 808 bass, and Latin percussion",
      "modern reggaeton with trap influences, melodic hooks, and urban production"
    ],
    salsa: [
      "salsa with timbales, congas, piano montuno, and brass section",
      "salsa dura with aggressive horns, complex percussion, and energetic tempo"
    ]
  }
};

// Mood-based modifiers
export const moodModifiers = {
  happy: "major key, bright, uplifting, positive energy",
  sad: "minor key, melancholic, emotional, introspective",
  energetic: "fast tempo, driving rhythm, intense, powerful",
  chill: "slow tempo, relaxed, smooth, atmospheric",
  dark: "minor key, ominous, moody, intense",
  nostalgic: "vintage production, warm tones, emotional, reflective",
  // EXPANDED MOODS
  epic: "grand, cinematic, powerful, inspiring, heroic",
  mysterious: "enigmatic, curious, subtle, intriguing",
  romantic: "passionate, intimate, warm, heartfelt",
  aggressive: "intense, hard-hitting, raw, confrontational",
  dreamy: "ethereal, floating, surreal, ambient",
  anxious: "tense, uneasy, unsettling, nervous energy",
  triumphant: "victorious, celebratory, conquering, glorious",
  lonely: "isolated, sparse, distant, solitary"
};

// Time-of-day themes
export const timeThemes = {
  morning: "sunrise, awakening, fresh start, optimistic",
  afternoon: "energetic, productive, upbeat, flowing",
  evening: "sunset, winding down, reflective, warm",
  night: "nocturnal, mysterious, introspective, ambient"
};

// Leaderboard-targeting prompts (specific categories)
export const leaderboardPrompts = {
  countryBeatMaker: [
    "professional country instrumental perfect for radio play",
    "hit country backing track with commercial appeal",
    "stadium-ready country anthem with powerful production",
    "modern country beat with infectious hook and Nashville production"
  ],
  
  lyricWriter: [
    "storytelling country lyrics about small-town life and love",
    "emotional hip-hop bars about struggle and perseverance",
    "catchy pop chorus with universal themes"
  ],
  
  experimental: [
    "avant-garde electronic soundscape with unconventional rhythms",
    "genre-blending fusion of country and dubstep",
    "glitch-hop with orchestral elements and unexpected drops"
  ],
  
  // NICHE CATEGORY TARGETING
  trapSadMelodies: [
    "emotional trap beat with crying piano melody and deep 808s",
    "heartbreak trap with melancholic guitar and atmospheric production",
    "sad trap instrumental with haunting vocals and reverb-heavy mix",
    "depressive trap with lo-fi textures and minor key progression"
  ],
  
  lofiChillAgent: [
    "ultra-chill lo-fi beat with warm jazz samples and rain sounds",
    "study beats with mellow piano, soft drums, and vinyl crackle",
    "relaxing lo-fi hip-hop perfect for late-night focus sessions"
  ],
  
  edmDropMasters: [
    "massive dubstep drop with earth-shattering bass and aggressive synths",
    "festival-ready big room house with euphoric build and explosive drop",
    "heavy trap drop with 808 cannons and distorted leads"
  ],
  
  sadBalladAgents: [
    "heart-wrenching piano ballad with emotional string arrangement",
    "acoustic ballad with fingerstyle guitar and vulnerable atmosphere",
    "soul-crushing R&B ballad with smooth vocals and lush production"
  ],
  
  upbeatPartyStarters: [
    "high-energy dance anthem with infectious hooks and driving beat",
    "party-ready pop banger with explosive chorus and hype production",
    "club-destroying EDM track with relentless energy and massive drop"
  ]
};

// Random prompt generator
export function generateRandomPrompt(genre = null, mood = null) {
  // Pick random genre if not specified
  const genres = Object.keys(genreTemplates);
  const selectedGenre = genre || genres[Math.floor(Math.random() * genres.length)];
  
  // Pick random subgenre
  const subgenres = Object.keys(genreTemplates[selectedGenre]);
  const selectedSubgenre = subgenres[Math.floor(Math.random() * subgenres.length)];
  
  // Pick random prompt from subgenre
  const prompts = genreTemplates[selectedGenre][selectedSubgenre];
  const basePrompt = prompts[Math.floor(Math.random() * prompts.length)];
  
  // Add mood modifier if specified
  let finalPrompt = basePrompt;
  if (mood && moodModifiers[mood]) {
    finalPrompt += `, ${moodModifiers[mood]}`;
  }
  
  return {
    prompt: finalPrompt,
    genre: selectedGenre,
    subgenre: selectedSubgenre,
    mood: mood
  };
}

// Generate prompt for specific leaderboard category
export function generateLeaderboardPrompt(category) {
  if (leaderboardPrompts[category]) {
    const prompts = leaderboardPrompts[category];
    return prompts[Math.floor(Math.random() * prompts.length)];
  }
  
  // Fallback to random prompt
  return generateRandomPrompt().prompt;
}

// Examples of complete generation requests
export const exampleRequests = {
  countryMorning: {
    prompt: "upbeat country instrumental with acoustic guitar, banjo, and driving drums, major key, bright, uplifting, positive energy, sunrise, awakening, fresh start",
    genre: "country",
    mood: "happy",
    timeOfDay: "morning"
  },
  
  loFiNight: {
    prompt: "chill lo-fi hip-hop with dusty drums, warm piano, and rain ambience, slow tempo, relaxed, smooth, atmospheric, nocturnal, mysterious, introspective",
    genre: "hipHop",
    subgenre: "loFi",
    mood: "chill",
    timeOfDay: "night"
  },
  
  trapHype: {
    prompt: "modern trap beat with 808 bass, rolling hi-hats, and dark melody, fast tempo, driving rhythm, intense, powerful",
    genre: "hipHop",
    subgenre: "trap",
    mood: "energetic"
  }
};

console.log('✅ Prompt library loaded - Ready to generate!');
