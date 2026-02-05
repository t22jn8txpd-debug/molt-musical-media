import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

const require = createRequire(import.meta.url);
const router = require("../src/routes/posts");
const { authRequired } = require("../src/middleware/auth");

describe("posts routes auth", () => {
  it("protects create post", () => {
    const route = findRoute(router, "post", "/posts");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects like", () => {
    const route = findRoute(router, "post", "/posts/:id/like");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects comment", () => {
    const route = findRoute(router, "post", "/posts/:id/comment");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects remix", () => {
    const route = findRoute(router, "post", "/posts/:id/remix");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});
