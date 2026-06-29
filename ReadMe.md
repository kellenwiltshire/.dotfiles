## 🛠️ Dotfiles Setup

`setup.sh` is an orchestrator that runs each executable script in `runs/` (in
filename order) and then symlinks the dotfiles into your home directory with `stow`.

Every step is idempotent — rerunning the setup updates or skips anything that is
already installed instead of failing.

### What gets installed

- `zsh` + [Oh My Zsh](https://ohmyz.sh/) and plugins (autosuggestions, syntax-highlighting, zsh-bat, you-should-use, fzf-tab)
- [Spaceship](https://spaceship-prompt.sh/) prompt theme
- `zoxide` (smarter `cd`)
- `nvm` + Node LTS
- Docker tooling: CLI, `buildx`, `compose`
- `lazydocker`
- [Ghostty](https://ghostty.org/) terminal (set as default on Linux)
- `bun`
- `go`

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

## How it works

### Orchestrator

`setup.sh` resolves the OS, exports `DOTFILES_OS`, then executes every
executable file in `runs/` in order:

| Script | Purpose |
| --- | --- |
| `00-install-packages.sh` | `zsh`, `stow`, `zoxide` |
| `10-install-oh-my-zsh.sh` | Oh My Zsh (installs or updates) |
| `20-install-zsh-plugins.sh` | Zsh plugins |
| `30-install-spaceship.sh` | Spaceship prompt theme |
| `40-install-nvm.sh` | `nvm` + Node LTS |
| `50-install-docker.sh` | Docker CLI, `buildx`, `compose` |
| `55-install-ghostty.sh` | Ghostty terminal |
| `60-install-bun.sh` | `bun` |
| `70-install-go.sh` | `go` |
| `80-install-lazydocker.sh` | `lazydocker` |
| `90-stow-home.sh` | Symlink dotfiles with `stow` |

Shared helpers (package install, git clone/update, OS detection) live in
`scripts/lib.sh`. To add a step, drop an executable script in `runs/` named with the
position you want it to run.

### Symlinking dotfiles

The final step stows everything under `home/` into your home directory. Before
linking, any existing real file that would be replaced is renamed to `<file>.backup`
(timestamped if a `.backup` already exists) so nothing is lost. Symlinks already
managed by this repo are left untouched, so reruns stay clean.

`PATH` entries for the installed tools (Bun, Go) live directly in `home/.zshrc`.
