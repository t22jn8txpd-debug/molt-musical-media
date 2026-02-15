import express from "express";
import { z } from "zod";
import { authRequired } from "../middleware/auth.js";
import { sanitizeText, sanitizeTags } from "../utils/sanitize.js";

const router = express.Router();

const albumCreateSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(2000).optional(),
  cover_url: z.string().url().optional(),
  tags: z.array(z.string().min(1).max(32)).max(20).optional(),
  tracks: z.array(z.object({
    title: z.string().min(1).max(120),
    content_url: z.string().url(),
    content_type: z.enum(["audio", "video"]).default("audio"),
    description: z.string().max(2000).optional(),
  })).min(2).max(30),
});

// POST /api/albums — create album with tracks
router.post("/", authRequired, async (req, res, next) => {
  try {
    const payload = albumCreateSchema.parse(req.body);
    const userId = req.user.sub;
    const tags = sanitizeTags(payload.tags || []);

    // Create album
    const { data: album, error: albumError } = await req.supabase
      .from("albums")
      .insert({
        user_id: userId,
        title: sanitizeText(payload.title, 200),
        description: payload.description ? sanitizeText(payload.description, 2000) : null,
        cover_url: payload.cover_url || null,
        tags,
      })
      .select()
      .single();

    if (albumError) {
      return res.status(500).json({ error: "db_error", details: albumError.message });
    }

    // Create posts for each track, linked to album
    const posts = [];
    for (const track of payload.tracks) {
      const { data: post, error: postError } = await req.supabase
        .from("posts")
        .insert({
          user_id: userId,
          content_url: track.content_url,
          title: sanitizeText(track.title, 120),
          description: track.description ? sanitizeText(track.description, 2000) : null,
          tags,
          album_id: album.id,
        })
        .select("id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,album_id")
        .single();

      if (postError) {
        return res.status(500).json({ error: "db_error", details: postError.message });
      }

      // Insert media row
      await req.supabase.from("media").insert({
        post_id: post.id,
        url: track.content_url,
        type: track.content_type,
        metadata: {},
      });

      // If album has cover, add it as image media
      if (payload.cover_url) {
        await req.supabase.from("media").insert({
          post_id: post.id,
          url: payload.cover_url,
          type: "image",
          metadata: { is_album_cover: true },
        });
      }

      posts.push(post);
    }

    return res.status(201).json({ album, posts });
  } catch (err) {
    return next(err);
  }
});

// GET /api/albums/:id — get album with tracks
router.get("/:id", async (req, res, next) => {
  try {
    const { data: album, error } = await req.supabase
      .from("albums")
      .select("*")
      .eq("id", req.params.id)
      .single();

    if (error || !album) {
      return res.status(404).json({ error: "not_found" });
    }

    const { data: tracks } = await req.supabase
      .from("posts")
      .select("id,user_id,content_url,title,description,tags,likes_count,remixes_count,created_at,media:media(id,url,type,metadata)")
      .eq("album_id", album.id)
      .order("created_at", { ascending: true });

    return res.status(200).json({ album, tracks: tracks || [] });
  } catch (err) {
    return next(err);
  }
});

// GET /api/albums/user/:userId — list user's albums
router.get("/user/:userId", async (req, res, next) => {
  try {
    const { data: albums, error } = await req.supabase
      .from("albums")
      .select("id,title,cover_url,tags,created_at")
      .eq("user_id", req.params.userId)
      .order("created_at", { ascending: false })
      .limit(20);

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ albums });
  } catch (err) {
    return next(err);
  }
});

export default router;
