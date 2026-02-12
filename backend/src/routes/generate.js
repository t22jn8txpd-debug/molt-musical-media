import express from 'express';
import { authRequired } from '../middleware/auth.js';
import { generateTrackSchema } from '../utils/validation.js';
import { generateTrack } from '../services/musicgen.js';
import { decryptKeys } from './profile.js';

const router = express.Router();

// POST /api/generate/track
router.post('/track', authRequired, async (req, res, next) => {
  try {
    const payload = generateTrackSchema.parse(req.body);

    // Check if user has BYOK Suno key
    const { data: user } = await req.supabase
      .from('users')
      .select('api_keys_encrypted')
      .eq('id', req.user.sub)
      .single();

    let useSuno = false;
    if (user?.api_keys_encrypted) {
      try {
        const keys = decryptKeys(user.api_keys_encrypted);
        if (keys.suno_key) {
          useSuno = true;
          // TODO: Implement Suno API integration when available
          // For now, fall through to MusicGen
        }
      } catch {
        // Decryption failed, proceed with MusicGen
      }
    }

    // Create a generation job record
    const jobId = crypto.randomUUID();
    await req.supabase.from('generation_jobs').insert({
      id: jobId,
      user_id: req.user.sub,
      prompt: payload.prompt,
      status: 'pending',
      metadata: {
        genre: payload.genre,
        mood: payload.mood,
        duration_seconds: payload.duration_seconds,
        instrumental: payload.instrumental,
        engine: useSuno ? 'suno' : 'musicgen'
      }
    });

    // Generate the track
    const result = await generateTrack({
      prompt: payload.prompt,
      duration: payload.duration_seconds || 30,
      genre: payload.genre,
      mood: payload.mood,
      instrumental: payload.instrumental
    });

    // Update job as completed
    await req.supabase
      .from('generation_jobs')
      .update({
        status: 'completed',
        result_url: result.audioUrl,
        metadata: result.metadata,
        completed_at: new Date().toISOString()
      })
      .eq('id', jobId);

    return res.status(200).json({
      track: {
        audioUrl: result.audioUrl,
        title: payload.prompt.slice(0, 120),
        duration: payload.duration_seconds || 30,
        tags: [payload.genre, payload.mood].filter(Boolean),
        metadata: result.metadata
      }
    });
  } catch (err) {
    return next(err);
  }
});

// GET /api/generate/status/:jobId
router.get('/status/:jobId', authRequired, async (req, res, next) => {
  try {
    const { data: job, error } = await req.supabase
      .from('generation_jobs')
      .select('*')
      .eq('id', req.params.jobId)
      .eq('user_id', req.user.sub)
      .single();

    if (error || !job) {
      return res.status(404).json({ error: 'job_not_found' });
    }

    const response = { status: job.status };
    if (job.status === 'completed') {
      response.track = {
        audioUrl: job.result_url,
        metadata: job.metadata
      };
    }

    return res.status(200).json(response);
  } catch (err) {
    return next(err);
  }
});

export default router;
