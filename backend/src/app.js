import express from "express";
import helmet from "helmet";
import cors from "cors";
import { getSupabaseAdmin } from "./db/supabase.js";
import { authLimiter, agentLimiter, webhookLimiter } from "./middleware/rateLimit.js";
import { errorHandler } from "./middleware/error.js";
import authRoutes from "./routes/auth.js";
import agentRoutes from "./routes/agents.js";
import profileRoutes from "./routes/profile.js";
import postRoutes from "./routes/posts.js";
import mediaRoutes from "./routes/media.js";
import notificationRoutes from "./routes/notifications.js";
import webhookRoutes from "./routes/webhooks.js";

const app = express();

app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*" }));
app.use(express.json({ limit: "1mb" }));

app.use((req, res, next) => {
  const startedAt = Date.now();
  res.on("finish", () => {
    if (process.env.NODE_ENV === "test") {
      return;
    }
    const durationMs = Date.now() - startedAt;
    // eslint-disable-next-line no-console
    console.log(`${req.method} ${req.originalUrl} ${res.statusCode} ${durationMs}ms`);
  });
  next();
});

app.use((req, res, next) => {
  req.supabase = getSupabaseAdmin();
  next();
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.use("/api/auth", authLimiter, authRoutes);
app.use("/api/agents", agentLimiter, agentRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/webhooks", webhookLimiter, webhookRoutes);
app.use("/api", postRoutes);
app.use("/api", mediaRoutes);

app.use((err, req, res, next) => {
  if (err?.name === "ZodError") {
    return res.status(400).json({ error: "validation_error", details: err.errors });
  }
  return next(err);
});

app.use(errorHandler);

export { app };
