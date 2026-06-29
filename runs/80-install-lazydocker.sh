#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "🐳 Installing lazydocker..."

if command -v lazydocker >/dev/null 2>&1; then
  echo "✅ lazydocker already installed."
  lazydocker --version
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  install_brew_package lazydocker
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm lazydocker
else
  go install github.com/jesseduffield/lazydocker@latest
fi

export PATH="$HOME/go/bin:$PATH"

lazydocker --version
