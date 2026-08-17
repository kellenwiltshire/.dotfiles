return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      exclude = { "node_modules" },
      sources = {
        -- the `files` source hard-codes these to false, and source config wins over global
        files = { hidden = true, ignored = true },
      },
    },
  },
}
