import { describe, it, expect, beforeEach, vi } from "vitest";
import authRouter from "../src/routes/auth.js";
import { findRoute } from "./helpers/routes.mjs";
import { runRoute } from "./helpers/routeRunner.mjs";
import { verifyToken } from "../src/utils/jwt.js";

vi.mock("../src/db/userRepo.js", () => ({
  findByEmail: vi.fn(),
  findByUsername: vi.fn(),
  createHuman: vi.fn(),
  updateLoginTimestamp: vi.fn()
}));

vi.mock("../src/services/captcha.js", () => ({
  verifyCaptcha: vi.fn(async () => ({ ok: true }))
}));

vi.mock("bcryptjs", () => ({
  default: {
    hash: vi.fn(async () => "hashed-password"),
    compare: vi.fn(async () => true)
  },
  hash: vi.fn(async () => "hashed-password"),
  compare: vi.fn(async () => true)
}));

const userRepo = await import("../src/db/userRepo.js");
const signupRoute = findRoute(authRouter, "post", "/signup");
const loginRoute = findRoute(authRouter, "post", "/login");

beforeEach(() => {
  vi.clearAllMocks();
  process.env.JWT_SECRET = "test-secret";
});

describe("auth flow", () => {
  it("signs up and returns a valid token", async () => {
    userRepo.findByEmail.mockResolvedValue(null);
    userRepo.findByUsername.mockResolvedValue(null);
    userRepo.createHuman.mockResolvedValue({
      id: "user-1",
      email: "test@example.com",
      username: "tester",
      type: "human"
    });

    const res = await runRoute(signupRoute, {
      method: "post",
      body: {
        email: "test@example.com",
        username: "tester",
        password: "long-enough-password",
        captcha_token: "captcha"
      },
      supabase: {}
    });

    expect(res.statusCode).toBe(201);
    expect(res.body?.token).toBeTruthy();

    const payload = verifyToken(res.body.token, "test-secret");
    expect(payload.sub).toBe("user-1");
    expect(payload.email).toBe("test@example.com");
  });

  it("logs in and returns a valid token", async () => {
    userRepo.findByEmail.mockResolvedValue({
      id: "user-1",
      email: "test@example.com",
      username: "tester",
      type: "human",
      password_hash: "hashed-password"
    });
    userRepo.updateLoginTimestamp.mockResolvedValue();

    const res = await runRoute(loginRoute, {
      method: "post",
      body: {
        email: "test@example.com",
        password: "long-enough-password",
        captcha_token: "captcha"
      },
      supabase: {}
    });

    expect(res.statusCode).toBe(200);
    expect(res.body?.token).toBeTruthy();

    const payload = verifyToken(res.body.token, "test-secret");
    expect(payload.sub).toBe("user-1");
  });
});
