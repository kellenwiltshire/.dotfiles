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
| `prefix` + `s` | Go to a session or project — popup picker with a preview |
| `ctrl`+`f` | The same picker, one key instead of two (*no prefix*) |
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

The picker lists running sessions first, each with its git branch, ordered so the one you came
from is at the top — `prefix` + `s` then Enter goes straight back. Below those come the
subdirectories of `~/code` that are not already running; picking one creates its session on the
way in. `?` opens a preview of whatever is highlighted — the session's live screen, or the
directory's contents.

Typing a name that matches nothing is handed to zoxide, which is how anywhere outside `~/code`
is reached, `~/.dotfiles` included. Failing that, the name becomes an empty session.

The session you are in is left out of the list, as is `scratch` — switching into the scratchpad's
session would strand its nvim in an ordinary window.

### Inside the picker

| Keys | Does |
| --- | --- |
| `enter` | Switch to the highlighted session, creating it if it is a directory |
| `alt`+`backspace` | Kill the highlighted session |
| `ctrl`+`r` | Rename the highlighted session |
| `ctrl`+`w` | List every window instead of sessions, to jump straight into one |
| `ctrl`+`f` | List the whole zoxide database |
| `ctrl`+`x` | List `~/.config` |
| `ctrl`+`t` | Swap the preview for a tree of sessions and windows |
| `ctrl`+`b` | Back to the session list after any of the above |
| `ctrl`+`p` / `ctrl`+`n` | Up / down the list |
| `ctrl`+`u` / `ctrl`+`d` | Scroll the preview |
| `?` | Toggle the preview — it starts hidden |

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
| `ctrl`+`h` / `j` / `k` / `l` | Move between panes **and** Neovim splits (*no prefix*) |
| `prefix` + `\|` | Split side by side |
| `prefix` + `-` | Split stacked |
| `prefix` + `x` | Kill pane |
| `prefix` + `z` | Zoom the pane full screen, and back |
| `ctrl`+`alt`+arrows | Move between panes (*no prefix*) |
| `ctrl`+`alt`+`shift`+arrows | Resize by 5 (*no prefix*) |
| `alt`+`enter` | Split stacked (*no prefix*) |
| `alt`+`shift`+`enter` | Split side by side (*no prefix*) |
| `alt`+`escape` | Kill pane (*no prefix*) |

`ctrl`+`h`/`j`/`k`/`l` treats Neovim's splits and tmux's panes as one grid: walk off the edge of a
split and you land in the pane next door. tmux only hands the key to Neovim when the pane is
running it, so those four are taken from readline everywhere else — `prefix` + the same key sends
the literal one, which is where backward-delete, accept-line, kill-line and clear-screen went.

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

### Popups

| Keys | Does |
| --- | --- |
| `alt`+`g` | Open / close a popup on `~/notes/scratch.md` (*no prefix*) |
| `prefix` + `g` | lazygit on the current pane's directory |

One shared `scratch` session sits behind the notes popup, so closing it detaches instead of
quitting nvim: cursor, undo history and unsaved text survive. Autosave flushes the file when you
stop typing. The lazygit popup holds no state and closes when lazygit exits.

### Status bar

Left is the session name, which becomes an orange `PREFIX` once the prefix is armed and a purple
`COPY` in copy mode. The clock sits in the middle. Right is CPU, load, memory used of total, free
disk, network down and up per second, battery and the host.

| Reads | Means |
| --- | --- |
| `BAT 79%+` | Charging |
| `BAT 79%=` | Plugged in, not charging |
| `BAT 79%` | On battery — orange under 20%, red under 10% |
| `CPU --` | Only one sample so far; a rate needs two, so this clears on the next tick |

Values go orange then red as they get worse: CPU past 60% and 85%, load past 70% and 100% of the
core count, memory past 75% and 90%, disk under 20G and 10G free. Segments drop as the terminal
narrows — load first, then disk, the host and the network — so the clock is always the survivor.

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
