import { describe, it, expect } from "vitest";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

import router from "../src/routes/agents.js";
import { authRequired } from "../src/middleware/auth.js";

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
