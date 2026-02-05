import { verifyToken } from "../utils/jwt.js";

export const authRequired = (req, res, next) => {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: "missing_token" });
  }
  try {
    const payload = verifyToken(token);
    req.user = payload;
    return next();
  } catch (err) {
    return res.status(401).json({ error: "invalid_token" });
  }
};