// SQL migration required:
// ALTER TABLE users ADD COLUMN IF NOT EXISTS api_keys_encrypted jsonb;

import express from "express";
import crypto from "crypto";
import { profileSchema, apiKeysUpdateSchema } from "../utils/validation.js";
import { authRequired } from "../middleware/auth.js";
import { findById, findByUsername, updateProfile } from "../db/userRepo.js";

const ENCRYPTION_KEY = process.env.API_KEYS_ENCRYPTION_KEY || crypto.randomBytes(32).toString('hex');
const KEY_BUFFER = Buffer.from(ENCRYPTION_KEY, 'hex');

export function encryptKeys(obj) {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', KEY_BUFFER, iv);
  const plaintext = JSON.stringify(obj);
  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const tag = cipher.getAuthTag().toString('hex');
  return { iv: iv.toString('hex'), encrypted, tag };
}

export function decryptKeys(envelope) {
  const { iv, encrypted, tag } = envelope;
  const decipher = crypto.createDecipheriv('aes-256-gcm', KEY_BUFFER, Buffer.from(iv, 'hex'));
  decipher.setAuthTag(Buffer.from(tag, 'hex'));
  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  return JSON.parse(decrypted);
}

const router = express.Router();

router.get("/me", authRequired, async (req, res, next) => {
  try {
    const supabase = req.supabase;
    const user = await findById(supabase, req.user.sub);
    if (!user) {
      return res.status(404).json({ error: "user_not_found" });
    }

    return res.status(200).json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        type: user.type,
        bio: user.bio,
        avatar_url: user.avatar_url,
        moltbook_handle: user.moltbook_handle
      }
    });
  } catch (err) {
    return next(err);
  }
});

router.put("/", authRequired, async (req, res, next) => {
  try {
    const payload = profileSchema.parse(req.body);
    if (payload.username) {
      const existing = await findByUsername(req.supabase, payload.username);
      if (existing && existing.id !== req.user.sub) {
        return res.status(409).json({ error: "username_in_use" });
      }
    }

    const user = await updateProfile(req.supabase, req.user.sub, {
      username: payload.username,
      bio: payload.bio,
      avatarUrl: payload.avatar_url
    });

    return res.status(200).json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        type: user.type,
        bio: user.bio,
        avatar_url: user.avatar_url,
        moltbook_handle: user.moltbook_handle
      }
    });
  } catch (err) {
    return next(err);
  }
});

// PUT /api/profile/api-keys
router.put('/api-keys', authRequired, async (req, res, next) => {
  try {
    const payload = apiKeysUpdateSchema.parse(req.body);

    // Get existing keys to merge
    const { data: user } = await req.supabase
      .from('users')
      .select('api_keys_encrypted')
      .eq('id', req.user.sub)
      .single();

    let existing = {};
    if (user?.api_keys_encrypted) {
      try { existing = decryptKeys(user.api_keys_encrypted); } catch { /* ignore */ }
    }

    // Merge new keys
    const merged = { ...existing };
    if (payload.suno_key !== undefined) merged.suno_key = payload.suno_key;
    if (payload.udio_key !== undefined) merged.udio_key = payload.udio_key;

    const encrypted = encryptKeys(merged);

    const { error } = await req.supabase
      .from('users')
      .update({ api_keys_encrypted: encrypted })
      .eq('id', req.user.sub);

    if (error) throw error;

    return res.status(200).json({
      suno_connected: !!merged.suno_key,
      udio_connected: !!merged.udio_key
    });
  } catch (err) {
    return next(err);
  }
});

// GET /api/profile/api-keys
router.get('/api-keys', authRequired, async (req, res, next) => {
  try {
    const { data: user } = await req.supabase
      .from('users')
      .select('api_keys_encrypted')
      .eq('id', req.user.sub)
      .single();

    if (!user?.api_keys_encrypted) {
      return res.status(200).json({ suno_connected: false, udio_connected: false });
    }

    try {
      const keys = decryptKeys(user.api_keys_encrypted);
      return res.status(200).json({
        suno_connected: !!keys.suno_key,
        udio_connected: !!keys.udio_key
      });
    } catch {
      return res.status(200).json({ suno_connected: false, udio_connected: false });
    }
  } catch (err) {
    return next(err);
  }
});

export default router;
