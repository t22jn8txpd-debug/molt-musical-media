import express from "express";

const router = express.Router();

router.post("/moltbook", async (req, res, next) => {
  try {
    const secret = process.env.MOLTBOOK_WEBHOOK_SECRET;
    if (secret) {
      const signature = req.headers["x-moltbook-signature"];
      if (!signature || signature !== secret) {
        return res.status(401).json({ error: "invalid_signature" });
      }
    }

    const payload = req.body || {};
    const eventType = payload?.type || payload?.event || "unknown";

    const { error } = await req.supabase.from("webhook_events").insert({
      source: "moltbook",
      event_type: eventType,
      payload
    });

    if (error) {
      return res.status(500).json({ error: "db_error", details: error.message });
    }

    return res.status(202).json({ received: true });
  } catch (err) {
    return next(err);
  }
});

export default router;
