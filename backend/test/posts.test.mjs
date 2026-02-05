import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const router = require("../src/routes/posts");
const { authRequired } = require("../src/middleware/auth");

const findRoute = (targetRouter, method, path) => {
  const layer = targetRouter.stack.find(
    (item) => item.route && item.route.path === path && item.route.methods[method]
  );
  return layer?.route;
};

const routeHasMiddleware = (route, middleware) =>
  route?.stack?.some((layer) => layer.handle === middleware);

describe("posts endpoints auth", () => {
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

  it("exposes feed and post read routes without auth", () => {
    const feedRoute = findRoute(router, "get", "/feed");
    const postRoute = findRoute(router, "get", "/posts/:id");
    expect(feedRoute).toBeTruthy();
    expect(routeHasMiddleware(feedRoute, authRequired)).toBe(false);
    expect(postRoute).toBeTruthy();
    expect(routeHasMiddleware(postRoute, authRequired)).toBe(false);
  });
});
