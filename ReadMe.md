# 🛠️ Dotfiles Setup

`setup.sh` is an orchestrator that runs each executable script in `runs/` (in
filename order) and then symlinks the dotfiles into your home directory with `stow`.

Every step is idempotent — rerunning the setup updates or skips anything that is
already installed instead of failing.

## What gets installed

On macOS, `Brewfile` is the source of truth for CLI tools, GUI apps (AeroSpace, Cursor,
VS Code, Ghostty, Raycast, Spotify, Proton Mail), fonts, and VS Code extensions. After
installing new things, refresh it with the `brewdump` alias (or run
`scripts/update-brewfile.sh`), then review the diff and commit.

**Not in the Brewfile on purpose:** Chrome, Firefox, Slack and Docker Desktop are deployed
by Jamf and owned by `root` in `/Applications`. Homebrew had _adopted_ them (see
`HOMEBREW_CASK_OPTS=--adopt` in `runs/05-brew-bundle.sh`) but could never upgrade them —
`brew upgrade --cask` fails on a root-owned bundle and leaves a multi-GB staging copy
behind. Worse, brew compares against its own install receipt, so once Keystone or Jamf
updates an app in the background `brew bundle check` reports drift forever. They're left to
IT. Don't re-add them: this note is here rather than in the `Brewfile` because `brewdump`
rewrites that file from scratch.

On Linux (Omarchy), `packages/arch-packages.txt` plays the same role for your _added_
packages — see [Arch/Omarchy packages](#archomarchy-packages).

- `zsh` + [Oh My Zsh](https://ohmyz.sh/) and plugins (autosuggestions, syntax-highlighting, zsh-bat, you-should-use, fzf-tab)
- [Spaceship](https://spaceship-prompt.sh/) prompt theme
- `zoxide` (smarter `cd`), `fzf` (with `Ctrl-R`/`Ctrl-T`/`Alt-C` keybindings), `direnv`
- Modern CLI tools: `bat`, `eza`, `fd`, `ripgrep`, `jq`, `git-delta`, `lazygit`, `tealdeer` (`tldr`), `btop`
- `nvm` + Node LTS
- Docker tooling: CLI, `buildx`, `compose`
- `lazydocker`
- [Ghostty](https://ghostty.org/) terminal (set as default on Linux)
- `bun`
- `go`
- [Cursor CLI](https://cursor.com/docs/cli) (`cursor-agent`) — macOS only; the `cursor-cli`
  cask is `depends_on :macos`, so there's no Linux equivalent in `arch-packages.txt`
- [Neovim](https://neovim.io/) — config layout is [below](#neovim)

On Linux these modern CLI tools are installed by `runs/00-install-packages.sh` for parity, so
the shared `zsh`/`git` config never points at a missing binary.

## Updating

Re-running `./setup.sh brew-bundle` does **not** upgrade anything — it runs with
`--no-upgrade` and only installs what's missing. To update everything installed via
Homebrew, use the `brewup` alias:

```bash
brewup   # brew update && brew upgrade && brew cleanup
```

`brew upgrade` skips casks that update themselves (Cursor, Docker, Chrome, …). Add
`--greedy` to force those too, though it's rarely needed.

`shared/.zshrc` also nudges you once a week (at most) on shell start if you haven't run
`brewup` recently — it's a time-based reminder, so it never hits the network or slows
startup. Running `brewup` resets the timer.

The `Brewfile` also stays in sync automatically: `shared/.zshrc` wraps `brew` so that after
a successful `install`, `uninstall`, `tap`, or `untap` it re-runs `brewdump`. The refreshed
`Brewfile` is left **uncommitted** so you can review the diff and commit it yourself.

## Arch/Omarchy packages

The Linux equivalent of the `Brewfile` is `packages/arch-packages.txt`. It tracks only the
packages **you added on top of Omarchy's defaults**, not Omarchy's full base set.

`pacdump` computes that by taking your explicitly-installed packages (`pacman -Qqe`) and
subtracting Omarchy's canonical manifests
(`~/.local/share/omarchy/install/omarchy-base.packages` and `omarchy-other.packages`):

```bash
pacdump   # writes packages/arch-packages.txt, then review + commit the diff
```

On a new Omarchy machine, install Omarchy first (which restores the base set), then
`setup.sh` runs `runs/05-arch-packages.sh`, which installs everything in the list with
`yay -S --needed` (works for both official-repo and AUR packages). Re-running is safe —
`--needed` skips anything already present.

Notes:

- Version pinning isn't used; you get whatever the current mirrors/AUR serve.
- Run this on a real Omarchy box — the manifests only exist there. Off Omarchy (e.g. plain
  Arch) `pacdump` falls back to listing all explicit packages, since there's no baseline.

## Usage

Clone the repo, `cd` into it, and run:

```bash
./setup.sh
```

When it finishes, refresh `~/.zshrc`.

### Run a subset

Pass a filter to only run scripts whose path matches it:

```bash
./setup.sh plugins   # runs runs/20-install-zsh-plugins.sh only
./setup.sh docker    # runs the docker-related scripts
```

### Operating system

The OS is auto-detected with `uname` and defaults to Linux. Force macOS if needed:

```bash
./setup.sh --macos   # or -m
./setup.sh --linux   # or -l
```

Each step picks the right package manager automatically (`brew`, `apt`, `dnf`, or
`pacman`), so the same command works on Linux and macOS.

## Manual steps after setup

`setup.sh` handles system defaults, the login shell, tools, and symlinks. A few things
still need a human:

### Both OSes

- Reload your shell (`refresh`) or log out/in — some changes (login shell, macOS key
  repeat) only apply after that.
- Generate an SSH key (`ssh-keygen -t ed25519 -C "you@example.com"`) — **required**, since
  commit signing is on and commits fail without it. Add it to GitHub/GHE as an
  **authentication** key, and again as a **signing** key for the Verified badge. Then re-run
  `./setup.sh ssh-allowed-signers` so local verification picks it up.
- Sign in to apps and browsers.

### macOS

- Grant **AeroSpace** Accessibility permission (System Settings → Privacy & Security →
  Accessibility), or it can't move windows.
- Set Ghostty as the default terminal (Ghostty → Settings) — there's no clean CLI for it.
- For Hootsuite tooling: run `hs-dotfiles-init` to auth the private `hootsuite/homebrew`
  tap, then `./setup.sh brew-bundle` to finish installing those formulae.

### Linux (Omarchy)

- Log out/in for the `zsh` login-shell change to take effect.
- Relaunch Hyprland (Super+Esc → Relaunch) to apply the stowed config.
- Edit `linux/.config/hypr/monitors.conf` and the NVIDIA env vars in `hyprland.conf` if
  the machine's hardware differs.

## Handy aliases

Defined in `shared/.zshrc` (reload with `refresh` after editing):

| Alias               | Does                                                       |
| ------------------- | ---------------------------------------------------------- |
| `refresh`           | Reload `~/.zshrc`                                          |
| `dots`              | Open this dotfiles repo in `$EDITOR_CMD`                   |
| `c`                 | Open the current directory in VS Code                      |
| `v`                 | `nvim`                                                     |
| `ls`/`ll`/`la`/`lt` | `eza` listings (plain / long / long+hidden / tree)         |
| `brewup`            | Update Homebrew and upgrade + clean up everything          |
| `brewdump`          | Refresh `Brewfile` from the current Homebrew state         |
| `pacdump`           | Refresh `packages/arch-packages.txt` (Linux/Omarchy)       |
| `gco`               | `git checkout`                                             |
| `main`              | Check out `main` and pull                                  |
| `develop`           | Check out `develop` and pull                               |
| `garbageday`        | Delete all local branches except `main`/`master`/`develop` |
| `lz`                | lazygit`                                                   |

## Window management

[AeroSpace](https://github.com/nikitabobko/AeroSpace) (macOS) and Hyprland (Omarchy) are kept
in sync so muscle memory carries across machines. Workspaces hold the same class of app on
both:

| WS  | Apps                                       |
| --- | ------------------------------------------ |
| 1   | Editor (Cursor / VS Code)                  |
| 2   | Chat (Slack, Messages / Discord, WhatsApp) |
| 3   | Terminal (Ghostty)                         |
| 4   | Mail (Proton Mail)                         |
| 5   | Music (Spotify)                            |

Browsers are intentionally left unassigned on both. Within a workspace, AeroSpace uses
`alt`+`h`/`j`/`k`/`l` to focus and `alt`+`shift`+`h`/`j`/`k`/`l` to move windows — the mirror
of Hyprland's arrow-key navigation (`alt` on macOS ≈ `super` on Linux). Workspace switching
uses `cmd`+number on macOS and `super`+number on Linux.

Ghostty's own splits sit one level down on `ctrl`+`shift`: `d` to split, `w` to close, `e` to
equalize, and `h`/`j`/`k`/`l` to move between them. They avoid `cmd`/`super` and bare `ctrl`
on purpose. Ghostty reads `cmd` as `super`, and on Omarchy Hyprland grabs `super` combos
compositor-side before the focused app sees them (`super`+`d` opens Discord, `super`+`w`
closes the window), so anything on `super` works on the Mac and silently dies on Omarchy.
Bare `ctrl`+`a`/`d`/`e`/`l`/`x` are readline keys (start of line, EOF, end of line, clear,
emacs prefix) and Ghostty swallows any key it has bound before the shell sees it.
`ctrl`+`shift` is untouched by both, and is Ghostty's own default modifier on Linux.

## Neovim

The config lives in `shared/`, so the two machines are identical and nothing depends on
Omarchy — which matters because Omarchy ships its own `neovim` and `omarchy-nvim` (a
pre-warmed LazyVim), and either can change upstream without warning.

Built on the [LazyVim](https://lazyvim.org) starter. The repo tracks only the user layer —
`init.lua`, `lua/config/`, `lua/plugins/` — because LazyVim itself is a _plugin_ that
`lazy.nvim` fetches into `~/.local/share/nvim`. Two generated files are tracked alongside it:
`lazy-lock.json` pins every plugin to an exact commit, and `lazyvim.json` records which
[Extras](https://www.lazyvim.org/extras) are enabled, which is the only reason a fresh machine
gets the Go, TypeScript, Markdown and other language layers.

`:Lazy update` and `:LazyExtras` write those files through the `stow` symlink straight into
this repo and leave them **uncommitted**, the same review-then-commit loop `brewdump` uses for
the `Brewfile`. `runs/92-nvim-bootstrap.sh` replays them so a fresh machine lands on the
identical set without a manual first launch. It runs after `90-stow-home.sh` because it needs
the config symlinked first.

**On a new machine** the bootstrap runs in two phases, because `Lazy! restore` only covers
plugins. Language servers, linters and formatters come from Mason, and treesitter parsers are
compiled locally; neither is in the lockfile. `scripts/nvim-install-tools.lua` reads the tool
list out of the resolved LazyVim config and installs both, blocking until they finish. Without
it the first launch is a half-built editor that fills itself in per filetype as you open files.
Budget a few minutes for roughly 27 Mason packages and 36 parsers. Compiling parsers shells
out to the `tree-sitter` CLI, so that is a real system dependency — `tree-sitter-cli` in the
`Brewfile` and in `runs/00-install-packages.sh` — and the script refuses to start without it
rather than failing halfway. `Could not rename temp: ENOTEMPTY` errors in the first phase are
expected: `Lazy!` starts parser builds and `+qa` kills them partway through, so the second
phase retries whatever is missing and fails only if a parser is still absent afterwards.

Mason is the one place the two machines can drift. It has no lockfile, so plugins are pinned to
a commit while tool versions are whatever the registry served on the day.

Beyond the language layers, the enabled extras are `dap.core`, `test.core`, `ai.sidekick`,
`util.octo`, `coding.mini-surround`, `ui.treesitter-context` and `editor.inc-rename`. Two need
local overrides, which is all `lua/plugins/` holds besides the theme. `ai.lua` disables
Sidekick's Next Edit Suggestions, because those need a Copilot subscription and enabling them
also starts a `copilot` LSP client; the half that is used is the CLI terminal, which drives the
`cursor-agent` binary from the `cursor-cli` cask. `test.lua` adds the jest, vitest and
Playwright adapters, because `test.core` ships neotest with no JavaScript adapter at all.
Debugging needs no override — `lang.typescript` already registers the node and chrome adapters
and reads `.vscode/launch.json`, so existing launch configs work untouched.

### Keys worth remembering

All LazyVim defaults, with `<leader>` being space. When a binding won't come to mind, press
`<leader>` alone for the which-key menu, or `<leader>sk` to search every keymap.

| Keys                                       | Does                                                  |
| ------------------------------------------ | ----------------------------------------------------- |
| `<leader>sk` / `<leader>?`                 | Search all keymaps / only this buffer's               |
| `s` / `S`                                  | Jump to any two characters on screen / a syntax node  |
| `]d` / `[d`                                | Next / previous diagnostic                            |
| `<leader>cd` / `<leader>xx`                | Diagnostic on this line / all of them in Trouble      |
| `<leader>cf`                               | Format the buffer                                     |
| `<leader>uf` / `<leader>uF`                | Toggle format-on-save globally / for this buffer      |
| `<leader>ud`                               | Turn diagnostics off                                  |
| `<leader>cr`                               | Rename a symbol, with live preview                    |
| `gsa` / `gsd` / `gsr`                      | Add / delete / replace surrounding quotes or brackets |
| `<leader>tr` / `<leader>tt`                | Run the nearest test / every test in the file         |
| `<leader>ts` / `<leader>tw`                | Test summary panel / watch mode                       |
| `<leader>td`                               | Debug the nearest test                                |
| `<leader>db` / `<leader>dc`                | Toggle a breakpoint / start or continue               |
| `<leader>di` / `<leader>dO` / `<leader>do` | Step into / over / out                                |
| `<leader>aa` / `ctrl`+`.`                  | Toggle the AI CLI panel / jump into it                |
| `<leader>at` / `<leader>av`                | Send the thing under the cursor / the selection       |
| `<leader>gp` / `<leader>gi`                | List PRs / issues without leaving the editor          |

When something looks wrong: `:LazyHealth` and `:checkhealth` for the broad picture,
`:checkhealth vim.lsp` for a language server that won't attach (`:LspInfo` no longer exists),
`:ConformInfo` for a formatter that isn't running, `:Mason` for a missing tool, `:Lazy` for a
plugin, and `:LazyExtras` to turn a layer on or off — which rewrites `lazyvim.json`, so it
needs committing afterwards.

### Learning the motions

`:Tutor` is the thirty-minute interactive tutorial built into Neovim, and it is the right
starting point. The LazyVim starter disables it by listing `tutor` in
`performance.rtp.disabled_plugins`; that line has been removed here, so the command works.

The leverage isn't in memorising bindings, it's in the grammar: an **operator** (`c` change,
`d` delete, `y` yank, `v` select) takes a **selector** (`i` inner, `a` around) and a **text
object**. Fifteen or so keys therefore cover several hundred edits. `mini.ai` and
`nvim-treesitter-textobjects` add the syntax-aware objects, which is where most of the value is
for TypeScript:

| Object                | Selects                                              |
| --------------------- | ---------------------------------------------------- |
| `f`                   | A function — `caf` replaces one, `cif` just its body |
| `u`                   | A function call, name and arguments together         |
| `t`                   | An HTML or JSX tag — `cit` swaps the contents        |
| `o`                   | The nearest block, conditional or loop               |
| `c`                   | A class                                              |
| `e`                   | One camelCase segment of an identifier               |
| `w` / `p` / `"` / `(` | Word, paragraph, quotes, brackets                    |

`hardtime.nvim` handles the habit side. It is set to `restriction_mode = "hint"`, so pressing
`j` five times in a row prints the motion that would have been shorter rather than swallowing
the keypress; arrow keys and the mouse are deliberately left working, unlike its defaults.
`<leader>uH` toggles it and `:Hardtime report` shows what you've been leaning on.

`:h motion.txt` and `:h text-objects` are the real references once the shape makes sense.

The colourscheme is Night Owl, matching Ghostty and the VS Code extension. Note that
`night-owl.nvim` never sets `g:colors_name`, so that variable reads `nil` even when the
theme is applied — check a highlight group instead.

**On Omarchy**, `omarchy-nvim` owns `~/.config/nvim` and pre-warms `~/.local/share/nvim`
with plugins that won't match our lockfile. Stow backs up each config file it replaces, and
the bootstrap script moves the data directory aside once (guarded by a marker file) so
`lazy.nvim` rebuilds cleanly. Leave the `omarchy-nvim` package installed — it's in Omarchy's
base set. If an `omarchy-update` migration ever re-runs `omarchy-nvim-setup`, it prompts
before overwriting, and `./setup.sh stow-home` puts things back.

## Cloning repos

Setup creates `~/code`, and `shared/.zshrc` wraps `git` so a bare clone lands there:

```bash
git clone https://github.com/org/repo.git   # → ~/code/repo
git clone https://github.com/org/repo.git .  # explicit target → clones into the current dir
```

Any invocation with an explicit target (or extra flags) is passed straight through to `git`.

## Git identity & commit signing

Everything except the email address lives in `shared/.gitconfig-common`, which both OS
configs pull in with a git `[include]`. That makes `macos/.gitconfig` and `linux/.gitconfig`
four lines each — the include plus one email — so a setting can't drift between the two:

```ini
[include]
 path = ~/.gitconfig-common
[user]
 email = kellen.wiltshire@hootsuite.com   # macOS (work machine)
```

The Mac only ever holds work repos, so it uses the Hootsuite identity everywhere with no
per-repo split; Omarchy uses the personal address. The two are never stowed together.

Both sign every commit with `~/.ssh/id_ed25519` (SSH signing, not GPG), so **each machine
needs that key or commits will fail outright** — `git commit` aborts with `failed to write
commit object` rather than falling back to unsigned. `runs/91-ssh-allowed-signers.sh` writes
`~/.ssh/allowed_signers` so `git log --show-signature` verifies locally, and warns loudly at
setup time if the key is missing. For a green "Verified" badge, upload the **same public key
again** as a _signing_ key — a separate entry from the authentication key — in GHE and/or
github.com under Settings → SSH and GPG keys.

## Node & Yarn versions

`nvm` handles Node per repo via `.nvmrc` (auto-switching on `cd`). Yarn/pnpm are handled by
[Corepack](https://github.com/nodejs/corepack): setup runs `corepack enable`, and the
`.zshrc` `nvm` hook re-enables it whenever a new Node version is installed or switched to.
In any repo that declares a `"packageManager"` field in `package.json`, `yarn` automatically
uses that exact version — no manual `yarn set version` needed.

## How it works

### Orchestrator

`setup.sh` resolves the OS, exports `DOTFILES_OS`, then executes every
executable file in `runs/` in order:

| Script                      | Purpose                                               |
| --------------------------- | ----------------------------------------------------- |
| `00-install-homebrew.sh`    | Bootstrap Homebrew (macOS only)                       |
| `00-install-packages.sh`    | `zsh`, `stow`, `zoxide`                               |
| `05-brew-bundle.sh`         | Install everything in `Brewfile` (macOS only)         |
| `05-arch-packages.sh`       | Install `packages/arch-packages.txt` (Linux only)     |
| `06-create-code-dir.sh`     | Ensure `~/code` exists                                |
| `10-install-oh-my-zsh.sh`   | Oh My Zsh (installs or updates)                       |
| `20-install-zsh-plugins.sh` | Zsh plugins                                           |
| `30-install-spaceship.sh`   | Spaceship prompt theme                                |
| `40-install-nvm.sh`         | `nvm` + Node LTS                                      |
| `50-install-docker.sh`      | Docker CLI, `buildx`, `compose`                       |
| `55-install-ghostty.sh`     | Ghostty terminal                                      |
| `60-install-bun.sh`         | `bun`                                                 |
| `70-install-go.sh`          | `go`                                                  |
| `80-install-lazydocker.sh`  | `lazydocker`                                          |
| `85-macos-defaults.sh`      | Apply macOS system defaults (macOS only)              |
| `88-set-default-shell.sh`   | Set `zsh` as the login shell (idempotent)             |
| `90-stow-home.sh`           | Symlink dotfiles with `stow`                          |
| `91-ssh-allowed-signers.sh` | Write `~/.ssh/allowed_signers` for SSH commit signing |
| `92-nvim-bootstrap.sh`      | Neovim plugins, Mason tools, treesitter parsers       |

Shared helpers (package install, git clone/update, OS detection) live in
`scripts/lib.sh`. To add a step, drop an executable script in `runs/` named with the
position you want it to run.

### Symlinking dotfiles

Dotfiles are split into three `stow` packages:

| Package   | Contents                                                                                   | Stowed on |
| --------- | ------------------------------------------------------------------------------------------ | --------- |
| `shared/` | `.zshrc`, `.gitconfig-common`, `.gitignore_global`, Ghostty and Neovim config              | always    |
| `macos/`  | `.gitconfig` (work email), `.ssh/config`, `.aerospace.toml`, `.zshrc.local` (work aliases) | macOS     |
| `linux/`  | `.gitconfig` (personal email), Hyprland (`.config/hypr`)                                   | Linux     |

`shared/.zshrc` sources `~/.zshrc.local` if present, so machine- or work-specific aliases
live in `macos/.zshrc.local` and are only stowed on macOS.

`.ssh/config` lives in `macos/` rather than `shared/` because it uses Apple's `UseKeychain`.

GUI editor settings are deliberately **not** tracked: Cursor is work-only on a single
machine, and VS Code on Omarchy uses its own Settings Sync. The `Brewfile` still tracks the
VS Code extension _list_. Neovim is the exception — see [Neovim](#neovim).

The final step stows `shared` plus the package for the detected OS, so macOS never
symlinks the Hyprland config and Linux never symlinks the AeroSpace config. Before
linking, any existing real file that would be replaced is renamed to `<file>.backup`
(timestamped if a `.backup` already exists) so nothing is lost. Symlinks already
managed by this repo are left untouched, so reruns stay clean.

`PATH` entries for the installed tools (Bun, Go) live directly in `shared/.zshrc`.
