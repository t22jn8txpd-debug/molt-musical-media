import express from "express";
import { z } from "zod";
import { authRequired } from "../middleware/auth.js";
import { sanitizeText } from "../utils/sanitize.js";

const router = express.Router();

const draftSchema = z.object({
  title: z.string().max(200).optional(),
  lyrics_text: z.string().max(10000),
  genre: z.string().max(50).optional(),
  mood: z.string().max(50).optional(),
  structure: z.string().max(500).optional(),
});

// POST /api/lyrics/drafts — save a new draft
router.post("/drafts", authRequired, async (req, res, next) => {
  try {
    const payload = draftSchema.parse(req.body);
    const userId = req.user.sub;

    const { data: draft, error } = await req.supabase
      .from("lyric_drafts")
      .insert({
        user_id: userId,
        title: payload.title ? sanitizeText(payload.title, 200) : "Untitled",
        lyrics_json: {
          text: payload.lyrics_text,
          structure: payload.structure || null,
        },
        genre: payload.genre || null,
        mood: payload.mood || null,
      })
      .select()
      .single();

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(201).json({ draft });
  } catch (err) {
    return next(err);
  }
});

// GET /api/lyrics/drafts — list user's drafts
router.get("/drafts", authRequired, async (req, res, next) => {
  try {
    const userId = req.user.sub;
    const { data: drafts, error } = await req.supabase
      .from("lyric_drafts")
      .select("id,title,genre,mood,created_at,updated_at")
      .eq("user_id", userId)
      .order("updated_at", { ascending: false })
      .limit(50);

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ drafts });
  } catch (err) {
    return next(err);
  }
});

// GET /api/lyrics/drafts/:id — get a single draft
router.get("/drafts/:id", authRequired, async (req, res, next) => {
  try {
    const { data: draft, error } = await req.supabase
      .from("lyric_drafts")
      .select("*")
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub)
      .single();

    if (error || !draft) {
      return res.status(404).json({ error: "not_found" });
    }

    return res.status(200).json({ draft });
  } catch (err) {
    return next(err);
  }
});

// PUT /api/lyrics/drafts/:id — update a draft
router.put("/drafts/:id", authRequired, async (req, res, next) => {
  try {
    const payload = draftSchema.parse(req.body);
    const { data: draft, error } = await req.supabase
      .from("lyric_drafts")
      .update({
        title: payload.title ? sanitizeText(payload.title, 200) : undefined,
        lyrics_json: {
          text: payload.lyrics_text,
          structure: payload.structure || null,
        },
        genre: payload.genre || null,
        mood: payload.mood || null,
        updated_at: new Date().toISOString(),
      })
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub)
      .select()
      .single();

    if (error || !draft) {
      return res.status(404).json({ error: "not_found" });
    }

    return res.status(200).json({ draft });
  } catch (err) {
    return next(err);
  }
});

// DELETE /api/lyrics/drafts/:id — delete a draft
router.delete("/drafts/:id", authRequired, async (req, res, next) => {
  try {
    const { error } = await req.supabase
      .from("lyric_drafts")
      .delete()
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub);

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ success: true });
  } catch (err) {
    return next(err);
  }
});

// POST /api/lyrics/generate — AI lyrics generation
const generateSchema = z.object({
  topic: z.string().max(500),
  genres: z.array(z.string()).optional(),
  mood: z.string().max(50).optional(),
});

router.post("/generate", authRequired, async (req, res, next) => {
  try {
    const payload = generateSchema.parse(req.body);
    const genre = payload.genres?.[0] || "pop";
    const mood = payload.mood || "energetic";
    const topic = sanitizeText(payload.topic, 500);

    // Simple template-based lyrics generation (no external API needed)
    const lyrics = [
      `[Verse 1]`,
      `Writing about ${topic}, feeling the ${mood} vibe`,
      `In this ${genre} world, where we come alive`,
      `Every word we speak is a brand new line`,
      `Every beat we drop is a sign of the time`,
      ``,
      `[Chorus]`,
      `${topic} on my mind, can't let it go`,
      `The rhythm takes me places I want to know`,
      `${topic} in my heart, feel it in my soul`,
      `This ${genre} sound is making me whole`,
      ``,
      `[Verse 2]`,
      `From the highs to the lows, we ride the wave`,
      `Every moment counts, every word we gave`,
      `The ${mood} energy keeps us moving on`,
      `Until the break of dawn, we carry on`,
      ``,
      `[Bridge]`,
      `Let the music speak what words cannot say`,
      `In this moment right here, we find our way`,
      ``,
      `[Chorus]`,
      `${topic} on my mind, can't let it go`,
      `The rhythm takes me higher than before`,
    ].join("\n");

    return res.status(200).json({ lyrics });
  } catch (err) {
    return next(err);
  }
});

export default router;
