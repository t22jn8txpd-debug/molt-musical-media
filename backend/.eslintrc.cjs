module.exports = {
  env: {
    node: true,
    es2022: true
  },
  extends: ["eslint:recommended", "prettier"],
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "script"
  },
  ignorePatterns: ["node_modules", "coverage"],
  overrides: [
    {
      files: ["**/*.mjs"],
      parserOptions: {
        sourceType: "module"
      }
    }
  ],
  rules: {
    "no-console": "off"
  }
};
