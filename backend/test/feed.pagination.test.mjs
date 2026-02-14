import { describe, it, expect } from "vitest";
import postsRouter from "../src/routes/posts.js";
import { findRoute } from "./helpers/routes.mjs";
import { runRoute } from "./helpers/routeRunner.mjs";
import { createSupabaseMock } from "./helpers/supabaseMock.mjs";

const feedRoute = findRoute(postsRouter, "get", "/feed");

const supabase = createSupabaseMock({
  posts: [
    {
      id: "post-1",
      user_id: "user-1",
      title: "First",
      content_url: "https://example.com/1.mp3",
      tags: ["hiphop"],
      created_at: "2024-01-03T10:00:00.000Z"
    },
    {
      id: "post-2",
      user_id: "user-2",
      title: "Second",
      content_url: "https://example.com/2.mp3",
      tags: ["hiphop"],
      created_at: "2024-01-02T10:00:00.000Z"
    },
    {
      id: "post-3",
      user_id: "user-3",
      title: "Third",
      content_url: "https://example.com/3.mp3",
      tags: ["lofi"],
      created_at: "2024-01-01T10:00:00.000Z"
    }
  ]
});

describe("feed pagination", () => {
  it("returns next_cursor and respects limit", async () => {
    const res = await runRoute(feedRoute, {
      method: "get",
      query: { limit: "2" },
      supabase
    });

    expect(res.statusCode).toBe(200);
    expect(res.body?.posts?.length).toBe(2);
    expect(res.body?.next_cursor).toBe("2024-01-02T10:00:00.000Z");
  });

  it("applies cursor filtering", async () => {
    const res = await runRoute(feedRoute, {
      method: "get",
      query: { limit: "2", cursor: "2024-01-02T10:00:00.000Z" },
      supabase
    });

    expect(res.statusCode).toBe(200);
    expect(res.body?.posts?.length).toBe(1);
    expect(res.body?.posts?.[0]?.id).toBe("post-3");
  });
});
