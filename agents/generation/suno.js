/**
 * Suno API Integration
 * Generate music tracks using Suno's AI music generation API
 */

import { autoTag, formatTagSummary } from './tagging.js';
import { generateRandomPrompt } from './prompts.js';

// Configuration (will be loaded from env variables)
const SUNO_API_KEY = process.env.SUNO_API_KEY || 'your-api-key-here';
const SUNO_API_URL = 'https://api.suno.ai/v1'; // Placeholder URL

/**
 * Generate a music track using Suno API
 * @param {object} options - Generation options
 * @returns {Promise<object>} - Generated track data
 */
export async function generateTrack(options = {}) {
  const {
    prompt = null,
    genre = null,
    mood = null,
    duration = 120, // seconds
    style = null,
    instrumental = true
  } = options;
  
  // Generate prompt if not provided
  let finalPrompt;
  let promptMeta;
  if (!prompt) {
    promptMeta = generateRandomPrompt(genre, mood);
    finalPrompt = promptMeta.prompt;
  } else {
    finalPrompt = prompt;
  }
  
  // Add instrumental marker if needed
  if (instrumental) {
    finalPrompt += ', instrumental, no vocals';
  }
  
  console.log(`🎵 Generating track with Suno...`);
  console.log(`Prompt: "${finalPrompt}"`);
  
  try {
    // TODO: Actual API call once Suno API is set up
    // For now, return mock data for testing
    const mockResponse = await mockSunoGeneration(finalPrompt, duration);
    
    // Auto-tag the generated track
    const tags = autoTag(finalPrompt, { duration });
    
    console.log(`✅ Track generated!`);
    console.log(`Tags: ${formatTagSummary(tags)}`);
    
    return {
      success: true,
      track: mockResponse.track,
      prompt: finalPrompt,
      tags: tags,
      metadata: {
        duration: duration,
        generatedAt: new Date().toISOString(),
        generator: 'suno',
        ...promptMeta
      }
    };
    
  } catch (error) {
    console.error('❌ Suno generation failed:', error.message);
    return {
      success: false,
      error: error.message
    };
  }
}

/**
 * Actual Suno API call (to be implemented)
 */
async function callSunoAPI(prompt, duration, style) {
  // TODO: Implement real API call
  // const response = await fetch(`${SUNO_API_URL}/generate`, {
  //   method: 'POST',
  //   headers: {
  //     'Authorization': `Bearer ${SUNO_API_KEY}`,
  //     'Content-Type': 'application/json'
  //   },
  //   body: JSON.stringify({
  //     prompt: prompt,
  //     duration: duration,
  //     style: style,
  //     wait: true // Wait for generation to complete
  //   })
  // });
  // 
  // if (!response.ok) {
  //   throw new Error(`Suno API error: ${response.status}`);
  // }
  // 
  // return await response.json();
  
  throw new Error('Suno API not implemented yet - waiting for API key');
}

/**
 * Mock generation for testing (before real API is set up)
 */
async function mockSunoGeneration(prompt, duration) {
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Return mock track data
  return {
    track: {
      id: `mock-${Date.now()}`,
      title: generateTitleFromPrompt(prompt),
      audioUrl: `https://mock-storage.com/tracks/${Date.now()}.mp3`,
      waveformUrl: `https://mock-storage.com/waveforms/${Date.now()}.png`,
      duration: duration,
      status: 'completed'
    }
  };
}

/**
 * Generate a track title from the prompt
 */
function generateTitleFromPrompt(prompt) {
  // Extract genre/mood keywords
  const keywords = prompt.match(/\b(country|hip.?hop|edm|pop|rock|upbeat|chill|emotional|dark)\b/gi) || [];
  
  // Random title templates
  const templates = [
    'Sunrise',
    'Midnight Drive',
    'Lost in Thought',
    'Golden Hour',
    'Neon Dreams',
    'Dusty Roads',
    'City Lights',
    'Endless Summer'
  ];
  
  const baseTitle = templates[Math.floor(Math.random() * templates.length)];
  
  // Add genre prefix if detected
  if (keywords.length > 0) {
    const genre = keywords[0].charAt(0).toUpperCase() + keywords[0].slice(1).toLowerCase();
    return `${genre} ${baseTitle}`;
  }
  
  return baseTitle;
}

/**
 * Batch generate multiple tracks
 * @param {number} count - Number of tracks to generate
 * @param {object} options - Shared generation options
 * @returns {Promise<array>} - Array of generated tracks
 */
export async function batchGenerate(count = 3, options = {}) {
  console.log(`\n🎵 Batch generating ${count} tracks...`);
  
  const results = [];
  
  for (let i = 0; i < count; i++) {
    console.log(`\n--- Track ${i + 1}/${count} ---`);
    const result = await generateTrack(options);
    results.push(result);
    
    // Add delay between generations to avoid rate limits
    if (i < count - 1) {
      console.log('⏳ Waiting 5 seconds before next generation...');
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
  
  const successful = results.filter(r => r.success).length;
  console.log(`\n✅ Batch complete: ${successful}/${count} tracks generated successfully`);
  
  return results;
}

/**
 * Test the generation system
 */
export async function testGeneration() {
  console.log('\n🎵 Testing Suno Generation System:\n');
  
  // Test 1: Random generation
  console.log('=== Test 1: Random Track ===');
  await generateTrack();
  
  // Test 2: Specific genre/mood
  console.log('\n=== Test 2: Country Upbeat ===');
  await generateTrack({ genre: 'country', mood: 'happy' });
  
  // Test 3: Custom prompt
  console.log('\n=== Test 3: Custom Prompt ===');
  await generateTrack({ 
    prompt: 'epic cinematic orchestral music with powerful drums and soaring strings',
    duration: 180
  });
}

// Run tests if executed directly
if (typeof require !== 'undefined' && require.main === module) {
  testGeneration();
}

console.log('✅ Suno integration loaded - Ready to generate music!');
