import { describe, it, expect } from "vitest";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

import router from "../src/routes/media.js";
import { authRequired } from "../src/middleware/auth.js";

describe("media routes auth", () => {
  it("protects upload", () => {
    const route = findRoute(router, "post", "/media/upload");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});
