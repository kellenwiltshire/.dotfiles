#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "🔧 Installing tmux plugins..."

# Cloned and sourced from tmux.conf rather than installed through TPM. One plugin does not earn a
# plugin manager, and clone_or_update is already how every other third-party checkout here works.
# Runs after 90-stow-home because stow --no-folding makes ~/.config/tmux a real directory of
# symlinks, which is what lets plugins/ live inside it without stow ever touching them.
clone_or_update https://github.com/omerxx/tmux-sessionx "$HOME/.config/tmux/plugins/tmux-sessionx"

# tmux.conf sets @sessionx-fzf-builtin-tmux, which needs `fzf --tmux` from fzf 0.53. Anything
# older silently falls back to the fzf-tmux script, which ships separately from fzf and is on
# neither machine, so the picker would open on an empty popup.
if command -v fzf >/dev/null 2>&1; then
  fzf_version=$(fzf --version | cut -d' ' -f1)
  if [[ $(printf '%s\n0.53.0\n' "$fzf_version" | sort -V | head -1) != "0.53.0" ]]; then
    echo "⚠️  fzf $fzf_version predates 0.53 — sessionx's popup needs a newer fzf."
  fi
else
  echo "⚠️  fzf is missing — sessionx cannot run without it."
fi

# A server that was already up when this ran has no binding for the plugin yet.
if tmux has-session 2>/dev/null; then
  tmux source-file "$HOME/.config/tmux/tmux.conf" && echo "🔄 Reloaded the running tmux config."
fi

echo "✅ tmux plugins complete."
