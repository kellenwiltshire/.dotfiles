#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

if [[ "$(detect_os)" != "macos" ]]; then
  echo "⏭️  Skipping Homebrew bootstrap (not macOS)."
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  echo "✅ Homebrew already installed."
else
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

ensure_brew_on_path

brew --version
