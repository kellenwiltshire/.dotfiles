# 📋 Cheatsheet

Quick lookup for the commands and keys this setup provides. The [ReadMe](ReadMe.md) covers why
any of it is the way it is.

## Dotfiles maintenance

| Command | Does |
| --- | --- |
| `./setup.sh` | Run every step for the detected OS |
| `./setup.sh <filter>` | Run only steps whose path matches, e.g. `./setup.sh docker` |
| `./setup.sh --macos` / `--linux` | Force an OS instead of auto-detecting (`-m` / `-l`) |
| `./setup.sh stow-home` | Re-symlink dotfiles, pruning orphans and backing up conflicts |
| `./setup.sh ssh-allowed-signers` | Rewrite `~/.ssh/allowed_signers` after adding a key |
| `dots` | Open this repo in `$EDITOR_CMD` |
| `refresh` | Reload `~/.zshrc` |

### Keeping package lists in sync

Both write an uncommitted file for you to review, then commit.

| Command | Does |
| --- | --- |
| `brewup` | `brew update && brew upgrade && brew cleanup` (macOS) |
| `brewdump` | Refresh `Brewfile` from current Homebrew state |
| `pacdump` | Refresh `packages/arch-packages.txt` (Omarchy only) |

`brewdump` runs automatically after `brew install`/`uninstall`/`tap`/`untap`. `brew upgrade`
skips self-updating casks; add `--greedy` to force them.

## Shell aliases

| Alias | Does |
| --- | --- |
| `ls` / `ll` / `la` / `lt` | `eza` listings: plain / long / long+hidden / tree |
| `v` | `nvim` |
| `c` | Open the current directory — Cursor on macOS, `$EDITOR_CMD` (nvim) elsewhere |
| `lz` | `lazygit` |
| `lzw [dir]` | `lazygit` in a new Ghostty window |
| `gco` | `git checkout` |
| `main` / `develop` | Check out that branch and pull |
| `garbageday` | Delete every local branch except `main`/`master`/`develop` |

Oh My Zsh's `git` plugin is loaded, so its aliases (`gst`, `gl`, `gcm`, …) are available too.

### macOS only

Defined in `macos/.zshrc.local`, which `shared/.zshrc` sources last.

| Alias | Does |
| --- | --- |
| `homepage` / `signup` / `fe-global` / `dashboard` / `website` | `cd` to that repo in `~/code` |
| `master` | Check out `master`, pull, then `yarn` |
| `rebase` | `git pull --rebase` |
| `start` / `yt` | `yarn start` / `yarn test` |
| `yarn1` / `yarn3` / `yarn4` | Pin Yarn to 1.22.22 / 3.2.4 / 4.6.0 |

## fzf

| Keys | Does |
| --- | --- |
| `ctrl`+`r` | Fuzzy-search command history |
| `ctrl`+`t` | Insert a file path into the command line |
| `alt`+`c` | `cd` into a subdirectory |
| `<tab>` | Fuzzy-complete the current word, with a preview pane |

## tmux

The prefix is `ctrl`+`a`. Press `prefix` then `a` to send a literal `ctrl`+`a` through to the
shell. Keys marked *no prefix* are pressed directly.

### Sessions

| Keys | Does |
| --- | --- |
| `cmd`+`return` / `super`+`return` | Terminal on workspace 1 — activates it on macOS, new window on Omarchy |
| `ctrl`+`f` | Sessionizer — pick a project, from any shell |
| `prefix` + `f` | Sessionizer, from inside tmux |
| `tmux-sessionizer <dir>` | Jump straight to a directory, skipping the picker |
| `prefix` + `C` | New session in the current pane's directory |
| `prefix` + `R` | Rename session |
| `prefix` + `K` | Kill session (you stay in tmux) |
| `prefix` + `P` / `N` | Previous / next session |
| `alt`+`up` / `alt`+`down` | Previous / next session (*no prefix*) |
| `alt`+`o` | Toggle back to the session you came from (*no prefix*) |
| `prefix` + `L` | Toggle back to the session you came from |
| `prefix` + `d` | Detach |
| `tmux ls` | List sessions |
| `tmux attach` | Reattach to the last session |

The sessionizer offers each subdirectory of `~/code` plus `~/.dotfiles`. Change that by
editing the `parents` and `leaves` arrays at the top of `shared/.local/bin/tmux-sessionizer`.

### Windows

| Keys | Does |
| --- | --- |
| `prefix` + `c` | New window in the current pane's directory |
| `prefix` + `r` | Rename window |
| `prefix` + `X` | Kill window |
| `prefix` + `^` | Last window |
| `alt`+`1`…`alt`+`9` | Jump to window by number (*no prefix*) |
| `alt`+`left` / `alt`+`right` | Previous / next window (*no prefix*) |
| `alt`+`shift`+`left` / `right` | Move this window left / right (*no prefix*) |

### Panes

| Keys | Does |
| --- | --- |
| `prefix` + `h` / `j` / `k` / `l` | Move between panes — hold prefix to repeat |
| `prefix` + `\|` | Split side by side |
| `prefix` + `-` | Split stacked |
| `prefix` + `x` | Kill pane |
| `prefix` + `z` | Zoom the pane full screen, and back |
| `ctrl`+`alt`+arrows | Move between panes (*no prefix*) |
| `ctrl`+`alt`+`shift`+arrows | Resize by 5 (*no prefix*) |
| `alt`+`enter` | Split stacked (*no prefix*) |
| `alt`+`shift`+`enter` | Split side by side (*no prefix*) |
| `alt`+`escape` | Kill pane (*no prefix*) |

### Copy mode

Mouse is on, so scrolling enters copy mode too. Yanks go to the system clipboard on both
machines via OSC 52.

| Keys | Does |
| --- | --- |
| `prefix` + `[` | Enter copy mode |
| `v` then motions | Start a selection (vi keys) |
| `y` | Copy the selection and exit |
| `prefix` + `]` | Paste |
| `q` | Leave copy mode |

### Scratch pad

| Keys | Does |
| --- | --- |
| `alt`+`g` | Open / close a popup on `~/notes/scratch.md` (*no prefix*) |

One shared `scratch` session behind the popup, so closing it detaches instead of quitting nvim:
cursor, undo history and unsaved text survive. Autosave flushes the file when you stop typing.

### Config

| Command | Does |
| --- | --- |
| `prefix` + `q` | Reload `~/.config/tmux/tmux.conf` |
| `tmux list-keys -T prefix` | Show every prefix binding actually in effect |

## Neovim

LazyVim defaults, with `<leader>` being space. Press `<leader>` alone for the which-key menu.

| Keys | Does |
| --- | --- |
| `<leader>sk` / `<leader>?` | Search all keymaps / only this buffer's |
| `s` / `S` | Jump to any two characters on screen / a syntax node |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cd` / `<leader>xx` | Diagnostic on this line / all of them in Trouble |
| `<leader>cf` | Format the buffer |
| `<leader>uf` / `<leader>uF` | Toggle format-on-save globally / for this buffer |
| `<leader>ud` | Turn diagnostics off |
| `<leader>cr` | Rename a symbol, with live preview |
| `gsa` / `gsd` / `gsr` | Add / delete / replace surrounding quotes or brackets |
| `<leader>tr` / `<leader>tt` | Run the nearest test / every test in the file |
| `<leader>ts` / `<leader>tw` | Test summary panel / watch mode |
| `<leader>td` | Debug the nearest test |
| `<leader>db` / `<leader>dc` | Toggle a breakpoint / start or continue |
| `<leader>di` / `<leader>dO` / `<leader>do` | Step into / over / out |
| `<leader>aa` / `ctrl`+`.` | Toggle the AI CLI panel / jump into it |
| `<leader>at` / `<leader>av` | Send the thing under the cursor / the selection |
| `<leader>gp` / `<leader>gi` | List PRs / issues without leaving the editor |

### Text objects

Combine an operator (`c` change, `d` delete, `y` yank, `v` select) with `i` inner or `a`
around, then one of these.

| Object | Selects |
| --- | --- |
| `f` | A function — `caf` replaces one, `cif` just its body |
| `u` | A function call, name and arguments together |
| `t` | An HTML or JSX tag — `cit` swaps the contents |
| `o` | The nearest block, conditional or loop |
| `c` | A class |
| `e` | One camelCase segment of an identifier |
| `w` / `p` / `"` / `(` | Word, paragraph, quotes, brackets |

### Learning and diagnosing

| Command | Does |
| --- | --- |
| `:Tutor` | The built-in thirty-minute tutorial |
| `:h motion.txt` / `:h text-objects` | The real references |
| `<leader>uH` / `:Hardtime report` | Toggle habit hints / see what you lean on |
| `:LazyHealth` / `:checkhealth` | Broad health check |
| `:checkhealth vim.lsp` | A language server that won't attach |
| `:ConformInfo` | A formatter that isn't running |
| `:Mason` / `:Lazy` | A missing tool / a plugin |
| `:LazyExtras` | Toggle a language layer — rewrites `lazyvim.json`, so commit after |

## Omarchy

| Command | Does |
| --- | --- |
| `omarchy menu keybindings --print` | List every Hyprland binding with its description |
| `omarchy-update` | Update Omarchy and run migrations |
| `omarchy-refresh-hyprland` | Reset all `~/.config/hypr/*.lua` to current defaults |
| `omarchy-refresh-config <path>` | Reset one shipped config, e.g. `tmux/tmux.conf` |
| `hyprctl monitors all` | Output names and every supported mode |
| `hyprctl clients` | Window classes and titles, for writing window rules |

Because the hypr configs are stowed, `omarchy-refresh-*` writes through the symlink into this
repo — review the result with `git diff`. It rewrites `monitors.lua` too, so re-apply the
monitor block afterwards.

| Keys | Does |
| --- | --- |
| `super`+`escape` | Omarchy menu, including Relaunch to reload Hyprland |
| `super`+`/` | Monitor scaling up — see the warning in the [ReadMe](ReadMe.md#hyprland-config) |
| `super`+`ctrl`+`l` | Lock |
| `super`+`ctrl`+`i` | Toggle locking on idle |

## Git

Identity and signing are configured for you; these are the parts worth remembering.

| Command | Does |
| --- | --- |
| `git clone <url>` | Clones into `~/code/<repo>` |
| `git clone <url> .` | Any explicit target is passed straight through to `git` |
| `git log --show-signature` | Verify commit signatures locally |
| `ssh-keygen -t ed25519 -C "you@example.com"` | Required on every machine, or commits fail |

Upload that public key to GitHub twice: once as an **authentication** key, once as a
**signing** key for the Verified badge.
