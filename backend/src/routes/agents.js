import express from "express";
import { authRequired } from "../middleware/auth.js";
import { agentVerifySchema, postCreateSchema, agentInteractSchema } from "../utils/validation.js";
import { verifyMoltbookProof } from "../services/moltbook.js";
import { signToken } from "../utils/jwt.js";
import { sanitizeText, sanitizeTags } from "../utils/sanitize.js";
import {
  findByMoltbookHandle,
  findByUsername,
  createMolt
} from "../db/userRepo.js";

const router = express.Router();

function normalizeTags(tags) {
  const cleaned = sanitizeTags(tags);
  return cleaned.length ? cleaned : [];
}

router.post("/verify", async (req, res, next) => {
  try {
    const payload = agentVerifySchema.parse(req.body);
    const verification = await verifyMoltbookProof({
      postIdOrUrl: payload.post_id_or_url,
      verificationCode: payload.verification_code,
      moltbookHandle: payload.moltbook_handle
    });
    if (!verification.ok) {
      return res.status(400).json({ error: verification.error });
    }
    const supabase = req.supabase;
    const existingHandle = await findByMoltbookHandle(supabase, payload.moltbook_handle);
    if (existingHandle) {
      const token = signToken(existingHandle);
      return res.status(200).json({
        token,
        user: {
          id: existingHandle.id,
          username: existingHandle.username,
          type: existingHandle.type,
          moltbook_handle: existingHandle.moltbook_handle
        }
      });
    }
    const username = payload.username || payload.moltbook_handle;
    const existingUsername = await findByUsername(supabase, username);
    if (existingUsername) {
      return res.status(409).json({ error: "username_in_use" });
    }
    const user = await createMolt(supabase, {
      username,
      moltbookHandle: payload.moltbook_handle
    });
    const token = signToken(user);
    return res.status(201).json({
      token,
      user: {
        id: user.id,
        username: user.username,
        type: user.type,
        moltbook_handle: user.moltbook_handle
      }
    });
  } catch (err) {
    return next(err);
  }
});

router.post("/post", authRequired, async (req, res, next) => {
  try {
    const payload = postCreateSchema.parse(req.body);
    const userId = req.user?.sub;
    const tags = normalizeTags(payload.tags);
    const title = sanitizeText(payload.title, 120);
    const description = payload.description ? sanitizeText(payload.description, 2000) : null;
    const { data: post, error } = await req.supabase
      .from("posts")
      .insert({
        user_id: userId,
        content_url: payload.content_url,
        title,
        description,
        tags
      })
      .select(
        "id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,original_post_id"
      )
      .single();
    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }
    const mediaRows = [
      {
        post_id: post.id,
        url: payload.content_url,
        type: payload.content_type,
        metadata: {}
      }
    ];
    if (payload.media?.length) {
      payload.media.forEach((item) => {
        if (item.url !== payload.content_url) {
          mediaRows.push({
            post_id: post.id,
            url: item.url,
            type: item.type,
            metadata: item.metadata || {}
          });
        }
      });
    }
    const { data: media, error: mediaError } = await req.supabase.from("media").insert(mediaRows).select();
    if (mediaError) {
      return res.status(500).json({ error: "db_error", details: mediaError.message });
    }
    return res.status(201).json({ post, media });
  } catch (err) {
    return next(err);
  }
});

router.post("/interact", authRequired, async (req, res, next) => {
  try {
    const payload = agentInteractSchema.parse(req.body);
    const userId = req.user?.sub;
    if (payload.action === "like") {
      const { data, error } = await req.supabase.rpc("like_post", {
        p_post_id: payload.post_id,
        p_user_id: userId
      });
      if (error) {
        return res.status(500).json({ error: "db_error", details: error.message });
      }
      return res.status(200).json({ success: true, likeCount: data });
    }
    if (payload.action === "comment") {
      const body = sanitizeText(payload.body, 500);
      const { data: comment, error } = await req.supabase
        .from("post_comments")
        .insert({
          post_id: payload.post_id,
          user_id: userId,
          body
        })
        .select("id,post_id,user_id,body,created_at")
        .single();
      if (error) {
        return res.status(500).json({ error: "db_error", details: error.message });
      }
      return res.status(201).json({ comment });
    }
    const { data: original, error: originalError } = await req.supabase
      .from("posts")
      .select("id,title")
      .eq("id", payload.post_id)
      .single();
    if (originalError) {
      if (originalError.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: originalError.message });
    }
    const tags = normalizeTags(payload.tags);
    const title = sanitizeText(payload.title || `Remix of ${original.title}`, 120);
    const description = payload.description ? sanitizeText(payload.description, 2000) : null;
    const { data: remixPost, error: remixError } = await req.supabase
      .from("posts")
      .insert({
        user_id: userId,
        content_url: payload.content_url,
        title,
        description,
        tags,
        original_post_id: payload.post_id
      })
      .select(
        "id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,original_post_id"
      )
      .single();
    if (remixError) {
      return res.status(500).json({ error: "db_error", details: remixError.message });
    }
    const mediaRows = [
      {
        post_id: remixPost.id,
        url: payload.content_url,
        type: payload.content_type,
        metadata: {}
      }
    ];
    if (payload.media?.length) {
      payload.media.forEach((item) => {
        if (item.url !== payload.content_url) {
          mediaRows.push({
            post_id: remixPost.id,
            url: item.url,
            type: item.type,
            metadata: item.metadata || {}
          });
        }
      });
    }
    const { error: mediaError } = await req.supabase.from("media").insert(mediaRows);
    if (mediaError) {
      return res.status(500).json({ error: "db_error", details: mediaError.message });
    }
    const { data: remixCount, error: countError } = await req.supabase.rpc(
      "refresh_remix_count",
      {
        p_post_id: payload.post_id
      }
    );
    if (countError) {
      return res.status(500).json({ error: "db_error", details: countError.message });
    }
    return res.status(201).json({ remixPost, remixCount });
  } catch (err) {
    return next(err);
  }
});

export default router;