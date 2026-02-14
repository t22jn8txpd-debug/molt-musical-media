import { describe, it, expect, beforeEach, vi } from "vitest";
import agentsRouter from "../src/routes/agents.js";
import { findRoute } from "./helpers/routes.mjs";
import { runRoute } from "./helpers/routeRunner.mjs";

vi.mock("../src/db/userRepo.js", () => ({
  findByMoltbookHandle: vi.fn(),
  findByUsername: vi.fn(),
  createMolt: vi.fn()
}));

const userRepo = await import("../src/db/userRepo.js");
const verifyRoute = findRoute(agentsRouter, "post", "/verify");

beforeEach(() => {
  vi.clearAllMocks();
  process.env.JWT_SECRET = "test-secret";
  process.env.MOLTBOOK_ALLOW_MOCK = "true";
});

describe("agent verify flow", () => {
  it("creates a new molt when handle is unused", async () => {
    userRepo.findByMoltbookHandle.mockResolvedValue(null);
    userRepo.findByUsername.mockResolvedValue(null);
    userRepo.createMolt.mockResolvedValue({
      id: "agent-1",
      username: "agent",
      type: "agent",
      moltbook_handle: "agent"
    });

    const res = await runRoute(verifyRoute, {
      method: "post",
      body: {
        post_id_or_url: "post-1",
        verification_code: "DEV-123456",
        moltbook_handle: "agent"
      },
      supabase: {}
    });

    expect(res.statusCode).toBe(201);
    expect(res.body?.token).toBeTruthy();
    expect(res.body?.user?.moltbook_handle).toBe("agent");
  });

  it("returns existing molt when handle already registered", async () => {
    userRepo.findByMoltbookHandle.mockResolvedValue({
      id: "agent-1",
      username: "agent",
      type: "agent",
      moltbook_handle: "agent"
    });

    const res = await runRoute(verifyRoute, {
      method: "post",
      body: {
        post_id_or_url: "post-1",
        verification_code: "DEV-123456",
        moltbook_handle: "agent"
      },
      supabase: {}
    });

    expect(res.statusCode).toBe(200);
    expect(res.body?.token).toBeTruthy();
  });
});
