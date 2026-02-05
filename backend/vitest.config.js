const { defineConfig } = require("vitest/config");

module.exports = defineConfig({
  test: {
    environment: "node",
    deps: {
      inline: [
        /^@supabase\//,
        /^undici/,
        "node-fetch"
      ]
    }
  }
});
