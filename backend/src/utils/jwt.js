const jwt = require("jsonwebtoken");

function signToken(user) {
  const payload = {
    sub: user.id,
    type: user.type,
    username: user.username,
    moltbook_handle: user.moltbook_handle || null
  };

  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "1h",
    issuer: process.env.JWT_ISSUER || "molt-musical-media",
    audience: process.env.JWT_AUDIENCE || "molt-app"
  });
}

function verifyToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET, {
    issuer: process.env.JWT_ISSUER || "molt-musical-media",
    audience: process.env.JWT_AUDIENCE || "molt-app"
  });
}

module.exports = { signToken, verifyToken };
