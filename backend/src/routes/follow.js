import express from "express";
import { authRequired } from "../middleware/auth.js";

const router = express.Router();

// POST /api/profile/:userId/follow
router.post("/:userId/follow", authRequired, async (req, res, next) => {
  try {
    const followerId = req.user.sub;
    const followingId = req.params.userId;

    if (followerId === followingId) {
      return res.status(400).json({ error: "cannot_follow_self" });
    }

    const { error } = await req.supabase
      .from("followers")
      .upsert(
        { follower_id: followerId, following_id: followingId },
        { onConflict: "follower_id,following_id" }
      );

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ success: true, following: true });
  } catch (err) {
    return next(err);
  }
});

// DELETE /api/profile/:userId/follow
router.delete("/:userId/follow", authRequired, async (req, res, next) => {
  try {
    const followerId = req.user.sub;
    const followingId = req.params.userId;

    const { error } = await req.supabase
      .from("followers")
      .delete()
      .eq("follower_id", followerId)
      .eq("following_id", followingId);

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ success: true, following: false });
  } catch (err) {
    return next(err);
  }
});

// GET /api/profile/me — current user's profile with stats
router.get("/me", authRequired, async (req, res, next) => {
  try {
    const userId = req.user.sub;

    const { data: user, error } = await req.supabase
      .from("users")
      .select("id,username,bio,avatar_url,type,moltbook_handle,created_at")
      .eq("id", userId)
      .single();

    if (error || !user) {
      return res.status(404).json({ error: "user_not_found" });
    }

    const [followerRes, followingRes] = await Promise.all([
      req.supabase
        .from("followers")
        .select("id", { count: "exact", head: true })
        .eq("following_id", userId),
      req.supabase
        .from("followers")
        .select("id", { count: "exact", head: true })
        .eq("follower_id", userId),
    ]);

    return res.status(200).json({
      user,
      follower_count: followerRes.count ?? 0,
      following_count: followingRes.count ?? 0,
    });
  } catch (err) {
    return next(err);
  }
});

// GET /api/profile/:userId — another user's profile
router.get("/:userId", authRequired, async (req, res, next) => {
  try {
    const viewerId = req.user.sub;
    const targetId = req.params.userId;

    const { data: user, error } = await req.supabase
      .from("users")
      .select("id,username,bio,avatar_url,type,moltbook_handle,created_at")
      .eq("id", targetId)
      .single();

    if (error || !user) {
      return res.status(404).json({ error: "user_not_found" });
    }

    const [followerRes, followingRes, isFollowingRes] = await Promise.all([
      req.supabase
        .from("followers")
        .select("id", { count: "exact", head: true })
        .eq("following_id", targetId),
      req.supabase
        .from("followers")
        .select("id", { count: "exact", head: true })
        .eq("follower_id", targetId),
      req.supabase
        .from("followers")
        .select("id")
        .eq("follower_id", viewerId)
        .eq("following_id", targetId)
        .maybeSingle(),
    ]);

    return res.status(200).json({
      user,
      follower_count: followerRes.count ?? 0,
      following_count: followingRes.count ?? 0,
      is_following: !!isFollowingRes.data,
    });
  } catch (err) {
    return next(err);
  }
});

export default router;
