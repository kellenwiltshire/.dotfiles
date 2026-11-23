#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "📦 Installing fnm..."

if command -v fnm >/dev/null 2>&1; then
  echo "✅ fnm already installed."
elif [[ "$(detect_distro)" == "debian" ]]; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/bin" --skip-shell
else
  install_package fnm
fi

eval "$(fnm env --shell bash)"

if default_version="$(fnm default 2>/dev/null)"; then
  echo "✅ fnm default already set to $default_version; leaving it as-is."
else
  echo "📦 Installing Node LTS and setting it as the default..."
  fnm install --lts
  fnm default lts-latest
fi

fnm use default

# Node 25+ no longer bundles Corepack. On macOS the Brewfile's `npm "corepack"` provides it.
if command -v corepack >/dev/null 2>&1; then
  echo "✅ Corepack already installed."
else
  echo "🧶 Installing Corepack (per-repo yarn/pnpm versions)..."
  npm install -g corepack
  corepack enable --install-directory "$HOME/.local/bin"
fi
