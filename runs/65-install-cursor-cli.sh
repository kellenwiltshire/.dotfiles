#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

if [[ "$(detect_os)" != "macos" ]]; then
  echo "⏭️  Skipping Cursor CLI (not macOS)."
  exit 0
fi

echo "🤖 Installing Cursor CLI..."

cursor_agent="$HOME/.local/bin/cursor-agent"

if [[ -x "$cursor_agent" ]]; then
  echo "✅ cursor-agent already installed."
  "$cursor_agent" --version
  exit 0
fi

curl -fsS https://cursor.com/install | bash

"$cursor_agent" --version
