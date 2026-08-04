## 🛠️ Dotfiles Setup

`setup.sh` is an orchestrator that runs each executable script in `runs/` (in
filename order) and then symlinks the dotfiles into your home directory with `stow`.

Every step is idempotent — rerunning the setup updates or skips anything that is
already installed instead of failing.

### What gets installed

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

On Linux these modern CLI tools are installed by `runs/00-install-packages.sh` for parity, so
the shared `zsh`/`git` config never points at a missing binary.

### Updating

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

**Both OSes**

- Reload your shell (`refresh`) or log out/in — some changes (login shell, macOS key
  repeat) only apply after that.
- Generate an SSH key (`ssh-keygen -t ed25519 -C "you@example.com"`) — **required**, since
  commit signing is on and commits fail without it. Add it to GitHub/GHE as an
  **authentication** key, and again as a **signing** key for the Verified badge. Then re-run
  `./setup.sh ssh-allowed-signers` so local verification picks it up.
- Sign in to apps and browsers.

**macOS**

- Grant **AeroSpace** Accessibility permission (System Settings → Privacy & Security →
  Accessibility), or it can't move windows.
- Set Ghostty as the default terminal (Ghostty → Settings) — there's no clean CLI for it.
- For Hootsuite tooling: run `hs-dotfiles-init` to auth the private `hootsuite/homebrew`
  tap, then `./setup.sh brew-bundle` to finish installing those formulae.

**Linux (Omarchy)**

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

Shared helpers (package install, git clone/update, OS detection) live in
`scripts/lib.sh`. To add a step, drop an executable script in `runs/` named with the
position you want it to run.

### Symlinking dotfiles

Dotfiles are split into three `stow` packages:

| Package   | Contents                                                                                   | Stowed on |
| --------- | ------------------------------------------------------------------------------------------ | --------- |
| `shared/` | `.zshrc`, `.gitconfig-common`, `.gitignore_global`, Ghostty config                         | always    |
| `macos/`  | `.gitconfig` (work email), `.ssh/config`, `.aerospace.toml`, `.zshrc.local` (work aliases) | macOS     |
| `linux/`  | `.gitconfig` (personal email), Hyprland (`.config/hypr`)                                   | Linux     |

`shared/.zshrc` sources `~/.zshrc.local` if present, so machine- or work-specific aliases
live in `macos/.zshrc.local` and are only stowed on macOS.

`.ssh/config` lives in `macos/` rather than `shared/` because it uses Apple's `UseKeychain`.

Editor settings are deliberately **not** tracked: Cursor is work-only on a single machine,
and VS Code on Omarchy uses its own Settings Sync. The `Brewfile` still tracks the VS Code
extension _list_.

The final step stows `shared` plus the package for the detected OS, so macOS never
symlinks the Hyprland config and Linux never symlinks the AeroSpace config. Before
linking, any existing real file that would be replaced is renamed to `<file>.backup`
(timestamped if a `.backup` already exists) so nothing is lost. Symlinks already
managed by this repo are left untouched, so reruns stay clean.

`PATH` entries for the installed tools (Bun, Go) live directly in `shared/.zshrc`.
