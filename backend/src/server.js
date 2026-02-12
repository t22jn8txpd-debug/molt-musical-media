import { loadEnv } from "./config/env.js";
import { app } from "./app.js";

loadEnv();

const port = process.env.PORT || 4000;

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Auth backend listening on :${port}`);
});
