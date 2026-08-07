-- LazyVim's test extra ships neotest itself but no JS adapters, and every repo in ~/code is
-- TypeScript. Adapters given a non-empty config are resolved through their setup/call hook;
-- neotest-vitest is the adapter itself, so it takes an empty table.
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "thenbe/neotest-playwright",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = { jestCommand = "npx jest" },
        ["neotest-vitest"] = {},
        ["neotest-playwright"] = {
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        },
      },
    },
  },
}
