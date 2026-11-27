#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

nvm_release="v0.41.0"
export NVM_DIR="$HOME/.nvm"

echo "📦 Installing nvm..."

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  echo "✅ nvm already installed."
else
  # PROFILE=/dev/null: shared/.zshrc loads nvm itself, so the installer must not append to it.
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_release/install.sh" | PROFILE=/dev/null bash
fi

source "$NVM_DIR/nvm.sh" --no-use

if default_version="$(nvm version default)" && [[ "$default_version" != "N/A" ]]; then
  echo "✅ nvm default already set to $default_version; leaving it as-is."
else
  echo "📦 Installing Node LTS and setting it as the default..."
  nvm install --lts
  nvm alias default "$(nvm version 'lts/*')"
fi

nvm use default

# Node 25+ no longer bundles Corepack. On macOS the Brewfile's `npm "corepack"` provides it.
if command -v corepack >/dev/null 2>&1; then
  echo "✅ Corepack already installed."
else
  echo "🧶 Installing Corepack (per-repo yarn/pnpm versions)..."
  npm install -g corepack
  corepack enable --install-directory "$HOME/.local/bin"
fi
