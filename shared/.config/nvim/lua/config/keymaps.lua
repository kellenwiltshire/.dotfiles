-- Auto-loaded by LazyVim on VeryLazy, after its own default keymaps.

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up" })

-- Normal mode only; `zz` in an operator-pending mapping would break the operator,
-- so LazyVim's x/o mappings for n/N are deliberately left in place.
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
