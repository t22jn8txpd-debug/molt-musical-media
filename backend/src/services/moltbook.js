const fetch = require("node-fetch");

function extractPostId(postIdOrUrl) {
  try {
    const url = new URL(postIdOrUrl);
    const parts = url.pathname.split("/").filter(Boolean);
    return parts[parts.length - 1] || postIdOrUrl;
  } catch {
    return postIdOrUrl;
  }
}

async function verifyMoltbookProof({ postIdOrUrl, verificationCode, moltbookHandle }) {
  if (process.env.MOLTBOOK_ALLOW_MOCK === "true") {
    if (verificationCode.startsWith("DEV-")) {
      return { ok: true, postId: "mock" };
    }
  }

  const baseUrl = process.env.MOLTBOOK_API_BASE_URL;
  if (!baseUrl) {
    return { ok: false, error: "moltbook_unconfigured" };
  }

  const postId = extractPostId(postIdOrUrl);
  const url = `${baseUrl.replace(/\/$/, "")}/posts/${encodeURIComponent(postId)}`;
  const res = await fetch(url, {
    headers: {
      "content-type": "application/json",
      ...(process.env.MOLTBOOK_API_KEY ? { Authorization: `Bearer ${process.env.MOLTBOOK_API_KEY}` } : {})
    }
  });

  if (!res.ok) {
    return { ok: false, error: "moltbook_fetch_failed" };
  }

  const data = await res.json();
  const authorHandle = data?.author?.handle || data?.author_handle || data?.handle;
  const content = data?.content || data?.text || "";

  if (!authorHandle || authorHandle.toLowerCase() !== moltbookHandle.toLowerCase()) {
    return { ok: false, error: "handle_mismatch" };
  }

  if (!content.includes(verificationCode)) {
    return { ok: false, error: "code_not_found" };
  }

  return { ok: true, postId };
}

module.exports = { verifyMoltbookProof };
