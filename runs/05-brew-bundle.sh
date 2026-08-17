#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
source "$script_dir/../scripts/lib.sh"

if [[ "$(detect_os)" != "macos" ]]; then
  echo "⏭️  Skipping Brewfile (not macOS)."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not found. Run runs/00-install-homebrew.sh first."
  exit 1
fi

# Adopt apps already present in /Applications instead of failing on them.
export HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:-} --adopt"

# Trust third-party cask taps so `brew bundle` can load their casks.
brew trust --tap nikitabobko/tap
brew trust --tap shaunsingh/sfmono-nerd-font-ligaturized

echo "🍺 Installing from Brewfile..."

# --no-upgrade: only install what's missing; don't upgrade existing tools on reruns.
# --no-vscode: refuse to drive the VS Code CLI even if a stale Brewfile still lists extensions,
# since `code` hangs rather than failing when it cannot talk to the app.
if brew bundle --no-upgrade --no-vscode --file="$repo_root/Brewfile"; then
  echo "✅ Brewfile complete."
else
  echo "⚠️  Some Brewfile entries failed to install. Common causes:"
  echo "   - the private 'hootsuite/homebrew' tap needs internal auth (run 'hs-dotfiles-init')"
  echo "   - a cask couldn't be adopted because the installed version differs"
  echo "   Re-run just this step with: ./setup.sh brew-bundle"
fi
