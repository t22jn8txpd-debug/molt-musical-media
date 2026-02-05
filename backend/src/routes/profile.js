const express = require("express");
const { profileSchema } = require("../utils/validation");
const { authRequired } = require("../middleware/auth");
const { findById, findByUsername, updateProfile } = require("../db/userRepo");

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

module.exports = router;
