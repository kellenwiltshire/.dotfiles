-- Makes Neovim's splits and tmux's panes one grid: C-h/j/k/l walks off the edge of a split into
-- the pane next door and back. LazyVim already binds those four to window movement, so this only
-- swaps the handler underneath them.
--
-- Chosen over vim-tmux-navigator for the handshake: this plugin marks its pane with
-- @pane-is-vim, which tmux.conf reads as a format. The alternative has tmux run `ps` against the
-- pane's tty on every single keypress to guess whether Neovim is in the foreground.
--
-- lazy = false is load-bearing. The marker is set on VimEnter and cleared on VimLeave, so a
-- lazy-loaded copy would leave tmux believing the pane is a plain shell until the first keypress.
return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {},
    keys = {
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Go to Left Window",
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Go to Lower Window",
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Go to Upper Window",
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Go to Right Window",
      },
    },
  },
}
