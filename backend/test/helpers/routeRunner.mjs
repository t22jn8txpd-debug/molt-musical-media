import { errorHandler } from "../../src/middleware/error.js";

export async function runRoute(route, options = {}) {
  if (!route) {
    throw new Error("Route not found");
  }

  const {
    method = "get",
    body = {},
    query = {},
    params = {},
    headers = {},
    supabase = {},
    ip = "127.0.0.1",
    originalUrl = "/test"
  } = options;

  let statusCode = 200;
  let responseBody;
  const responseHeaders = {};

  const req = {
    method: method.toUpperCase(),
    body,
    query,
    params,
    headers,
    supabase,
    ip,
    originalUrl,
    path: originalUrl
  };

  const res = {
    status(code) {
      statusCode = code;
      return res;
    },
    json(payload) {
      responseBody = payload;
      return res;
    },
    set(field, value) {
      responseHeaders[String(field).toLowerCase()] = value;
      return res;
    },
    setHeader(field, value) {
      responseHeaders[String(field).toLowerCase()] = value;
    },
    getHeader(field) {
      return responseHeaders[String(field).toLowerCase()];
    }
  };

  const stack = route.stack.map((layer) => layer.handle);

  const next = async (err) => {
    if (err) {
      if (err?.name === "ZodError") {
        res.status(400).json({ error: "validation_error", details: err.errors });
        return;
      }
      errorHandler(err, req, res, () => {});
      return;
    }

    const handler = stack.shift();
    if (!handler) {
      return;
    }
    await handler(req, res, next);
  };

  await next();

  return { statusCode, body: responseBody, headers: responseHeaders };
}
