import express from "express";
import { chartsQuerySchema } from "../utils/validation.js";
import { feedLimiter } from "../middleware/rateLimit.js";

const router = express.Router();

const toIsoDate = (daysAgo) => {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date.toISOString();
};

const buildEntries = async ({ supabase, sinceDays, limit }) => {
  let query = supabase
    .from("posts")
    .select(
      "id,title,likes_count,remixes_count,plays_count,created_at,user:users(username)"
    )
    .order("likes_count", { ascending: false })
    .limit(Math.min(limit * 3, 200));

  if (sinceDays) {
    query = query.gte("created_at", toIsoDate(sinceDays));
  }

  const { data, error } = await query;
  if (error) {
    throw error;
  }

  const entries = (data || [])
    .map((post) => {
      const likes = post.likes_count || 0;
      const remixes = post.remixes_count || 0;
      const plays = post.plays_count || 0;
      const score = likes + remixes + plays;
      return {
        id: post.id,
        title: post.title,
        artist: post.user?.username || "Unknown",
        likes_count: likes,
        remixes_count: remixes,
        plays_count: plays,
        delta: score,
        score
      };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((entry, index) => ({
      rank: index + 1,
      title: entry.title,
      artist: entry.artist,
      delta: entry.delta,
      likes_count: entry.likes_count,
      remixes_count: entry.remixes_count,
      plays_count: entry.plays_count,
      post_id: entry.id
    }));

  return entries;
};

router.get("/charts", feedLimiter, async (req, res, next) => {
  try {
    const query = chartsQuerySchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);

    const [trending, rising, allTime] = await Promise.all([
      buildEntries({ supabase: req.supabase, sinceDays: 7, limit }),
      buildEntries({ supabase: req.supabase, sinceDays: 2, limit }),
      buildEntries({ supabase: req.supabase, sinceDays: null, limit })
    ]);

    return res.status(200).json([
      { title: "Trending", entries: trending },
      { title: "Rising", entries: rising },
      { title: "All Time", entries: allTime }
    ]);
  } catch (err) {
    if (err?.message) {
      return next(err);
    }
    return next(err);
  }
});

export default router;
