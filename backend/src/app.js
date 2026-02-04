const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const { getSupabaseAdmin } = require("./db/supabase");
const { authLimiter, agentLimiter } = require("./middleware/rateLimit");
const { errorHandler } = require("./middleware/error");
const authRoutes = require("./routes/auth");
const agentRoutes = require("./routes/agents");
const profileRoutes = require("./routes/profile");

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || "*" }));
app.use(express.json({ limit: "1mb" }));

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

app.use((err, req, res, next) => {
  if (err?.name === "ZodError") {
    return res.status(400).json({ error: "validation_error", details: err.errors });
  }
  return next(err);
});

app.use(errorHandler);

module.exports = { app };
