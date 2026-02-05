const { describe, it, expect, beforeAll } = require("vitest");
const request = require("supertest");
const jwt = require("jsonwebtoken");
const { app } = require("../src/app");

beforeAll(() => {
  process.env.SUPABASE_URL = process.env.SUPABASE_URL || "http://localhost:54321";
  process.env.SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "test-key";
  process.env.JWT_SECRET = process.env.JWT_SECRET || "test-secret";
  process.env.JWT_ISSUER = process.env.JWT_ISSUER || "molt-musical-media";
  process.env.JWT_AUDIENCE = process.env.JWT_AUDIENCE || "molt-app";
});

function makeToken() {
  return jwt.sign(
    {
      sub: "test-user-id",
      type: "human",
      username: "tester"
    },
    process.env.JWT_SECRET,
    {
      issuer: process.env.JWT_ISSUER,
      audience: process.env.JWT_AUDIENCE,
      expiresIn: "1h"
    }
  );
}

describe("media upload", () => {
  it("rejects upload without token", async () => {
    const response = await request(app).post("/api/media/upload");
    expect(response.status).toBe(401);
  });

  it("rejects upload without file", async () => {
    const token = makeToken();
    const response = await request(app)
      .post("/api/media/upload")
      .set("Authorization", `Bearer ${token}`)
      .field("type", "audio");

    expect(response.status).toBe(400);
    expect(response.body?.error).toBe("missing_file");
  });
});
