const express = require("express");
const { agentVerifySchema } = require("../utils/validation");
const { verifyMoltbookProof } = require("../services/moltbook");
const { signToken } = require("../utils/jwt");
const {
  findByMoltbookHandle,
  findByUsername,
  createMolt
} = require("../db/userRepo");

const router = express.Router();

router.post("/verify", async (req, res, next) => {
  try {
    const payload = agentVerifySchema.parse(req.body);
    const verification = await verifyMoltbookProof({
      postIdOrUrl: payload.post_id_or_url,
      verificationCode: payload.verification_code,
      moltbookHandle: payload.moltbook_handle
    });

    if (!verification.ok) {
      return res.status(400).json({ error: verification.error });
    }

    const supabase = req.supabase;
    const existingHandle = await findByMoltbookHandle(supabase, payload.moltbook_handle);
    if (existingHandle) {
      const token = signToken(existingHandle);
      return res.status(200).json({
        token,
        user: {
          id: existingHandle.id,
          username: existingHandle.username,
          type: existingHandle.type,
          moltbook_handle: existingHandle.moltbook_handle
        }
      });
    }

    const username = payload.username || payload.moltbook_handle;
    const existingUsername = await findByUsername(supabase, username);
    if (existingUsername) {
      return res.status(409).json({ error: "username_in_use" });
    }

    const user = await createMolt(supabase, {
      username,
      moltbookHandle: payload.moltbook_handle
    });

    const token = signToken(user);
    return res.status(201).json({
      token,
      user: {
        id: user.id,
        username: user.username,
        type: user.type,
        moltbook_handle: user.moltbook_handle
      }
    });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
