[[ "$ZSH_SESSION" == fe-dev ]] && FE_DEV=1

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Must precede compinit (run by oh-my-zsh below) for Docker CLI completions to load.
fpath=($HOME/.docker/completions $fpath)

if [[ -z "${FE_DEV:-}" ]]; then

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

# Spaceship prompt
SPACESHIP_PROMPT_ASYNC=true #fixes double prompt in warp
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false

 SPACESHIP_PROMPT_ORDER=(
    time           # Time stamps section
    user           # Username section
    dir            # Current directory section
    host           # Hostname section
    git            # Git section (git_branch + git_status)
    hg             # Mercurial section (hg_branch  + hg_status)
    package        # Package version
    node           # Node.js section
    bun            # Bun section
    deno           # Deno section
    ruby           # Ruby section
    python         # Python section
    elm            # Elm section
    elixir         # Elixir section
    xcode          # Xcode section
    swift          # Swift section
    golang         # Go section
    perl           # Perl section
    php            # PHP section
    rust           # Rust section
    haskell        # Haskell Stack section
    scala          # Scala section
    kotlin         # Kotlin section
    java           # Java section
    lua            # Lua section
    dart           # Dart section
    julia          # Julia section
    crystal        # Crystal section
    docker         # Docker section
    docker_compose # Docker section
    aws            # Amazon Web Services section
    gcloud         # Google Cloud Platform section
    azure          # Azure section
    venv           # virtualenv section
    conda          # conda virtualenv section
    dotnet         # .NET section
    ocaml          # OCaml section
    vlang          # V section
    zig            # Zig section
    purescript     # PureScript section
    erlang         # Erlang section
    kubectl        # Kubectl context section
    ansible        # Ansible section
    terraform      # Terraform workspace section
    pulumi         # Pulumi stack section
    ibmcloud       # IBM Cloud section
    nix_shell      # Nix shell
    gnu_screen     # GNU Screen section
    exec_time      # Execution time
    async          # Async jobs indicator
    line_sep       # Line break
    battery        # Battery level and status
    jobs           # Background jobs indicator
    exit_code      # Exit code section
    sudo           # Sudo indicator
    # char           # Prompt character
  )

# Update handling
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

plugins=(vscode zsh-autosuggestions git you-should-use zsh-bat zsh-syntax-highlighting fzf-tab)

source $ZSH/oh-my-zsh.sh

else
  autoload -Uz compinit
  compinit
fi

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Go (binaries installed via `go install`)
export PATH="$HOME/go/bin:$PATH"

# EDITOR_CMD is the bare command; EDITOR adds --wait for GUI editors so git blocks
# until the buffer is closed.
for _candidate in cursor code nvim vim vi; do
  if command -v "$_candidate" >/dev/null; then
    export EDITOR_CMD="$_candidate"
    break
  fi
done
unset _candidate

case "$EDITOR_CMD" in
  cursor|code) export EDITOR="$EDITOR_CMD --wait" ;;
  "")          ;;
  *)           export EDITOR="$EDITOR_CMD" ;;
esac
export VISUAL="$EDITOR"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
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

#Alias
alias garbageday="git branch | grep -vE '^\*?\s*(main|master|develop)\$' | xargs git branch -D"
alias refresh="source ~/.zshrc"
alias dots="\$EDITOR_CMD ~/.dotfiles"
alias brewdump="~/.dotfiles/scripts/update-brewfile.sh"
alias pacdump="~/.dotfiles/scripts/update-pacfile.sh"
alias gco="git checkout"
alias c="code ."
alias main="gco main && gl"
alias develop="gco develop && gl"

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
  brew() {
    command brew "$@"
    local ret=$?
    if [[ $ret -eq 0 ]]; then
      case "$1" in
        install|uninstall|remove|rm|tap|untap)
          "$HOME/.dotfiles/scripts/update-brewfile.sh"
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
command -v fzf >/dev/null && eval "$(fzf --zsh 2>/dev/null)"

if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lah --group-directories-first --git'
  alias lt='eza --tree --level=2'
fi

autoload -U add-zsh-hook
load-nvmrc() {
  (( _load_nvmrc_running )) && return
  _load_nvmrc_running=1
  local nvmrc_path nvmrc_version nvmrc_node_version default_version node_path nvm_node_path
  nvmrc_path="$(nvm_find_nvmrc)"
  if [[ -n "$nvmrc_path" ]]; then
    nvmrc_version="$(tr -d '[:space:]' < "$nvmrc_path")"
    if [[ -n "$nvmrc_version" ]]; then
      nvmrc_node_version="$(nvm version "$nvmrc_version")"
      if [[ "$nvmrc_node_version" == "N/A" ]]; then
        nvm install "$nvmrc_version"
        command -v corepack >/dev/null && corepack enable
        rehash
      else
        node_path="$(command -v node 2>/dev/null)"
        nvm_node_path="$(nvm which current 2>/dev/null)"
        if [[ "$(nvm version)" != "$nvmrc_node_version" || "$node_path" != "$nvm_node_path" ]]; then
          nvm use "$nvmrc_version"
          command -v corepack >/dev/null && corepack enable
          rehash
        fi
      fi
    fi
  elif [[ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ]]; then
    default_version="$(nvm version default 2>/dev/null)"
    if [[ -n "$default_version" && "$default_version" != "N/A" && "$(nvm version)" != "$default_version" ]]; then
      echo "Reverting to nvm default version"
      nvm use default
      rehash
    fi
  fi
  _load_nvmrc_running=0
}
if (( $+functions[nvm_find_nvmrc] )); then
  add-zsh-hook -d chpwd load-nvmrc 2>/dev/null
  add-zsh-hook -d precmd nvmrc-sync-node 2>/dev/null
  add-zsh-hook chpwd load-nvmrc
  load-nvmrc
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
