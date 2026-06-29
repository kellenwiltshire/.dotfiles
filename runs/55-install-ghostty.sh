#!/bin/bash

set -euo pipefail

echo "👻 Installing Ghostty..."

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

if command -v ghostty >/dev/null 2>&1; then
  echo "✅ ghostty already installed."
elif command -v brew >/dev/null 2>&1; then
  install_brew_cask ghostty
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm ghostty
else
  install_package ghostty
fi

echo "🖥️ Setting Ghostty as the default terminal..."

if [[ "$(detect_os)" == "linux" ]]; then
  mkdir -p "$HOME/.config"
  printf "com.mitchellh.ghostty.desktop\n" > "$HOME/.config/xdg-terminals.list"

  touch "$HOME/.zshrc.local"

  if ! grep -qx 'export TERMINAL="ghostty"' "$HOME/.zshrc.local"; then
    printf '\nexport TERMINAL="ghostty"\n' >> "$HOME/.zshrc.local"
  fi
else
  echo "ℹ️ On macOS, set Ghostty as default via Ghostty → Settings, or System Settings."
fi
