import { describe, it, expect } from 'vitest';
import { findRoute, routeHasMiddleware } from './helpers/routes.mjs';

import postRouter from '../src/routes/posts.js';
import { authRequired } from '../src/middleware/auth.js';

describe("posts routes auth", () => {
  it("protects create post", () => {
    const route = findRoute(postRouter, "post", "/posts");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects like", () => {
    const route = findRoute(postRouter, "post", "/posts/:id/like");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects comment", () => {
    const route = findRoute(postRouter, "post", "/posts/:id/comment");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects remix", () => {
    const route = findRoute(postRouter, "post", "/posts/:id/remix");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});
