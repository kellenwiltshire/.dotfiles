-- Nudges toward better motions rather than taking keys away: "hint" names the motion that
-- would have been shorter instead of swallowing the keypress, and the mouse is left alone.
-- Arrow keys get nagged too, but still work. Toggle with <leader>uH when it stops being useful.
local arrow_motions = {
  ["<Up>"] = "k",
  ["<Down>"] = "j",
  ["<Left>"] = "h",
  ["<Right>"] = "l",
}

local arrow_hints = {}
local arrow_restrictions = {}
for arrow, motion in pairs(arrow_motions) do
  arrow_hints[arrow] = {
    message = function()
      return "Use " .. motion .. " instead of " .. arrow
    end,
  }
  arrow_restrictions[arrow] = { "i" }
end

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
      hints = arrow_hints,
      -- hints are driven by vim.on_key, which bails out in insert mode, so insert-mode arrows are
      -- caught by restricted_keys instead: nagged once they repeat max_count times within max_time.
      restricted_keys = arrow_restrictions,
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
