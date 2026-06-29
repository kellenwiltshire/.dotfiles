#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "✨ Installing Oh My Zsh..."

if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  echo "🔄 Updating Oh My Zsh..."
  git -C "$HOME/.oh-my-zsh" pull --ff-only
  exit 0
fi

RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
