[[ "$ZSH_SESSION" == fe-dev ]] && FE_DEV=1

export PATH="$HOME/.local/bin:$PATH"

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Must precede compinit (run by oh-my-zsh below) for Docker CLI completions to load.
fpath=($HOME/.docker/completions $fpath)

if [[ -z "${FE_DEV:-}" ]]; then

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

# Update handling
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

plugins=(zsh-autosuggestions git you-should-use zsh-bat zsh-syntax-highlighting fzf-tab)

source $ZSH/oh-my-zsh.sh

command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.omp.toml)"

else
  autoload -Uz compinit
  compinit
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Go (binaries installed via `go install`)
export PATH="$HOME/go/bin:$PATH"

# EDITOR_CMD is the bare command; EDITOR adds --wait for GUI editors so git blocks
# until the buffer is closed.
for _candidate in nvim cursor vim vi; do
  if command -v "$_candidate" >/dev/null; then
    export EDITOR_CMD="$_candidate"
    break
  fi
done
unset _candidate

case "$EDITOR_CMD" in
  cursor) export EDITOR="$EDITOR_CMD --wait" ;;
  "")     ;;
  *)      export EDITOR="$EDITOR_CMD" ;;
esac
export VISUAL="$EDITOR"

# History
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt extended_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
if command -v eza >/dev/null; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath'
else
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

# Argument completion for a few thousand commands, replacing zsh's own for each. Bridges hand
# the rest back to whichever shell already has a completer, so nothing regresses to bare filenames.
#
# fzf-tab reads group headers out of this format string and shows nothing without it, so it is
# load-bearing rather than styling, and it restyles every completion, not only carapace's.
# Both branches above have run compinit by this point, which is all carapace's compdefs need.
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
command -v carapace >/dev/null && source <(carapace _carapace)

#Alias
garbageday() {
  git fetch || return
  git for-each-ref --format='%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)' refs/heads |
    xargs -r git branch -D
}
alias refresh="source ~/.zshrc"
alias dots="\$EDITOR_CMD ~/.dotfiles"
alias brewdump="~/.dotfiles/scripts/update-brewfile.sh"
alias pacdump="~/.dotfiles/scripts/update-pacfile.sh"
alias gco="git checkout"
alias v="nvim"
alias main="gco main && git pull"
alias develop="gco develop && git pull"
alias lz="lazygit"
lzw() {
  local dir="${1:-$PWD}"
  if [[ "$(uname)" == Darwin ]]; then
    open -na Ghostty.app --args --working-directory="$dir" -e lazygit
  elif command -v ghostty >/dev/null; then
    ghostty --working-directory="$dir" -e lazygit &!
  else
    (cd "$dir" && lazygit)
  fi
}

# Clone into ~/code by default; pass an explicit target (e.g. `.`) to override.
git() {
  if [[ "$1" == clone && $# -eq 2 && "$2" != -* ]]; then
    mkdir -p "$HOME/code"
    command git clone "$2" "$HOME/code/$(basename "${2%.git}")"
  else
    command git "$@"
  fi
}

if whence -p brew >/dev/null; then
  # Keep the Brewfile in sync after brew changes (leaves it uncommitted to review).
  # brew bundle resolves `npm` from PATH, and the Brewfile's npm entries belong to Homebrew's
  # Node rather than fnm's.
  brew() {
    local brew_path="$PATH"
    [[ "$1" == bundle ]] && brew_path="$HOMEBREW_PREFIX/bin:$PATH"
    PATH="$brew_path" command brew "$@"
    local ret=$?
    if [[ $ret -eq 0 ]]; then
      case "$1" in
        install|uninstall|remove|rm|untap)
          "$HOME/.dotfiles/scripts/update-brewfile.sh"
          ;;
        tap)
          # Bare `brew tap` only lists taps, so it must not pay for a full dump.
          if [[ $# -ge 2 ]]; then
            "$HOME/.dotfiles/scripts/update-brewfile.sh"
          fi
          ;;
      esac
    fi
    return $ret
  }

  brewup() {
    brew update && brew upgrade && brew cleanup
    mkdir -p "$HOME/.cache"
    touch "$HOME/.cache/brewup-stamp"
  }
fi

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"

if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# The session picker, one key instead of prefix + f. Set after fzf's own bindings so it wins.
# This takes C-f from forward-char; use the right arrow to move a character.
command -v tmux-sessionx >/dev/null && bindkey -s '^f' 'tmux-sessionx\n'

if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lah --group-directories-first --git'
  alias lt='eza --tree --level=2'
fi

autoload -U add-zsh-hook
# fnm's own --use-on-cd hook prompts instead of installing a missing .nvmrc version.
if command -v fnm >/dev/null; then
  eval "$(fnm env --version-file-strategy=recursive --shell zsh)"
  use-project-node() {
    fnm use --install-if-missing --silent-if-unchanged
  }
  add-zsh-hook chpwd use-project-node
  use-project-node
fi

# Nudge to update Homebrew at most once a week (time-based; no network on startup).
if whence -p brew >/dev/null; then
  _brewup_stamp="$HOME/.cache/brewup-stamp"
  if [[ ! -e "$_brewup_stamp" || -n "$(find "$_brewup_stamp" -mtime +7 2>/dev/null)" ]]; then
    print -P "%F{yellow}🍺 Homebrew may be out of date — run 'brewup' to update.%f"
    mkdir -p "$HOME/.cache"
    touch "$_brewup_stamp"
  fi
  unset _brewup_stamp
fi

[[ -r /opt/homebrew/bin/hs-opskit-rc-zsh ]] && . /opt/homebrew/bin/hs-opskit-rc-zsh
