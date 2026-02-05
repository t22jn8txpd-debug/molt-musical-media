import { describe, it, expect } from "vitest";
import validationModule from "../src/utils/validation.js";
const { signupSchema, agentVerifySchema, profileSchema } = validationModule;

describe("validation schemas", () => {
  it("rejects short password", () => {
    const result = signupSchema.safeParse({
      email: "test@example.com",
      password: "short",
      username: "valid_name"
    });
    expect(result.success).toBe(false);
  });
  it("accepts valid signup payload", () => {
    const result = signupSchema.safeParse({
      email: "test@example.com",
      password: "long-enough-password",
      username: "valid_name"
    });
    expect(result.success).toBe(true);
  });
  it("rejects agent verify missing code", () => {
    const result = agentVerifySchema.safeParse({
      post_id_or_url: "abc",
      verification_code: "",
      moltbook_handle: "Agent1"
    });
    expect(result.success).toBe(false);
  });
  it("rejects profile with bad username", () => {
    const result = profileSchema.safeParse({
      username: "bad name"
    });
    expect(result.success).toBe(false);
  });
});