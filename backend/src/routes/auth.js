import express from "express";
import bcrypt from "bcryptjs";
import { signupSchema, loginSchema } from "../utils/validation.js";
import { verifyCaptcha } from "../services/captcha.js";
import { signToken } from "../utils/jwt.js";
import {
  findByEmail,
  findByUsername,
  createHuman,
  updateLoginTimestamp
} from "../db/userRepo.js";

const router = express.Router();

router.post("/signup", async (req, res, next) => {
  try {
    const payload = signupSchema.parse(req.body);
    const captcha = await verifyCaptcha(payload.captcha_token, req.ip);
    if (!captcha.ok) {
      return res.status(400).json({ error: captcha.error });
    }

    const supabase = req.supabase;
    const existingEmail = await findByEmail(supabase, payload.email);
    if (existingEmail) {
      return res.status(409).json({ error: "email_in_use" });
    }

    const existingUsername = await findByUsername(supabase, payload.username);
    if (existingUsername) {
      return res.status(409).json({ error: "username_in_use" });
    }

    const passwordHash = await bcrypt.hash(payload.password, 12);
    const user = await createHuman(supabase, {
      email: payload.email,
      username: payload.username,
      passwordHash
    });

    const token = signToken(user);
    return res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        type: user.type
      }
    });
  } catch (err) {
    return next(err);
  }
});

router.post("/login", async (req, res, next) => {
  try {
    const payload = loginSchema.parse(req.body);
    const captcha = await verifyCaptcha(payload.captcha_token, req.ip);
    if (!captcha.ok) {
      return res.status(400).json({ error: captcha.error });
    }

    const supabase = req.supabase;
    const user = await findByEmail(supabase, payload.email);
    if (!user || !user.password_hash) {
      return res.status(401).json({ error: "invalid_credentials" });
    }

    const match = await bcrypt.compare(payload.password, user.password_hash);
    if (!match) {
      return res.status(401).json({ error: "invalid_credentials" });
    }

    await updateLoginTimestamp(supabase, user.id);
    const token = signToken(user);
    return res.status(200).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        type: user.type
      }
    });
  } catch (err) {
    return next(err);
  }
});

export default router;
