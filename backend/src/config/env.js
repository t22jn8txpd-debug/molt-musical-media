import dotenv from "dotenv";

const required = ["JWT_SECRET"];
const optional = ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"];

export function loadEnv() {
  if (!process.env.NODE_ENV || process.env.NODE_ENV !== "production") {
    dotenv.config();
  }

  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(", ")}`);
  }

  const missingOptional = optional.filter((key) => !process.env[key]);
  if (missingOptional.length > 0) {
    console.warn(`⚠️  Optional env vars not set: ${missingOptional.join(", ")}`);
  }
}
