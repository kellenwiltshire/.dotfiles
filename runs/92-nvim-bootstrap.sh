#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "💤 Bootstrapping Neovim plugins..."

if ! command -v nvim >/dev/null 2>&1; then
  echo "⏭️  Skipping (nvim not installed)."
  exit 0
fi

config_dir="$HOME/.config/nvim"
data_dir="$HOME/.local/share/nvim"
marker="$data_dir/.dotfiles-bootstrapped"

if [[ ! -L "$config_dir/init.lua" ]]; then
  echo "❌ $config_dir/init.lua is not a symlink into this repo."
  echo "   Run runs/90-stow-home.sh first."
  exit 1
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
  echo "❌ tree-sitter CLI not found — nvim-treesitter's main branch needs it to build parsers."
  echo "   Run runs/00-install-packages.sh first."
  exit 1
fi

# Omarchy's omarchy-nvim package ships pre-warmed plugins here that don't match
# our lockfile, which is the documented cause of its treesitter breakage. Move
# them aside once and let lazy.nvim rebuild from lazy-lock.json.
if [[ -d "$data_dir" && ! -e "$marker" ]]; then
  backup="$data_dir.backup.$(date +%Y%m%d%H%M%S)"
  echo "📦 Backing up pre-existing $data_dir -> $backup"
  mv "$data_dir" "$backup"
fi

if [[ -e "$config_dir/lazy-lock.json" ]]; then
  nvim --headless "+Lazy! restore" +qa
else
  echo "ℹ️  No lazy-lock.json yet — installing latest and writing one."
  nvim --headless "+Lazy! sync" +qa
fi

# Written before the tools step so a failure there can't re-trigger the backup above and
# discard the plugins that were just restored.
mkdir -p "$data_dir"
touch "$marker"

echo "🔧 Installing LSP servers, linters, formatters and treesitter parsers..."
NVIM_BOOTSTRAP_SCRIPT="$script_dir/../scripts/nvim-install-tools.lua" \
  nvim --headless -c "lua dofile(vim.env.NVIM_BOOTSTRAP_SCRIPT)" +qa

echo "✅ Neovim ready."
