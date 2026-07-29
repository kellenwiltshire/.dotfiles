#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

zsh_path="$(command -v zsh || true)"

if [[ -z "$zsh_path" ]]; then
  echo "⚠️  zsh not found; skipping default shell change."
  exit 0
fi

current_shell=""
if command -v getent >/dev/null 2>&1; then
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
elif command -v dscl >/dev/null 2>&1; then
  current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
fi

if [[ "$current_shell" == "$zsh_path" ]]; then
  echo "✅ zsh is already the default shell."
  exit 0
fi

echo "🐚 Setting zsh ($zsh_path) as the default shell..."

if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
  echo "   Adding $zsh_path to /etc/shells (needs sudo)..."
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi

if chsh -s "$zsh_path"; then
  echo "✅ Default shell set to zsh (log out and back in to take effect)."
else
  echo "⚠️  Could not change the default shell automatically. Run manually: chsh -s $zsh_path"
fi
