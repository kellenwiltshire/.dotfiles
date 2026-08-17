-- Motion drills on throwaway buffers, started with :VimBeGood. Pairs with hardtime.nvim, which
-- only nudges while editing real files; this is the deliberate-practice half. Loaded on the
-- command alone so it costs nothing at startup.
return {
  {
    "ThePrimeagen/vim-be-good",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "VimBeGood",
  },
}
