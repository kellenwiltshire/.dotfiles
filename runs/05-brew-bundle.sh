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

# The Brewfile taps a private GHE repo over SSH. On a machine without those credentials git sits on
# an interactive host-key or password prompt forever, and because brew bundle swallows the prompt
# it reads as an indefinite hang with no output. Make git and ssh fail fast and say why instead.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"

private_tap="hootsuite/homebrew"
private_tap_url="hootsuite@hootsuite.ghe.com:hootsuite/homebrew.git"

# One failed tap aborts the whole bundle, taking every unrelated formula and cask down with it. On a
# machine with no internal access, drop the work tap and its formulae so the rest still installs.
if [[ ! -d "$(brew --repo "$private_tap" 2>/dev/null)" ]] &&
  ! git ls-remote --exit-code "$private_tap_url" HEAD >/dev/null 2>&1; then
  echo "⏭️  No access to $private_tap; skipping it and its formulae."
  echo "   Run 'hs-dotfiles-init' once you have internal credentials, then re-run this step."
  export HOMEBREW_BUNDLE_TAP_SKIP="$private_tap"
  export HOMEBREW_BUNDLE_BREW_SKIP="$(grep -o "^brew \"$private_tap/[^\"]*\"" "$repo_root/Brewfile" | cut -d'"' -f2 | tr '\n' ' ')"
fi

# Trust third-party cask taps so `brew bundle` can load their casks.
brew trust --tap nikitabobko/tap
brew trust --tap shaunsingh/sfmono-nerd-font-ligaturized

echo "🍺 Installing from Brewfile..."

# --no-upgrade: only install what's missing; don't upgrade existing tools on reruns.
# There is no --no-vscode here: unlike `dump`, the install subcommand rejects it outright. Keeping
# `vscode` lines out of the Brewfile is what stops brew from driving the hang-prone `code` CLI.
if brew bundle --no-upgrade --file="$repo_root/Brewfile"; then
  echo "✅ Brewfile complete."
else
  echo "⚠️  Some Brewfile entries failed to install. Common causes:"
  echo "   - the private 'hootsuite/homebrew' tap needs internal auth (run 'hs-dotfiles-init')"
  echo "   - a cask couldn't be adopted because the installed version differs"
  echo "   Re-run just this step with: ./setup.sh brew-bundle"
fi
