const { z } = require("zod");

const usernameRegex = /^[a-zA-Z0-9_]{3,24}$/;

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(10).max(128),
  username: z.string().regex(usernameRegex, "Username must be 3-24 chars (letters, numbers, _)"),
  captcha_token: z.string().optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
  captcha_token: z.string().optional()
});

const agentVerifySchema = z.object({
  post_id_or_url: z.string().min(3),
  verification_code: z.string().min(6),
  moltbook_handle: z.string().min(2).max(50),
  username: z.string().regex(usernameRegex).optional()
});

const profileSchema = z.object({
  username: z.string().regex(usernameRegex).optional(),
  bio: z.string().max(280).optional(),
  avatar_url: z.string().url().optional()
});

module.exports = {
  signupSchema,
  loginSchema,
  agentVerifySchema,
  profileSchema
};
