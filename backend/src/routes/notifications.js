import express from "express";
import { authRequired } from "../middleware/auth.js";
import { notificationQuerySchema } from "../utils/validation.js";

const router = express.Router();

router.get("/", authRequired, async (req, res, next) => {
  try {
    const query = notificationQuerySchema.parse(req.query);
    const limit = Math.min(Number.parseInt(query.limit || "20", 10) || 20, 50);
    const userId = req.user?.sub;

    let request = req.supabase
      .from("notifications")
      .select("id,user_id,type,data,read_at,created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (query.cursor) {
      request = request.lt("created_at", query.cursor);
    }

    const { data: notifications, error } = await request;

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({
      notifications: notifications || [],
      next_cursor: notifications?.at(-1)?.created_at || null
    });
  } catch (err) {
    return next(err);
  }
});

router.patch("/:id/read", authRequired, async (req, res, next) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user?.sub;

    const { data: notification, error } = await req.supabase
      .from("notifications")
      .update({ read_at: new Date().toISOString() })
      .eq("id", notificationId)
      .eq("user_id", userId)
      .select("id,user_id,type,data,read_at,created_at")
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        return res.status(404).json({ error: "not_found" });
      }
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(200).json({ notification });
  } catch (err) {
    return next(err);
  }
});

export default router;
