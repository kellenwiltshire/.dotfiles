-- Installs the Mason packages and treesitter parsers that LazyVim's config asks for,
-- blocking until they finish. `Lazy! restore` only pins plugins; without this the tools
-- trickle in per-filetype during interactive use.

local timeout_ms = tonumber(vim.env.NVIM_BOOTSTRAP_TIMEOUT_MS or "") or 900000

local function say(msg)
  io.stdout:write(msg .. "\n")
end

local function die(msg)
  say("❌ " .. msg)
  os.exit(1)
end

local lazy_config = require("lazy.core.config")

local function plugin_opts(name)
  local plugin = lazy_config.plugins[name]
  if not plugin then
    return {}
  end
  return require("lazy.core.plugin").values(plugin, "opts", false) or {}
end

local function load_plugins(names)
  local present = vim.tbl_filter(function(name)
    return lazy_config.plugins[name] ~= nil
  end, names)
  if #present > 0 then
    require("lazy").load({ plugins = present })
  end
end

local function wanted_packages()
  local wanted = {}
  for _, tool in ipairs(plugin_opts("mason.nvim").ensure_installed or {}) do
    wanted[tool] = true
  end

  local ok, mappings = pcall(require, "mason-lspconfig.mappings")
  if ok then
    local to_package = mappings.get_mason_map().lspconfig_to_package
    for server, cfg in pairs(plugin_opts("nvim-lspconfig").servers or {}) do
      -- "*" is LazyVim's shared-defaults key; enabled/mason = false means "not via Mason".
      local managed = server ~= "*" and not (type(cfg) == "table" and (cfg.enabled == false or cfg.mason == false))
      if managed and to_package[server] then
        wanted[to_package[server]] = true
      end
    end
  end

  return vim.tbl_keys(wanted)
end

local function refresh_registry(registry)
  local done = false
  registry.refresh(function()
    done = true
  end)
  if not vim.wait(120000, function()
    return done
  end, 200) then
    die("Timed out refreshing the Mason registry.")
  end
end

local function install_mason_packages()
  local registry = require("mason-registry")
  refresh_registry(registry)

  local targets, unknown = {}, {}
  for _, name in ipairs(wanted_packages()) do
    if registry.has_package(name) then
      table.insert(targets, name)
    else
      table.insert(unknown, name)
    end
  end

  -- `is_installed()` only stats the package directory, which Mason creates as soon as an
  -- install starts, so it reports true mid-download. The receipt is written on success only.
  local uv = vim.uv or vim.loop
  local function installed(pkg)
    return not pkg:is_installing() and uv.fs_stat(pkg:get_receipt_path()) ~= nil
  end

  local failed = {}
  for _, name in ipairs(targets) do
    local pkg = registry.get_package(name)
    if not installed(pkg) then
      pkg:once("install:failed", function()
        failed[name] = true
      end)
      -- LazyVim's own ensure_installed fires on config load, so some are already in flight.
      if not pkg:is_installing() then
        pkg:install()
      end
    end
  end

  local function outstanding()
    return vim.tbl_filter(function(name)
      return not failed[name] and not installed(registry.get_package(name))
    end, targets)
  end

  local left = outstanding()
  if #left > 0 then
    say(("⏳ Installing %d Mason package(s)..."):format(#left))
    if not vim.wait(timeout_ms, function()
      return #outstanding() == 0
    end, 500) then
      die("Timed out installing Mason packages: " .. table.concat(outstanding(), ", "))
    end
  end

  local names = vim.tbl_keys(failed)
  for _, name in ipairs(unknown) do
    table.insert(names, name .. " (absent from registry)")
  end
  return names
end

local function install_parsers()
  local treesitter = require("nvim-treesitter")

  local function missing()
    local installed = {}
    for _, lang in ipairs(treesitter.get_installed("parsers")) do
      installed[lang] = true
    end
    return vim.tbl_filter(function(lang)
      return not installed[lang]
    end, plugin_opts("nvim-treesitter").ensure_installed or {})
  end

  -- `Lazy!` kicks off parser builds as a build step and is killed by +qa partway through, so
  -- the first attempt can trip over the scratch directories it left behind. Outcome is judged
  -- by what ended up on disk rather than by whether a given attempt reported success.
  for _ = 1, 2 do
    local todo = missing()
    if #todo == 0 then
      return
    end
    say(("⏳ Building %d treesitter parser(s)..."):format(#todo))
    pcall(function()
      treesitter.install(todo):wait(timeout_ms)
    end)
  end

  local todo = missing()
  if #todo > 0 then
    die("Treesitter parsers failed to build: " .. table.concat(todo, ", "))
  end
end

local function main()
  load_plugins({ "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig", "nvim-treesitter" })

  local failed = install_mason_packages()
  install_parsers()

  if #failed > 0 then
    die("Could not install: " .. table.concat(failed, ", "))
  end
end

-- nvim keeps going after an error in `-c lua ...` and would still exit 0, so failures have
-- to be turned into an explicit non-zero exit.
local ok, err = pcall(main)
if not ok then
  die(tostring(err))
end

say("✅ Mason tools and treesitter parsers ready.")
