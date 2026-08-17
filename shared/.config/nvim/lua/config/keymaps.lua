-- Auto-loaded by LazyVim on VeryLazy, after its own default keymaps.

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up" })

-- Normal mode only; `zz` in an operator-pending mapping would break the operator,
-- so LazyVim's x/o mappings for n/N are deliberately left in place.
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })
