-- Run with `rex do agent-watcher.lua --all`. Cursor CLI only reports "waiting for you" through its
-- terminal title ("<chat> - <emoji> <status>", not a documented interface), so this turns that title
-- into an OSC 7501 blocked report on the agent's terminal. The Cursor hooks report working and done.

local last_state_by_block = {}

local function cursor_agent_state(title)
  local status = title:match(" %- [^ -~]+ (.+)$")
  if status == nil then
    return nil
  elseif status == "Waiting for confirmation" then
    return "permission"
  elseif status == "Waiting for you" then
    return "question"
  elseif status == "Ready" then
    return "ready"
  end
  return "working"
end

local function report_to_terminal_of(owner, block_id, fields)
  if owner == nil then
    error("Rex didn't say which process retitled " .. block_id, 0)
  end
  local ps, err = rex.exec({ "/bin/ps", "-o", "tty=", "-p", tostring(owner.pid) })
  if ps == nil then
    error(err, 0)
  end
  local tty = ps.stdout:gsub("%s", "")
  if not ps.ok or tty == "" or tty:sub(1, 1) == "?" then
    error("No terminal for " .. owner.name .. " (pid " .. owner.pid .. ")", 0)
  end
  local terminal, open_err = io.open("/dev/" .. tty, "w")
  if terminal == nil then
    error(open_err, 0)
  end
  terminal:write("\27]7501;state=" .. fields .. ":app=cursor-agent\27\\")
  terminal:close()
end

local function is_waiting(state)
  return state == "permission" or state == "question"
end

rex.on("terminal.title_changed", function(ctx, ev)
  local state = cursor_agent_state(ev.title or "")
  local previous = last_state_by_block[ctx.block_id]
  last_state_by_block[ctx.block_id] = state
  if state == previous then
    return
  end
  if is_waiting(state) then
    report_to_terminal_of(ev.owner, ctx.block_id, "blocked:kind=" .. state)
  elseif state == "working" and is_waiting(previous) then
    report_to_terminal_of(ev.owner, ctx.block_id, "working")
  end
end)
