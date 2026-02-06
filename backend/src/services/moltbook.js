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
  
  console.log('[Moltbook] Fetching post:', url);
  
  const res = await fetch(url, {
    headers: {
      "content-type": "application/json",
      ...(process.env.MOLTBOOK_API_KEY ? { Authorization: `Bearer ${process.env.MOLTBOOK_API_KEY}` } : {})
    }
  });

  if (!res.ok) {
    console.log('[Moltbook] Fetch failed:', res.status);
    return { ok: false, error: "moltbook_fetch_failed" };
  }

  const data = await res.json();
  console.log('[Moltbook] Full API response:', JSON.stringify(data, null, 2).substring(0, 500));
  
  const postData = data?.post || data;
  console.log('[Moltbook] Post data author object:', JSON.stringify(postData?.author, null, 2));
  
  const authorHandle = postData?.author?.handle || postData?.author?.name || postData?.author_handle || postData?.handle;
  const content = postData?.content || postData?.text || "";

  console.log('[Moltbook] Author handle from API:', authorHandle);
  console.log('[Moltbook] Expected handle:', moltbookHandle);
  console.log('[Moltbook] Comparison:', `"${authorHandle?.toLowerCase()}" === "${moltbookHandle.toLowerCase()}"`);
  console.log('[Moltbook] Content includes code:', content.includes(verificationCode));

  if (!authorHandle || authorHandle.toLowerCase() !== moltbookHandle.toLowerCase()) {
    console.log('[Moltbook] ❌ HANDLE MISMATCH!');
    return { ok: false, error: "name_mismatch" };
  }

  if (!content.includes(verificationCode)) {
    return { ok: false, error: "code_not_found" };
  }

  return { ok: true, postId };
}


module.exports = { verifyMoltbookProof };
