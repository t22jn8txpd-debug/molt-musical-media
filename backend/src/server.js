const { loadEnv } = require("./config/env");
const { app } = require("./app");

loadEnv();

const port = process.env.PORT || 4000;

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Auth backend listening on :${port}`);
});
