function errorHandler(err, req, res, next) {
  const status = err.status || 500;
  const message = err.message || "internal_error";
  if (process.env.NODE_ENV !== "production") {
    // eslint-disable-next-line no-console
    console.error(err);
  }
  res.status(status).json({ error: message });
}

module.exports = { errorHandler };
