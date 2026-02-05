const fetch = require("node-fetch");

async function verifyCaptcha(token, ip) {
  const secret = process.env.CAPTCHA_SECRET;
  if (!secret) {
    return { ok: true, skipped: true };
  }

  if (!token) {
    return { ok: false, error: "captcha_required" };
  }

  const provider = (process.env.CAPTCHA_PROVIDER || "turnstile").toLowerCase();
  let url = "";
  const body = new URLSearchParams();
  body.set("secret", secret);
  body.set("response", token);
  if (ip) body.set("remoteip", ip);

  if (provider === "hcaptcha") {
    url = "https://hcaptcha.com/siteverify";
  } else {
    url = "https://challenges.cloudflare.com/turnstile/v0/siteverify";
  }

  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body
  });
  const data = await res.json();
  if (!data.success) {
    return { ok: false, error: "captcha_failed" };
  }
  return { ok: true };
}

module.exports = { verifyCaptcha };
