#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

if [[ "$(detect_os)" != "macos" ]]; then
  echo "⏭️  Skipping macOS defaults (not macOS)."
  exit 0
fi

echo "⚙️  Applying macOS defaults..."

# Keyboard: fast key repeat
defaults write -g KeyRepeat -int 5
defaults write -g InitialKeyRepeat -int 30

# Appearance: dark mode
defaults write -g AppleInterfaceStyle -string "Dark"

# Trackpad: natural scrolling off, tap-to-click off
defaults write -g com.apple.swipescrolldirection -bool false
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false

# Dock: auto-hide, tile size
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 38

# Screenshots: save to ~/Pictures/Screenshots
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

killall Dock Finder SystemUIServer 2>/dev/null || true

echo "✅ macOS defaults applied (a logout/login may be needed for some to fully take effect)."
