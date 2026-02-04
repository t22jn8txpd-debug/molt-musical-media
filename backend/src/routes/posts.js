const express = require("express");
const { authRequired } = require("../middleware/auth");
const { contentLimiter, feedLimiter } = require("../middleware/rateLimit");
const {
  postCreateSchema,
  postCommentSchema,
  postRemixSchema,
  feedQuerySchema
} = require("../utils/validation");
const { sanitizeText, sanitizeTags } = require("../utils/sanitize");

const router = express.Router();

function normalizeTags(tags) {
  const cleaned = sanitizeTags(tags);
  return cleaned.length ? cleaned : [];
}

router.post("/posts", authRequired, contentLimiter, async (req, res, next) => {
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

router.get("/feed", feedLimiter, async (req, res, next) => {
  try {
    const query = feedQuerySchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);

    let request = req.supabase
      .from("posts")
      .select(
        "id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,original_post_id,media:media(id,url,type,metadata)"
      )
      .order("created_at", { ascending: false })
      .limit(limit);

    if (query.cursor) {
      request = request.lt("created_at", query.cursor);
    }

    if (query.tag) {
      request = request.contains("tags", [query.tag.toLowerCase()]);
    }

    const { data: posts, error } = await request;

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ posts, next_cursor: posts?.at(-1)?.created_at || null });
  } catch (err) {
    return next(err);
  }
});

router.get("/posts/:id", async (req, res, next) => {
  try {
    const postId = req.params.id;
    const { data: post, error } = await req.supabase
      .from("posts")
      .select(
        "id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,original_post_id,media:media(id,url,type,metadata)"
      )
      .eq("id", postId)
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ post });
  } catch (err) {
    return next(err);
  }
});

router.post("/posts/:id/like", authRequired, contentLimiter, async (req, res, next) => {
  try {
    const postId = req.params.id;
    const userId = req.user?.sub;

    const { data, error } = await req.supabase.rpc("like_post", {
      p_post_id: postId,
      p_user_id: userId
    });

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ success: true, likeCount: data });
  } catch (err) {
    return next(err);
  }
});

router.post("/posts/:id/comment", authRequired, contentLimiter, async (req, res, next) => {
  try {
    const postId = req.params.id;
    const payload = postCommentSchema.parse(req.body);
    const userId = req.user?.sub;
    const body = sanitizeText(payload.body, 500);

    const { data: comment, error } = await req.supabase
      .from("post_comments")
      .insert({
        post_id: postId,
        user_id: userId,
        body
      })
      .select("id,post_id,user_id,body,created_at")
      .single();

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(201).json({ comment });
  } catch (err) {
    return next(err);
  }
});

router.post("/posts/:id/remix", authRequired, contentLimiter, async (req, res, next) => {
  try {
    const postId = req.params.id;
    const payload = postRemixSchema.parse(req.body);
    const userId = req.user?.sub;
    const tags = normalizeTags(payload.tags);

    const { data: original, error: originalError } = await req.supabase
      .from("posts")
      .select("id,title")
      .eq("id", postId)
      .single();

    if (originalError) {
      if (originalError.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: originalError.message });
    }

    const title = sanitizeText(
      payload.title || `Remix of ${original.title}`,
      120
    );
    const description = payload.description ? sanitizeText(payload.description, 2000) : null;

    const { data: remixPost, error: remixError } = await req.supabase
      .from("posts")
      .insert({
        user_id: userId,
        content_url: payload.content_url,
        title,
        description,
        tags,
        original_post_id: postId
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
        p_post_id: postId
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

module.exports = router;
