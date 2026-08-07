-- Nudges toward better motions rather than taking keys away: "hint" names the motion that
-- would have been shorter instead of swallowing the keypress, and the arrow keys and mouse are
-- left alone. Toggle with <leader>uH when it stops being useful.
return {
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      restriction_mode = "hint",
      disable_mouse = false,
      -- disabled_keys are refused outright whatever the restriction_mode, so each one has to be
      -- switched off by name; emptying the table would just deep-merge back to the defaults.
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
        ["<Left>"] = false,
        ["<Right>"] = false,
      },
    },
    config = function(_, opts)
      require("hardtime").setup(opts)
      Snacks.toggle({
        name = "Hardtime",
        get = function()
          return require("hardtime").is_plugin_enabled
        end,
        set = function(state)
          require("hardtime")[state and "enable" or "disable"]()
        end,
      }):map("<leader>uH")
    end,
  },
}
