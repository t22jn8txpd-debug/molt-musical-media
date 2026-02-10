import { describe, it, expect, beforeEach } from "vitest";
import postsRouter from "../src/routes/posts.js";
import { findRoute } from "./helpers/routes.mjs";
import { runRoute } from "./helpers/routeRunner.mjs";
import { createSupabaseMock } from "./helpers/supabaseMock.mjs";
import { signToken } from "../src/utils/jwt.js";

const createRoute = findRoute(postsRouter, "post", "/posts");
const readRoute = findRoute(postsRouter, "get", "/posts/:id");
const likeRoute = findRoute(postsRouter, "post", "/posts/:id/like");
const commentRoute = findRoute(postsRouter, "post", "/posts/:id/comment");
const remixRoute = findRoute(postsRouter, "post", "/posts/:id/remix");

describe("posts flow", () => {
  let token;
  let supabase;

  beforeEach(() => {
    process.env.JWT_SECRET = "test-secret";
    token = signToken({
      id: "user-1",
      email: "user@example.com",
      username: "user1",
      type: "human"
    });
    supabase = createSupabaseMock();
  });

  it("creates, reads, likes, comments, and remixes a post", async () => {
    const createRes = await runRoute(createRoute, {
      method: "post",
      headers: { authorization: `Bearer ${token}` },
      body: {
        content_url: "https://example.com/track.mp3",
        content_type: "audio",
        title: "First track",
        tags: ["hiphop"]
      },
      supabase
    });

    expect(createRes.statusCode).toBe(201);
    const postId = createRes.body?.post?.id;
    expect(postId).toBeTruthy();

    const readRes = await runRoute(readRoute, {
      method: "get",
      params: { id: postId },
      supabase
    });

    expect(readRes.statusCode).toBe(200);
    expect(readRes.body?.post?.id).toBe(postId);

    const likeRes = await runRoute(likeRoute, {
      method: "post",
      params: { id: postId },
      headers: { authorization: `Bearer ${token}` },
      supabase
    });

    expect(likeRes.statusCode).toBe(200);
    expect(likeRes.body?.likeCount).toBeGreaterThan(0);

    const commentRes = await runRoute(commentRoute, {
      method: "post",
      params: { id: postId },
      headers: { authorization: `Bearer ${token}` },
      body: { body: "Nice track" },
      supabase
    });

    expect(commentRes.statusCode).toBe(201);
    expect(commentRes.body?.comment?.body).toBe("Nice track");

    const remixRes = await runRoute(remixRoute, {
      method: "post",
      params: { id: postId },
      headers: { authorization: `Bearer ${token}` },
      body: {
        content_url: "https://example.com/remix.mp3",
        content_type: "audio",
        title: "Remix track"
      },
      supabase
    });

    expect(remixRes.statusCode).toBe(201);
    expect(remixRes.body?.remixPost?.original_post_id).toBe(postId);
  });
});
