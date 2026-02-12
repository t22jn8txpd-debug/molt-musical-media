import { uploadBuffer } from './cloudinary.js';
import crypto from 'crypto';

const HF_API_URL = 'https://api-inference.huggingface.co/models/facebook/musicgen-small';

function buildPrompt({ prompt, genre, mood, instrumental }) {
  const parts = [prompt];
  if (genre) parts.push(genre);
  if (mood) parts.push(mood);
  if (instrumental) parts.push('instrumental');
  return parts.join(', ');
}

function generateMockAudio() {
  // Generate a tiny valid WAV file (silence) as fallback
  const sampleRate = 22050;
  const duration = 5;
  const numSamples = sampleRate * duration;
  const dataSize = numSamples * 2;
  const buffer = Buffer.alloc(44 + dataSize);

  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write('WAVE', 8);
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20); // PCM
  buffer.writeUInt16LE(1, 22); // mono
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * 2, 28);
  buffer.writeUInt16LE(2, 32);
  buffer.writeUInt16LE(16, 34);
  buffer.write('data', 36);
  buffer.writeUInt32LE(dataSize, 40);
  // Rest is zeros (silence)

  return buffer;
}

/**
 * Generate a music track using Hugging Face MusicGen model.
 * Falls back to mock audio if HF is unavailable.
 */
export async function generateTrack({ prompt, duration = 30, genre, mood, instrumental }) {
  const fullPrompt = buildPrompt({ prompt, genre, mood, instrumental });
  const jobId = crypto.randomUUID();
  let audioBuffer;
  let source = 'musicgen';

  try {
    const headers = { 'Content-Type': 'application/json' };
    if (process.env.HUGGINGFACE_API_KEY) {
      headers.Authorization = `Bearer ${process.env.HUGGINGFACE_API_KEY}`;
    }

    const response = await fetch(HF_API_URL, {
      method: 'POST',
      headers,
      body: JSON.stringify({ inputs: fullPrompt }),
      signal: AbortSignal.timeout(120_000)
    });

    if (!response.ok) {
      const text = await response.text().catch(() => '');
      console.error(`HF API error ${response.status}: ${text}`);
      throw new Error(`hf_api_error_${response.status}`);
    }

    audioBuffer = Buffer.from(await response.arrayBuffer());
  } catch (err) {
    console.warn('MusicGen unavailable, using mock fallback:', err.message);
    audioBuffer = generateMockAudio();
    source = 'mock';
  }

  // Upload to Cloudinary
  const result = await uploadBuffer({
    buffer: audioBuffer,
    filename: `musicgen-${jobId}`,
    resourceType: 'video', // Cloudinary uses 'video' for audio
    folder: 'molt/generated',
    tags: [genre, mood, 'generated'].filter(Boolean)
  });

  const metadata = {
    jobId,
    prompt: fullPrompt,
    duration,
    genre: genre || null,
    mood: mood || null,
    instrumental: !!instrumental,
    source,
    model: 'facebook/musicgen-small',
    generatedAt: new Date().toISOString()
  };

  return {
    audioUrl: result.secure_url,
    metadata
  };
}
