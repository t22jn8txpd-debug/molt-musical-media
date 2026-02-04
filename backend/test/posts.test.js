const { describe, it, expect, beforeAll } = require("vitest");
const request = require("supertest");
const { app } = require("../src/app");

beforeAll(() => {
  process.env.SUPABASE_URL = process.env.SUPABASE_URL || "http://localhost:54321";
  process.env.SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "test-key";
  process.env.JWT_SECRET = process.env.JWT_SECRET || "test-secret";
});

describe("posts endpoints auth", () => {
  it("returns 200 for health", async () => {
    const response = await request(app).get("/health");
    expect(response.status).toBe(200);
  });

  it("rejects create post without token", async () => {
    const response = await request(app).post("/api/posts").send({
      content_url: "https://example.com/track.mp3",
      content_type: "audio",
      title: "Test track"
    });
    expect(response.status).toBe(401);
  });

  it("rejects like without token", async () => {
    const response = await request(app).post("/api/posts/123/like");
    expect(response.status).toBe(401);
  });

  it("rejects comment without token", async () => {
    const response = await request(app).post("/api/posts/123/comment").send({
      body: "Nice"
    });
    expect(response.status).toBe(401);
  });

  it("rejects remix without token", async () => {
    const response = await request(app).post("/api/posts/123/remix").send({
      content_url: "https://example.com/remix.mp3",
      content_type: "audio"
    });
    expect(response.status).toBe(401);
  });
});
