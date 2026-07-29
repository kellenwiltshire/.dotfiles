#!/bin/bash

set -euo pipefail

echo "📦 Installing nvm..."

mkdir -p "$HOME/.nvm"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "✅ nvm already installed."
else
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

source "$HOME/.nvm/nvm.sh"

current_default="$(nvm version default 2>/dev/null || true)"

if [[ -z "$current_default" || "$current_default" == "N/A" ]]; then
  echo "📦 Installing Node LTS and setting it as the default..."
  nvm install --lts
  nvm alias default 'lts/*'
else
  echo "✅ nvm default already set to $current_default; leaving it as-is."
fi

nvm use default >/dev/null
