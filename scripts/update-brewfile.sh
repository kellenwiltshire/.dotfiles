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
# --no-vscode: editors are LazyVim's job now. Dumping extensions also shells out to `code
# --list-extensions`, which blocks indefinitely whenever the VS Code CLI cannot reach the app.
brew bundle dump --force --describe --no-vscode --file="$brewfile"

# Homebrew 4 serves these two through its JSON API and refuses to tap them, so dumping them from a
# machine that still has them tapped locally produces a Brewfile that dies on any fresh install.
if grep -Eq '^tap "homebrew/(core|cask)"$' "$brewfile"; then
  grep -Ev '^tap "homebrew/(core|cask)"$' "$brewfile" >"$brewfile.tmp"
  mv "$brewfile.tmp" "$brewfile"
  echo "🧹 Dropped redundant homebrew/core and homebrew/cask tap lines."
fi

echo "✅ Brewfile updated. Review with: git -C \"$repo_root\" diff Brewfile"
