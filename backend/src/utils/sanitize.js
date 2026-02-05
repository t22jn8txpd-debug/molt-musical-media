function sanitizeText(value, maxLen) {
  if (typeof value !== "string") {
    return value;
  }
  const trimmed = value.trim().replace(/\s+/g, " ");
  if (maxLen && trimmed.length > maxLen) {
    return trimmed.slice(0, maxLen);
  }
  return trimmed;
}

function sanitizeTags(tags) {
  if (!Array.isArray(tags)) {
    return [];
  }
  const cleaned = tags
    .map((tag) => (typeof tag === "string" ? tag.trim().toLowerCase() : ""))
    .filter(Boolean);
  return Array.from(new Set(cleaned));
}

module.exports = { sanitizeText, sanitizeTags };
