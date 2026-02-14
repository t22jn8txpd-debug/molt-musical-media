import { describe, it, expect, beforeEach } from "vitest";
import postsRouter from "../src/routes/posts.js";
import { findRoute } from "./helpers/routes.mjs";
import { runRoute } from "./helpers/routeRunner.mjs";
import { createSupabaseMock } from "./helpers/supabaseMock.mjs";

const createRoute = findRoute(postsRouter, "post", "/posts");
const supabase = createSupabaseMock();

beforeEach(() => {
  process.env.JWT_SECRET = "test-secret";
});

describe("auth middleware", () => {
  it("rejects missing token", async () => {
    const res = await runRoute(createRoute, {
      method: "post",
      body: {
        content_url: "https://example.com/track.mp3",
        content_type: "audio",
        title: "Test"
      },
      supabase
    });

    expect(res.statusCode).toBe(401);
    expect(res.body?.error).toBe("missing_token");
  });

  it("rejects invalid token", async () => {
    const res = await runRoute(createRoute, {
      method: "post",
      headers: { authorization: "Bearer invalid" },
      body: {
        content_url: "https://example.com/track.mp3",
        content_type: "audio",
        title: "Test"
      },
      supabase
    });

    expect(res.statusCode).toBe(401);
    expect(res.body?.error).toBe("invalid_token");
  });
});
