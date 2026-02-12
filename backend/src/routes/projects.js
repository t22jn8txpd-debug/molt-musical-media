import express from "express";
import { authRequired } from "../middleware/auth.js";
import { contentLimiter } from "../middleware/rateLimit.js";
import { projectCreateSchema, projectUpdateSchema, paginationSchema } from "../utils/validation.js";

const router = express.Router();

router.post("/projects", authRequired, contentLimiter, async (req, res, next) => {
  try {
    const payload = projectCreateSchema.parse(req.body);
    const { data: project, error } = await req.supabase
      .from("projects")
      .insert({
        user_id: req.user.sub,
        title: payload.title,
        bpm: payload.bpm,
        key: payload.key,
        genre: payload.genre,
        data: payload.data || {}
      })
      .select("id,user_id,title,bpm,key,genre,data,created_at,updated_at")
      .single();

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(201).json({ project });
  } catch (err) {
    return next(err);
  }
});

router.get("/projects", authRequired, async (req, res, next) => {
  try {
    const query = paginationSchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);
    const cursor = query.cursor;

    let request = req.supabase
      .from("projects")
      .select("id,user_id,title,bpm,key,genre,data,created_at,updated_at")
      .eq("user_id", req.user.sub)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (cursor) {
      request = request.lt("created_at", cursor);
    }

    const { data: projects, error } = await request;

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res
      .status(200)
      .json({ projects: projects || [], next_cursor: projects?.at(-1)?.created_at || null });
  } catch (err) {
    return next(err);
  }
});

router.get("/projects/:id", authRequired, async (req, res, next) => {
  try {
    const { data: project, error } = await req.supabase
      .from("projects")
      .select("id,user_id,title,bpm,key,genre,data,created_at,updated_at")
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub)
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ project });
  } catch (err) {
    return next(err);
  }
});

router.put("/projects/:id", authRequired, contentLimiter, async (req, res, next) => {
  try {
    const payload = projectUpdateSchema.parse(req.body);
    const { data: project, error } = await req.supabase
      .from("projects")
      .update({
        title: payload.title,
        bpm: payload.bpm,
        key: payload.key,
        genre: payload.genre,
        data: payload.data
      })
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub)
      .select("id,user_id,title,bpm,key,genre,data,created_at,updated_at")
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ project });
  } catch (err) {
    return next(err);
  }
});

router.delete("/projects/:id", authRequired, async (req, res, next) => {
  try {
    const { error } = await req.supabase
      .from("projects")
      .delete()
      .eq("id", req.params.id)
      .eq("user_id", req.user.sub);

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

export default router;
