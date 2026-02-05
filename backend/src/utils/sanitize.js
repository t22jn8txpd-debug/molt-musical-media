export function sanitizeText(text, maxLength = 1000) {
  if (!text) return '';
  // Basic sanitization: trim, remove HTML tags, etc.
  return text
    .trim()
    .replace(/<[^>]*>/g, '') // strip HTML
    .substring(0, maxLength);
}

export function sanitizeTags(tags) {
  if (!tags || !Array.isArray(tags)) return [];
  return tags
    .filter(tag => typeof tag === 'string' && tag.trim().length > 0)
    .map(tag => tag.trim().toLowerCase().replace(/\s+/g, '-')) // normalize to slug-like
    .slice(0, 20); // limit to reasonable number
}