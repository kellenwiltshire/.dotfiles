## 🛠️ Dotfiles Setup

`setup.sh` is an orchestrator that runs each executable script in `runs/` (in
filename order) and then symlinks the dotfiles into your home directory with `stow`.

Every step is idempotent — rerunning the setup updates or skips anything that is
already installed instead of failing.

### What gets installed

On macOS, `Brewfile` is the source of truth for CLI tools, GUI apps (AeroSpace, Cursor,
VS Code, Ghostty, Docker Desktop, Chrome, Firefox, Slack, Raycast, Spotify, Proton Mail),
fonts, and VS Code extensions. After installing new things, refresh it with the `brewdump`
alias (or run `scripts/update-brewfile.sh`), then review the diff and commit.

- `zsh` + [Oh My Zsh](https://ohmyz.sh/) and plugins (autosuggestions, syntax-highlighting, zsh-bat, you-should-use, fzf-tab)
- [Spaceship](https://spaceship-prompt.sh/) prompt theme
- `zoxide` (smarter `cd`)
- `nvm` + Node LTS
- Docker tooling: CLI, `buildx`, `compose`
- `lazydocker`
- [Ghostty](https://ghostty.org/) terminal (set as default on Linux)
- `bun`
- `go`

### Updating

Re-running `./setup.sh brew-bundle` does **not** upgrade anything — it runs with
`--no-upgrade` and only installs what's missing. To update everything installed via
Homebrew, use the `brewup` alias:

```bash
brewup   # brew update && brew upgrade && brew cleanup
```

`brew upgrade` skips casks that update themselves (Cursor, Docker, Chrome, …). Add
`--greedy` to force those too, though it's rarely needed.

## Usage

Clone the repo, `cd` into it, and run:

```bash
./setup.sh
```

When it finishes it loads your new `~/.zshrc` automatically.

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

## Handy aliases

Defined in `shared/.zshrc` (reload with `refresh` after editing):

| Alias | Does |
| --- | --- |
| `refresh` | Reload `~/.zshrc` |
| `zsh` | Open this dotfiles repo in VS Code |
| `c` | Open the current directory in VS Code |
| `brewup` | Update Homebrew and upgrade + clean up everything |
| `brewdump` | Refresh `Brewfile` from the current Homebrew state |
| `gco` | `git checkout` |
| `main` | Check out `main` and pull |
| `develop` | Check out `develop` and pull |
| `garbageday` | Delete all local branches except `main`/`master`/`develop` |

## Cloning repos

Setup creates `~/code`, and `shared/.zshrc` wraps `git` so a bare clone lands there:

```bash
git clone https://github.com/org/repo.git   # → ~/code/repo
git clone https://github.com/org/repo.git .  # explicit target → clones into the current dir
```

Any invocation with an explicit target (or extra flags) is passed straight through to `git`.

## How it works

### Orchestrator

`setup.sh` resolves the OS, exports `DOTFILES_OS`, then executes every
executable file in `runs/` in order:

| Script | Purpose |
| --- | --- |
| `00-install-homebrew.sh` | Bootstrap Homebrew (macOS only) |
| `00-install-packages.sh` | `zsh`, `stow`, `zoxide` |
| `05-brew-bundle.sh` | Install everything in `Brewfile` (macOS only) |
| `06-create-code-dir.sh` | Ensure `~/code` exists |
| `10-install-oh-my-zsh.sh` | Oh My Zsh (installs or updates) |
| `20-install-zsh-plugins.sh` | Zsh plugins |
| `30-install-spaceship.sh` | Spaceship prompt theme |
| `40-install-nvm.sh` | `nvm` + Node LTS |
| `50-install-docker.sh` | Docker CLI, `buildx`, `compose` |
| `55-install-ghostty.sh` | Ghostty terminal |
| `60-install-bun.sh` | `bun` |
| `70-install-go.sh` | `go` |
| `80-install-lazydocker.sh` | `lazydocker` |
| `85-macos-defaults.sh` | Apply macOS system defaults (macOS only) |
| `88-set-default-shell.sh` | Set `zsh` as the login shell (idempotent) |
| `90-stow-home.sh` | Symlink dotfiles with `stow` |

Shared helpers (package install, git clone/update, OS detection) live in
`scripts/lib.sh`. To add a step, drop an executable script in `runs/` named with the
position you want it to run.

### Symlinking dotfiles

Dotfiles are split into three `stow` packages:

| Package | Contents | Stowed on |
| --- | --- | --- |
| `shared/` | `.zshrc`, `.gitconfig`, Ghostty config | always |
| `macos/` | `.aerospace.toml`, `.zshrc.local` (work aliases) | macOS |
| `linux/` | Hyprland (`.config/hypr`) | Linux |

`shared/.zshrc` sources `~/.zshrc.local` if present, so machine- or work-specific aliases
live in `macos/.zshrc.local` and are only stowed on macOS.

The final step stows `shared` plus the package for the detected OS, so macOS never
symlinks the Hyprland config and Linux never symlinks the AeroSpace config. Before
linking, any existing real file that would be replaced is renamed to `<file>.backup`
(timestamped if a `.backup` already exists) so nothing is lost. Symlinks already
managed by this repo are left untouched, so reruns stay clean.

`PATH` entries for the installed tools (Bun, Go) live directly in `shared/.zshrc`.
