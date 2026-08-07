-- Sidekick's Next Edit Suggestions need a Copilot subscription, and enabling them also turns
-- on the copilot LSP client. Only the CLI terminal half is used here, which drives the
-- `cursor-agent` binary from the cursor-cli cask.
return {
  {
    "folke/sidekick.nvim",
    opts = { nes = { enabled = false } },
  },
}
