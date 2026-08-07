-- Matches Ghostty's "Night Owl" theme and the night-owl-black VS Code extension.
return {
  { "oxfist/night-owl.nvim", lazy = false, priority = 1000 },
  { "LazyVim/LazyVim", opts = { colorscheme = "night-owl" } },
}
