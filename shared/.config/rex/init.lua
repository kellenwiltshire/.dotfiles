-- tmux (~/.config/tmux/tmux.conf), prefix ctrl+a
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>q", "client.config.reload")

rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("repeat/h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("repeat/j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("repeat/k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })
rex.bind("repeat/l", "pane.focus", { direction = "right" })

rex.bind("ctrl+a>ctrl+h", "pane.send_key", { key = "ctrl+h" })
rex.bind("ctrl+a>ctrl+j", "pane.send_key", { key = "ctrl+j" })
rex.bind("ctrl+a>ctrl+k", "pane.send_key", { key = "ctrl+k" })
rex.bind("ctrl+a>ctrl+l", "pane.send_key", { key = "ctrl+l" })

rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("alt+enter", "pane.split", { direction = "down" })
rex.bind("alt+shift+enter", "pane.split", { direction = "right" })
rex.bind("alt+esc", "pane.close")

rex.bind("ctrl+alt+left", "pane.focus", { direction = "left" })
rex.bind("ctrl+alt+right", "pane.focus", { direction = "right" })
rex.bind("ctrl+alt+up", "pane.focus", { direction = "up" })
rex.bind("ctrl+alt+down", "pane.focus", { direction = "down" })

rex.bind("ctrl+alt+shift+left", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+alt+shift+down", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+alt+shift+up", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+alt+shift+right", "pane.resize", { amount = 5, direction = "right" })

rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>shift+x", "client.tab.close")
rex.bind("ctrl+a>shift+k", "session.close")

rex.bind("ctrl+a>r", "client.tab.rename")
rex.bind("ctrl+a>c", "client.tab.new")

rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })

rex.bind("alt+left", "client.tab.previous")
rex.bind("alt+right", "client.tab.next")

rex.bind("ctrl+a>shift+r", "session.rename")
rex.bind("ctrl+a>shift+c", "session.new")
rex.bind("ctrl+a>shift+p", "session.previous")
rex.bind("ctrl+a>shift+n", "session.next")
rex.bind("alt+up", "session.previous")
rex.bind("alt+down", "session.next")

local function open_float(bounds, label, options)
  local _, err = rex.session.new_layer({
    bounds = bounds,
    focus = true,
    layout = rex.layout.block({ flavor = "com.superlogical.terminal.shell", label = label, options = options }),
  })
  if err ~= nil then
    error(err, 0)
  end
end

local function path_from_file_url(url)
  local path = url:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function focused_pane_directory(ctx)
  local result, err = rex.block.call("com.superlogical.terminal", "pwd", { block_id = ctx.block_id })
  if err ~= nil then
    error(err, 0)
  end
  if result.pwd == nil then
    error("The focused pane hasn't reported its directory", 0)
  end
  return path_from_file_url(result.pwd)
end

local function floating_layer_labelled(view, label)
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then
      for _, layer in ipairs(window.layers) do
        for _, block in ipairs(layer.blocks or {}) do
          if layer.kind == "floating" and block.label == label then
            return layer
          end
        end
      end
    end
  end
end

rex.action({
  name = "lazygit",
  title = "Open lazygit",
  run = function(ctx)
    open_float({ 0.05, 0.05, 0.9, 0.9 }, "lazygit", { command = { "lazygit" }, cwd = focused_pane_directory(ctx) })
  end,
})
rex.bind("ctrl+a>g", "lazygit")

local scratchpad_note = os.getenv("HOME") .. "/notes/scratch.md"
local scratchpad_socket = (os.getenv("TMPDIR") or "/tmp"):gsub("/$", "") .. "/nvim-scratchpad.sock"
local attach_to_scratchpad_nvim = [[
if ! nvim --server "$1" --remote-send '' >/dev/null 2>&1; then
  rm -f "$1"
  mkdir -p "$(dirname "$2")"
  set -m
  SCRATCHPAD_NOTE="$2" nvim --headless --listen "$1" \
    -c 'set autowriteall' \
    -c 'autocmd CursorHold,CursorHoldI,FocusLost,BufLeave * silent! wall' \
    -c 'autocmd UIEnter * ++once lua vim.schedule(function() vim.cmd.edit(vim.fn.fnameescape(vim.env.SCRATCHPAD_NOTE)) end)' \
    </dev/null >/dev/null 2>&1 &
  while [ ! -S "$1" ]; do
    kill -0 $! 2>/dev/null || { echo "Scratchpad nvim exited before listening on $1" >&2; exit 1; }
    sleep 0.05
  done
fi
exec nvim --server "$1" --remote-ui
]]

rex.action({
  name = "scratchpad",
  title = "Toggle Scratchpad",
  run = function()
    local view, err = rex.session.view({})
    if err ~= nil then
      error(err, 0)
    end
    local open_scratchpad = floating_layer_labelled(view, "notes")
    if open_scratchpad ~= nil then
      local _, close_err = rex.session.close_layer({ layer_id = open_scratchpad.layer_id })
      if close_err ~= nil then
        error(close_err, 0)
      end
      return
    end
    open_float({ 0.1, 0.1, 0.8, 0.8 }, "notes", {
      command = { "sh", "-c", attach_to_scratchpad_nvim, "sh", scratchpad_socket, scratchpad_note },
      cwd = scratchpad_note:match("(.*)/"),
    })
  end,
})
rex.bind("alt+g", "scratchpad")

-- Ghostty (~/.config/ghostty/config)
rex.bind("ctrl+shift+d", "pane.split", { direction = "right" })
rex.bind("ctrl+shift+w", "pane.close")
rex.bind("ctrl+shift+e", "pane.balance")
rex.bind("ctrl+shift+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+shift+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+shift+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+shift+l", "pane.focus", { direction = "right" })

local function file_exists(path)
  local file = io.open(path)
  if file == nil then
    return false
  end
  file:close()
  return true
end

-- --autostart=false keeps the watcher from spawning a second server while this one is starting up.
local run_agent_watcher = [[
exec >>"$HOME/Library/Logs/rex-agent-watcher.log" 2>&1
attempts=0
until "$1" --autostart=false whoami >/dev/null 2>&1; do
  attempts=$((attempts + 1))
  [ "$attempts" -lt 60 ] || { echo "$(date): Rex server didn't answer; agent watcher not started"; exit 1; }
  sleep 1
done
exec "$1" --autostart=false do "$2" --all
]]

local rex_cli = os.getenv("HOME")
  .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
if file_exists(rex_cli) then
  local lock = (os.getenv("TMPDIR") or "/tmp"):gsub("/$", "") .. "/rex-agent-watcher.lock"
  local watcher = os.getenv("HOME") .. "/.config/rex/agent-watcher.lua"
  local _, err = rex.exec.start(
    { "/usr/bin/lockf", "-s", "-t", "0", lock, "/bin/sh", "-c", run_agent_watcher, "sh", rex_cli, watcher },
    { detach = true, stdout = false, stderr = false }
  )
  if err ~= nil then
    rex.log("error", "Couldn't start the agent watcher: " .. err)
  end
end

-- ~/.cursor/hooks/rex-agent-status reports these. Cursor CLI installs both names.
for _, cursor_agent in ipairs({ "cursor-agent", "agent" }) do
  rex.set("resume.trust." .. cursor_agent, { command = { cursor_agent, "--resume", rex.match.uuid } })
end

-- ~/.config/nvim/lua/config/autocmds.lua reports this. -S runs the file, so only persistence.nvim's sessions.
rex.set("resume.trust.nvim", { command = { "nvim", "-S", rex.match.under("~/.local/state/nvim/sessions") } })

local home = os.getenv("HOME")

local function output_lines(argv)
  local result, err = rex.exec(argv)
  if result == nil then
    error(err, 0)
  end
  if not result.ok then
    error(argv[1] .. " failed: " .. result.stderr, 0)
  end
  local lines = {}
  for line in result.stdout:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end

local function first_existing(paths)
  for _, path in ipairs(paths) do
    if file_exists(path) then
      return path
    end
  end
  error("None of these exist: " .. table.concat(paths, ", "), 0)
end

local function project_directories()
  local directories = output_lines({
    "/usr/bin/find",
    home .. "/code",
    "-mindepth",
    "1",
    "-maxdepth",
    "1",
    "-type",
    "d",
    "-not",
    "-name",
    ".*",
  })
  table.sort(directories)
  local zoxide = first_existing({ "/opt/homebrew/bin/zoxide", "/usr/local/bin/zoxide", "/usr/bin/zoxide" })
  for _, directory in ipairs(output_lines({ zoxide, "query", "--list" })) do
    table.insert(directories, directory)
  end
  return directories
end

local function directory_name(directory)
  return directory:match("[^/]+$")
end

local function with_tilde(directory)
  if directory:sub(1, #home) == home then
    return "~" .. directory:sub(#home + 1)
  end
  return directory
end

local function session_switcher_items(sessions)
  local items, session_labels, listed_directories = {}, {}, {}
  for _, session in ipairs(sessions) do
    session_labels[session.label] = true
    table.insert(items, { id = session.session_id, title = session.label, icon = "terminal", detail = "session" })
  end
  for _, directory in ipairs(project_directories()) do
    if not listed_directories[directory] and not session_labels[directory_name(directory)] then
      listed_directories[directory] = true
      table.insert(
        items,
        { id = directory, title = directory_name(directory), subtitle = with_tilde(directory), icon = "folder" }
      )
    end
  end
  return items
end

local function new_session_in(directory)
  local created, err = rex.call("session.create", {
    label = directory_name(directory),
    initial_windows = {
      { layout = rex.layout.block({ flavor = "com.superlogical.terminal.shell", options = { cwd = directory } }) },
    },
  })
  if err ~= nil then
    error(err, 0)
  end
  return created.session_id
end

rex.action({
  name = "session_switcher",
  title = "Switch Session or Open Project",
  run = function()
    local listed, err = rex.call("session.list")
    if err ~= nil then
      error(err, 0)
    end
    local choice, why, detail = rex.ui.pick({
      title = "Switch session",
      placeholder = "Filter sessions and projects",
      items = session_switcher_items(listed.sessions),
    })
    if choice == nil then
      if why == "cancelled" then
        return
      end
      error("Session switcher got no answer: " .. why .. " " .. (detail or ""), 0)
    end
    if choice:sub(1, 1) == "/" then
      choice = new_session_in(choice)
    end
    rex.client.queue("session.select", { session_id = choice })
  end,
})
rex.bind("ctrl+a>s", "session_switcher")
