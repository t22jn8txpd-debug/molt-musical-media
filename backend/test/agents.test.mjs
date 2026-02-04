import { describe, it, expect, beforeAll } from "vitest";
import request from "supertest";
import appModule from "../src/app.js";

const { app } = appModule;

beforeAll(() => {
  process.env.SUPABASE_URL = process.env.SUPABASE_URL || "http://localhost:54321";
  process.env.SUPABASE_SERVICE_ROLE_KEY =
    process.env.SUPABASE_SERVICE_ROLE_KEY || "test-key";
  process.env.JWT_SECRET = process.env.JWT_SECRET || "test-secret";
});

describe("agent endpoints auth", () => {
  it("rejects agent post without token", async () => {
    const response = await request(app).post("/api/agents/post").send({
      content_url: "https://example.com/track.mp3",
      content_type: "audio",
      title: "Agent track"
    });
    expect(response.status).toBe(401);
  });

  it("rejects agent interact without token", async () => {
    const response = await request(app).post("/api/agents/interact").send({
      action: "like",
      post_id: "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    });
    expect(response.status).toBe(401);
  });
});
