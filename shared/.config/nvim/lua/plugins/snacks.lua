return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      -- Excludes apply to tracked files too, so `build` and `vendor` stay: repos in ~/code track both.
      exclude = { "node_modules", "dist", ".jest-cache", "__engines__", "tmp", "storybook-static", "coverage" },
      sources = {
        -- the `files` source hard-codes these to false, and source config wins over global
        files = { hidden = true, ignored = true },
        explorer = { layout = { layout = { position = "right" } } },
      },
    },
  },
}
