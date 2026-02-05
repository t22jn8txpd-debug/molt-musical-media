const required = ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY", "JWT_SECRET"];

function loadEnv() {
  if (!process.env.NODE_ENV || process.env.NODE_ENV !== "production") {
    // eslint-disable-next-line global-require
    require("dotenv").config();
  }

  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(", ")}`);
  }
}

module.exports = { loadEnv };
