function errorHandler(err, req, res, next) {
  if (err?.type === "entity.parse.failed" || err instanceof SyntaxError) {
    return res.status(400).json({ error: "invalid_json" });
  }
  const status = err.status || 500;
  const message = err.message || "internal_error";
  if (process.env.NODE_ENV !== "production") {
    // eslint-disable-next-line no-console
    console.error(err);
  }
  res.status(status).json({ error: message });
}

module.exports = { errorHandler };
