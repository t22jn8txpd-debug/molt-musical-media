import fetch from "node-fetch";

function extractPostId(postIdOrUrl) {
  try {
    const url = new URL(postIdOrUrl);
    const parts = url.pathname.split("/").filter(Boolean);
    return parts[parts.length - 1] || postIdOrUrl;
  } catch {
    return postIdOrUrl;
  }
}

async function fetchWithRetry(url, options, { retries = 3, baseDelayMs = 300 } = {}) {
  let attempt = 0;
  let lastError;
  while (attempt <= retries) {
    try {
      const res = await fetch(url, options);
      if (res.ok || (res.status >= 400 && res.status < 500)) {
        return res;
      }
      lastError = new Error(`moltbook_http_${res.status}`);
    } catch (err) {
      lastError = err;
    }

    if (attempt === retries) {
      break;
    }

    const jitter = Math.floor(Math.random() * 100);
    const delay = baseDelayMs * 2 ** attempt + jitter;
    await new Promise((resolve) => setTimeout(resolve, delay));
    attempt += 1;
  }

  throw lastError;
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
  let res;
  try {
    res = await fetchWithRetry(
      url,
      {
        headers: {
          "content-type": "application/json",
          ...(process.env.MOLTBOOK_API_KEY
            ? { Authorization: `Bearer ${process.env.MOLTBOOK_API_KEY}` }
            : {})
        }
      },
      {
        retries: Number.parseInt(process.env.MOLTBOOK_RETRY_COUNT || "3", 10) || 3,
        baseDelayMs: Number.parseInt(process.env.MOLTBOOK_RETRY_BASE_MS || "300", 10) || 300
      }
    );
  } catch (err) {
    return { ok: false, error: "moltbook_fetch_failed" };
  }

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

export { verifyMoltbookProof };
