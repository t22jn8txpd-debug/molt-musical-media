const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const { getSupabaseAdmin } = require("./db/supabase");
const { authLimiter, agentLimiter } = require("./middleware/rateLimit");
const { errorHandler } = require("./middleware/error");
const authRoutes = require("./routes/auth");
const agentRoutes = require("./routes/agents");
const profileRoutes = require("./routes/profile");
const postRoutes = require("./routes/posts");

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
app.use("/api", postRoutes);

app.use((err, req, res, next) => {
  if (err?.name === "ZodError") {
    return res.status(400).json({ error: "validation_error", details: err.errors });
  }
  return next(err);
});

app.use(errorHandler);

module.exports = { app };
