import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

const require = createRequire(import.meta.url);
const router = require("../src/routes/projects").default;
const { authRequired } = require("../src/middleware/auth");

describe("projects endpoints auth", () => {
  it("protects create project", () => {
    const route = findRoute(router, "post", "/projects");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects list projects", () => {
    const route = findRoute(router, "get", "/projects");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });

  it("protects get project", () => {
    const route = findRoute(router, "get", "/projects/:id");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});
