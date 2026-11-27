-- Auto-loaded by LazyVim on VeryLazy, after its own default autocmds.
-- Remove a default group with vim.api.nvim_del_augroup_by_name("lazyvim_<name>").

local rex_resume_token = vim.env.OSC7577_TOKEN
vim.env.OSC7577_TOKEN = nil

local function report_resume_command_to_rex(session_file)
  local argv = { "nvim", "-S", session_file }
  for i, arg in ipairs(argv) do
    argv[i] = vim.base64.encode(arg)
  end
  -- This process is Neovim's server. The terminal runs its parent, the TUI.
  local body = ("pid=%d:time=%d:argv=%s"):format(vim.uv.os_getppid(), os.time(), table.concat(argv, ","))
  vim.api.nvim_ui_send("\27]7577;" .. body .. ":mac=" .. vim.fn.sha256(body .. ":" .. rex_resume_token) .. "\27\\")
end

local is_scratchpad = vim.env.SCRATCHPAD_NOTE ~= nil
if rex_resume_token ~= nil and not is_scratchpad then
  local rex_resume = vim.api.nvim_create_augroup("rex_resume", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusLost" }, {
    group = rex_resume,
    desc = "Save the session the way persistence.nvim does on quit, so a Rex restart resumes it",
    callback = function()
      local persistence = package.loaded["persistence"]
      if persistence ~= nil and persistence.active() and vim.g.SessionLoad == nil then
        vim.api.nvim_exec_autocmds("VimLeavePre", { group = "persistence" })
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = rex_resume,
    pattern = "PersistenceSavePost",
    callback = function()
      report_resume_command_to_rex(vim.v.this_session)
    end,
  })
end
