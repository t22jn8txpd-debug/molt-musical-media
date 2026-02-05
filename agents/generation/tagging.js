/**
 * Auto-Tagging System for Music Tracks
 * Analyzes prompts and generates relevant tags for leaderboards/discovery
 */

// Genre detection patterns
const genrePatterns = {
  country: /country|acoustic|banjo|fiddle|steel guitar|honky.?tonk|americana/i,
  hipHop: /hip.?hop|rap|trap|boom.?bap|lo.?fi|beats/i,
  edm: /edm|electronic|house|dubstep|trance|techno|bass music/i,
  pop: /pop|radio|catchy|mainstream/i,
  rock: /rock|guitar|metal|punk|grunge/i,
  jazz: /jazz|swing|bebop|smooth|fusion/i,
  classical: /classical|orchestra|symphony|piano concerto/i,
  rnb: /r&b|soul|neo.?soul|contemporary r&b/i,
  reggae: /reggae|dancehall|ska|dub/i,
  latin: /latin|salsa|reggaeton|bachata|dembow|afrobeat|afro/i,
  // NICHE GENRES
  ambient: /ambient|soundscape|atmospheric|ethereal/i,
  synthwave: /synthwave|vaporwave|outrun|retro.?wave/i,
  folk: /folk|celtic|fingerstyle/i,
  experimental: /experimental|avant.?garde|glitch|noise/i
};

// Subgenre detection
const subgenrePatterns = {
  // Country
  countryRock: /country rock/i,
  countryPop: /country pop/i,
  honkyTonk: /honky.?tonk/i,
  bluegrass: /bluegrass/i,
  americana: /americana/i,
  
  // Hip-Hop
  boomBap: /boom.?bap|90s|old.?school/i,
  trap: /trap|808/i,
  loFi: /lo.?fi|chill beats|study/i,
  trapSadMelodies: /sad trap|emotional trap|heartbreak trap|depressive trap/i,
  
  // EDM
  house: /house|four.?on.?the.?floor/i,
  dubstep: /dubstep|wobble|bass drop/i,
  trance: /trance|uplifting|progressive/i,
  techno: /techno/i,
  drumAndBass: /drum.?and.?bass|dnb/i,
  
  // Niche EDM
  synthwave: /synthwave|vaporwave|outrun/i,
  afroHouse: /afro.?house/i,
  
  // Jazz
  jazzFusion: /jazz fusion|fusion|contemporary jazz/i,
  smoothJazz: /smooth jazz/i,
  
  // Ambient
  darkAmbient: /dark ambient/i,
  spaceAmbient: /space ambient|cosmic/i,
  
  // Latin
  reggaeton: /reggaeton|dembow/i,
  salsa: /salsa/i,
  afrobeat: /afrobeat|afro.?beat/i
};

// Mood detection
const moodPatterns = {
  happy: /happy|upbeat|joyful|cheerful|bright|positive|uplifting/i,
  sad: /sad|melancholic|emotional|heartfelt|somber|blue|crying|heartbreak|depressive/i,
  energetic: /energetic|intense|powerful|driving|hype/i,
  chill: /chill|relaxed|smooth|mellow|calm|peaceful/i,
  dark: /dark|ominous|moody|haunting/i,
  romantic: /romantic|love|passionate|intimate/i,
  nostalgic: /nostalgic|vintage|retro|throwback/i,
  epic: /epic|cinematic|grand|massive|anthem/i,
  // EXPANDED MOODS
  aggressive: /aggressive|hard.?hitting|raw|confrontational|brutal/i,
  dreamy: /dreamy|ethereal|floating|surreal|ambient/i,
  mysterious: /mysterious|enigmatic|curious|subtle|intriguing/i,
  anxious: /anxious|tense|uneasy|unsettling|nervous/i,
  triumphant: /triumphant|victorious|celebratory|conquering|glorious/i,
  lonely: /lonely|isolated|sparse|distant|solitary/i
};

// Tempo detection
const tempoPatterns = {
  slow: /slow|ballad|downtempo|under 90 bpm/i,
  medium: /moderate|mid.?tempo|90.?120 bpm/i,
  fast: /fast|up.?tempo|energetic|over 120 bpm/i,
  variable: /varying tempo|dynamic/i
};

// Instrumentation detection
const instrumentPatterns = {
  // Strings
  acousticGuitar: /acoustic guitar/i,
  electricGuitar: /electric guitar|distorted guitar/i,
  bass: /bass|bassline|808/i,
  
  // Keys
  piano: /piano|keys/i,
  synth: /synth|electronic/i,
  organ: /organ/i,
  
  // Percussion
  drums: /drums|percussion|beat/i,
  hiHat: /hi.?hat/i,
  
  // Unique
  banjo: /banjo/i,
  fiddle: /fiddle|violin/i,
  steelGuitar: /steel guitar|pedal steel/i,
  saxophone: /sax|saxophone/i,
  trumpet: /trumpet|horn/i
};

// Vocal detection
const vocalPatterns = {
  instrumental: /instrumental|no vocals|backing track/i,
  vocals: /vocals|singing|singer|voice/i,
  rap: /rap|bars|flow|16s/i,
  harmonies: /harmonies|choir|group vocals/i
};

// Purpose/Use Case tags
const purposePatterns = {
  radio: /radio|commercial|hit|mainstream/i,
  workout: /workout|gym|training|exercise/i,
  study: /study|focus|concentration/i,
  party: /party|club|dance floor/i,
  relaxation: /relax|meditation|sleep|ambient/i,
  driving: /driving|road trip|highway/i
};

/**
 * Auto-generate tags from a prompt
 * @param {string} prompt - The generation prompt
 * @param {object} metadata - Optional metadata (bpm, duration, etc.)
 * @returns {object} - Tags categorized by type
 */
export function autoTag(prompt, metadata = {}) {
  const tags = {
    genres: [],
    subgenres: [],
    moods: [],
    tempo: null,
    instruments: [],
    vocals: null,
    purposes: [],
    leaderboardCategories: []
  };
  
  // Detect genres
  for (const [genre, pattern] of Object.entries(genrePatterns)) {
    if (pattern.test(prompt)) {
      tags.genres.push(genre);
    }
  }
  
  // Detect subgenres
  for (const [subgenre, pattern] of Object.entries(subgenrePatterns)) {
    if (pattern.test(prompt)) {
      tags.subgenres.push(subgenre);
    }
  }
  
  // Detect moods
  for (const [mood, pattern] of Object.entries(moodPatterns)) {
    if (pattern.test(prompt)) {
      tags.moods.push(mood);
    }
  }
  
  // Detect tempo (from BPM if available)
  if (metadata.bpm) {
    if (metadata.bpm < 90) tags.tempo = 'slow';
    else if (metadata.bpm < 120) tags.tempo = 'medium';
    else tags.tempo = 'fast';
  } else {
    // Detect from prompt
    for (const [tempo, pattern] of Object.entries(tempoPatterns)) {
      if (pattern.test(prompt)) {
        tags.tempo = tempo;
        break;
      }
    }
  }
  
  // Detect instruments
  for (const [instrument, pattern] of Object.entries(instrumentPatterns)) {
    if (pattern.test(prompt)) {
      tags.instruments.push(instrument);
    }
  }
  
  // Detect vocals
  for (const [vocalType, pattern] of Object.entries(vocalPatterns)) {
    if (pattern.test(prompt)) {
      tags.vocals = vocalType;
      break;
    }
  }
  
  // Detect purposes
  for (const [purpose, pattern] of Object.entries(purposePatterns)) {
    if (pattern.test(prompt)) {
      tags.purposes.push(purpose);
    }
  }
  
  // Determine leaderboard categories to target
  tags.leaderboardCategories = determineLeaderboardCategories(tags);
  
  return tags;
}

/**
 * Determine which leaderboard categories this track should compete in
 * @param {object} tags - The generated tags
 * @returns {array} - List of leaderboard category identifiers
 */
function determineLeaderboardCategories(tags) {
  const categories = ['overall']; // Always compete in overall
  
  // Genre-specific leaderboards
  if (tags.genres.includes('country')) {
    categories.push('country-beat-makers');
  }
  if (tags.genres.includes('hipHop')) {
    categories.push('hip-hop-producers');
  }
  if (tags.genres.includes('edm')) {
    categories.push('edm-drop-masters');
  }
  if (tags.genres.includes('pop')) {
    categories.push('pop-producers');
  }
  
  // Mood-specific leaderboards
  if (tags.moods.includes('sad')) {
    categories.push('sad-ballads');
  }
  if (tags.moods.includes('energetic') || tags.moods.includes('happy')) {
    categories.push('upbeat-party-starters');
  }
  if (tags.moods.includes('chill')) {
    categories.push('lofi-chill-agents');
  }
  if (tags.moods.includes('epic') || tags.moods.includes('triumphant')) {
    categories.push('epic-anthem-makers');
  }
  if (tags.moods.includes('dark') || tags.moods.includes('mysterious')) {
    categories.push('dark-ambient-producers');
  }
  
  // Subgenre-specific leaderboards
  if (tags.subgenres.includes('trapSadMelodies')) {
    categories.push('trap-sad-melodies');
  }
  if (tags.subgenres.includes('loFi')) {
    categories.push('lofi-chill-agents');
  }
  if (tags.subgenres.includes('dubstep') || tags.subgenres.includes('trap')) {
    categories.push('edm-drop-masters');
  }
  
  // Vocal/instrumental leaderboards
  if (tags.vocals === 'instrumental') {
    categories.push('instrumental-beat-makers');
  }
  if (tags.vocals === 'rap') {
    categories.push('lyric-writers');
  }
  
  // Experimental
  if (tags.genres.length > 2) {
    categories.push('experimental-agents');
  }
  
  return categories;
}

/**
 * Generate a human-readable tag summary
 * @param {object} tags - The generated tags
 * @returns {string} - Formatted summary
 */
export function formatTagSummary(tags) {
  const parts = [];
  
  if (tags.genres.length > 0) {
    parts.push(`Genres: ${tags.genres.join(', ')}`);
  }
  
  if (tags.moods.length > 0) {
    parts.push(`Moods: ${tags.moods.join(', ')}`);
  }
  
  if (tags.tempo) {
    parts.push(`Tempo: ${tags.tempo}`);
  }
  
  if (tags.vocals) {
    parts.push(`Vocals: ${tags.vocals}`);
  }
  
  if (tags.instruments.length > 0) {
    parts.push(`Instruments: ${tags.instruments.slice(0, 3).join(', ')}`);
  }
  
  if (tags.leaderboardCategories.length > 0) {
    parts.push(`Competing in: ${tags.leaderboardCategories.join(', ')}`);
  }
  
  return parts.join(' | ');
}

/**
 * Example usage and testing
 */
export function testTagging() {
  const testPrompts = [
    "upbeat country instrumental with acoustic guitar, banjo, and driving drums",
    "chill lo-fi hip-hop with dusty drums, warm piano, and rain ambience",
    "modern trap beat with 808 bass, rolling hi-hats, and dark melody",
    "emotional country ballad with acoustic guitar and gentle strings"
  ];
  
  console.log('\n🏷️  Testing Auto-Tagging System:\n');
  
  testPrompts.forEach((prompt, i) => {
    console.log(`Test ${i + 1}: "${prompt}"`);
    const tags = autoTag(prompt);
    console.log(formatTagSummary(tags));
    console.log('---\n');
  });
}

// Run tests if executed directly
if (typeof require !== 'undefined' && require.main === module) {
  testTagging();
}

console.log('✅ Auto-tagging system loaded - Ready to categorize tracks!');
