import express from "express";
import { profileSchema, paginationSchema } from "../utils/validation.js";
import { authRequired } from "../middleware/auth.js";
import { findById, findByUsername, updateProfile } from "../db/userRepo.js";

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

router.get("/:id", async (req, res, next) => {
  try {
    const supabase = req.supabase;
    const user = await findById(supabase, req.params.id);
    if (!user) {
      return res.status(404).json({ error: "user_not_found" });
    }

    const { count: postCount, error: postCountError } = await supabase
      .from("posts")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id);

    if (postCountError) {
      return res.status(500).json({ error: "db_error", details: postCountError.message });
    }

    const { data: likeRows, error: likeError } = await supabase
      .from("posts")
      .select("likes_count")
      .eq("user_id", user.id);

    if (likeError) {
      return res.status(500).json({ error: "db_error", details: likeError.message });
    }

    const likeCount = (likeRows || []).reduce((sum, row) => sum + (row.likes_count || 0), 0);

    let followerCount = 0;
    const { count: followerCountResult, error: followerError } = await supabase
      .from("follows")
      .select("follower_id", { count: "exact", head: true })
      .eq("following_id", user.id);

    if (!followerError) {
      followerCount = followerCountResult || 0;
    }

    return res.status(200).json({
      user: {
        id: user.id,
        username: user.username,
        type: user.type,
        bio: user.bio,
        avatar_url: user.avatar_url,
        moltbook_handle: user.moltbook_handle,
        posts_count: postCount || 0,
        likes_count: likeCount,
        followers_count: followerCount
      }
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/:id/posts", async (req, res, next) => {
  try {
    const query = paginationSchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);

    let request = req.supabase
      .from("posts")
      .select(
        "id,user_id,content_url,title,description,tags,likes_count,remixes_count,plays_count,created_at,original_post_id,media:media(id,url,type,metadata)"
      )
      .eq("user_id", req.params.id)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (query.cursor) {
      request = request.lt("created_at", query.cursor);
    }

    const { data: posts, error } = await request;

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res
      .status(200)
      .json({ posts: posts || [], next_cursor: posts?.at(-1)?.created_at || null });
  } catch (err) {
    return next(err);
  }
});

export default router;
