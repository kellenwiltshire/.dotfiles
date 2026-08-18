-- markdownlint-cli2 only reads config files from the cwd downwards, so a user-level
-- default has to be passed explicitly. Project configs still override it.
local user_config = vim.fn.expand("~/.config/markdownlint/.markdownlint-cli2.yaml")

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", user_config, "-" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          args = { "--config", user_config, "--fix", "$FILENAME" },
        },
      },
    },
  },
}
