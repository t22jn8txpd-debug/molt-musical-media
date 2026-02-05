import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { findRoute, routeHasMiddleware } from "./helpers/routes.mjs";

const require = createRequire(import.meta.url);
const router = require("../src/routes/media");
const { authRequired } = require("../src/middleware/auth");

describe("media routes auth", () => {
  it("protects upload", () => {
    const route = findRoute(router, "post", "/media/upload");
    expect(route).toBeTruthy();
    expect(routeHasMiddleware(route, authRequired)).toBe(true);
  });
});
