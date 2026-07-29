#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
brewfile="$repo_root/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not found."
  exit 1
fi

echo "🍺 Refreshing $brewfile from current Homebrew state..."
brew bundle dump --force --describe --file="$brewfile"

echo "✅ Brewfile updated. Review with: git -C \"$repo_root\" diff Brewfile"
