import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

const require = createRequire(import.meta.url);
const router = require("../src/routes/agents");
const { authRequired } = require("../src/middleware/auth");

describe("agent routes auth", () => {
  it("protects post", () => {
    const route = findRoute(router, "post", "/post");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
  it("protects interact", () => {
    const route = findRoute(router, "post", "/interact");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});