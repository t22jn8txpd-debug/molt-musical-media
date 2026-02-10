import express from "express";
import { searchQuerySchema } from "../utils/validation.js";
import { feedLimiter } from "../middleware/rateLimit.js";

const router = express.Router();

router.get("/search", feedLimiter, async (req, res, next) => {
  try {
    const query = searchQuerySchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);
    const keyword = query.q.trim();

    const { data: posts, error: postError } = await req.supabase.rpc("search_posts", {
      p_query: keyword,
      p_limit: limit
    });

    if (postError) {
      return res.status(500).json({ error: "db_error", details: postError.message });
    }

    const { data: users, error: userError } = await req.supabase
      .from("users")
      .select("id,username,avatar_url,bio,type")
      .ilike("username", `%${keyword}%`)
      .limit(limit);

    if (userError) {
      return res.status(500).json({ error: "db_error", details: userError.message });
    }

    return res.status(200).json({ posts: posts || [], users: users || [] });
  } catch (err) {
    return next(err);
  }
});

export default router;
