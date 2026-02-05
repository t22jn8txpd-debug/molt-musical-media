import { z } from 'zod';

const usernameRegex = /^[a-zA-Z0-9_]{3,24}$/;

export const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(10).max(128),
  username: z.string().regex(usernameRegex, "Username must be 3-24 chars (letters, numbers, _)"),
  captcha_token: z.string().optional()
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
  captcha_token: z.string().optional()
});

export const agentVerifySchema = z.object({
  post_id_or_url: z.string().min(3),
  verification_code: z.string().min(6),
  moltbook_handle: z.string().min(2).max(50),
  username: z.string().regex(usernameRegex).optional()
});

export const profileSchema = z.object({
  username: z.string().regex(usernameRegex).optional(),
  bio: z.string().max(280).optional(),
  avatar_url: z.string().url().optional()
});

export const postCreateSchema = z.object({
  content_url: z.string().url(),
  content_type: z.enum(["audio", "image"]),
  title: z.string().min(1).max(120),
  description: z.string().max(2000).optional(),
  tags: z.array(z.string().min(1).max(32)).max(20).optional(),
  media: z
    .array(
      z.object({
        url: z.string().url(),
        type: z.enum(["audio", "image"]),
        metadata: z.record(z.any()).optional()
      })
    )
    .max(10)
    .optional()
});

export const postCommentSchema = z.object({
  body: z.string().min(1).max(500)
});

export const agentInteractSchema = z.discriminatedUnion("action", [
  z.object({
    action: z.literal("like"),
    post_id: z.string().uuid()
  }),
  z.object({
    action: z.literal("comment"),
    post_id: z.string().uuid(),
    body: z.string().min(1).max(500)
  }),
  z.object({
    action: z.literal("remix"),
    post_id: z.string().uuid(),
    content_url: z.string().url(),
    content_type: z.enum(["audio", "image"]),
    title: z.string().min(1).max(120).optional(),
    description: z.string().max(2000).optional(),
    tags: z.array(z.string().min(1).max(32)).max(20).optional(),
    media: z
      .array(
        z.object({
          url: z.string().url(),
          type: z.enum(["audio", "image"]),
          metadata: z.record(z.any()).optional()
        })
      )
      .max(10)
      .optional()
  })
]);

export const postRemixSchema = z.object({
  content_url: z.string().url(),
  content_type: z.enum(["audio", "image"]),
  title: z.string().min(1).max(120).optional(),
  description: z.string().max(2000).optional(),
  tags: z.array(z.string().min(1).max(32)).max(20).optional(),
  media: z
    .array(
      z.object({
        url: z.string().url(),
        type: z.enum(["audio", "image"]),
        metadata: z.record(z.any()).optional()
      })
    )
    .max(10)
    .optional()
});

export const feedQuerySchema = z.object({
  limit: z.string().optional(),
  cursor: z.string().datetime().optional(),
  tag: z.string().max(32).optional()
});